---
name: holy-grail
description: Use when the user asks to upgrade, improve, level up, perfect, polish, or "make the best it can be" - a feature, codebase, page, component, design, copy, strategy, or document. Triggers on "upgrade X", "improve X", "level up X", "make X world-class", "make this the best it can be", "holy grail". Accepts a description, a live URL, a screenshot, a file path, or a Figma link. Runs a one-shot, expert-reviewed, self-improving pipeline. Do NOT use for "upgrade gstack/tools" (use gstack-upgrade) or paywall/checkout conversion (use paywall-upgrade-cro).
metadata:
  author: Ryan Spiteri
  version: 1.0.0
---

# holy-grail

The one-shot upgrade-anything pipeline. The user points at something and says make it better. You produce the best possible version: brief, plan, build, review by a panel of experts, improve until world-class, ship, and learn from the run. Act as the genuine world-class expert in every field the target touches. Never rush.

This skill conducts other skills. It does not reimplement them. When an engine skill is installed you invoke it; when it is absent you use the built-in fallback in `references/fallbacks.md`. Either way the discipline holds.

## Operating Principles

- Act as the world-class expert in every field the target touches.
- State the why before the how. No work without strategic intent.
- Lead with capability, not polish. To upgrade something is first to ask what NET-NEW features and capabilities would make it dramatically more valuable, then build the high-value ones. Design, copy, and polish support that, they are not the headline. Feature improvements are the point of an upgrade.
- Measure the starting point. Prove the upgrade against a baseline, not a vibe.
- Never rush. Sequential phases, one task at a time, re-check after every change.
- Improve, do not just fix. Each loop raises the ceiling: re-spec, re-plan, rebuild, retest until it cannot be meaningfully bettered, not just until it passes.
- A panel of expert agents reviews everything. Nothing ships unreviewed.
- Do the complete thing, not the minimal thing, but right-size to the target. No full ceremony on a typo.
- Self-learn every run. Read the playbook first, write to it last. Learn which reviewers earn their keep.
- One human gate only, at Phase 6. Auto-decide other forks via `references/auto-decisions.md`.
- Anti-AI-slop. No em-dashes anywhere in output.

```
CORE INVARIANTS  (the self-learning retro must never weaken or remove these)
- The Phase 6 human gate always happens before shipping, merging, or PR.
- Every change is reviewed before ship (second opinion + expert panel).
- No completion claim without fresh verification evidence (baseline before claim).
- One-shot autonomy: auto-decide mechanical/taste forks; auto-build feature improvements that clear the value-vs-effort bar and are reversible; park only user-challenge forks (new product direction, real spend, pricing, legal, irreversible) for the gate.
- Anti-AI-slop, no em-dashes.
- Never auto-merge or auto-deploy without explicit approval.
Learned additions append BELOW the pipeline, never edit this block.
```

## Setup

Announce: "Using holy-grail to upgrade <target>." Then create a TodoWrite item for each of Phases 0 through 7 and work them in order, one in progress at a time.

Read `references/auto-decisions.md` for the ingestion matrix, routing, intensity, capability map, the 6 auto-decision principles, and the quality bars. Read `references/expert-panel.md` for the panel. Read `references/playbook.md` for past lessons. Read `references/fallbacks.md` only for the steps where the native skill is absent.

## The Pipeline

### Phase 0 - Ingest, Recall, Route, Baseline

1. If `.holy-grail/<slug>/state.md` exists for this target from an interrupted run, resume from its recorded phase.
2. **Ingest by modality** (auto-decisions.md ingestion matrix): a live URL is opened and screenshotted via `Skill(browse)` or `Skill(gstack)`, then mapped to its source component; a screenshot/image is read visually; a file/folder path is read; a Figma link goes through `Skill(figma)`; a plain description proceeds. The input is the baseline.
3. **Recall**: read `references/playbook.md` (the runtime self-learning file). If it does not exist yet, copy `references/playbook.seed.md` to `references/playbook.md` first, then read it. If ruflo is present, also `mcp__ruflo__memory_search` (project namespace then global) and scan the project auto-memory. State out loud which past lessons you are applying this run.
4. **Capability check**: read `~/.holy-grail/capabilities.json` (run `scripts/bootstrap.sh` with no flag to build it if missing or stale; detection is read-only). Decide native-vs-fallback per step. Say the mode in one line. If a dependency is missing, do NOT install it mid-task: tell the user to run `bash install.sh` (or `scripts/bootstrap.sh --install-deps`), which installs superpowers + gstack + codex CLI, then proceed with fallbacks for this run.
5. If the target is genuinely ambiguous (for example "upgrade the app" with no link or screenshot), ask exactly ONE scoping question. Otherwise proceed.
6. **Route**: classify the target (code / ui / copy / strategy / mixed) and run the UI and DX scope detection. Select the phases and reviewers that apply.
7. **Intensity**: set Deep, Full, or Epic per auto-decisions.md. The floor is always thorough.
8. **Baseline**: write `.holy-grail/<slug>/baseline.md` with current metrics, test results, screenshots, the source map, and the artifact as-is. For brand-facing targets load the brand voice, `DESIGN.md` if present, and the anti-slop rules.

### Phase 1 - Strategy and the Perfect Brief

Act as the domain expert. Write `.holy-grail/<slug>/01-brief.md`:

- The why and the strategic intent.
- **Feature opportunities (the headline of the brief, lead with these).** Brainstorm the highest-leverage NET-NEW features and capability upgrades that would make the target dramatically more valuable, not just a nicer version of what exists. Rank by impact vs effort. For each: what it is, why it matters, rough effort, reversible or not, in-scope (auto-build) or user-challenge (park for the gate). Aim for at least 5 candidates before filtering. This is where most of the value is, do not shortcut it.
- The 10-star outcome, framed around the new capabilities the target would gain.
- A north-star metric and a predicted improvement (you will check the prediction at Phase 7).
- Measurable success criteria, each tied to the baseline, including the high-value features to be built this run.
- Blast radius and risk, constraints, non-goals.

Then:

- **Benchmark to best-in-class**: name the world-class reference for this target (via `Skill(competitor-intelligence)` or `Skill(benchmark)` if present, else domain knowledge) so "the best it can be" has a concrete ceiling.
- **Instantiate the panel**: from `references/expert-panel.md`, pull the personas this target needs. If a needed field has no persona, synthesize one and append it to the roster.
- **Self-critique** the brief against its own rubric.
- **Second opinion**: `Skill(codex)` consult mode, or the fallback internal review, asking what is missing, wrong, or under-ambitious.
- Revise. Do not stop. Auto-decide forks, park user-challenge forks for Phase 6.

### Phase 2 - Brainstorm and Plan

- Spec: `Skill(superpowers:brainstorming)` on the brief in autonomous mode, or the fallback spec method. Override the skill's approval gate; you have one gate at Phase 6.
- Plan: `Skill(superpowers:writing-plans)`, or the fallback plan method. For non-code, an equivalent structured execution outline.
- **Panel review of the plan**: code or product plans go through `Skill(autoplan)` if present; otherwise dispatch the parallel expert panel from `references/expert-panel.md` against the plan. For UI plans add `Skill(plan-design-review)` if present.
- **Adversarial check**: `Skill(codex)` review or challenge on the plan, or the fallback red-team.
- Revise the plan. Collect any genuine taste or strategy forks for Phase 6.

### Phase 3 - Build or Produce

- **Build the high-value features first.** The brief's ranked feature opportunities that clear the value-vs-effort bar and are reversible are the main work of the build, not an afterthought. Build them. Park only genuinely large or strategic expansions (new product direction, pricing, spend, legal, irreversible) for the gate. Design and polish come after the capability is in.
- For UI or design targets, use the design and asset toolchain in `references/auto-decisions.md` section 3.5. If no `DESIGN.md` exists, establish the system first (`Skill(design-consultation)` or infer one). Explore variants (`Skill(design-shotgun)` if present, else 2 to 3 distinct directions) and converge on the strongest. Build distinctive UI with `Skill(frontend-design)` when present. Generate any needed visual assets with `Skill(nano-banana-pro)` or `Skill(higgsfield-generate)`. Pull designs via `Skill(figma)` if the input was Figma. Do not ship the first idea, and never ship a generic AI-slop UI.
- For code: `Skill(superpowers:using-git-worktrees)` to isolate, then `Skill(superpowers:subagent-driven-development)` with `superpowers:test-driven-development`. If superpowers is absent, use the fallback subagent build loop. Fresh subagent per task, two-stage spec then quality review per task, test first.
- For non-code: produce the artifact via focused per-section subagents, each reviewed.
- One task at a time. Never batch. Re-check after every change.

### Phase 4 - Verify and Expert-Panel Review

- `Skill(superpowers:verification-before-completion)` or the fallback: run tests and build for real, capture the actual output. No "should pass".
- `Skill(superpowers:requesting-code-review)` or the fallback internal review on the diff.
- Independent second opinion: `Skill(codex)` review on the diff with a PASS or FAIL gate on P1 findings. Add `Skill(codex)` challenge for Epic or risky code. Fallback: the internal red-team review.
- If UI scope is active: `Skill(design-review)`, `Skill(qa)`, `Skill(gstack)` screenshots and health score, or the design/QA fallback.
- **Dispatch the expert panel** (parallel subagents per `references/expert-panel.md`) against the brief's success criteria, including the red-team / abuse-case persona for anything touching auth, payments, user data, or input. Each scores its dimensions 0 to 10. The panel is complementary to the code review above: when superpowers and codex have already reviewed the code, the panel skips a duplicate correctness pass and contributes only the design, conversion, product, performance, accessibility, domain, and red-team lenses plus the scoring. If superpowers and codex are both absent, the panel's Staff Engineer owns code correctness. For non-code targets the panel is the whole review.
- Log every finding to `.holy-grail/<slug>/findings.md` tagged with the reviewer that raised it. This feeds Phase 7.

### Phase 5 - Improve Loop (re-spec, rebuild, retest until it cannot be bettered)

This is an improvement engine, not a fix-until-green loop. Each round does two kinds of work:

1. **Fix** every defect: codex P1s, panel Critical and Important findings, QA bugs. Re-verify after each.
2. **Elevate (re-spec yourself).** The Product/Feature Strategist and the panel name the highest-leverage change, biased toward NET-NEW features and capabilities, then design and polish. If it clears the value-vs-effort bar (it moves a real success metric, it is reversible, it is not gold-plating), then **fold it back into the brief and spec, re-plan that increment, build it test-first, and re-verify.** This includes building net-new feature improvements, not just polishing existing dimensions. Park only genuinely large or strategic expansions (new product direction, pricing, spend, legal, irreversible) for the gate.

Then re-run the reviewers whose area changed, and loop: improve, rebuild, retest.

**Stop only when BOTH hold:**
- **Correct:** second opinion PASS with no open P1, tests and build green, QA green for UI, every brief success criterion met against the baseline.
- **Excellent:** every activated panel dimension is at least 9 out of 10, AND the panel cannot name a further improvement that clears the value-vs-effort bar. That is the excellence plateau, not "good enough".

Keep going while the panel keeps finding worthwhile improvements. Stop when more work would not meaningfully move the outcome (diminishing returns), or at the safety cap of 3 rounds. Never loop forever and never silently ship a missed bar: at the cap, record the specific gap and the best remaining option for the Phase 6 gate. Ordinary feature improvements that clear the value bar are built, not parked. Only genuinely large or strategic expansions (new product direction, pricing, spend, legal, irreversible) park for the gate.

### Phase 6 - Final Gate and Finish

1. Write `.holy-grail/<slug>/report.md`: what changed and why, before/after against the baseline, evidence (test output, second-opinion verdict, panel scores, screenshots, north-star delta), the **feature improvements built this run**, a **ranked list of the larger feature and strategy ideas parked for your greenlight** (so you can pick the next run), the taste forks you auto-decided so the user can override, and any remaining gaps.
2. Present the report and use `AskUserQuestion` to get approval to ship. This is the only stop.
3. Optionally notify via the Telegram reply tool when the gate is reached.
4. On approval: for code, `Skill(superpowers:finishing-a-development-branch)`, then commit, push, and open a PR (always push, never ask). For non-code, deliver the artifact.
5. **Prove it on the real surface**: for any live target, re-open the URL or app after deploy and capture before/after screenshots on every surface it touches. Done means verified on the live surface, not green tests.

### Phase 7 - Self-Learning Retro

Dispatch a retro subagent that reads `findings.md` and the brief, then:

- Compares the predicted improvement to the actual delta. Writes the gap as a lesson in the form "Next time, do X, because Y (evidence: this run)." Vague lessons are discarded.
- Tallies, per target type, which reviewers produced real fixes versus noise. Updates the Finding ledger so future runs of this target type keep the high-signal reviewers and drop the rest.
- Notes any new expert persona that proved useful (it is already in the roster from Phase 1).
- Appends a Lesson entry to `references/playbook.md`. If a lesson has now recurred 3 or more times, or is structural, promote it into the "Learned additions" section below and log it in the playbook Changelog. Never touch the Core Invariants. Decay stale low-confidence lessons.
- If ruflo is present, also `mcp__ruflo__memory_store` (project namespace, and global if it generalizes) and update the auto-memory index.

## Autonomy and the single gate

Run autonomous. Override the intermediate approval gates inside brainstorming and writing-plans. Auto-decide mechanical and taste forks via the 6 principles in `references/auto-decisions.md`, logging each in `state.md`. Auto-build feature improvements that clear the value-vs-effort bar and are reversible. Park only user-challenge forks (new product direction, real spend, pricing or positioning, legal or compliance, irreversible) for the Phase 6 gate, or ask the single Phase 0 scoping question if one blocks starting.

## Red flags (rationalizations that mean stop)

| Thought | Reality |
|---|---|
| "Skip the brief, I know what to build" | The brief is the leverage. Write it. A bad brief wastes the whole run. |
| "Just polish what is there" | An upgrade leads with new capability. Ask what features would make this 10x more valuable first, build the high-value ones, then polish. Design is support, not the headline. |
| "Skip the second opinion, it looks fine" | An independent reviewer reliably finds defects single-pass work misses. Always run it. |
| "One review round is enough" | Re-check after every change. The bar is every dimension at 9, not "good enough". |
| "I do not need the playbook" | Reading it is the entire self-learning loop. Load it and say what you are applying. |
| "It is just a small change, run everything" | Right-size. Full ceremony on a typo is rushing in disguise, wasting the run. |
| "Tests pass, it is done" | Done is verified on the live surface with before/after evidence. |

## Reference files (read when)

- `references/auto-decisions.md` - at Phase 0 for ingestion, routing, intensity, capability map; mid-run for the 6 principles and the quality bars.
- `references/expert-panel.md` - at Phase 1 to instantiate the panel, at Phases 2 and 4 to dispatch it.
- `references/playbook.md` - at Phase 0 to load lessons, at Phase 7 to append them.
- `references/fallbacks.md` - only for steps where `capabilities.json` shows the native skill is absent.

---

## Learned additions

Promoted lessons append here over time (Phase 7). They refine the pipeline above. They never override the Core Invariants.

(none yet)
