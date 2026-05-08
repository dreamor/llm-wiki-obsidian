import type { WikiIndex, LintIssue } from "../types.js";

export function checkDeadLinks(index: WikiIndex): LintIssue[] {
  const issues: LintIssue[] = [];

  for (const [pageName, pageLinks] of index.links) {
    for (const link of pageLinks) {
      if (!index.pages.has(link)) {
        issues.push({
          check: "dead_links",
          severity: "critical",
          file: pageName,
          message: `死链接: [[${link}]]`,
        });
      }
    }
  }

  return issues;
}
