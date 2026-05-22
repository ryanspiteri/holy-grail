# Dependencies

holy-grail is self-contained. It works with nothing else installed, and gets better when the ecosystem is present. It never bundles or installs licensed tooling. No em-dashes in this file.

`scripts/bootstrap.sh` detects what you have and writes `~/.holy-grail/capabilities.json`. The skill reads that at the start of every run and routes each step to the native skill or to its built-in fallback in `skills/holy-grail/references/fallbacks.md`.

## Tier 1 - Core (required: none)

The whole pipeline runs on built-in Claude Code tools plus subagents. No external skill is required. If you install nothing, holy-grail still writes the brief, plans, builds with a per-task subagent loop, reviews with an internal adversarial pass and an expert panel, verifies, and self-learns.

## Tier 2 - Auto-installed (free, official)

- **superpowers** (`superpowers@claude-plugins-official`): higher-quality brainstorming, plan writing, subagent-driven build, TDD, code-review, and verification skills. bootstrap installs it automatically if missing. If the automatic install cannot run, bootstrap prints the one command to run in Claude Code:
  ```
  /plugin install superpowers@claude-plugins-official
  ```

## Tier 3 - Detected and used if present (licensed or key-required, never bundled)

- **gstack** (licensed): unlocks `codex`, `autoplan`, `qa`, `design-review`, `browse`, `design-shotgun`, and the plan-review skills. If you have a gstack license, install it from your gstack source. holy-grail detects it and uses it. If absent, it uses its built-in design/QA/second-opinion fallbacks.
- **codex** / OpenAI key: the independent code-review second opinion. Needs your own `OPENAI_API_KEY` or `~/.codex/auth.json`. Detected and used if present; otherwise the internal red-team subagent stands in.
- **ruflo** memory (optional): cross-session lesson storage. If absent, learnings still persist in `references/playbook.md`.

## What never happens

holy-grail will not download, copy, or auto-install gstack or codex. They are licensed or key-gated, and redistributing them would be neither legal nor functional (machine-specific binaries). holy-grail carries its own fallback for each job instead.
