import type { WikiIndex, LintIssue } from "../types.js";

const SPECIAL_PAGES = new Set(["index", "log"]);

export function checkOrphanPages(index: WikiIndex): LintIssue[] {
  const issues: LintIssue[] = [];

  for (const [name, page] of index.pages) {
    if (SPECIAL_PAGES.has(name)) continue;
    if (page.category === "root") continue;

    const incomingLinks = index.backlinks.get(name) ?? [];
    if (incomingLinks.length === 0) {
      issues.push({
        check: "orphan_pages",
        severity: "warning",
        file: page.path,
        message: `孤立页面: ${name} (无入链)`,
      });
    }
  }

  return issues;
}
