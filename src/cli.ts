#!/usr/bin/env node

import { Command } from "commander";
import { resolve } from "path";
import { loadConfig } from "./config.js";
import { buildIndex } from "./scanner.js";
import { ALL_CHECKS } from "./checks/index.js";
import type { LintIssue, LintReport } from "./types.js";

const program = new Command();

program
  .name("wiki-lint")
  .description("LLM Wiki Obsidian 知识库管理工具")
  .version("1.2.0");

program
  .command("lint")
  .description("执行知识库健康检查")
  .option("-c, --config <path>", "配置文件路径")
  .option("-w, --wiki <dir>", "Wiki 目录路径")
  .option("--fix", "尝试自动修复")
  .option("--dry-run", "预览修复操作，不实际修改文件")
  .option("-v, --verbose", "详细输出")
  .option("--json", "JSON 格式输出")
  .action((opts) => {
    const config = loadConfig(opts.config);
    const wikiDir = resolve(opts.wiki ?? config.wiki.wiki_dir);
    const index = buildIndex(wikiDir);

    const issues: LintIssue[] = [];
    const checkOptions = {
      maxWords: config.lint.max_page_words,
      requiredFields: config.lint.required_frontmatter_fields,
      wikiDir,
    };

    for (const checkName of config.lint.enabled_checks) {
      const checkFn = ALL_CHECKS[checkName];
      if (!checkFn) continue;
      issues.push(...checkFn(index, checkOptions));
    }

    const report: LintReport = {
      wiki_dir: wikiDir,
      timestamp: new Date().toISOString(),
      issues,
      stats: {
        critical: issues.filter((i) => i.severity === "critical").length,
        warning: issues.filter((i) => i.severity === "warning").length,
        info: issues.filter((i) => i.severity === "info").length,
        total: issues.length,
        files_scanned: index.pages.size,
      },
    };

    if (opts.json) {
      process.stdout.write(JSON.stringify(report, null, 2) + "\n");
    } else {
      printReport(report, opts.verbose ?? false);
    }

    if (report.stats.critical > 0) process.exit(1);
  });

function printReport(report: LintReport, verbose: boolean): void {
  const COLORS = {
    red: "\x1b[0;31m",
    green: "\x1b[0;32m",
    yellow: "\x1b[1;33m",
    blue: "\x1b[0;34m",
    bold: "\x1b[1m",
    nc: "\x1b[0m",
  };

  console.log(
    `${COLORS.bold}═══ Wiki Lint 报告 ═══${COLORS.nc}`
  );
  console.log(`Wiki 目录: ${report.wiki_dir}`);
  console.log(`检查时间: ${report.timestamp}`);
  console.log(`文件数量: ${report.stats.files_scanned}`);
  console.log();

  if (report.issues.length === 0) {
    console.log(`${COLORS.green}所有检查通过！${COLORS.nc}`);
    return;
  }

  const grouped = new Map<string, typeof report.issues>();
  for (const issue of report.issues) {
    const existing = grouped.get(issue.check) ?? [];
    existing.push(issue);
    grouped.set(issue.check, existing);
  }

  for (const [check, checkIssues] of grouped) {
    console.log(`${COLORS.bold}[${check}]${COLORS.nc}`);
    for (const issue of checkIssues) {
      const color =
        issue.severity === "critical"
          ? COLORS.red
          : issue.severity === "warning"
            ? COLORS.yellow
            : COLORS.blue;
      const loc = issue.line ? `:${issue.line}` : "";
      const file = issue.file ? ` ${issue.file}${loc}` : "";
      console.log(`  ${color}${issue.severity.toUpperCase()}${COLORS.nc}${file}`);
      if (verbose) {
        console.log(`    ${issue.message}`);
      }
    }
    console.log();
  }

  console.log("--- 统计 ---");
  console.log(`${COLORS.red}严重: ${report.stats.critical}${COLORS.nc}`);
  console.log(`${COLORS.yellow}警告: ${report.stats.warning}${COLORS.nc}`);
  console.log(`${COLORS.blue}信息: ${report.stats.info}${COLORS.nc}`);
  console.log(`总计: ${report.stats.total}`);

  if (report.stats.critical > 0) {
    console.log(`\n${COLORS.red}状态: 需要立即修复${COLORS.nc}`);
  } else if (report.stats.warning > 0) {
    console.log(`\n${COLORS.yellow}状态: 建议修复${COLORS.nc}`);
  } else {
    console.log(`\n${COLORS.green}状态: 健康${COLORS.nc}`);
  }
}

program.parse();
