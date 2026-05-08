import { readFileSync, readdirSync, statSync, existsSync } from "fs";
import { join, basename, relative } from "path";
import type { WikiPage, WikiIndex } from "./types.js";

const WIKILINK_RE = /\[\[([^\]|]+)(?:\|[^\]]+)?\]\]/g;

function extractFrontmatter(
  content: string
): Record<string, unknown> {
  if (!content.startsWith("---\n")) return {};

  const endIdx = content.indexOf("\n---", 4);
  if (endIdx === -1) return {};

  const yaml = content.slice(4, endIdx);
  const result: Record<string, unknown> = {};

  for (const line of yaml.split("\n")) {
    const colonIdx = line.indexOf(":");
    if (colonIdx === -1) continue;
    const key = line.slice(0, colonIdx).trim();
    const value = line.slice(colonIdx + 1).trim();
    result[key] = value;
  }

  return result;
}

function extractLinks(content: string): string[] {
  const links: string[] = [];
  let match: RegExpExecArray | null;
  while ((match = WIKILINK_RE.exec(content)) !== null) {
    links.push(match[1]);
  }
  return links;
}

function countWords(content: string): number {
  const stripped = content
    .replace(/^---[\s\S]*?---\n?/, "")
    .replace(/```[\s\S]*?```/g, "")
    .replace(/[#|*\->`~\[\]]/g, " ");
  return stripped.split(/\s+/).filter((w) => w.length > 0).length;
}

function scanDirectory(dir: string, category: string): WikiPage[] {
  if (!existsSync(dir)) return [];

  const pages: WikiPage[] = [];

  for (const entry of readdirSync(dir)) {
    if (!entry.endsWith(".md")) continue;
    const filePath = join(dir, entry);
    const stat = statSync(filePath);
    if (!stat.isFile()) continue;

    const content = readFileSync(filePath, "utf-8");
    const name = basename(entry, ".md");

    pages.push({
      path: filePath,
      name,
      category,
      frontmatter: extractFrontmatter(content),
      links: extractLinks(content),
      wordCount: countWords(content),
    });
  }

  return pages;
}

export function buildIndex(wikiDir: string): WikiIndex {
  const pages = new Map<string, WikiPage>();
  const links = new Map<string, string[]>();
  const backlinks = new Map<string, string[]>();

  const categories = ["entities", "concepts", "sources", "synthesis"];

  for (const cat of categories) {
    const dir = join(wikiDir, cat);
    for (const page of scanDirectory(dir, cat)) {
      pages.set(page.name, page);
      links.set(page.name, page.links);

      for (const link of page.links) {
        const existing = backlinks.get(link) ?? [];
        existing.push(page.name);
        backlinks.set(link, existing);
      }
    }
  }

  const rootFiles = ["index.md", "log.md"];
  for (const file of rootFiles) {
    const filePath = join(wikiDir, file);
    if (!existsSync(filePath)) continue;
    const content = readFileSync(filePath, "utf-8");
    const name = basename(file, ".md");
    pages.set(name, {
      path: filePath,
      name,
      category: "root",
      frontmatter: extractFrontmatter(content),
      links: extractLinks(content),
      wordCount: countWords(content),
    });
  }

  return { pages, links, backlinks };
}
