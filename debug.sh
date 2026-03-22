echo "=== NanoClaw Diagnostics ==="
 
echo -e "\n1. Authentication configured?"
[ -f .env ] && (grep -q "CLAUDE_CODE_OAUTH_TOKEN=sk-" .env || grep -q "ANTHROPIC_API_KEY=sk-" .env) && echo "✓ OK" || echo "✗ MISSING - add CLAUDE_CODE_OAUTH_TOKEN or ANTHROPIC_API_KEY to .env"
 
echo -e "\n2. Env file for container?"
[ -f data/env/env ] && echo "✓ OK" || echo "⚠ MISSING - created on first run"
 
echo -e "\n3. Container runtime?"
container system status &>/dev/null && echo "✓ container running" || echo "✗ NOT RUNNING - start container Desktop (macOS) or sudo systemctl start container (Linux)"
 
echo -e "\n4. Container image?"
container image ls | grep -q nanoclaw-agent && echo "✓ Image exists" || echo "✗ MISSING - run ./container/build.sh"
 
echo -e "\n5. Session mount path?"
grep -q "/home/node/.claude" src/container-runner.ts && echo "✓ Correct (/home/node/.claude)" || echo "✗ WRONG - should be /home/node/.claude, not /root/.claude"
 
echo -e "\n6. Groups directory?"
[ -d groups ] && echo "✓ $(ls groups | wc -l) groups" || echo "✗ MISSING - run setup"
 
echo -e "\n7. Recent container logs?"
if ls -t groups/*/logs/container-*.log 2>/dev/null | head -3 &>/dev/null; then
  echo "✓ Found:"
  ls -t groups/*/logs/container-*.log 2>/dev/null | head -3
else
  echo "⚠ No logs yet"
fi
 
echo -e "\n8. Service status?"
if command -v launchctl &>/dev/null; then
  launchctl list | grep -q nanoclaw && echo "✓ Running (macOS)" || echo "✗ Not loaded"
elif command -v systemctl &>/dev/null; then
  systemctl --user is-active --quiet nanoclaw && echo "✓ Running (Linux)" || echo "✗ Not running"
else
  echo "⚠ Unknown init system"
fi
 
echo -e "\n9. Database accessible?"
if [ -f store/messages.db ]; then
  MSG_COUNT=$(sqlite3 store/messages.db "SELECT COUNT(*) FROM messages" 2>/dev/null)
  echo "✓ $MSG_COUNT messages stored"
else
  echo "✗ Database missing"
fi
 
echo -e "\n10. Session continuity?"
if [ -f logs/nanoclaw.log ]; then
  UNIQUE_SESSIONS=$(grep "Session initialized" logs/nanoclaw.log 2>/dev/null | tail -10 | awk '{print $NF}' | sort -u | wc -l)
  [ "$UNIQUE_SESSIONS" -le 3 ] && echo "✓ Sessions being reused" || echo "⚠ Many unique sessions, check resumption"
else
  echo "⚠ No logs yet"
fi