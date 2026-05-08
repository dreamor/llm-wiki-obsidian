import type { WikiIndex, LintIssue } from "../types.js";

export function checkIndexCompleteness(index: WikiIndex): LintIssue[] {
  const issues: LintIssue[] = [];

  const indexPage = index.pages.get("index");
  if (!indexPage) {
    issues.push({
      check: "index_completeness",
      severity: "critical",
      file: "index.md",
      message: "index.md 不存在",
    });
    return issues;
  }

  const indexedLinks = new Set(indexPage.links);

  for (const [name, page] of index.pages) {
    if (page.category === "root") continue;
    if (!indexedLinks.has(name)) {
      issues.push({
        check: "index_completeness",
        severity: "warning",
        file: page.path,
        message: `索引缺失: ${name} (在 ${page.category}/)`,
      });
    }
  }

  return issues;
}
