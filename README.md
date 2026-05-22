# holy-grail

The one-shot "upgrade anything" skill for Claude Code.

Say **"upgrade X"** (a feature, a page, a codebase, copy, a design, a strategy) and holy-grail runs a complete, expert-grade improvement pipeline end to end, in one shot, without rushing. It writes the perfect brief, plans it, builds it with subagents, reviews it through a panel of world-class expert agents plus an adversarial second opinion, improves until it is the best it can be, ships it, and learns from the run so the next one is sharper.

No em-dashes anywhere. Built to act as the genuine expert in every field the target touches.

## What it does

A run moves through eight phases:

0. **Ingest, recall, route, baseline** - accepts a description, a live URL, a screenshot, a file, or a Figma link. Asks one question up front: what to focus on (new features / design and UX / engineering health / all of the above). Captures the before-state. Loads past lessons. Classifies the target and right-sizes the effort.
1. **Strategy and the perfect brief** - states the why, the 10-star outcome, a north-star metric, benchmarks best-in-class, and gets a second opinion on the brief itself.
2. **Brainstorm and plan** - turns the brief into a spec and a plan, then a panel of experts and an adversarial reviewer tear the plan apart before any code.
3. **Build** - subagent-driven, one task at a time, test-first for code, variants explored for UI.
4. **Verify and review** - tests and build pass for real, an independent reviewer checks the diff, and the expert panel scores every dimension 0 to 10, including a red-team pass.
5. **Improve loop** - not just fixing defects. Each round the panel names the highest-leverage improvement, the skill folds it back into the brief (re-spec), re-plans it, rebuilds it test-first, and re-verifies. It keeps raising the ceiling until the work is both correct (tests green, second opinion passes) and excellent (every dimension at least 9 out of 10 and no worthwhile improvement remains), not merely passing.
6. **Final gate and finish** - a one-page report (before/after, evidence, the calls it auto-made so you can override), one approval, then ship and prove it on the live surface with before/after screenshots.
7. **Self-learning retro** - records what worked, which reviewers earned their keep, and grows its own playbook and expert roster.

## How it learns

The model's weights do not change. holy-grail keeps a durable, structured memory in `skills/holy-grail/references/playbook.md` that it reads at the start of every run and appends to at the end. It compares what it predicted against what actually happened, learns which reviewers add signal for which kinds of target, and promotes recurring lessons into the skill itself. See the playbook for the format.

## Install (for a teammate)

The repo is private, so first get access: the owner adds you as a collaborator on GitHub (repo Settings -> Collaborators), or makes the repo public.

Then, in a terminal:

```
git clone https://github.com/ryanspiteri/holy-grail.git
cd holy-grail
bash install.sh
```

`install.sh` symlinks the skill into `~/.claude/skills/` (so it works in every project) and installs the dependencies (superpowers, gstack, codex CLI). One optional manual step to activate the codex review:

```
codex login
```

Start a new Claude Code session, then say: `upgrade <something>` (or `/holy-grail`).

To update later, `git pull` in the repo. The symlink picks up changes automatically.

## Dependencies

None are required. holy-grail is self-contained with built-in fallbacks. `install.sh` also installs the full ecosystem for you, best effort: `superpowers` (free official plugin), `gstack` (MIT, cloned from its public repo), and the `codex` CLI (`@openai/codex` via npm). The one manual step is `codex login` (your own OpenAI credentials). Nothing is bundled or redistributed; each is installed from its own official source. See `DEPENDENCIES.md`.

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
