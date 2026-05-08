import { statSync } from "fs";
import type { WikiIndex, LintIssue } from "../types.js";

const NINETY_DAYS_MS = 90 * 24 * 60 * 60 * 1000;

export function checkStalePages(index: WikiIndex): LintIssue[] {
  const issues: LintIssue[] = [];
  const now = Date.now();

  for (const [name, page] of index.pages) {
    if (page.category === "root") continue;

    const stat = statSync(page.path);
    const ageMs = now - stat.mtimeMs;

    if (ageMs < NINETY_DAYS_MS) continue;

    const hasInlinks = (index.backlinks.get(name) ?? []).length > 0;
    if (hasInlinks) continue;

    const daysOld = Math.floor(ageMs / (24 * 60 * 60 * 1000));
    issues.push({
      check: "stale_pages",
      severity: "info",
      file: page.path,
      message: `陈旧页面: ${name} (${daysOld} 天未更新，0 入链，建议归档)`,
    });
  }

  return issues;
}
