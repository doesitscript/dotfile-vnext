#!/usr/bin/env python3
"""Build the Langfuse vendor reference pack in the sibling AI library."""

from __future__ import annotations

import datetime as dt
import html
import json
import re
import shutil
import ssl
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any


PACKET_ROOT = Path(
    "/Users/joshc/develop/dotfile-vnext/docs/plans/"
    "2026-07-08--langfuse-vendor-reference-pack-incomplete"
)
OUTPUT_ROOT = Path("/Users/joshc/develop/ai-resource-library/vendors/langfuse")

CONTEXT7_RECORD = {
    "library_id": "/langfuse/langfuse-docs",
    "topics": [
        "integrations docs under paths like /docs/integrations/*",
        "general guides and how-to content under content/guides/*",
        "workshop/tutorial-style cookbook content generated into "
        "content/guides/cookbook/* from cookbook/ notebooks",
        "MCP usage docs in content/docs/docs-mcp.mdx plus Docs MCP examples "
        "such as the public MCP server config and agent workflow examples",
    ],
    "purpose": (
        "Confirm the official Langfuse documentation library that best covers "
        "integrations, guides, workshop/tutorial content, and MCP usage docs "
        "for this vendor-pack slice."
    ),
}

INTEGRATIONS_URL = "https://langfuse.com/integrations#overview"
GUIDES_URL = "https://langfuse.com/guides"
WORKSHOP_URL = "https://langfuse.com/workshop"
WORKSHOP_REPO = "https://github.com/langfuse/langfuse-workshop"
WORKSHOP_GH_API = (
    "https://api.github.com/repos/langfuse/langfuse-workshop/contents"
)
SKILLS_README_URL = (
    "https://raw.githubusercontent.com/langfuse/skills/refs/heads/main/README.md"
)
LANGFUSE_MCP_README_URL = (
    "https://raw.githubusercontent.com/langfuse/langfuse/refs/heads/main/"
    "web/src/features/mcp/README.md"
)
MCP_USE_URL = "https://langfuse.com/integrations/other/mcp-use"
MCP_SERVER_URL = "https://langfuse.com/docs/api-and-data-platform/features/mcp-server"
VSCODE_URL = "https://langfuse.com/integrations/developer-tools/vscode"


HTML_HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/130.0 Safari/537.36"
    ),
    "Accept": "text/html,application/json;q=0.9,*/*;q=0.8",
}


@dataclass
class PageRecord:
    title: str
    slug: str
    output_path: str
    source_urls: list[str]
    asset_paths: list[str]
    kind: str
    notes: str


def utc_now() -> str:
    return dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace(
        "+00:00", "Z"
    )


CAPTURED_AT = utc_now()
CAPTURED_DATE = CAPTURED_AT[:10]


def _request(url: str, *, headers: dict[str, str] | None = None) -> urllib.request.Request:
    merged = dict(HTML_HEADERS)
    if headers:
        merged.update(headers)
    return urllib.request.Request(url, headers=merged)


def fetch_bytes(url: str) -> bytes:
    context = ssl.create_default_context()
    delays = [0, 2, 5, 10]
    last_error: Exception | None = None
    for attempt, delay in enumerate(delays, start=1):
        if delay:
            time.sleep(delay)
        request = _request(url)
        try:
            with urllib.request.urlopen(request, context=context, timeout=60) as response:
                return response.read()
        except urllib.error.HTTPError as exc:
            last_error = exc
            if exc.code not in {403, 429} or attempt == len(delays):
                raise
            retry_after = exc.headers.get("Retry-After") if exc.headers else None
            if retry_after and retry_after.isdigit():
                time.sleep(int(retry_after))
        except urllib.error.URLError as exc:
            last_error = exc
            if attempt == len(delays):
                raise
    if last_error:
        raise last_error
    raise RuntimeError(f"Unable to fetch bytes from {url}")


def fetch_text(url: str) -> str:
    data = fetch_bytes(url)
    return data.decode("utf-8", errors="replace")


def fetch_json(url: str) -> Any:
    return json.loads(fetch_text(url))


def ensure_clean_dir(path: Path) -> None:
    if path.exists():
        shutil.rmtree(path)
    path.mkdir(parents=True, exist_ok=True)


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text.rstrip() + "\n", encoding="utf-8")


def write_json(path: Path, payload: Any) -> None:
    write_text(path, json.dumps(payload, indent=2, sort_keys=False))


def markdown_escape(text: str) -> str:
    return text.replace("|", "\\|")


def normalize_space(text: str) -> str:
    text = re.sub(r"<[^>]+>", "", text)
    text = html.unescape(text)
    text = text.replace("\xa0", " ")
    return re.sub(r"\s+", " ", text).strip()


def slugify(text: str) -> str:
    text = text.lower().strip()
    text = text.replace("&", " and ")
    text = re.sub(r"[^a-z0-9]+", "-", text)
    return re.sub(r"-{2,}", "-", text).strip("-")


def full_url(url: str) -> str:
    return urllib.parse.urljoin("https://langfuse.com", url)


def github_raw_url(repo: str, path: str) -> str:
    return f"https://raw.githubusercontent.com/{repo}/main/{path}"


def relative_output(path: Path) -> str:
    return path.relative_to(OUTPUT_ROOT).as_posix()


def provenance_block(
    source_urls: list[str], notes: list[str], capture_mode: str
) -> str:
    lines = [
        "## Provenance",
        f"- Captured at: `{CAPTURED_AT}`",
        f"- Capture mode: {capture_mode}",
        "- Source URL(s):",
    ]
    for url in source_urls:
        lines.append(f"  - `{url}`")
    lines.append("- Normalization notes:")
    for note in notes:
        lines.append(f"  - {note}")
    return "\n".join(lines)


def page_header(
    title: str, source_urls: list[str], notes: list[str], capture_mode: str
) -> str:
    return "\n\n".join(
        [f"# {title}", provenance_block(source_urls, notes, capture_mode)]
    )


def parse_integration_sections(html_text: str) -> list[dict[str, Any]]:
    heading_pattern = re.compile(
        r'<h2[^>]+id="([^"]+)"[^>]*>.*?<a[^>]*>(.*?)</a>.*?</h2>', re.S
    )
    headings = list(heading_pattern.finditer(html_text))
    sections: list[dict[str, Any]] = []
    wanted = {
        "Native",
        "Frameworks",
        "Model Providers",
        "Gateways",
        "No-Code",
        "Analytics",
        "Developer Tools",
        "Other",
    }
    for index, heading in enumerate(headings):
        title = normalize_space(heading.group(2))
        if title not in wanted:
            continue
        start = heading.end()
        end = headings[index + 1].start() if index + 1 < len(headings) else len(html_text)
        block = html_text[start:end]
        description_match = re.search(r"<p[^>]*>(.*?)</p>", block, re.S)
        description = normalize_space(description_match.group(1)) if description_match else ""
        card_pattern = re.compile(
            r'<a[^>]+data-card="true"[^>]+href="([^"]+)"[^>]*>(.*?)</a>', re.S
        )
        items = []
        seen = set()
        for href, inner in card_pattern.findall(block):
            if href in seen:
                continue
            seen.add(href)
            label_match = re.search(r"<h3[^>]*>(.*?)</h3>", inner, re.S)
            if not label_match:
                continue
            label = normalize_space(label_match.group(1))
            if not label:
                continue
            img_match = re.search(r'<img[^>]+src="([^"]+)"', inner)
            items.append(
                {
                    "label": label,
                    "href": full_url(href),
                    "icon_url": full_url(img_match.group(1)) if img_match else None,
                    "source_has_icon": bool(img_match),
                }
            )
        sections.append(
            {
                "title": title,
                "description": description,
                "items": items,
            }
        )
    return sections


def download_file(url: str, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    data = fetch_bytes(url)
    dest.write_bytes(data)


def parse_guides_cards(html_text: str) -> list[dict[str, str]]:
    cards = []
    seen = set()
    pattern = re.compile(r'<a[^>]+href="([^"]+)"[^>]*>.*?<h3[^>]*>(.*?)</h3>', re.S)
    for href, label_html in pattern.findall(html_text):
        href = href.strip()
        if href.startswith("#") or href == "/support":
            continue
        label = normalize_space(label_html)
        if not label or href in seen:
            continue
        seen.add(href)
        if not (
            href.startswith("/blog/")
            or href.startswith("/guides/")
            or href.startswith("/docs/")
            or href.startswith("https://github.com/langfuse/langfuse-docs/tree/main/cookbook")
        ):
            continue
        cards.append({"label": label, "href": full_url(href) if href.startswith("/") else href})
    return cards


def parse_workshop_routes(html_text: str) -> list[str]:
    routes = sorted(set(re.findall(r"/workshop/learner/[0-9][0-9]-[a-z0-9-]+", html_text)))
    return routes


def github_tree_recursive(api_url: str) -> list[dict[str, Any]]:
    items = fetch_json(api_url)
    collected: list[dict[str, Any]] = []
    for item in items:
        if item["type"] == "dir":
            collected.extend(github_tree_recursive(item["url"]))
        else:
            collected.append(item)
    return collected


def extract_title_from_markdown(markdown_text: str, fallback: str) -> str:
    for line in markdown_text.splitlines():
        if line.startswith("# "):
            return line[2:].strip()
    return fallback


def rewrite_workshop_image_refs(markdown_text: str) -> tuple[str, list[str]]:
    asset_paths: list[str] = []

    def replace_relative(match: re.Match[str]) -> str:
        original = match.group(1)
        relative = original.removeprefix("../images/")
        asset_path = f"assets/workshop/{relative}"
        asset_paths.append(asset_path)
        return asset_path

    markdown_text = re.sub(r"\.\./images/([A-Za-z0-9_\-./]+)", replace_relative, markdown_text)
    return markdown_text, sorted(set(asset_paths))


def build_integrations_page(
    sections: list[dict[str, Any]], assets_dir: Path
) -> tuple[str, list[str]]:
    asset_paths: list[str] = []
    lines = [
        page_header(
            "Langfuse Integrations Overview",
            [INTEGRATIONS_URL],
            [
                "Preserved the page category structure from the live integrations overview.",
                "Downloaded local icon assets whenever the source card exposed a discrete image file.",
                "Annotated cards that rendered without a separate icon asset in the source HTML.",
            ],
            "structured_summary",
        ),
        "## Summary",
        (
            "This page is the local reminder/reference copy of the Langfuse integrations "
            "overview. It keeps the visible category groupings and records each card as a "
            "local markdown entry with a source link."
        ),
        "## Categories",
    ]
    for section in sections:
        lines.append(f"### {section['title']}")
        if section["description"]:
            lines.append(section["description"])
        lines.append("")
        lines.append("| Icon | Integration | Source | Notes |")
        lines.append("| --- | --- | --- | --- |")
        for item in section["items"]:
            notes = ""
            icon_markdown = "_No source icon_"
            if item["icon_url"]:
                filename = Path(urllib.parse.urlparse(item["icon_url"]).path).name
                local_path = assets_dir / filename
                if not local_path.exists():
                    download_file(item["icon_url"], local_path)
                rel = relative_output(local_path)
                asset_paths.append(rel)
                icon_markdown = f"![{markdown_escape(item['label'])}]({rel})"
            else:
                notes = "Source card rendered without a separate icon file."
            lines.append(
                "| "
                + " | ".join(
                    [
                        icon_markdown,
                        markdown_escape(item["label"]),
                        f"[page]({item['href']})",
                        markdown_escape(notes),
                    ]
                )
                + " |"
            )
        lines.append("")
    return "\n".join(lines).rstrip() + "\n", sorted(set(asset_paths))


def build_guides_page(guides_cards: list[dict[str, str]]) -> str:
    featured = []
    cookbook = []
    for card in guides_cards:
        href = card["href"]
        if "/guides/cookbook/" in href or "langfuse-docs/tree/main/cookbook" in href:
            cookbook.append(card)
        else:
            featured.append(card)
    featured = featured[:14]
    cookbook = cookbook[:12]

    lines = [
        page_header(
            "Langfuse Guides Overview",
            [GUIDES_URL],
            [
                "Captured the current guides landing page as a curated index rather than a full leaf-page mirror.",
                "Preserved live guide/blog links surfaced on the page for later expansion of the vendor subtree.",
            ],
            "structured_summary",
        ),
        "## Summary",
        (
            "The Langfuse guides page acts as a living landing page for tutorials, "
            "evaluation patterns, cookbook examples, and adjacent blog guidance."
        ),
        "## Featured guide and tutorial links",
    ]
    for card in featured:
        lines.append(f"- [{card['label']}]({card['href']})")
    lines.extend(
        [
            "",
            "## Cookbook entrypoints",
        ]
    )
    for card in cookbook:
        lines.append(f"- [{card['label']}]({card['href']})")
    lines.extend(
        [
            "",
            "## Notes",
            "- The current Langfuse guides page is a curated landing page rather than a single deep article.",
            "- This slice keeps the index plus workshop learner pages; it does not yet mirror every guide leaf into local markdown.",
        ]
    )
    return "\n".join(lines).rstrip() + "\n"


def lesson_output_name(lesson_path: str) -> str:
    name = Path(lesson_path).name
    return f"workshop-learner-{name}"


def build_workshop_overview(routes: list[str]) -> str:
    lines = [
        page_header(
            "Langfuse Workshop Overview",
            [WORKSHOP_URL, WORKSHOP_REPO],
            [
                "Recorded the learner-module routes visible on the workshop page.",
                "Connected the workshop page to the raw learner markdown and localized GitHub image tree.",
            ],
            "structured_summary",
        ),
        "## Summary",
        (
            "The workshop page is the landing surface for the Langfuse workshop curriculum. "
            "This pack captures the learner-track modules as local markdown pages and localizes "
            "their screenshots/diagrams from the workshop repository."
        ),
        "## Learner modules",
        "| Lesson | Source route | Local file |",
        "| --- | --- | --- |",
    ]
    for route in routes:
        lesson_name = route.rsplit("/", 1)[-1]
        local_file = lesson_output_name(lesson_name + ".md")
        lines.append(
            f"| `{lesson_name}` | [{route}]({full_url(route)}) | [{local_file}]({local_file}) |"
        )
    lines.extend(
        [
            "",
            "## Notes",
            "- The workshop page also exposes instructor variants, but this slice intentionally captures the learner column only.",
            "- Workshop screenshots/diagrams come from the upstream GitHub `docs/images/` tree and are kept as local assets under `assets/workshop/`.",
        ]
    )
    return "\n".join(lines).rstrip() + "\n"


def build_summary_page(
    title: str,
    source_urls: list[str],
    summary_lines: list[str],
    related_links: list[tuple[str, str]],
    notes: list[str],
) -> str:
    lines = [
        page_header(title, source_urls, notes, "structured_summary"),
        "## Summary",
    ]
    lines.extend(f"- {line}" for line in summary_lines)
    if related_links:
        lines.extend(["", "## Related links"])
        lines.extend(f"- [{label}]({url})" for label, url in related_links)
    return "\n".join(lines).rstrip() + "\n"


def build_raw_markdown_page(title: str, source_urls: list[str], body: str, notes: list[str]) -> str:
    return "\n\n".join(
        [
            f"# {title}",
            provenance_block(source_urls, notes, "full_capture"),
            "## Normalized content",
            body.strip(),
        ]
    ).rstrip() + "\n"


def collect_workshop_assets(assets_root: Path) -> list[str]:
    image_items = github_tree_recursive(f"{WORKSHOP_GH_API}/docs/images")
    collected: list[str] = []
    for item in image_items:
        if item["type"] != "file":
            continue
        relative = item["path"].removeprefix("docs/images/")
        dest = assets_root / relative
        download_file(github_raw_url("langfuse/langfuse-workshop", item["path"]), dest)
        collected.append(relative_output(dest))
    return sorted(collected)


def update_vendors_index() -> None:
    vendors_readme = Path("/Users/joshc/develop/ai-resource-library/vendors/README.md")
    text = vendors_readme.read_text(encoding="utf-8")
    line = "- [`langfuse/`](langfuse/) - Langfuse integrations, guides, workshop, and MCP reference pack"
    if line not in text:
        anchor = "- [`diagrams/`](diagrams/) - diagramming research and examples"
        text = text.replace(anchor, anchor + "\n" + line)
        vendors_readme.write_text(text, encoding="utf-8")


def main() -> int:
    ensure_clean_dir(OUTPUT_ROOT)
    (OUTPUT_ROOT / "assets" / "integrations").mkdir(parents=True, exist_ok=True)
    (OUTPUT_ROOT / "assets" / "workshop").mkdir(parents=True, exist_ok=True)

    integrations_html = fetch_text(INTEGRATIONS_URL)
    guides_html = fetch_text(GUIDES_URL)
    workshop_html = fetch_text(WORKSHOP_URL)

    integration_sections = parse_integration_sections(integrations_html)
    integrations_page, integration_assets = build_integrations_page(
        integration_sections, OUTPUT_ROOT / "assets" / "integrations"
    )

    guides_cards = parse_guides_cards(guides_html)
    guides_page = build_guides_page(guides_cards)

    workshop_routes = parse_workshop_routes(workshop_html)
    workshop_page = build_workshop_overview(workshop_routes)

    workshop_asset_paths = collect_workshop_assets(OUTPUT_ROOT / "assets" / "workshop")

    page_records: list[PageRecord] = []

    def add_record(
        title: str,
        filename: str,
        source_urls: list[str],
        asset_paths: list[str],
        kind: str,
        notes: str,
        body: str,
    ) -> None:
        path = OUTPUT_ROOT / filename
        write_text(path, body)
        page_records.append(
            PageRecord(
                title=title,
                slug=slugify(filename.removesuffix(".md")),
                output_path=relative_output(path),
                source_urls=source_urls,
                asset_paths=asset_paths,
                kind=kind,
                notes=notes,
            )
        )

    add_record(
        "Langfuse Integrations Overview",
        "integrations-overview.md",
        [INTEGRATIONS_URL],
        integration_assets,
        "page",
        "Category-preserving capture of the integrations overview with local icon assets where exposed by the source page.",
        integrations_page,
    )
    add_record(
        "Langfuse Guides Overview",
        "guides-overview.md",
        [GUIDES_URL],
        [],
        "page",
        "Curated summary/index of the live guides landing page.",
        guides_page,
    )
    add_record(
        "Langfuse Workshop Overview",
        "workshop-overview.md",
        [WORKSHOP_URL, WORKSHOP_REPO],
        workshop_asset_paths,
        "page",
        "Workshop landing-page summary plus learner-module mapping.",
        workshop_page,
    )

    lesson_source_urls = []
    for route in workshop_routes:
        lesson_name = route.rsplit("/", 1)[-1]
        raw_url = github_raw_url(
            "langfuse/langfuse-workshop", f"docs/learner/{lesson_name}.md"
        )
        lesson_markdown = fetch_text(raw_url)
        lesson_title = extract_title_from_markdown(lesson_markdown, lesson_name)
        rewritten, lesson_assets = rewrite_workshop_image_refs(lesson_markdown)
        lesson_file = lesson_output_name(f"{lesson_name}.md")
        lesson_source_url = full_url(route)
        lesson_source_urls.append(lesson_source_url)
        add_record(
            lesson_title,
            lesson_file,
            [lesson_source_url, raw_url],
            lesson_assets,
            "lesson",
            "Raw learner markdown preserved with image paths rewritten to localized workshop assets.",
            build_raw_markdown_page(
                lesson_title,
                [lesson_source_url, raw_url],
                rewritten,
                [
                    "Preserved the upstream learner markdown body as closely as practical.",
                    "Rewrote `../images/...` references to local `assets/workshop/...` paths.",
                ],
            ),
        )

    skills_readme = fetch_text(SKILLS_README_URL)
    skills_title = extract_title_from_markdown(skills_readme, "Langfuse Skills README")
    add_record(
        skills_title,
        "langfuse-skills-readme.md",
        [SKILLS_README_URL],
        [],
        "page",
        "Upstream raw README captured with provenance header.",
        build_raw_markdown_page(
            skills_title,
            [SKILLS_README_URL],
            skills_readme,
            ["Captured from the upstream raw GitHub README without structural rewriting."],
        ),
    )

    langfuse_mcp_readme = fetch_text(LANGFUSE_MCP_README_URL)
    mcp_readme_title = extract_title_from_markdown(langfuse_mcp_readme, "Langfuse MCP README")
    add_record(
        mcp_readme_title,
        "langfuse-mcp-readme.md",
        [LANGFUSE_MCP_README_URL],
        [],
        "page",
        "Upstream raw Langfuse MCP README captured with provenance header.",
        build_raw_markdown_page(
            mcp_readme_title,
            [LANGFUSE_MCP_README_URL],
            langfuse_mcp_readme,
            ["Captured from the upstream raw GitHub README without structural rewriting."],
        ),
    )

    add_record(
        "Langfuse mcp-use Integration",
        "mcp-use.md",
        [MCP_USE_URL],
        [],
        "page",
        "Summary of the Langfuse mcp-use integration page.",
        build_summary_page(
            "Langfuse mcp-use Integration",
            [MCP_USE_URL],
            [
                "The page documents Langfuse observability for agent workflows built with `mcp-use` and the Model Context Protocol.",
                "It positions Langfuse as the tracing/monitoring layer for tool-use and agent execution flows built on MCP-enabled components.",
                "This slice keeps the page as a source-backed reference page and pairs it with the broader MCP README and MCP server pages in the same pack.",
            ],
            [
                ("Langfuse MCP README", "langfuse-mcp-readme.md"),
                ("Langfuse MCP server page", MCP_SERVER_URL),
            ],
            [
                "Normalized from the live rendered page into a concise reference summary.",
                "Kept related local pack links so MCP documentation stays connected inside the vendor subtree.",
            ],
        ),
    )

    add_record(
        "Langfuse MCP Server",
        "mcp-server.md",
        [MCP_SERVER_URL],
        [],
        "page",
        "Summary of the native Langfuse MCP server docs page.",
        build_summary_page(
            "Langfuse MCP Server",
            [MCP_SERVER_URL],
            [
                "The page describes Langfuse's native authenticated MCP server for documentation and product assistance workflows.",
                "It also points operators toward the Langfuse Agent Skill path when a CLI/bash-capable environment is available.",
                "This local page is paired with the raw Langfuse MCP README and the VS Code integration page for adjacent setup context.",
            ],
            [
                ("Langfuse MCP README", "langfuse-mcp-readme.md"),
                ("VS Code integration", VSCODE_URL),
                ("mcp-use integration", MCP_USE_URL),
            ],
            [
                "Normalized from the live rendered page into a concise reference summary.",
                "Kept the adjacent MCP-related source links rather than attempting to fully mirror the live docs app structure.",
            ],
        ),
    )

    add_record(
        "Langfuse VS Code Integration",
        "vscode-integration.md",
        [VSCODE_URL],
        [],
        "page",
        "Summary of the Langfuse developer-tools VS Code integration page.",
        build_summary_page(
            "Langfuse VS Code Integration",
            [VSCODE_URL],
            [
                "The page documents connecting the Langfuse MCP server to VS Code and GitHub Copilot agent-mode workflows.",
                "It serves as the developer-tool bridge between the native MCP server and editor-side agent experiences.",
                "This page is intentionally kept near the MCP server and raw MCP README pages in the local pack for retrieval continuity.",
            ],
            [
                ("Langfuse MCP server page", MCP_SERVER_URL),
                ("Langfuse MCP README", "langfuse-mcp-readme.md"),
            ],
            [
                "Normalized from the live rendered page into a concise reference summary.",
                "Focused on the integration's role in the local vendor reference pack rather than mirroring every live docs widget.",
            ],
        ),
    )

    all_asset_paths = sorted(
        {
            asset
            for page_record in page_records
            for asset in page_record.asset_paths
        }
    )

    readme_lines = [
        "# Langfuse",
        "",
        "Langfuse integrations, guides, workshop learner materials, and MCP reference material collected into a local vendor pack for retrieval and operator reference.",
        "",
        "## Sources",
        f"- Live integrations page: `{INTEGRATIONS_URL}`",
        f"- Live guides page: `{GUIDES_URL}`",
        f"- Live workshop page: `{WORKSHOP_URL}`",
        f"- Workshop GitHub repo: `{WORKSHOP_REPO}`",
        f"- Skills README: `{SKILLS_README_URL}`",
        f"- Langfuse MCP README: `{LANGFUSE_MCP_README_URL}`",
        "",
        "## Context7 record",
        f"- Library id: `{CONTEXT7_RECORD['library_id']}`",
        f"- Queried at: `{CAPTURED_AT}`",
        f"- Purpose: {CONTEXT7_RECORD['purpose']}",
        "- Topics used:",
    ]
    readme_lines.extend(f"  - {topic}" for topic in CONTEXT7_RECORD["topics"])
    readme_lines.extend(
        [
            "",
            "## Files included",
        ]
    )
    readme_lines.extend(f"- `{page.output_path}` - {page.notes}" for page in page_records)
    readme_lines.extend(
        [
            "",
            "## Asset roots",
            "- `assets/integrations/` - downloaded integration icons exposed by the live overview page",
            "- `assets/workshop/` - localized workshop screenshots/diagrams from the upstream GitHub repo",
        ]
    )
    write_text(OUTPUT_ROOT / "README.md", "\n".join(readme_lines))

    metadata = {
        "collection": "Langfuse vendor reference pack",
        "captured_at": CAPTURED_AT,
        "source_type": "mixed-live-html-and-raw-markdown",
        "governing_repo": "dotfile-vnext",
        "output_root": str(OUTPUT_ROOT),
        "packet_root": str(PACKET_ROOT),
        "context7": {
            **CONTEXT7_RECORD,
            "queried_at": CAPTURED_AT,
        },
        "source_urls": [
            INTEGRATIONS_URL,
            GUIDES_URL,
            WORKSHOP_URL,
            MCP_USE_URL,
            MCP_SERVER_URL,
            VSCODE_URL,
            SKILLS_README_URL,
            LANGFUSE_MCP_README_URL,
        ],
        "files": [
            {
                "path": page.output_path,
                "title": page.title,
                "kind": page.kind,
                "source_urls": page.source_urls,
                "asset_paths": page.asset_paths,
                "notes": page.notes,
            }
            for page in page_records
        ],
        "asset_roots": [
            "assets/integrations",
            "assets/workshop",
        ],
        "asset_count": len(all_asset_paths),
    }
    write_json(OUTPUT_ROOT / "metadata.json", metadata)
    write_json(
        OUTPUT_ROOT / "page-index.json",
        [
            {
                "title": page.title,
                "slug": page.slug,
                "output_path": page.output_path,
                "source_urls": page.source_urls,
                "asset_paths": page.asset_paths,
                "kind": page.kind,
                "notes": page.notes,
            }
            for page in page_records
        ],
    )

    update_vendors_index()

    print(
        json.dumps(
            {
                "captured_at": CAPTURED_AT,
                "pages": len(page_records),
                "assets": len(all_asset_paths),
                "integration_categories": len(integration_sections),
                "learner_lessons": len(
                    [page for page in page_records if page.kind == "lesson"]
                ),
            },
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except urllib.error.URLError as exc:
        print(f"Network failure: {exc}", file=sys.stderr)
        raise
