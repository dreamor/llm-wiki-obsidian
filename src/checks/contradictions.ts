import { readFileSync } from "fs";
import type { WikiIndex, LintIssue } from "../types.js";

const CONTRADICTION_RE = /⚠️|矛盾|冲突|contradict/i;

export function checkContradictions(index: WikiIndex): LintIssue[] {
  const issues: LintIssue[] = [];

  for (const [name, page] of index.pages) {
    if (page.category === "root") continue;

    const content = readFileSync(page.path, "utf-8");
    const lines = content.split("\n");

    for (let i = 0; i < lines.length; i++) {
      if (CONTRADICTION_RE.test(lines[i])) {
        issues.push({
          check: "contradictions",
          severity: "warning",
          file: page.path,
          message: `矛盾标记: ${name}`,
          line: i + 1,
        });
      }
    }
  }

  return issues;
}
