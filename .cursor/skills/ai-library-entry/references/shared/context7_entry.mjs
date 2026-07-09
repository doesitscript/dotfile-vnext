#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {
  callMcpTool,
  extractToolText,
  inferLibraryIdFromResolveOutput,
} from "./mcp_runtime.mjs";

export function provenanceHeader({ sourceUrl, tool, mode, collectedAt }) {
  return [
    "---",
    `source_url: ${sourceUrl}`,
    `collected_at: ${collectedAt || new Date().toISOString()}`,
    `collection_tool: ${tool}`,
    `capture_mode: ${mode}`,
    "---",
    "",
  ].join("\n");
}

export function readYamlScalar(filePath, keyPath) {
  const text = fs.readFileSync(filePath, "utf8");
  const leafKey = keyPath.split(".").at(-1);
  const match = text.match(new RegExp(`^\\s*${leafKey}:\\s*"?([^"\\n#]+)"?\\s*$`, "m"));
  return match?.[1]?.trim() || null;
}

export function pickVersionedLibraryId(resolveText, contractVersion, suffix = "stable") {
  const majorMinorPatch = String(contractVersion).match(/^(\d+)\.(\d+)\.(\d+)/);
  if (!majorMinorPatch) {
    return null;
  }
  const [, major, minor] = majorMinorPatch;

  const fullPathPattern = new RegExp(
    `/berriai/litellm/v${major}\\.${minor}\\.\\d+-${suffix}`,
    "i",
  );
  const direct = resolveText.match(fullPathPattern);
  if (direct) {
    return direct[0];
  }

  const anySdkPath = resolveText.match(/\/berriai\/litellm\/v[\d.]+-\w+/gi);
  if (anySdkPath?.length) {
    const sameMinor = anySdkPath.filter((entry) =>
      new RegExp(`/berriai/litellm/v${major}\\.${minor}\\.`, "i").test(entry),
    );
    if (sameMinor.length) {
      return sameMinor.sort().at(-1);
    }
  }

  const versionsLine = resolveText.match(/Versions:\s*([^\n]+)/i);
  if (!versionsLine) {
    return null;
  }

  const versionTokens = versionsLine[1].split(/,\s*/).map((token) => token.trim());
  const minorStable = versionTokens.filter(
    (token) =>
      token.startsWith(`v${major}.${minor}.`) && token.toLowerCase().endsWith(`-${suffix}`),
  );
  if (minorStable.length) {
    return `/berriai/litellm/${minorStable.sort().at(-1)}`;
  }

  const anyStable = versionTokens.filter((token) => token.toLowerCase().endsWith(`-${suffix}`));
  if (anyStable.length) {
    return `/berriai/litellm/${anyStable.sort().at(-1)}`;
  }

  return null;
}

export async function resolveContext7Libraries(resolveConfig) {
  const resolved = [];
  for (const row of resolveConfig) {
    const result = await callMcpTool("context7", "resolve-library-id", {
      libraryName: row.library_name,
      query: row.resolve_query,
    });
    const text = extractToolText(result).trim();
    let selectedId = inferLibraryIdFromResolveOutput(text);
    let versionPin = null;

    if (row.version_pin?.source_file && row.version_pin?.yaml_path) {
      const contractVersion = readYamlScalar(row.version_pin.source_file, row.version_pin.yaml_path);
      if (contractVersion) {
        versionPin = pickVersionedLibraryId(
          text,
          contractVersion,
          row.version_pin.version_library_suffix || "stable",
        );
        if (versionPin) {
          selectedId = versionPin;
        }
      }
    }

    const libraryIds = {
      website: row.fallback_library_ids?.find((id) => id.includes("websites")) || selectedId,
      sdk:
        versionPin ||
        row.fallback_library_ids?.find((id) => id.includes("berriai/litellm")) ||
        selectedId,
      selected: versionPin || selectedId,
    };

    resolved.push({
      library_name: row.library_name,
      resolve_query: row.resolve_query,
      resolve_text_excerpt: text.slice(0, 1200),
      selected_library_id: selectedId,
      version_pinned_library_id: versionPin,
      library_ids: libraryIds,
      fallback_library_ids: row.fallback_library_ids || [],
    });
  }
  return resolved;
}

export async function queryContext7Shard({ libraryId, query }) {
  const result = await callMcpTool("context7", "query-docs", { libraryId, query });
  return extractToolText(result).trim();
}

function extractCrossCheckTerms(text) {
  const terms = new Set();
  const body = String(text || "");
  for (const match of body.matchAll(/`([^`]{2,80})`/g)) {
    const term = match[1].toLowerCase().trim();
    if (term) {
      terms.add(term);
    }
  }
  for (const match of body.matchAll(/^#+\s+(.+)$/gm)) {
    const term = match[1].toLowerCase().trim();
    if (term) {
      terms.add(term);
    }
  }
  for (const match of body.matchAll(
    /\b(config\.yaml|litellm_params|model_list|master_key|virtual[_ ]?key|openapi|swagger|\/v1\/[a-z0-9_/-]+|bearer|authorization)\b/gi,
  )) {
    const term = match[1].toLowerCase().trim();
    if (term) {
      terms.add(term);
    }
  }
  return terms;
}

export function compareFirecrawlAndContext7(firecrawlText, context7Text) {
  const firecrawlTerms = extractCrossCheckTerms(firecrawlText);
  const context7Terms = extractCrossCheckTerms(context7Text);
  const overlap = [...firecrawlTerms].filter((term) => context7Terms.has(term));
  const context7Only = [...context7Terms].filter((term) => !firecrawlTerms.has(term));
  const firecrawlOnly = [...firecrawlTerms].filter((term) => !context7Terms.has(term));
  const overlapRatio = firecrawlTerms.size ? overlap.length / firecrawlTerms.size : 0;
  const gapNotes = [];

  if (!firecrawlText) {
    gapNotes.push("missing_firecrawl_capture");
  }
  if (!context7Text || context7Text.length < 120) {
    gapNotes.push("thin_context7_response");
  }
  if (firecrawlText && overlapRatio < 0.12) {
    gapNotes.push("low_term_overlap");
  }
  if (context7Only.length >= 5) {
    gapNotes.push("context7_has_terms_missing_from_firecrawl");
  }
  if (firecrawlText && context7Text.length > firecrawlText.length * 1.8) {
    gapNotes.push("firecrawl_capture_thinner_than_context7");
  }
  if (firecrawlText && !firecrawlText.toLowerCase().includes("source_url:")) {
    gapNotes.push("missing_firecrawl_provenance");
  }

  return {
    overlap_ratio: Number(overlapRatio.toFixed(3)),
    overlap_terms: overlap.slice(0, 30),
    context7_only_terms: context7Only.slice(0, 25),
    firecrawl_only_terms: firecrawlOnly.slice(0, 25),
    gap_notes: gapNotes,
    status: gapNotes.length ? "gaps_detected" : "ok",
  };
}

export async function crossCheckFirecrawlPages({
  pages,
  libraryId,
  outputRoot,
}) {
  const results = [];
  for (const page of pages) {
    const query =
      page.validation_query ||
      page.cross_check_query ||
      `LiteLLM implementation syntax and configuration covered by documentation page ${page.url}. Focus on config keys, API routes, env vars, CLI commands, and OpenAPI/Swagger surfaces relevant to ${page.id}.`;
    const context7Text = await queryContext7Shard({ libraryId, query });
    const pagePath = path.join(outputRoot, `${page.id}.md`);
    const firecrawlText = fs.existsSync(pagePath) ? fs.readFileSync(pagePath, "utf8") : "";
    const comparison = compareFirecrawlAndContext7(firecrawlText, context7Text);
    results.push({
      page_id: page.id,
      url: page.url,
      library_id: libraryId,
      query,
      firecrawl_chars: firecrawlText.length,
      context7_chars: context7Text.length,
      ...comparison,
      context7_excerpt: context7Text.slice(0, 400),
      validated_at: new Date().toISOString(),
    });
  }
  return results;
}

export async function validatePagesWithContext7(args) {
  return crossCheckFirecrawlPages(args);
}

export async function writeTopicShards({
  shards,
  libraryIds,
  outputDir,
  collectedAt,
}) {
  const written = [];
  for (const shard of shards) {
    const targets = (shard.library_ids || ["website"]).map((key) => libraryIds[key] || libraryIds.selected);
    const uniqueTargets = [...new Set(targets.filter(Boolean))];
    const sections = [
      provenanceHeader({
        sourceUrl: `context7://query-docs/${shard.id}`,
        tool: "context7",
        mode: "sdk_context_note",
        collectedAt,
      }).trimEnd(),
      "",
      `# ${shard.title || shard.id}`,
      "",
      `Topic shard: \`${shard.id}\``,
      "",
    ];

    for (const libraryId of uniqueTargets) {
      const text = await queryContext7Shard({ libraryId, query: shard.query });
      sections.push(`## Library \`${libraryId}\``);
      sections.push("");
      sections.push(`### Query`);
      sections.push(shard.query);
      sections.push("");
      sections.push(text);
      sections.push("");
    }

    const outputPath = path.isAbsolute(shard.path)
      ? shard.path
      : path.join(outputDir, shard.path);
    fs.mkdirSync(path.dirname(outputPath), { recursive: true });
    fs.writeFileSync(
      outputPath,
      sections.join("\n").endsWith("\n") ? sections.join("\n") : `${sections.join("\n")}\n`,
    );
    written.push({ id: shard.id, path: outputPath, query: shard.query });
  }
  return written;
}

export async function buildOpenApiSwaggerOverview({
  libraryId,
  productName,
  specUrl,
  outputPath,
  collectedAt,
}) {
  const query = `${productName} proxy OpenAPI Swagger specification: authentication model, admin endpoints, OpenAI-compatible routes, key management, and how to explore the Swagger UI. Reference spec URL ${specUrl} when helpful.`;
  const text = await queryContext7Shard({ libraryId, query });
  const content = [
    provenanceHeader({
      sourceUrl: `context7://query-docs/openapi-swagger-overview`,
      tool: "context7",
      mode: "sdk_context_note",
      collectedAt,
    }).trimEnd(),
    "",
    `# ${productName} OpenAPI / Swagger (Context7)`,
    "",
    "Context7 is the **primary** interpretive layer for OpenAPI/Swagger in this pack.",
    `Spec mirror (optional offline JSON): ${specUrl}`,
    "",
    text,
    "",
  ].join("\n");
  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  fs.writeFileSync(outputPath, content.endsWith("\n") ? content : `${content}\n`);
}

export async function buildOpenApiUsageNotes({
  libraryId,
  corePaths,
  openapiIndex,
  outputPath,
  collectedAt,
}) {
  const operations = (openapiIndex?.operations || []).filter((row) =>
    corePaths.some((needle) => row.path === needle || row.path.endsWith(needle)),
  );
  const sections = [
    provenanceHeader({
      sourceUrl: "context7://query-docs/openapi-usage",
      tool: "context7",
      mode: "sdk_context_note",
      collectedAt,
    }).trimEnd(),
    "",
    "# OpenAPI / Swagger Usage Notes (Context7)",
    "",
    "Per-endpoint usage notes from Context7. Pair with `openapi-swagger-overview.md` and optional `openapi/openapi.json` mirror.",
    "",
  ];

  for (const operation of operations) {
    const query = `LiteLLM proxy server: how to call ${operation.method} ${operation.path}. Include authentication headers, request body shape, and example curl. Operation: ${operation.summary || operation.operationId || "no summary"}.`;
    const text = await queryContext7Shard({ libraryId, query });
    sections.push(`## \`${operation.method} ${operation.path}\``);
    sections.push("");
    sections.push(text);
    sections.push("");
  }

  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  fs.writeFileSync(
    outputPath,
    sections.join("\n").endsWith("\n") ? sections.join("\n") : `${sections.join("\n")}\n`,
  );
}

export function buildIndexesPackReadme({
  entryId,
  indexRoot,
  crosswalkPath,
  crossCheckPath,
  backlogPath,
  collectedAt,
}) {
  const artifactLines = [
    `- [doc-api-inventory-crosswalk.json](./${path.basename(crosswalkPath)}) — doc page ↔ OpenAPI ↔ inventory`,
    `- [firecrawl-context7-crosscheck.json](./${path.basename(crossCheckPath)}) — per-page capture vs Context7 gaps`,
  ];
  if (backlogPath) {
    artifactLines.push(
      `- [capture-backlog.yml](./${path.basename(backlogPath)}) — pages needing thicker Firecrawl capture`,
    );
  }
  const content = [
    `# ${entryId} — library indexes`,
    "",
    `Generated: ${collectedAt}`,
    "",
    "Indexes pack for crosswalks and Firecrawl↔Context7 reconciliation.",
    "",
    "## Artifacts",
    "",
    ...artifactLines,
    "",
    "## Update rule",
    "",
    "When adding vendor doc pages, OpenAPI paths, or inventory surfaces, update the crosswalk, cross-check, and capture backlog in the same build slice.",
    "",
  ].join("\n");
  fs.mkdirSync(indexRoot, { recursive: true });
  const readmePath = path.join(indexRoot, "README.md");
  fs.writeFileSync(readmePath, content.endsWith("\n") ? content : `${content}\n`);
  return readmePath;
}

export function summarizeCrossCheck(pages) {
  const gaps = pages.filter((page) => page.status === "gaps_detected");
  return {
    page_count: pages.length,
    ok_count: pages.length - gaps.length,
    gaps_detected_count: gaps.length,
    pages_with_context7_only_terms: pages.filter((page) =>
      (page.gap_notes || []).includes("context7_has_terms_missing_from_firecrawl"),
    ).length,
    pages_with_low_overlap: pages.filter((page) =>
      (page.gap_notes || []).includes("low_term_overlap"),
    ).length,
  };
}

function yamlString(value) {
  return JSON.stringify(String(value));
}

function backlogPriority(page) {
  const notes = page.gap_notes || [];
  if (
    notes.includes("missing_firecrawl_capture") ||
    notes.includes("firecrawl_capture_thinner_than_context7")
  ) {
    return "high";
  }
  return "medium";
}

function backlogCaptureMode(page) {
  const notes = page.gap_notes || [];
  if (
    notes.includes("missing_firecrawl_capture") ||
    notes.includes("firecrawl_capture_thinner_than_context7") ||
    (page.context7_only_terms || []).length >= 10
  ) {
    return "markdown";
  }
  return "markdown";
}

function backlogActions(page) {
  const notes = page.gap_notes || [];
  const actions = [];
  if (notes.includes("missing_firecrawl_capture")) {
    actions.push("Create the missing Firecrawl capture for this page.");
  }
  if (notes.includes("low_term_overlap")) {
    actions.push("Re-scrape with Firecrawl markdown instead of summary-only output.");
  }
  if (notes.includes("context7_has_terms_missing_from_firecrawl")) {
    actions.push("Review Context7-only terms and thicken the vendor capture around those config/API concepts.");
  }
  if (notes.includes("firecrawl_capture_thinner_than_context7")) {
    actions.push("Prefer a thicker Firecrawl markdown capture and consider a full capture if the page stays thin.");
  }
  if (notes.includes("missing_firecrawl_provenance")) {
    actions.push("Normalize the vendor markdown with the required provenance header.");
  }
  if (actions.length === 0) {
    actions.push("Inspect the cross-check entry and refresh the Firecrawl capture if needed.");
  }
  return actions;
}

export function buildCaptureBacklog({
  entryId,
  pages,
  collectedAt,
  crossCheckArtifact = "firecrawl-context7-crosscheck.json",
}) {
  const backlogPages = pages.filter((page) => page.status === "gaps_detected");
  const lines = [
    `generated_at: ${yamlString(collectedAt)}`,
    `entry_id: ${yamlString(entryId)}`,
    `source_artifact: ${yamlString(crossCheckArtifact)}`,
  ];

  if (backlogPages.length === 0) {
    lines.push("pages: []");
    return `${lines.join("\n")}\n`;
  }

  lines.push("pages:");
  for (const page of backlogPages) {
    lines.push(`  - page_id: ${yamlString(page.page_id)}`);
    lines.push(`    url: ${yamlString(page.url)}`);
    lines.push(`    priority: ${yamlString(backlogPriority(page))}`);
    lines.push(`    recommended_firecrawl_format: ${yamlString(backlogCaptureMode(page))}`);
    lines.push("    gap_notes:");
    for (const note of page.gap_notes || []) {
      lines.push(`      - ${yamlString(note)}`);
    }
    lines.push("    follow_up_actions:");
    for (const action of backlogActions(page)) {
      lines.push(`      - ${yamlString(action)}`);
    }
    const context7Only = (page.context7_only_terms || []).slice(0, 10);
    if (context7Only.length === 0) {
      lines.push("    context7_only_terms: []");
    } else {
      lines.push("    context7_only_terms:");
      for (const term of context7Only) {
        lines.push(`      - ${yamlString(term)}`);
      }
    }
  }

  return `${lines.join("\n")}\n`;
}

export function buildDocApiInventoryCrosswalk({
  pages,
  openapiIndex,
  inventory,
  extraMappings = [],
}) {
  const corePaths = [
    "/v1/chat/completions",
    "/v1/models",
    "/models",
    "/model/info",
    "/key/generate",
    "/ui",
  ];
  const openapiCore = (openapiIndex?.operations || []).filter((row) =>
    corePaths.some((needle) => row.path === needle || row.path.endsWith(needle)),
  );

  const defaultMappings = [
    {
      doc_id: "proxy-quick-start",
      openapi_paths: ["/v1/chat/completions", "/v1/models"],
      inventory_keys: ["k3s_litellm_gateway_image_repository", "k3s_litellm_gateway_image_tag"],
    },
    {
      doc_id: "proxy-ui",
      openapi_paths: ["/ui"],
      inventory_keys: ["k3s_litellm_gateway_master_key", "k3s_litellm_gateway_database_url"],
    },
    {
      doc_id: "proxy-authentication",
      openapi_paths: ["/key/generate"],
      inventory_keys: ["k3s_litellm_gateway_master_key"],
    },
    {
      doc_id: "routing-load-balancing",
      openapi_paths: ["/model/info"],
      inventory_keys: ["k3s_litellm_gateway_model_list"],
    },
    {
      doc_id: "homelab-operator-reference",
      openapi_paths: ["/v1/chat/completions", "/v1/models", "/model/info"],
      inventory_keys: ["k3s_litellm_gateway_lan_hostname", "k3s_litellm_gateway_lan_node_port"],
    },
  ];

  return {
    generated_at: new Date().toISOString(),
    content_family: "library_indexes",
    collection_tool: "context7_entry_crosswalk",
    doc_pages: pages.map((page) => ({ id: page.id, url: page.url })),
    openapi_core_operations: openapiCore.map((row) => ({
      method: row.method,
      path: row.path,
      operationId: row.operationId,
      summary: row.summary,
    })),
    inventory,
    mappings: [...defaultMappings, ...extraMappings],
  };
}

export function buildContext7ReadmeIndex({
  resolvedLibraries,
  topicShards,
  outputDir,
  collectedAt,
  extraLinks = [],
}) {
  const lines = [
    provenanceHeader({
      sourceUrl: "context7://index",
      tool: "context7",
      mode: "sdk_context_note",
      collectedAt,
    }).trimEnd(),
    "",
    "# Context7 SDK Context Index",
    "",
    `Generated: ${collectedAt}`,
    "",
    "## Resolved libraries",
    "",
    ...resolvedLibraries.flatMap((row) => [
      `- **${row.library_name}**`,
      `  - selected: \`${row.selected_library_id}\``,
      row.version_pinned_library_id
        ? `  - version pin: \`${row.version_pinned_library_id}\``
        : "  - version pin: _(none matched)_",
      `  - website: \`${row.library_ids.website}\``,
      `  - sdk: \`${row.library_ids.sdk}\``,
    ]),
    "",
    "## Topic shards",
    "",
    ...topicShards.map(
      (shard) => `- [\`${shard.id}\`](./${path.basename(shard.path)}) — ${shard.query}`,
    ),
    ...extraLinks,
    "",
    "Context7 owns OpenAPI/Swagger interpretation in this pack. Optional spec mirror under `vendors/<entry>/openapi/`.",
    "",
  ];
  const readmePath = path.join(outputDir, "README.md");
  fs.writeFileSync(
    readmePath,
    lines.join("\n").endsWith("\n") ? lines.join("\n") : `${lines.join("\n")}\n`,
  );
  return readmePath;
}
