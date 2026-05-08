import { readFileSync, existsSync } from "fs";
import { resolve } from "path";
import type { WikiConfig } from "./types.js";

const DEFAULTS: WikiConfig = {
  vault: { path: ".", name: "wiki" },
  wiki: {
    raw_dir: "raw",
    wiki_dir: "wiki",
    index_file: "index.md",
    log_file: "log.md",
    subdirs: {
      entities: "wiki/entities",
      concepts: "wiki/concepts",
      sources: "wiki/sources",
      synthesis: "wiki/synthesis",
    },
  },
  lint: {
    enabled_checks: [
      "dead_links",
      "orphan_pages",
      "index_completeness",
      "missing_concepts",
      "contradictions",
      "large_pages",
      "frontmatter",
      "format_consistency",
    ],
    max_page_words: 1200,
    required_frontmatter_fields: ["type", "date"],
    auto_fix: false,
  },
};

export function loadConfig(configPath?: string): WikiConfig {
  const path = configPath ?? resolve("config.json");

  if (!existsSync(path)) {
    return DEFAULTS;
  }

  const raw = readFileSync(path, "utf-8");
  const parsed = JSON.parse(raw) as Partial<WikiConfig>;

  return {
    vault: { ...DEFAULTS.vault, ...parsed.vault },
    wiki: { ...DEFAULTS.wiki, ...parsed.wiki },
    lint: { ...DEFAULTS.lint, ...parsed.lint },
  };
}
