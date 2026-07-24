#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import sys
import urllib.error
import urllib.request


API_ROOT = "https://api.github.com/repos"


def fetch_json(url: str) -> dict:
    request = urllib.request.Request(
        url,
        headers={
            "Accept": "application/vnd.github+json",
            "User-Agent": "dotfile-vnext-github-release-binary-intake",
        },
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.load(response)


def choose_release(repo: str, tag: str | None) -> dict:
    if tag:
        return fetch_json(f"{API_ROOT}/{repo}/releases/tags/{tag}")
    return fetch_json(f"{API_ROOT}/{repo}/releases/latest")


def summarize_release(release: dict) -> dict:
    assets = []
    checksum_candidates = []

    for asset in release.get("assets", []):
        asset_summary = {
            "name": asset.get("name"),
            "size": asset.get("size"),
            "content_type": asset.get("content_type"),
            "download_url": asset.get("browser_download_url"),
            "created_at": asset.get("created_at"),
            "updated_at": asset.get("updated_at"),
        }
        assets.append(asset_summary)

        name = (asset.get("name") or "").lower()
        if any(token in name for token in ("sha256", "checksums", "checksum", "sums")):
            checksum_candidates.append(asset_summary)

    return {
        "tag_name": release.get("tag_name"),
        "name": release.get("name"),
        "published_at": release.get("published_at"),
        "draft": release.get("draft"),
        "prerelease": release.get("prerelease"),
        "html_url": release.get("html_url"),
        "assets": assets,
        "checksum_candidates": checksum_candidates,
    }


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Inspect the current or pinned GitHub release for a repo."
    )
    parser.add_argument("repo", help="GitHub repo in owner/name form")
    parser.add_argument(
        "--tag",
        help="Specific release tag. Defaults to the current latest release.",
    )
    args = parser.parse_args()

    try:
        release = choose_release(args.repo, args.tag)
    except urllib.error.HTTPError as exc:
        print(f"error: GitHub API returned HTTP {exc.code} for {args.repo}", file=sys.stderr)
        return 1
    except urllib.error.URLError as exc:
        print(f"error: could not reach GitHub API: {exc}", file=sys.stderr)
        return 1

    print(json.dumps(summarize_release(release), indent=2, sort_keys=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
