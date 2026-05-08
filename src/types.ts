export interface WikiConfig {
  vault: { path: string; name: string };
  wiki: {
    raw_dir: string;
    wiki_dir: string;
    index_file: string;
    log_file: string;
    subdirs: Record<string, string>;
  };
  lint: {
    enabled_checks: string[];
    max_page_words: number;
    required_frontmatter_fields: string[];
    auto_fix: boolean;
  };
}

export type Severity = "critical" | "warning" | "info";

export interface LintIssue {
  check: string;
  severity: Severity;
  file: string;
  message: string;
  line?: number;
}

export interface LintReport {
  wiki_dir: string;
  timestamp: string;
  issues: LintIssue[];
  stats: {
    critical: number;
    warning: number;
    info: number;
    total: number;
    files_scanned: number;
  };
}

export interface WikiPage {
  path: string;
  name: string;
  category: string;
  frontmatter: Record<string, unknown>;
  links: string[];
  wordCount: number;
}

export interface WikiIndex {
  pages: Map<string, WikiPage>;
  links: Map<string, string[]>;
  backlinks: Map<string, string[]>;
}
