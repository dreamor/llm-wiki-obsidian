# Troubleshooting

## Obsidian CLI 无响应

**症状**: 运行 `obsidian` 命令后无输出或超时。

**解决方案**:
1. 确认 Obsidian 应用正在运行（CLI 依赖应用进程）
2. 检查 Obsidian 版本 >= 1.9
3. 在 macOS 上确认授予了辅助功能权限

## CLI 未启用

**症状**: `obsidian: command not found` 或 CLI 命令不可用。

**解决方案**:
1. 打开 Obsidian → 设置 → 社区插件
2. 确认 `obsidian.json` 包含 `"cli": true`
3. 重启 Obsidian 使配置生效
4. 验证: `which obsidian` 应返回有效路径

## 权限错误

**症状**: `Permission denied` 或 `EACCES` 错误。

**解决方案**:
1. 检查 wiki 目录权限: `ls -la wiki/`
2. 修复权限: `chmod -R u+rw wiki/`
3. 如使用 git，确保 `.git/` 目录权限正确

## 配置文件格式错误

**症状**: `SyntaxError: Unexpected token` 或 lint 无法启动。

**解决方案**:
1. 验证 JSON 格式: `npx ajv validate -s config.schema.json -d config.json`
2. 检查常见问题:
   - 尾部逗号（JSON 不允许）
   - 缺少引号
   - 编码不是 UTF-8
3. 从 `config.example.json` 重新生成: `cp config.example.json config.json`

## 大型 Vault 操作超时

**症状**: Lint 或 crosslink 在大型知识库上运行缓慢。

**解决方案**:
1. 使用增量模式: `./scripts/lint.sh --incremental`
2. 使用 Node.js 版本（自动启用，性能提升 5-8x）
3. 减少检查范围: 在 `config.json` 的 `enabled_checks` 中禁用不需要的检查
4. 对于 1000+ 文件的 Vault，建议首次全量后始终使用增量模式

## Node.js 版本不可用

**症状**: lint.sh 总是走 bash fallback。

**解决方案**:
1. 确认 Node.js >= 18: `node --version`
2. 安装依赖: `npm install`
3. 验证 `src/cli.ts` 存在
4. 手动测试: `npx tsx src/cli.ts lint --help`

## 测试失败

**症状**: `scripts/test.sh` 报告 FAIL。

**解决方案**:
1. 确保在项目根目录运行
2. 检查 `scripts/lib/` 下所有库文件存在
3. 在 macOS 上确认使用 bash 4+: `bash --version`
4. 清理临时文件: `rm -rf /tmp/wiki-test-*`
