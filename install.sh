#!/usr/bin/env bash
# install.sh - install holy-grail for the current user.
#
# Two install modes:
#   1. Plugin (recommended): add this repo as a marketplace and install via /plugin.
#   2. Local skill (simplest): symlink the skill into ~/.claude/skills so it is
#      discovered immediately as a user skill.
#
# Then runs bootstrap to detect/auto-install free dependencies.

set -u

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="${REPO_DIR}/skills/holy-grail"
SKILL_DEST="${HOME}/.claude/skills/holy-grail"

echo "holy-grail installer"
echo "repo: ${REPO_DIR}"
echo ""

# --- local skill install (symlink) ---
mkdir -p "${HOME}/.claude/skills"
if [ -e "${SKILL_DEST}" ] && [ ! -L "${SKILL_DEST}" ]; then
  echo "warning: ${SKILL_DEST} exists and is not a symlink. Leaving it alone."
else
  ln -sfn "${SKILL_SRC}" "${SKILL_DEST}"
  echo "linked skill: ${SKILL_DEST} -> ${SKILL_SRC}"
fi

echo ""
echo "To use it as a shareable plugin instead, run inside Claude Code:"
echo "  /plugin marketplace add <git-url-of-this-repo>"
echo "  /plugin install holy-grail"
echo ""

# --- detect + INSTALL deps (superpowers + gstack + codex CLI), write capability map ---
bash "${REPO_DIR}/scripts/bootstrap.sh" --install-deps

echo ""
echo "done. Start a new Claude Code session, then say: upgrade <something>"
echo "(If codex was just installed, run 'codex login' once to activate the codex review.)"

# --- truthful finish: read back the capability map and report the real mode ---
CAP_FILE="${HOME}/.holy-grail/capabilities.json"
sp_active=0; cx_active=0
if [ -f "${CAP_FILE}" ]; then
  grep -q '"superpowers": true' "${CAP_FILE}" && sp_active=1
  grep -q '"codex": true' "${CAP_FILE}" && cx_active=1
fi
echo ""
if [ "${sp_active}" = "1" ] && [ "${cx_active}" = "1" ]; then
  echo "MODE: enhanced"
else
  echo "MODE: FALLBACK (superpowers and/or codex not active; holy-grail will use built-in fallbacks). Run /plugin install superpowers@claude-plugins-official and/or codex login to enable enhanced mode."
fi
