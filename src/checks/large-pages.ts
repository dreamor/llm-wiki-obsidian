import type { WikiIndex, LintIssue } from "../types.js";

export function checkLargePages(
  index: WikiIndex,
  options: { maxWords: number }
): LintIssue[] {
  const issues: LintIssue[] = [];

  for (const [name, page] of index.pages) {
    if (page.category === "root") continue;

    if (page.wordCount > options.maxWords) {
      issues.push({
        check: "large_pages",
        severity: "info",
        file: page.path,
        message: `大页面: ${name} (${page.wordCount} 词，建议拆分)`,
      });
    }
  }

  return issues;
}
