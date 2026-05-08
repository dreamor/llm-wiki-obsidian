import type { WikiIndex, LintIssue } from "../types.js";

const SPECIAL_PAGES = new Set(["index", "log"]);

export function checkFrontmatter(
  index: WikiIndex,
  options: { requiredFields: string[] }
): LintIssue[] {
  const issues: LintIssue[] = [];

  for (const [name, page] of index.pages) {
    if (SPECIAL_PAGES.has(name)) continue;
    if (page.category === "root") continue;

    if (Object.keys(page.frontmatter).length === 0) {
      issues.push({
        check: "frontmatter",
        severity: "warning",
        file: page.path,
        message: `缺少 frontmatter: ${name}`,
      });
      continue;
    }

    for (const field of options.requiredFields) {
      if (!(field in page.frontmatter)) {
        issues.push({
          check: "frontmatter",
          severity: "warning",
          file: page.path,
          message: `缺少字段 '${field}': ${name}`,
        });
      }
    }
  }

  return issues;
}
