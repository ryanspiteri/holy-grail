# holy-grail

The one-shot "upgrade anything" skill for Claude Code.

Say **"upgrade X"** (a feature, a page, a codebase, copy, a design, a strategy) and holy-grail runs a complete, expert-grade improvement pipeline end to end, in one shot, without rushing. It writes the perfect brief, plans it, builds it with subagents, reviews it through a panel of world-class expert agents plus an adversarial second opinion, improves until it is the best it can be, ships it, and learns from the run so the next one is sharper.

No em-dashes anywhere. Built to act as the genuine expert in every field the target touches.

## What it does

A run moves through eight phases:

0. **Ingest, recall, route, baseline** - accepts a description, a live URL, a screenshot, a file, or a Figma link. Captures the before-state. Loads past lessons. Classifies the target and right-sizes the effort.
1. **Strategy and the perfect brief** - states the why, the 10-star outcome, a north-star metric, benchmarks best-in-class, and gets a second opinion on the brief itself.
2. **Brainstorm and plan** - turns the brief into a spec and a plan, then a panel of experts and an adversarial reviewer tear the plan apart before any code.
3. **Build** - subagent-driven, one task at a time, test-first for code, variants explored for UI.
4. **Verify and review** - tests and build pass for real, an independent reviewer checks the diff, and the expert panel scores every dimension 0 to 10, including a red-team pass.
5. **Improve loop** - fix, re-check, fix again until the second opinion passes, every panel dimension is at least 9 out of 10, QA is green, and every success criterion is met.
6. **Final gate and finish** - a one-page report (before/after, evidence, the calls it auto-made so you can override), one approval, then ship and prove it on the live surface with before/after screenshots.
7. **Self-learning retro** - records what worked, which reviewers earned their keep, and grows its own playbook and expert roster.

## How it learns

The model's weights do not change. holy-grail keeps a durable, structured memory in `skills/holy-grail/references/playbook.md` that it reads at the start of every run and appends to at the end. It compares what it predicted against what actually happened, learns which reviewers add signal for which kinds of target, and promotes recurring lessons into the skill itself. See the playbook for the format.

## Install

Local skill (simplest):

```
bash install.sh
```

As a shareable plugin, inside Claude Code:

```
/plugin marketplace add ryanspiteri/holy-grail
/plugin install holy-grail
```

The repo is private. To let a coworker install it, add them as a collaborator on the GitHub repo first, then they run the two commands above.

Then start a new session and say: `upgrade <something>`.

## Dependencies

None are required. holy-grail is self-contained with built-in fallbacks. It auto-installs the free official `superpowers` plugin if missing, and detects and uses `gstack` / `codex` if you already have them. It never bundles or installs licensed tooling. See `DEPENDENCIES.md`.

## Repo layout

```
.claude-plugin/plugin.json   plugin manifest
install.sh                   local + plugin install
scripts/bootstrap.sh         detect deps, auto-install free ones, write capability map
DEPENDENCIES.md              the three dependency tiers
skills/holy-grail/
  SKILL.md                   the pipeline
  references/                routing, fallbacks, expert panel, the self-learning playbook
  tests/                     RED/GREEN validation prompts
```
