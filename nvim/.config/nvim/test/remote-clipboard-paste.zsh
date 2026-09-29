#!/bin/zsh
# Regression test for the remote_clipboard OSC 52 paste stall.
# Must be run from inside a herdr pane (HERDR_PANE_ID set) for the test to be
# meaningful; outside one the provider is never installed.
set -u

LUA_PROBE="${TMPDIR:-/tmp}/osc52_paste_probe.lua"
RESULT="${TMPDIR:-/tmp}/osc52_paste_probe_result.txt"
MAX_MS=200
PROBE_TEXT="PROBE-TEXT"

cat > "$LUA_PROBE" <<'LUA'
local f = assert(io.open(os.getenv("PROBE_RESULT"), "w"))
f:write("provider=" .. tostring(vim.g.clipboard and vim.g.clipboard.name) .. "\n")
f:write("herdr_pane=" .. tostring(vim.env.HERDR_PANE_ID) .. "\n")

vim.fn.system({ "pbcopy" }, vim.env.PROBE_TEXT)
vim.opt.clipboard = "unnamedplus"

-- paste path: `p` must bring in the system clipboard, fast
vim.cmd("enew!")
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
vim.api.nvim_win_set_cursor(0, { 1, 0 })
local t0 = vim.uv.hrtime()
vim.cmd("normal! p")
local paste_ms = (vim.uv.hrtime() - t0) / 1e6
f:write(string.format("paste_ms=%.0f\n", paste_ms))
f:write("pasted=" .. tostring(vim.api.nvim_buf_get_lines(0, 0, -1, false)[1]) .. "\n")

-- copy path: yanking must reach the system clipboard
vim.api.nvim_buf_set_lines(0, 0, -1, false, { vim.env.PROBE_TEXT .. "-YANK" })
vim.api.nvim_win_set_cursor(0, { 1, 0 })
local t1 = vim.uv.hrtime()
vim.cmd('normal! "+yy')
f:write(string.format("copy_ms=%.0f\n", (vim.uv.hrtime() - t1) / 1e6))

f:close()
vim.cmd("q!")
LUA

PROBE_RESULT="$RESULT" PROBE_TEXT="$PROBE_TEXT" \
  script -q /dev/null nvim -c "luafile $LUA_PROBE" >/dev/null 2>&1

yanked=$(pbpaste)

provider=$(sed -n 's/^provider=//p' "$RESULT")
paste_ms=$(sed -n 's/^paste_ms=//p' "$RESULT")
copy_ms=$(sed -n 's/^copy_ms=//p' "$RESULT")
pasted=$(sed -n 's/^pasted=//p' "$RESULT")

paste_fast=$(awk "BEGIN{print ($paste_ms < $MAX_MS) ? \"yes\" : \"no\"}")
paste_ok=$([ "$pasted" = "$PROBE_TEXT" ] && echo yes || echo no)
copy_ok=$([ "$yanked" = "$PROBE_TEXT-YANK" ] && echo yes || echo no)

print "provider=${provider} paste=${paste_ms}ms copy=${copy_ms}ms"
print "  paste fast (<${MAX_MS}ms): ${paste_fast}"
print "  paste content '${pasted}': ${paste_ok}"
print "  yank reached pbpaste '${yanked}': ${copy_ok}"

if [ "$paste_fast" = yes ] && [ "$paste_ok" = yes ] && [ "$copy_ok" = yes ]; then
  print "PASS"
  exit 0
fi
print "FAIL"
exit 1
