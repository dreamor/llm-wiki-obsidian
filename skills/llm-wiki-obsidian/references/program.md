# AutoResearch Program — 研究配置

自定义 `/autoresearch` 命令的行为。编辑此文件调整研究偏好。

## 来源偏好

按优先级排列：

1. **官方文档** — 项目官网、API 文档、官方博客
2. **学术论文** — arXiv、ACL、NeurIPS、ICML
3. **技术博客** — 知名工程师/研究者的博客
4. **行业报告** — Gartner、McKinsey 等
5. **社区讨论** — Reddit、Hacker News、Stack Overflow（仅作补充）

## 置信度规则

| 条件 | 置信度调整 |
|------|-----------|
| 来源有同行评审 | +1 |
| 来源来自官方渠道 | +1 |
| 来源超过 2 年 | -1 |
| 来源无引用/参考 | -1 |
| 与多个独立来源一致 | +1 |
| 与已有 Wiki 矛盾 | 0（标注矛盾，不调整） |

**摄入阈值**：置信度 ≥ 中（低于中的来源不摄入，仅记录）

## 研究约束

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `max_rounds` | 3 | 最大研究轮次 |
| `max_pages_per_round` | 10 | 每轮最大抓取页面数 |
| `min_sources` | 3 | 最少摄入来源数 |
| `max_sources` | 15 | 最多摄入来源数 |
| `deep_mode_rounds` | 5 | `--deep` 模式轮次 |
| `quick_mode_rounds` | 1 | `--quick` 模式轮次 |

## 领域特定覆盖

### LLM/AI 领域（当前默认）
- 优先：Hugging Face、OpenAI、Anthropic 官方文档
- 优先：arXiv 上的 LLM 相关论文
- 排除：纯营销内容、无技术细节的新闻稿

### 机器学习领域
- 优先：Papers With Code、Google Research、DeepMind Blog
- 优先：顶级会议论文（NeurIPS、ICML、ICLR）

### 产品构思
- 优先：Product Hunt、Indie Hackers、Y Combinator Blog
- 优先：竞品分析报告

---

## 使用方式

在 `/autoresearch` 命令前，先编辑此文件调整研究偏好。例如：

```
# 临时调整为医学研究
请先更新 program.md：来源偏好改为"优先 PubMed 和 Cochrane"，置信度阈值改为"高"，
然后执行 /autoresearch [医学主题]
```