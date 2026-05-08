import type { WikiIndex, LintIssue } from "../types.js";

export function checkMissingConcepts(index: WikiIndex): LintIssue[] {
  const issues: LintIssue[] = [];

  const linkCounts = new Map<string, number>();

  for (const [, pageLinks] of index.links) {
    for (const link of pageLinks) {
      linkCounts.set(link, (linkCounts.get(link) ?? 0) + 1);
    }
  }

  for (const [link, count] of linkCounts) {
    if (count >= 3 && !index.pages.has(link)) {
      issues.push({
        check: "missing_concepts",
        severity: "info",
        file: "",
        message: `建议创建: [[${link}]] (被引用 ${count} 次)`,
      });
    }
  }

  return issues;
}
