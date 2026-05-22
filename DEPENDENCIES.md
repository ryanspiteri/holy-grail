# Dependencies

holy-grail is self-contained: it works with nothing else installed, via built-in fallbacks in `skills/holy-grail/references/fallbacks.md`. It also gets better when the ecosystem is present, and `install.sh` installs that ecosystem for you. No em-dashes in this file.

`scripts/bootstrap.sh` writes `~/.holy-grail/capabilities.json`, which the skill reads at the start of every run to route each step to a native skill or to its built-in fallback.

Nothing is bundled or redistributed. Each dependency is installed from its own official source (the Anthropic plugin marketplace, the public MIT gstack repo, the public `@openai/codex` npm package).

## Tier 1 - Core (required: none)

The whole pipeline runs on built-in Claude Code tools plus subagents. No external skill is required. With nothing installed, holy-grail still writes the brief, plans, builds with a per-task subagent loop, reviews with an internal adversarial pass and an expert panel, verifies, and self-learns.

## Tier 2 - Installed for you by `install.sh`

Running `bash install.sh` (or `scripts/bootstrap.sh --install-deps`) installs all three, best effort and non-fatal:

- **superpowers** (`superpowers@claude-plugins-official`): the build chain (brainstorming, writing-plans, subagent-driven-development, TDD, code review, verification). Free, official Anthropic plugin.
- **gstack** (MIT, `github.com/garrytan/gstack`): unlocks `codex`, `autoplan`, `qa`, `design-review`, `plan-design-review`, `design-consultation`, `design-shotgun`, `browse`, and the plan-review skills. Installed by cloning the public repo and running its `setup`, the same method `/gstack-upgrade` uses.
- **codex CLI** (`@openai/codex`): the independent code-review second opinion. The binary is installed via npm (or brew). It needs your own OpenAI or ChatGPT login: run `codex login` once to activate it. Until you do, holy-grail uses its built-in red-team review instead.

The only manual step after `install.sh` is `codex login` (your own OpenAI credentials, which no installer can provide for you).

## Optional

- **ruflo** memory: cross-session lesson storage. If absent, learnings still persist in `skills/holy-grail/references/playbook.md`.

## Design and asset tools (used for ui targets if present)

Installed with gstack above: `design-consultation`, `design-shotgun`, `design-review`, `plan-design-review`. Plus, install via `/plugin` if you want them: `frontend-design` and `figma` (free official plugins) for distinctive UI code and Figma import. Image generation (`nano-banana-pro`, `higgsfield-generate`) needs its own API keys (Gemini, Higgsfield). All have a Principal-Designer-persona fallback, so a ui upgrade works without any of them.

## Why nothing is "bundled"

holy-grail never copies another tool's files into itself. Bundling would break (machine-specific binaries) and is unnecessary: each dependency installs cleanly from its own official source. holy-grail just orchestrates them, and falls back to its own built-in versions when one is missing.
