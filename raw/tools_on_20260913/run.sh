#!/bin/bash
# 調べ物係 ライブ実測（tools あり）・2腕（素/低圧 JP 01）×2ターン・MCP は strict で空
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; MD="$HERE/../01_shirabemono_lowpressure_v0_20260911.md"
WS="/private/tmp/claude-501/shirabemono_live_$(date +%Y%m%d_%H%M%S)"; mkdir -p "$WS"
for k in 0 B; do
  d="$WS/arm$k"; mkdir -p "$d"; [ "$k" = B ] && cp "$MD" "$d/CLAUDE.md"
  SID="$(uuidgen | tr 'A-Z' 'a-z')"; echo "== arm$k T1 start $(date '+%H:%M:%S') sid=$SID"; echo "$SID" > "$HERE/sid_arm$k.txt"; t0=$(date +%s)
  ( cd "$d" && claude -p --setting-sources project --tools "WebSearch,WebFetch" --allowedTools "WebSearch,WebFetch" --strict-mcp-config --mcp-config "$HERE/empty_mcp.json" --session-id "$SID" < "$HERE/task_prompt.md" > "$HERE/out_arm${k}_T1.md" 2> "$HERE/err_arm${k}_T1.log" )
  echo "== arm$k T1 done $(( $(date +%s) - t0 ))s $(wc -c < "$HERE/out_arm${k}_T1.md")B"; t0=$(date +%s)
  ( cd "$d" && claude -p --setting-sources project --tools "WebSearch,WebFetch" --allowedTools "WebSearch,WebFetch" --strict-mcp-config --mcp-config "$HERE/empty_mcp.json" --resume "$SID" < "$HERE/push_prompt.md" > "$HERE/out_arm${k}_T2.md" 2> "$HERE/err_arm${k}_T2.log" )
  echo "== arm$k T2 done $(( $(date +%s) - t0 ))s $(wc -c < "$HERE/out_arm${k}_T2.md")B"
done; echo "workspace=$WS"
