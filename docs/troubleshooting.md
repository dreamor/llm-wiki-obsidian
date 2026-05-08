# Troubleshooting

## Obsidian CLI Not Responding

**Symptom**: Running `obsidian` commands produces no output or times out.

**Solution**:
1. Confirm Obsidian app is running (CLI depends on the app process)
2. Check Obsidian version >= 1.9
3. On macOS, ensure accessibility permissions are granted

## CLI Not Enabled

**Symptom**: `obsidian: command not found` or CLI commands unavailable.

**Solution**:
1. Open Obsidian → Settings → Community Plugins
2. Confirm `obsidian.json` contains `"cli": true`
3. Restart Obsidian for config to take effect
4. Verify: `which obsidian` should return a valid path

## Permission Errors

**Symptom**: `Permission denied` or `EACCES` errors.

**Solution**:
1. Check wiki directory permissions: `ls -la wiki/`
2. Fix permissions: `chmod -R u+rw wiki/`
3. If using git, ensure `.git/` directory permissions are correct

## Config File Format Errors

**Symptom**: `SyntaxError: Unexpected token` or lint fails to start.

**Solution**:
1. Validate JSON format: `npx ajv validate -s config.schema.json -d config.json`
2. Common issues:
   - Trailing commas (not allowed in JSON)
   - Missing quotes
   - Encoding is not UTF-8
3. Regenerate from example: `cp config.example.json config.json`

## Large Vault Timeouts

**Symptom**: Lint or crosslink runs slowly on large knowledge bases.

**Solution**:
1. Use incremental mode: `./scripts/lint.sh --incremental`
2. Use Node.js version (auto-enabled, 5-8x faster)
3. Reduce check scope: disable unneeded checks in `config.json` `enabled_checks`
4. For 1000+ file vaults, always use incremental mode after the initial full scan

## Node.js Version Not Available

**Symptom**: `lint.sh` always falls back to bash.

**Solution**:
1. Confirm Node.js >= 18: `node --version`
2. Install dependencies: `npm install`
3. Verify `src/cli.ts` exists
4. Manual test: `npx tsx src/cli.ts lint --help`

## Test Failures

**Symptom**: `scripts/test.sh` reports FAIL.

**Solution**:
1. Ensure you run from the project root
2. Check all library files exist under `scripts/lib/`
3. On macOS, confirm bash 4+: `bash --version`
4. Clean temp files: `rm -rf /tmp/wiki-test-*`
