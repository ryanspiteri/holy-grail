#!/usr/bin/env bash
# bootstrap.sh - detect holy-grail's dependencies, auto-install the free ones,
# and write a capability map the skill reads at Phase 0.
#
# Run by install.sh and re-run by the skill when the map is missing or stale.
# Never installs licensed/keyed tooling (gstack, codex). Only detects them.
# Safe to run repeatedly. Exits 0 even when optional deps are missing.

set -u

HG_HOME="${HOME}/.holy-grail"
CAP_FILE="${HG_HOME}/capabilities.json"
PLUGINS_DIR="${HOME}/.claude/plugins"
SKILLS_DIR="${HOME}/.claude/skills"
mkdir -p "${HG_HOME}"

have() { command -v "$1" >/dev/null 2>&1; }
json_bool() { if [ "$1" = "1" ]; then printf "true"; else printf "false"; fi; }

# --- detect superpowers (free, official, auto-installable) ---
SUPERPOWERS=0
if grep -q "superpowers" "${PLUGINS_DIR}/installed_plugins.json" 2>/dev/null; then
  SUPERPOWERS=1
elif ls -d "${PLUGINS_DIR}"/cache/*/superpowers 2>/dev/null | grep -q .; then
  SUPERPOWERS=1
fi

# --- detect gstack (licensed: detect only, never install) ---
GSTACK=0
[ -d "${SKILLS_DIR}/gstack" ] && GSTACK=1

# --- detect codex (key-required: detect only, never install) ---
CODEX=0
if have codex || [ -f "${HOME}/.codex/auth.json" ] || [ -n "${OPENAI_API_KEY:-}${CODEX_API_KEY:-}" ]; then
  CODEX=1
fi

# --- detect a drivable browser (for the design/QA fallback) ---
BROWSER=0
if [ "${GSTACK}" = "1" ]; then
  BROWSER=1
elif have google-chrome || have chromium || have chromium-browser \
  || [ -d "/Applications/Google Chrome.app" ] || [ -d "/Applications/Chromium.app" ]; then
  BROWSER=1
fi

# --- detect ruflo memory (optional; usually an MCP server, so check MCP configs) ---
RUFLO=0
if have ruflo || [ -f "${PWD}/.swarm/memory.db" ] \
  || grep -qs "ruflo" "${HOME}/.claude.json" "${HOME}/.claude/settings.json" "${HOME}/.claude/.mcp.json" "${PWD}/.mcp.json" \
  || grep -q "ruflo" "${PLUGINS_DIR}/installed_plugins.json" 2>/dev/null; then
  RUFLO=1
fi

# --- detect git ---
GIT=0
have git && GIT=1

# --- auto-install superpowers if missing (best effort, non-fatal) ---
INSTALL_NOTE=""
if [ "${SUPERPOWERS}" = "0" ]; then
  if have claude && claude plugin install superpowers@claude-plugins-official >/dev/null 2>&1; then
    SUPERPOWERS=1
    INSTALL_NOTE="installed superpowers automatically"
  else
    INSTALL_NOTE="superpowers missing - run this in Claude Code: /plugin install superpowers@claude-plugins-official"
  fi
fi

# --- write the capability map ---
cat > "${CAP_FILE}" <<EOF
{
  "superpowers": $(json_bool "${SUPERPOWERS}"),
  "codex": $(json_bool "${CODEX}"),
  "gstack": $(json_bool "${GSTACK}"),
  "browser": $(json_bool "${BROWSER}"),
  "ruflo": $(json_bool "${RUFLO}"),
  "git": $(json_bool "${GIT}"),
  "updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

# --- one-line report ---
mode="enhanced"
[ "${SUPERPOWERS}" = "0" ] && mode="fallback"
echo "holy-grail capabilities: superpowers=$(json_bool ${SUPERPOWERS}) codex=$(json_bool ${CODEX}) gstack=$(json_bool ${GSTACK}) browser=$(json_bool ${BROWSER}) ruflo=$(json_bool ${RUFLO})"
echo "mode: ${mode}  (map written to ${CAP_FILE})"
[ -n "${INSTALL_NOTE}" ] && echo "note: ${INSTALL_NOTE}"
echo "licensed tools (gstack, codex) are detected only, never installed - holy-grail uses its built-in fallback when they are absent."
exit 0
