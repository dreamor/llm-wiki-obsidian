import type { WikiIndex, LintIssue } from "../types.js";
import { checkDeadLinks } from "./dead-links.js";
import { checkOrphanPages } from "./orphan-pages.js";
import { checkFrontmatter } from "./frontmatter.js";
import { checkLargePages } from "./large-pages.js";
import { checkIndexCompleteness } from "./index-completeness.js";
import { checkMissingConcepts } from "./missing-concepts.js";
import { checkContradictions } from "./contradictions.js";
import { checkStalePages } from "./stale-pages.js";

export type CheckFn = (
  index: WikiIndex,
  options: { maxWords: number; requiredFields: string[]; wikiDir: string }
) => LintIssue[];

export const ALL_CHECKS: Record<string, CheckFn> = {
  dead_links: checkDeadLinks,
  orphan_pages: checkOrphanPages,
  frontmatter: checkFrontmatter,
  large_pages: checkLargePages,
  index_completeness: checkIndexCompleteness,
  missing_concepts: checkMissingConcepts,
  contradictions: checkContradictions,
  stale_pages: checkStalePages,
};
