#!/usr/bin/env bash
# bootstrap.sh - detect holy-grail's dependencies and (with --install-deps) install them.
#
# Two modes:
#   bootstrap.sh                -> DETECT ONLY. Pure, no side effects. Safe to run any time,
#                                  including from the skill at Phase 0. Writes capabilities.json.
#   bootstrap.sh --install-deps -> DETECT + INSTALL the missing dependencies, then re-detect.
#                                  Run by install.sh (an explicit user action). Heavier:
#                                  installs superpowers (plugin), gstack (git clone + setup),
#                                  and the codex CLI (npm). Never runs during a normal task.
#
# All installs are best effort and non-fatal. Everything has a fallback in the skill, so a
# failed install never breaks holy-grail. codex still needs the user's own `codex login`.

set -u

INSTALL_DEPS=0
[ "${1:-}" = "--install-deps" ] && INSTALL_DEPS=1

HG_HOME="${HOME}/.holy-grail"
CAP_FILE="${HG_HOME}/capabilities.json"
PLUGINS_DIR="${HOME}/.claude/plugins"
SKILLS_DIR="${HOME}/.claude/skills"
GSTACK_DIR="${SKILLS_DIR}/gstack"
mkdir -p "${HG_HOME}"

have() { command -v "$1" >/dev/null 2>&1; }
json_bool() { if [ "$1" = "1" ]; then printf "true"; else printf "false"; fi; }

detect() {
  SUPERPOWERS=0
  if grep -q "superpowers" "${PLUGINS_DIR}/installed_plugins.json" 2>/dev/null \
    || ls -d "${PLUGINS_DIR}"/cache/*/superpowers 2>/dev/null | grep -q .; then SUPERPOWERS=1; fi

  GSTACK=0
  [ -d "${GSTACK_DIR}" ] && GSTACK=1

  # The skill invokes the codex CLI, so the usable flag requires BOTH the CLI and auth.
  CODEX_CLI=0; have codex && CODEX_CLI=1
  CODEX_AUTH=0; { [ -f "${HOME}/.codex/auth.json" ] || [ -n "${OPENAI_API_KEY:-}${CODEX_API_KEY:-}" ]; } && CODEX_AUTH=1
  CODEX=0; [ "${CODEX_CLI}" = "1" ] && [ "${CODEX_AUTH}" = "1" ] && CODEX=1

  BROWSER=0
  if [ "${GSTACK}" = "1" ] || have google-chrome || have chromium || have chromium-browser \
    || [ -d "/Applications/Google Chrome.app" ] || [ -d "/Applications/Chromium.app" ]; then BROWSER=1; fi

  RUFLO=0
  if have ruflo \
    || grep -qs "ruflo" "${HOME}/.claude.json" "${HOME}/.claude/settings.json" "${HOME}/.claude/.mcp.json" \
    || grep -q "ruflo" "${PLUGINS_DIR}/installed_plugins.json" 2>/dev/null; then RUFLO=1; fi

  GIT=0; have git && GIT=1
}

NOTES=""
note() { NOTES="${NOTES}\n  - $1"; }

detect

if [ "${INSTALL_DEPS}" = "1" ]; then
  echo "Installing holy-grail dependencies (best effort, non-fatal)..."

  # 1. superpowers (free official plugin)
  if [ "${SUPERPOWERS}" = "0" ]; then
    if have claude && claude plugin install superpowers@claude-plugins-official >/dev/null 2>&1; then
      note "superpowers: installed"
    else
      note "superpowers: install in Claude Code -> /plugin install superpowers@claude-plugins-official"
    fi
  fi

  # 2. gstack (MIT, public repo; same method as /gstack-upgrade: clone + setup)
  if [ "${GSTACK}" = "0" ]; then
    if have git; then
      _TMP="$(mktemp -d)"
      # NOTE: --depth 1 clones unpinned HEAD (no tag/commit pin) - known supply-chain note.
      if git clone --depth 1 https://github.com/garrytan/gstack.git "${_TMP}/gstack" >/dev/null 2>&1; then
        mkdir -p "${SKILLS_DIR}"
        mv "${_TMP}/gstack" "${GSTACK_DIR}"
        if [ -x "${GSTACK_DIR}/setup" ]; then
          # stdin from /dev/null + timeout so an interactive prompt cannot hang the installer.
          if have timeout; then
            ( cd "${GSTACK_DIR}" && timeout 300 ./setup </dev/null >/dev/null 2>&1 ) && note "gstack: installed + setup ran" || note "gstack: cloned, but ./setup failed - run 'cd ${GSTACK_DIR} && ./setup'"
          else
            ( cd "${GSTACK_DIR}" && ./setup </dev/null >/dev/null 2>&1 ) && note "gstack: installed + setup ran" || note "gstack: cloned, but ./setup failed - run 'cd ${GSTACK_DIR} && ./setup'"
          fi
        else
          note "gstack: cloned (no setup script found)"
        fi
      else
        note "gstack: clone failed - install manually: git clone https://github.com/garrytan/gstack.git ${GSTACK_DIR} && cd ${GSTACK_DIR} && ./setup"
      fi
      rm -rf "${_TMP}"
    else
      note "gstack: needs git (not found) - install git then re-run"
    fi
  fi

  # 3. codex CLI (OpenAI's @openai/codex; binary installs, but user must run 'codex login')
  if ! have codex; then
    if have npm; then
      npm install -g @openai/codex >/dev/null 2>&1 && note "codex CLI: installed (now run: codex login)" || note "codex CLI: npm install failed - try 'brew install codex' or 'npm i -g @openai/codex'"
    elif have brew; then
      brew install codex >/dev/null 2>&1 && note "codex CLI: installed (now run: codex login)" || note "codex CLI: brew install failed"
    else
      note "codex CLI: needs npm or brew - install one, then 'npm i -g @openai/codex'"
    fi
  fi

  detect  # re-detect after installs
fi

cat > "${CAP_FILE}" <<EOF
{
  "superpowers": $(json_bool "${SUPERPOWERS}"),
  "codex": $(json_bool "${CODEX}"),
  "codex_cli": $(json_bool "${CODEX_CLI}"),
  "codex_auth": $(json_bool "${CODEX_AUTH}"),
  "gstack": $(json_bool "${GSTACK}"),
  "browser": $(json_bool "${BROWSER}"),
  "ruflo": $(json_bool "${RUFLO}"),
  "git": $(json_bool "${GIT}"),
  "updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

mode="enhanced"; [ "${SUPERPOWERS}" = "0" ] && mode="fallback"
echo "holy-grail capabilities: superpowers=$(json_bool ${SUPERPOWERS}) codex=$(json_bool ${CODEX}) gstack=$(json_bool ${GSTACK}) browser=$(json_bool ${BROWSER}) ruflo=$(json_bool ${RUFLO})"
echo "mode: ${mode}  (map written to ${CAP_FILE})"
[ -n "${NOTES}" ] && printf "install notes:${NOTES}\n"
if [ "${CODEX_CLI}" = "1" ] && [ "${CODEX_AUTH}" = "0" ]; then
  echo "codex CLI is installed but not logged in. Run 'codex login' to activate the codex review (until then holy-grail uses its built-in red-team review)."
fi
exit 0
