#!/usr/bin/env node

import path from "node:path";

export function normalizeVendorDocUrl(url, { origin, rootPath }) {
  if (!url) {
    return null;
  }
  const parsed = new URL(url, origin);
  if (parsed.origin !== origin) {
    return null;
  }
  if (!parsed.pathname.startsWith(rootPath)) {
    return null;
  }
  parsed.hash = "";
  parsed.search = "";
  let normalized = parsed.toString().replace(/\/+$/, "");
  if (normalized === `${origin}${rootPath}`) {
    normalized = `${origin}${rootPath}`;
  }
  return normalized;
}

export function buildHierarchicalDocOutputPath(
  url,
  { origin, rootPath, rootOutputPath, subtreeDir, hubRoutes = [] },
) {
  const normalized = normalizeVendorDocUrl(url, { origin, rootPath });
  if (!normalized) {
    return null;
  }

  const pathname = new URL(normalized).pathname;
  if (pathname === rootPath) {
    return rootOutputPath;
  }

  const relativePath = pathname.slice(rootPath.length).replace(/^\/+/, "");
  if (!relativePath) {
    return rootOutputPath;
  }

  const hubSet = new Set(hubRoutes);
  if (hubSet.has(pathname)) {
    return path.join(subtreeDir, relativePath, "index.md");
  }

  const segments = relativePath.split("/").filter(Boolean);
  if (segments.length === 1) {
    return path.join(subtreeDir, `${segments[0]}.md`);
  }
  return path.join(subtreeDir, ...segments.slice(0, -1), `${segments.at(-1)}.md`);
}

export function assetSubdirForUrl(url, { origin, rootPath, landingDir = "landing" }) {
  const normalized = normalizeVendorDocUrl(url, { origin, rootPath });
  if (!normalized) {
    return landingDir;
  }

  const pathname = new URL(normalized).pathname;
  if (pathname === rootPath) {
    return landingDir;
  }

  return pathname
    .slice(rootPath.length)
    .replace(/^\/+/, "")
    .split("/")
    .filter(Boolean)
    .join("/");
}

export function slugFromRelativeOutput(relativeOutputPath) {
  return relativeOutputPath
    .replace(/\\/g, "/")
    .replace(/\/index\.md$/, "-index")
    .replace(/\.md$/, "")
    .replace(/\//g, "-");
}
