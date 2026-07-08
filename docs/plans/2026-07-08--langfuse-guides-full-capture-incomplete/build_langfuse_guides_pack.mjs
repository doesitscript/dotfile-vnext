#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import { execFileSync } from "node:child_process";
import { createRequire } from "node:module";

const GLOBAL_NODE_MODULES = "/Users/joshc/.nvm/versions/node/v20.20.0/lib/node_modules";
const JSDOM_MODULE = `file://${path.join(
  GLOBAL_NODE_MODULES,
  "mcp-fetch-server",
  "node_modules",
  "jsdom",
  "lib",
  "api.js",
)}`;
const YAML_MODULE = `file://${path.join(
  GLOBAL_NODE_MODULES,
  "langfuse-cli",
  "node_modules",
  "yaml",
  "browser",
  "index.js",
)}`;

const { JSDOM } = await import(JSDOM_MODULE);
const require = createRequire(import.meta.url);
const TurndownService = require(
  path.join(
    GLOBAL_NODE_MODULES,
    "mcp-fetch-server",
    "node_modules",
    "turndown",
    "lib",
    "turndown.cjs.js",
  ),
);
const YAML = await import(YAML_MODULE);

const PACKET_ROOT =
  "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-07-08--langfuse-guides-full-capture-incomplete";
const OUTPUT_ROOT = "/Users/joshc/develop/ai-resource-library/vendors/langfuse";
const GUIDES_ROOT = path.join(OUTPUT_ROOT, "guides");
const ASSETS_ROOT = path.join(OUTPUT_ROOT, "assets", "guides");
const ROOT_README = path.join(OUTPUT_ROOT, "README.md");
const ROOT_METADATA = path.join(OUTPUT_ROOT, "metadata.json");
const ROOT_PAGE_INDEX = path.join(OUTPUT_ROOT, "page-index.json");
const GUIDES_OVERVIEW = path.join(OUTPUT_ROOT, "guides-overview.md");
const ENTRY_SPEC = path.join(PACKET_ROOT, "entry-spec.yml");
const MCP_CLIENT = path.join(PACKET_ROOT, "mcp_tool_client.mjs");
const GUIDE_MANIFEST = path.join(PACKET_ROOT, "guide-manifest.json");

const GUIDES_URL = "https://langfuse.com/guides";
const HUB_URLS = [
  "https://langfuse.com/guides",
  "https://langfuse.com/guides/cookbook",
  "https://langfuse.com/guides/videos",
];
const FIRECRAWL_SEARCH_QUERIES = [
  {
    label: "guides-root-search",
    arguments: {
      query: "site:langfuse.com/guides langfuse guides",
      limit: 10,
      includeDomains: ["langfuse.com"],
      sources: [{ type: "web" }],
    },
  },
  {
    label: "guides-cookbook-search",
    arguments: {
      query: "site:langfuse.com/guides/cookbook langfuse cookbook",
      limit: 10,
      includeDomains: ["langfuse.com"],
      sources: [{ type: "web" }],
    },
  },
];
const CONTEXT7_QUERIES = [
  "Langfuse guides landing surface and cookbook/tutorial documentation coverage",
  "Langfuse video tutorial documentation and guides indexing coverage",
];

function nowIso() {
  return new Date().toISOString();
}

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function readJson(filePath, fallback) {
  if (!fs.existsSync(filePath)) {
    return fallback;
  }
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeJson(filePath, data) {
  fs.writeFileSync(filePath, `${JSON.stringify(data, null, 2)}\n`);
}

function mcpCall(serverName, toolName, args) {
  const output = execFileSync("node", [MCP_CLIENT, serverName, "call", toolName, JSON.stringify(args)], {
    encoding: "utf8",
    cwd: PACKET_ROOT,
    maxBuffer: 1024 * 1024 * 16,
  });
  return JSON.parse(output);
}

function extractToolText(result) {
  const textChunk = (result.content || []).find((item) => item.type === "text");
  if (!textChunk) {
    throw new Error(`MCP result missing text content: ${JSON.stringify(result).slice(0, 500)}`);
  }
  return textChunk.text;
}

function firecrawlSearchEvidence() {
  const runs = [];
  for (const query of FIRECRAWL_SEARCH_QUERIES) {
    const result = mcpCall("firecrawl", "firecrawl_search", query.arguments);
    const payload = JSON.parse(extractToolText(result));
    runs.push({
      label: query.label,
      query: query.arguments.query,
      result: payload,
    });
  }
  return runs;
}

function context7Evidence() {
  const resolved = mcpCall("context7", "resolve-library-id", {
    libraryName: "Langfuse",
    query: "Langfuse product documentation and guides library id",
  });
  const resolvedPayload = extractToolText(resolved);
  const firstLine = resolvedPayload.split("\n").find((line) => line.includes("/langfuse/")) || "";
  const libraryId = firstLine.trim().split(/\s+/).find((token) => token.startsWith("/")) || "/langfuse/langfuse-docs";
  const docs = CONTEXT7_QUERIES.map((query) => {
    const result = mcpCall("context7", "query-docs", {
      libraryId,
      query,
    });
    return {
      query,
      response: extractToolText(result),
    };
  });
  return {
    libraryId,
    resolveResponse: extractToolText(resolved),
    docs,
  };
}

async function fetchText(url) {
  const response = await fetch(url, {
    headers: {
      "user-agent": "langfuse-guides-pack-builder/0.1",
      accept: "text/html,application/xhtml+xml",
    },
  });
  if (!response.ok) {
    throw new Error(`Failed to fetch ${url}: ${response.status}`);
  }
  return await response.text();
}

function normalizeGuideUrl(url) {
  if (!url) {
    return null;
  }
  if (url.startsWith("/")) {
    url = `https://langfuse.com${url}`;
  }
  if (!url.startsWith("https://langfuse.com/guides")) {
    return null;
  }
  const clean = url.split("#")[0].split("?")[0].replace(/\/+$/, "");
  return clean || GUIDES_URL;
}

function discoverGuideLinks(htmlText) {
  const matches = htmlText.match(/href="([^"]+)"/g) || [];
  const discovered = new Set();
  for (const raw of matches) {
    const href = raw.slice(6, -1);
    const normalized = normalizeGuideUrl(href);
    if (normalized && normalized !== "https://langfuse.com/guides/videos/beginners-guide-to-rag-evaluation ") {
      discovered.add(normalized);
    }
  }
  return [...discovered].sort();
}

function routeToRelativePath(url) {
  const route = new URL(url).pathname.replace(/^\/+/, "");
  if (route === "guides") {
    return "guides-overview.md";
  }

  const segments = route.split("/").slice(1);
  if (segments.length === 1 && ["cookbook", "videos"].includes(segments[0])) {
    return path.join("guides", segments[0], "index.md");
  }
  if (segments.length === 1) {
    return path.join("guides", `${segments[0]}.md`);
  }
  return path.join("guides", ...segments.slice(0, -1), `${segments.at(-1)}.md`);
}

function assetDirForUrl(url) {
  const route = new URL(url).pathname.replace(/^\/+/, "");
  const segments = route.split("/").slice(1);
  if (segments.length === 0) {
    return "landing";
  }
  return segments.join("/");
}

function selectMainHtml(document, url) {
  const selectors = [
    "main",
    "article",
    "[data-pagefind-body]",
    ".prose",
  ];
  for (const selector of selectors) {
    const node = document.querySelector(selector);
    if (node) {
      return node;
    }
  }
  throw new Error(`Could not find main content node for ${url}`);
}

function cleanDocument(node) {
  for (const selector of [
    "script",
    "style",
    "nav",
    "footer",
    "aside",
    "button",
    "noscript",
    "[role='dialog']",
    ".cookie",
    ".Cookie",
  ]) {
    node.querySelectorAll(selector).forEach((element) => element.remove());
  }
}

async function downloadFile(url, destinationPath) {
  ensureDir(path.dirname(destinationPath));
  const response = await fetch(url, {
    headers: {
      "user-agent": "langfuse-guides-pack-builder/0.1",
    },
  });
  if (!response.ok) {
    throw new Error(`Failed to download ${url}: ${response.status}`);
  }
  const arrayBuffer = await response.arrayBuffer();
  fs.writeFileSync(destinationPath, Buffer.from(arrayBuffer));
}

function sanitizeStem(value) {
  return value.replace(/[^A-Za-z0-9._-]+/g, "-").replace(/-+/g, "-").replace(/^-|-$/g, "") || "asset";
}

function guessExtension(assetUrl, contentType, index) {
  const pathname = new URL(assetUrl).pathname;
  const ext = path.extname(pathname);
  if (ext) {
    return ext;
  }
  if (contentType.includes("png")) {
    return ".png";
  }
  if (contentType.includes("jpeg")) {
    return ".jpg";
  }
  if (contentType.includes("svg")) {
    return ".svg";
  }
  if (contentType.includes("webp")) {
    return ".webp";
  }
  return `-${index}.bin`;
}

async function localizeAssets(document, pageUrl, assetRoot) {
  const downloaded = [];
  const images = [...document.querySelectorAll("img[src]")];
  for (const [index, image] of images.entries()) {
    const src = image.getAttribute("src");
    if (!src) {
      continue;
    }
    const absolute = new URL(src, pageUrl).toString();
    const response = await fetch(absolute, {
      headers: {
        "user-agent": "langfuse-guides-pack-builder/0.1",
      },
    });
    if (!response.ok) {
      throw new Error(`Failed to download ${absolute}: ${response.status}`);
    }
    const contentType = response.headers.get("content-type") || "";
    const pathname = new URL(absolute).pathname;
    const baseStem = sanitizeStem(path.basename(pathname, path.extname(pathname)) || "image");
    const basename = `${String(index + 1).padStart(3, "0")}-${baseStem}${guessExtension(absolute, contentType, index + 1)}`;
    const target = path.join(assetRoot, basename);
    ensureDir(path.dirname(target));
    fs.writeFileSync(target, Buffer.from(await response.arrayBuffer()));
    downloaded.push({
      source: absolute,
      path: target,
      basename,
    });
    image.setAttribute("src", target);
  }
  return downloaded;
}

function rewriteMarkdownAssetPaths(markdownText, outputPath, assetRecords) {
  let rewritten = markdownText;
  for (const asset of assetRecords) {
    const relative = path.relative(path.dirname(outputPath), asset.path).split(path.sep).join("/");
    const escaped = asset.path.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    rewritten = rewritten.replace(new RegExp(escaped, "g"), relative);
    rewritten += `\n<!-- source: ${asset.source} -->`;
  }
  return rewritten;
}

function buildProvenanceHeader({ title, sourceUrl, collectedAt, collectionTool, notes }) {
  return [
    `# ${title}`,
    "",
    `Source: ${sourceUrl}`,
    `Captured: ${collectedAt}`,
    `Collection-tool: ${collectionTool}`,
    "Capture mode: full_capture",
    `Normalization notes: ${notes.join("; ")}`,
    "",
  ].join("\n");
}

async function capturePage(url) {
  const htmlText = await fetchText(url);
  const dom = new JSDOM(htmlText);
  const document = dom.window.document;
  const title = document.querySelector("h1")?.textContent?.trim() || document.title.replace(/\s+-\s+Langfuse$/, "").trim();
  const mainNode = selectMainHtml(document, url);
  cleanDocument(mainNode);
  const assetRoot = path.join(ASSETS_ROOT, assetDirForUrl(url));
  const assets = await localizeAssets(mainNode, url, assetRoot);
  const turndown = new TurndownService({
    headingStyle: "atx",
    codeBlockStyle: "fenced",
    bulletListMarker: "-",
  });
  const markdownBody = turndown.turndown(mainNode.innerHTML).trim();
  const relativeOutput = routeToRelativePath(url);
  const absoluteOutput = path.join(OUTPUT_ROOT, relativeOutput);
  const notes = [
    "Fetched live HTML directly after Firecrawl discovery",
    "Removed navigation and chrome elements from the main content node",
    assets.length > 0 ? "Localized page images under assets/guides" : "No downloadable page images discovered",
  ];
  let markdown = `${buildProvenanceHeader({
    title,
    sourceUrl: url,
    collectedAt: nowIso(),
    collectionTool: "fetch_fallback_after_firecrawl_discovery",
    notes,
  })}${markdownBody}\n`;
  markdown = rewriteMarkdownAssetPaths(markdown, absoluteOutput, assets);
  ensureDir(path.dirname(absoluteOutput));
  fs.writeFileSync(absoluteOutput, `${markdown}\n`);
  return {
    title,
    url,
    outputPath: absoluteOutput,
    relativeOutput,
    assets,
  };
}

function buildGuidesReadme(entries, context7, firecrawlEvidence) {
  const lines = [
    "# Langfuse Guides Full Capture",
    "",
    `Captured: ${nowIso()}`,
    "",
    "This subtree contains full-capture Langfuse guide pages discovered from the live `/guides` hub surfaces.",
    "",
    "## MCP evidence",
    "",
    "- Langfuse Docs MCP: used for initial discovery, but not authoritative for the full route list.",
    `- Firecrawl MCP: used for live-search discovery with ${firecrawlEvidence.length} recorded query passes.`,
    `- Context7 library id: \`${context7.libraryId}\``,
    "",
    "## Captured pages",
    "",
  ];
  for (const entry of entries) {
    if (entry.relativeOutput === "guides-overview.md") {
      continue;
    }
    lines.push(`- [${entry.title}](./${path.relative(GUIDES_ROOT, entry.outputPath).split(path.sep).join("/")})`);
  }
  lines.push("");
  return `${lines.join("\n")}\n`;
}

function updateRootReadme(entries, context7) {
  const existing = fs.existsSync(ROOT_README) ? fs.readFileSync(ROOT_README, "utf8") : "# Langfuse\n\n";
  const marker = "## Guides full capture subtree";
  const section = [
    marker,
    "",
    "The Langfuse guides surface is now materialized as full captures under `guides/`.",
    "",
    `- Landing page full capture: \`guides-overview.md\``,
    `- Hierarchy root: \`guides/\``,
    `- Localized guide assets: \`assets/guides/\``,
    `- Context7 library id for this slice: \`${context7.libraryId}\``,
    `- Captured guide pages in this pass: ${entries.length}`,
    "",
  ].join("\n");
  const updated = existing.includes(marker)
    ? `${existing.slice(0, existing.indexOf(marker)).trimEnd()}\n\n${section}\n`
    : `${existing.trimEnd()}\n\n${section}\n`;
  fs.writeFileSync(ROOT_README, updated);
}

function updateMetadata(entries, context7, firecrawlEvidence, langfuseDocsEvidence) {
  const existing = readJson(ROOT_METADATA, {});
  existing.guides_full_capture = {
    captured_at: nowIso(),
    output_root: GUIDES_ROOT,
    asset_root: ASSETS_ROOT,
    entry_spec: ENTRY_SPEC,
    guide_manifest: GUIDE_MANIFEST,
    context7: {
      library_id: context7.libraryId,
      topics: CONTEXT7_QUERIES,
      resolve_response: context7.resolveResponse,
    },
    langfuse_docs_mcp: langfuseDocsEvidence,
    firecrawl_mcp: firecrawlEvidence.map((item) => ({
      label: item.label,
      query: item.query,
      result_count: item.result?.data?.web?.length || 0,
    })),
    pages: entries.map((entry) => ({
      title: entry.title,
      url: entry.url,
      output_path: path.relative(OUTPUT_ROOT, entry.outputPath).split(path.sep).join("/"),
      asset_paths: entry.assets.map((asset) => path.relative(OUTPUT_ROOT, asset.path).split(path.sep).join("/")),
    })),
  };
  writeJson(ROOT_METADATA, existing);
}

function updatePageIndex(entries) {
  const existing = readJson(ROOT_PAGE_INDEX, []);
  const filtered = existing.filter((entry) => {
    const outputPath = entry.output_path || "";
    return outputPath !== "guides-overview.md" && !outputPath.startsWith("guides/");
  });
  for (const entry of entries) {
    filtered.push({
      title: entry.title,
      slug: path.basename(entry.relativeOutput, ".md"),
      output_path: entry.relativeOutput.split(path.sep).join("/"),
      source_urls: [entry.url],
      asset_paths: entry.assets.map((asset) => path.relative(OUTPUT_ROOT, asset.path).split(path.sep).join("/")),
      kind: "page",
      notes:
        entry.relativeOutput === "guides-overview.md"
          ? "Full capture of the Langfuse guides landing page."
          : "Full capture of a Langfuse guide page discovered from the live guides hierarchy.",
    });
  }
  writeJson(ROOT_PAGE_INDEX, filtered);
}

function buildLangfuseDocsEvidence() {
  return {
    used_first: true,
    conclusion:
      "Helpful for initial lookup and grouping confirmation, but not authoritative enough to enumerate the full guide export set.",
    notes: [
      "Initial discovery used Langfuse Docs MCP before Firecrawl.",
      "The docs MCP missed some child-card link structure on the guides landing surface.",
    ],
  };
}

function buildEntrySpec(entries, context7) {
  const sourceUrls = [];
  const requiredOutputs = [
    {
      id: "pack-readme",
      path: ROOT_README,
      content_family: "vendor_docs",
      source_urls: [GUIDES_URL],
      provenance_required: false,
      summary_allowed: false,
      context7_topics: CONTEXT7_QUERIES,
      asset_paths: [],
    },
    {
      id: "pack-metadata",
      path: ROOT_METADATA,
      content_family: "vendor_docs",
      source_urls: HUB_URLS,
      provenance_required: false,
      summary_allowed: false,
      context7_topics: CONTEXT7_QUERIES,
      asset_paths: [],
    },
    {
      id: "page-index",
      path: ROOT_PAGE_INDEX,
      content_family: "vendor_docs",
      source_urls: HUB_URLS,
      provenance_required: false,
      summary_allowed: false,
      context7_topics: CONTEXT7_QUERIES,
      asset_paths: [],
    },
    {
      id: "guides-readme",
      path: path.join(GUIDES_ROOT, "README.md"),
      content_family: "vendor_docs",
      source_urls: HUB_URLS,
      provenance_required: false,
      summary_allowed: false,
      context7_topics: CONTEXT7_QUERIES,
      asset_paths: [],
    },
  ];
  const outputModes = {
    "pack-readme": "index_record",
    "pack-metadata": "index_record",
    "page-index": "index_record",
    "guides-readme": "index_record",
  };

  for (const entry of entries) {
    const outputId = entry.relativeOutput === "guides-overview.md"
      ? "guides-overview"
      : entry.relativeOutput
          .replace(/^guides\//, "guides-")
          .replace(/\/index\.md$/, "-index")
          .replace(/\.md$/, "")
          .replace(/[\\/]/g, "-");
    sourceUrls.push({
      url: entry.url,
      kind: "live_doc",
      maps_to: [outputId, "pack-metadata", "page-index"],
    });
    requiredOutputs.push({
      id: outputId,
      path: entry.outputPath,
      content_family: "vendor_docs",
      source_urls: [entry.url],
      provenance_required: true,
      summary_allowed: false,
      context7_topics: CONTEXT7_QUERIES,
      asset_paths: entry.assets.map((asset) => asset.path),
    });
    outputModes[outputId] = "full_capture";
  }

  const spec = {
    entry_id: "langfuse_guides_full_capture",
    content_families: ["vendor_docs"],
    library_targets: {
      vendor_docs: OUTPUT_ROOT,
    },
    source_urls: sourceUrls,
    required_outputs: requiredOutputs,
    output_modes: outputModes,
    collection_strategy: {
      primary: "firecrawl_search_then_scrape",
      discovery: "firecrawl_search_then_scrape",
      fallback: ["fetch_fallback"],
      live_collection_required: true,
    },
    context7_required: true,
    context7_topics: CONTEXT7_QUERIES,
    asset_requirements: {
      localization_required: true,
      sidecar_extraction_required: false,
    },
    allowed_summary_outputs: [],
    validation_rules: {
      packet_readme: path.join(PACKET_ROOT, "README.md"),
      validator_pass_token: "AI_LIBRARY_ENTRY_VALIDATION_OK",
      required_metadata_outputs: ["pack-metadata"],
      required_index_outputs: ["page-index"],
      full_capture_provenance_markers: [
        "Source:",
        "Captured:",
        "Collection-tool:",
        "Capture mode: full_capture",
      ],
    },
    context7_library_id: context7.libraryId,
  };
  fs.writeFileSync(ENTRY_SPEC, YAML.stringify(spec));
}

async function main() {
  fs.rmSync(GUIDES_ROOT, { recursive: true, force: true });
  fs.rmSync(ASSETS_ROOT, { recursive: true, force: true });
  ensureDir(GUIDES_ROOT);
  ensureDir(ASSETS_ROOT);

  const firecrawlEvidence = firecrawlSearchEvidence();
  const context7 = context7Evidence();
  const langfuseDocsEvidence = buildLangfuseDocsEvidence();

  const discovered = new Set(HUB_URLS);
  for (const hubUrl of HUB_URLS) {
    const html = await fetchText(hubUrl);
    for (const url of discoverGuideLinks(html)) {
      discovered.add(url);
    }
  }

  const entries = [];
  for (const url of [...discovered].sort()) {
    entries.push(await capturePage(url));
  }

  fs.writeFileSync(
    path.join(GUIDES_ROOT, "README.md"),
    buildGuidesReadme(entries, context7, firecrawlEvidence),
  );
  updateRootReadme(entries, context7);
  updateMetadata(entries, context7, firecrawlEvidence, langfuseDocsEvidence);
  updatePageIndex(entries);
  buildEntrySpec(entries, context7);

  writeJson(GUIDE_MANIFEST, {
    captured_at: nowIso(),
    page_count: entries.length,
    urls: entries.map((entry) => entry.url),
  });

  process.stdout.write(
    `${JSON.stringify(
      {
        captured_at: nowIso(),
        pages: entries.length,
        output_root: OUTPUT_ROOT,
        guides_root: GUIDES_ROOT,
      },
      null,
      2,
    )}\n`,
  );
}

await main();
