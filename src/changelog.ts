import { execSync } from "child_process";

interface ChangeEntry {
  date: string;
  hash: string;
  message: string;
  files: string[];
}

export function generateChangelog(
  sinceDate: string,
  wikiDir: string
): ChangeEntry[] {
  const log = execSync(
    `git log --since="${sinceDate}" --pretty=format:"%H|%ai|%s" -- "${wikiDir}"`,
    { encoding: "utf-8" }
  ).trim();

  if (!log) return [];

  const entries: ChangeEntry[] = [];

  for (const line of log.split("\n")) {
    const [hash, date, message] = line.split("|", 3);
    if (!hash) continue;

    const filesRaw = execSync(
      `git diff-tree --no-commit-id --name-only -r ${hash} -- "${wikiDir}"`,
      { encoding: "utf-8" }
    ).trim();

    entries.push({
      date: date.slice(0, 10),
      hash: hash.slice(0, 7),
      message,
      files: filesRaw ? filesRaw.split("\n") : [],
    });
  }

  return entries;
}

export function formatChangelog(entries: ChangeEntry[]): string {
  if (entries.length === 0) return "无变更。\n";

  const grouped = new Map<string, ChangeEntry[]>();

  for (const entry of entries) {
    const existing = grouped.get(entry.date) ?? [];
    existing.push(entry);
    grouped.set(entry.date, existing);
  }

  const lines: string[] = ["# Wiki Changelog\n"];

  for (const [date, dateEntries] of grouped) {
    lines.push(`## ${date}\n`);
    for (const entry of dateEntries) {
      lines.push(`- ${entry.message} (\`${entry.hash}\`)`);
      if (entry.files.length > 0 && entry.files.length <= 5) {
        for (const f of entry.files) {
          lines.push(`  - ${f}`);
        }
      } else if (entry.files.length > 5) {
        lines.push(`  - ${entry.files.length} 个文件变更`);
      }
    }
    lines.push("");
  }

  return lines.join("\n");
}
