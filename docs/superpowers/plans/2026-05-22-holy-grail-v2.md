# holy-grail v2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade the holy-grail skill to a fire-and-forget, genuinely self-learning, honest, cross-project upgrade pipeline per the approved spec.

**Architecture:** holy-grail is a Claude Code skill (a `SKILL.md` spine + `references/*.md` + shell scripts), not a compiled codebase. There are no unit tests; verification is (a) grep invariants, (b) `bash -n` syntax checks, (c) `wc -l` budget, (d) a no-em-dash lint, and (e) a subagent that routes the prompts in `tests/test-prompts.md` and confirms the expected phases/personas/finish. "RED" = the assertion fails on the current file; "GREEN" = it passes after the edit. Full content for each change lives in the spec; tasks below name the exact change + the checkable assertion.

**Spec:** `docs/superpowers/specs/2026-05-22-holy-grail-v2-design.md` (read it before each task).

**Tech Stack:** Markdown, bash, GitHub (gh), git. No build system.

**Repo:** `~/Documents/holy-grail`. Commit + push after each task (public repo). No em-dashes in any shipped file (the skill's own rule). Commit author: `Ryan Spiteri <ryan@onesthealth.com>`, co-author trailer `Claude Opus 4.7`.

---

## File responsibilities after v2

- `skills/holy-grail/SKILL.md` — spine: fire-and-forget autonomy, 8 phases (Phase 5 = main + 3 rounds + final check), slim Operating Principles, slim Core Invariants (safety floors only), red-flags, frontmatter. References everything else; stays under 500 lines.
- `skills/holy-grail/references/auto-decisions.md` — routing brain: ingestion, classification, scope detection, intensity, capability map, the 6 principles, the SINGLE definition of park/build + the value-vs-effort bar, quality bars, multi-repo, subagent budgets, propose-only, blast-radius cap, proof split.
- `skills/holy-grail/references/expert-panel.md` — persona roster + the stated precedence chain + self-assessed labeling + dispatch template + rubric.
- `skills/holy-grail/references/playbook.seed.md` — lesson schema (`trigger`, `scope`, `count`, `confidence`, `last_confirmed_run`), the run counter, the Always-apply block, and the how-to-use rules (trigger retrieval, merge-before-append, promote, decay).
- `skills/holy-grail/references/run-state.md` — NEW: `state.md` schema + when written, `outcomes.md` schema, the finish protocol (PR + notify + exit), resume.
- `skills/holy-grail/references/fallbacks.md` — note the codex_cli vs codex_auth distinction.
- `scripts/bootstrap.sh`, `install.sh` — robustness fixes.
- `.claude-plugin/plugin.json`, `README.md` — description sync.
- `skills/holy-grail/tests/test-prompts.md` — routing/behavior validation cases.

---

### Task 1: Self-learning mechanics + lesson schema (playbook.seed.md)

**Files:**
- Modify: `skills/holy-grail/references/playbook.seed.md`

- [ ] **Step 1 (RED): assertion that currently fails.** Run: `grep -c "trigger:" skills/holy-grail/references/playbook.seed.md` → expect 0 now (no trigger field). Also `grep -ci "always-apply" skills/holy-grail/references/playbook.seed.md` → expect 0.
- [ ] **Step 2: rewrite the lesson template** to: `trigger:` (retrieval condition), `scope: universal | project`, `target type`, `lesson`, `evidence`, `confidence: low|medium|high`, `count`, `last_confirmed_run`. New singletons start at `confidence: low`.
- [ ] **Step 3: add a run counter** as the first content line: `run_count: 0` (incremented every Phase 7).
- [ ] **Step 4: add an "Always-apply" section** above the trigger-indexed lessons, seeded with one promoted universal lesson: "On any diff with an irreversible external action, money, or access control, run the adversarial reviewer hard and iteratively (including on the plan) until it returns SHIP." (trigger: `irreversible-or-access-control-or-money`, scope: universal, confidence: high, count: 3).
- [ ] **Step 5: rewrite "How to use this file"** to specify: Phase 0 retrieval = Always-apply block + up to 8 lessons whose `trigger` matches the run's conditions, ranked by confidence then count; Phase 7 = merge-before-append (same trigger + corrective action increments count, appends evidence, bumps confidence, sets last_confirmed_run; only append when no match), promote at count>=3 into the Always-apply block + Changelog (verify it appears), decay when `run_count - last_confirmed_run > 10 && confidence: low`.
- [ ] **Step 6 (GREEN): re-run assertions.** `grep -c "trigger:" ...` >= 2; `grep -ci "always-apply" ...` >= 1; `grep -c "run_count:" ...` == 1. No em-dashes: `grep -c $'—' skills/holy-grail/references/playbook.seed.md` == 0.
- [ ] **Step 7: Commit.** `git add -A && git commit -m "feat(playbook): trigger-indexed schema + merge/promote/decay + run counter"`

### Task 2: Cross-project memory split (auto-decisions.md + SKILL Phase 0/7)

**Files:**
- Modify: `skills/holy-grail/references/auto-decisions.md` (add a "Memory model" subsection)
- Modify: `skills/holy-grail/SKILL.md` (Phase 0 recall step; Phase 7 routing step)

- [ ] **Step 1 (RED):** `grep -ci "project.md\|universal" skills/holy-grail/references/auto-decisions.md` → expect 0.
- [ ] **Step 2: add a "Memory model" subsection to auto-decisions.md**: universal lessons live in `references/playbook.md` (per-machine, generalizable only); project-specific conventions + lessons live in `.holy-grail/project.md` inside the target repo; the host `CLAUDE.md` is authoritative project context. Lessons never cross projects.
- [ ] **Step 3: update SKILL.md Phase 0 recall**: read host `CLAUDE.md` + `.holy-grail/project.md` (if present) as authoritative project context, plus the universal playbook (trigger-retrieved).
- [ ] **Step 4: update SKILL.md Phase 7**: the retro decides per lesson "does this generalize beyond this project?" Universal -> universal playbook; project-specific -> the project's `.holy-grail/project.md`.
- [ ] **Step 5 (GREEN):** `grep -ci "project.md" skills/holy-grail/references/auto-decisions.md` >= 1; SKILL Phase 0 mentions `CLAUDE.md`; em-dash lint == 0 on both files.
- [ ] **Step 6: Commit.** `-m "feat(memory): universal-vs-project split + project-context primitive"`

### Task 3: Durable run-state (NEW run-state.md + SKILL phases)

**Files:**
- Create: `skills/holy-grail/references/run-state.md`
- Modify: `skills/holy-grail/SKILL.md` (Phase 0 resume; each phase ends by writing state.md; Phase 6 finish protocol references it)

- [ ] **Step 1 (RED):** `test -f skills/holy-grail/references/run-state.md` → fails (not created).
- [ ] **Step 2: write run-state.md** with: the `state.md` schema (phase, intensity, focus, classification, decision_log, repos_worktrees, task_index, panel_scores_by_round, predicted_vs_actual); when it is written (end of every phase); the `outcomes.md` schema (date, target, predicted delta, actual delta); the finish protocol (persist state, open PR, notify Telegram, exit, no block); resume (read state.md, continue from phase).
- [ ] **Step 3: update SKILL.md** so each phase ends with "write/update `.holy-grail/<slug>/state.md`" and Phase 0 step 1 reads it to resume. Point Phase 6 at run-state.md for the finish protocol.
- [ ] **Step 4 (GREEN):** `test -f .../run-state.md` passes; `grep -c "state.md" skills/holy-grail/SKILL.md` >= 3 (resume + write + finish); em-dash lint == 0.
- [ ] **Step 5: Commit.** `-m "feat(run-state): real state.md + outcomes + resume + finish protocol"`

### Task 4: Fire-and-forget autonomy + cadence + Core Invariants (SKILL.md)

**Files:**
- Modify: `skills/holy-grail/SKILL.md` (Operating Principles, Core Invariants block, Phase 5 cadence, Phase 6 finish, Autonomy section)

- [ ] **Step 1 (RED):** `grep -ci "blocking\|no further prompting\|fire-and-forget\|main pass plus 3" skills/holy-grail/SKILL.md` low/0; `grep -c "auto-build" <core-invariants-block>` currently 1 (auto-build wrongly inside invariants).
- [ ] **Step 2: rewrite the Autonomy section**: fire-and-forget default; the only interactive prompt is the one up-front focus question (skippable if focus is in the command); NO mid-run questions; auto-decide every fork; user-challenge forks get a logged safe-default and surface in the report (not a block).
- [ ] **Step 3: rewrite Phase 5** to the explicit cadence: main pass + 3 improvement rounds + a distinct final check; each cycle = build/improve/add-features/test/review; stop a round early only at the measurable plateau; default to the full cadence.
- [ ] **Step 4: rewrite Phase 6** to the finish protocol (PR + report + Telegram notify + exit, no blocking gate); reference run-state.md.
- [ ] **Step 5: clean Core Invariants**: remove the auto-build line (move to Autonomy); replace "Phase 6 human gate always happens" with "never auto-merge or auto-deploy; the run ends at a PR the human merges asynchronously". Keep: review before PR, evidence before claim, anti-slop, no auto-deploy.
- [ ] **Step 6 (GREEN):** Core Invariants block contains no "auto-build"; contains "never auto-merge"; Phase 5 contains "final check" + "3"; em-dash lint == 0.
- [ ] **Step 7: Commit.** `-m "feat(autonomy): fire-and-forget, cadence (main+3+final), PR-not-gate finish"`

### Task 5: Honesty / anti-slop (SKILL.md + expert-panel.md)

**Files:**
- Modify: `skills/holy-grail/SKILL.md` (banned-word removal; report template separation; proof split)
- Modify: `skills/holy-grail/references/expert-panel.md` (label scores self-assessed)

- [ ] **Step 1 (RED):** `grep -ciE "world-class|cannot be bettered|best it can be" skills/holy-grail/SKILL.md skills/holy-grail/references/*.md` → expect > 0 now.
- [ ] **Step 2: remove banned words** from the instructions (keep the name + the aim "the strongest version", reworded), across SKILL.md and references.
- [ ] **Step 3: label panel scores self-assessed** in expert-panel.md rubric and dispatch template.
- [ ] **Step 4: update the Phase 6 report template** (in SKILL.md) to separate an "Objective signals" section (tests pass, codex PASS/FAIL, QA health, real metric delta) from a "Self-assessed panel scores" section.
- [ ] **Step 5: add the proof split** (Phase 6): in-run local/preview proof vs post-merge production proof (mobile may be impossible in-loop); the report states which was achieved.
- [ ] **Step 6 (GREEN):** the banned-words grep == 0 across all shipped files; report template has both labeled sections; em-dash lint == 0.
- [ ] **Step 7: Commit.** `-m "fix(honesty): drop banned words, label self-assessed scores, proof split"`

### Task 6: Persona precedence + security floor (expert-panel.md)

**Files:**
- Modify: `skills/holy-grail/references/expert-panel.md`

- [ ] **Step 1 (RED):** dispatch a subagent with the current expert-panel.md + the case "ui target, focus = Design & UX, on a payments screen" and ask "does the Feature Strategist run? does Security run?" Confirm the answer is currently ambiguous/contradictory.
- [ ] **Step 2: state the precedence chain once**: target type = candidate set -> focus question filters it (intersection) -> complementary rule drops the panel correctness pass when codex present -> Security/Red-Team is an always-on floor for auth/payments/user-data/input. Resolve: the Feature Strategist leads only when New features or All is in focus; under a Design-only focus it does not run.
- [ ] **Step 3: add the security floor to every focus-map row** (a "+ Security/Red-Team if auth/payments/user-data/input" note on each).
- [ ] **Step 4 (GREEN):** re-dispatch the same subagent; it must now answer deterministically (Feature Strategist off under Design-only focus; Security on for the payments screen). em-dash lint == 0.
- [ ] **Step 5: Commit.** `-m "fix(panel): state precedence chain + security floor in every focus row"`

### Task 7: De-dup + parallel build + conditional plan-panel (SKILL.md + auto-decisions.md)

**Files:**
- Modify: `skills/holy-grail/references/auto-decisions.md` (single home for park/build + value bar)
- Modify: `skills/holy-grail/SKILL.md` (phases reference it; Phase 3 parallel build; Phase 2 conditional panel; consolidate principle restatements)

- [ ] **Step 1 (RED):** `grep -c "new product direction, pricing, spend, legal, irreversible\|new product direction, real spend" skills/holy-grail/SKILL.md` → expect >= 5 (the duplication). `wc -l skills/holy-grail/SKILL.md` → record baseline.
- [ ] **Step 2: define park/build + the value-vs-effort bar exactly once** in auto-decisions.md section 4 (canonical). 
- [ ] **Step 3: replace the 5+ SKILL.md restatements** with a single reference: "build in-scope feature improvements, park user-challenge forks (see auto-decisions section 4)."
- [ ] **Step 4: Phase 3 parallel build**: fan independent features to parallel subagents on disjoint file sets; serialize schema + migration-journal edits; clarify "one task at a time" applies WITHIN a feature, independent features may parallelize.
- [ ] **Step 5: Phase 2 conditional plan-panel**: full parallel persona panel on the PLAN only for Epic/money/auth/multi-tenant; otherwise codex-on-the-plan suffices.
- [ ] **Step 6 (GREEN):** the park/build clause appears <= 2 times in SKILL.md (down from 5+); auto-decisions.md defines it once; `wc -l skills/holy-grail/SKILL.md` <= baseline; Phase 3 mentions "disjoint"; em-dash lint == 0; SKILL.md < 500 lines.
- [ ] **Step 7: Commit.** `-m "refactor(flow): single park/build home, parallel build, conditional plan-panel"`

### Task 8: Observability + budgets + multi-repo + propose-only + blast-radius (auto-decisions.md + SKILL.md)

**Files:**
- Modify: `skills/holy-grail/references/auto-decisions.md`
- Modify: `skills/holy-grail/SKILL.md` (run ledger in report; propose-only modifier; multi-repo in Phase 0)

- [ ] **Step 1 (RED):** `grep -ciE "subagent budget|run ledger|propose-only|multi-repo|blast.radius" skills/holy-grail/references/auto-decisions.md skills/holy-grail/SKILL.md` → expect 0.
- [ ] **Step 2: add subagent budgets** per intensity (Deep <= 5, Full <= 15, Epic <= 30); exceeding forces a checkpoint.
- [ ] **Step 3: add the run ledger** to the Phase 6 report (phases, intensity, subagents dispatched, improve rounds, codex passes).
- [ ] **Step 4: add multi-repo handling** to Phase 0 (detect N target repos -> N worktrees/PRs + cross-repo contract flag).
- [ ] **Step 5: add propose-only mode** (a modifier running Phases 0-2 + panel, no build).
- [ ] **Step 6: add the blast-radius cap** (an auto-built feature > 10 changed files, or touching schema/migration, escalates to the report as its own sub-upgrade rather than building silently).
- [ ] **Step 7 (GREEN):** the grep from Step 1 now > 0 for each term; a subagent routes a "propose-only" prompt (stops after plan) and a multi-repo prompt (N PRs) correctly; em-dash lint == 0.
- [ ] **Step 8: Commit.** `-m "feat: budgets + run ledger + multi-repo + propose-only + blast-radius cap"`

### Task 9: Bootstrap + install robustness (scripts)

**Files:**
- Modify: `scripts/bootstrap.sh`
- Modify: `install.sh`

- [ ] **Step 1 (RED):** read bootstrap.sh: confirm `CODEX=1` can be set from a bare `OPENAI_API_KEY`; confirm `./setup` runs without `</dev/null`; confirm install.sh prints "done" unconditionally.
- [ ] **Step 2: codex usability** = `codex_cli && codex_auth` (a bare API key with no CLI -> codex unusable); keep `codex_cli`/`codex_auth` fields; the skill warns at runtime when the "independent" review is the fallback.
- [ ] **Step 3: harden gstack setup**: `( cd "$GSTACK_DIR" && ./setup </dev/null >/dev/null 2>&1 )` wrapped in a `timeout` (e.g. `timeout 300`); pin the clone to a tag/ref if one is resolvable, else note the unpinned risk.
- [ ] **Step 4: ruflo detection** must not depend on `$PWD` (drop the `$PWD/.swarm` check or make it explicit it is best-effort; rely on the MCP-config greps which are absolute).
- [ ] **Step 5: install.sh truthful finish**: read back `~/.holy-grail/capabilities.json` and print the actual mode ("enhanced" vs "FALLBACK: superpowers and/or codex not active") instead of an unconditional "done".
- [ ] **Step 6 (GREEN):** `bash -n scripts/bootstrap.sh && bash -n install.sh` pass; run `OPENAI_API_KEY=x bash scripts/bootstrap.sh` in a temp dir with no codex CLI on PATH -> capabilities.json shows `"codex": false`; install.sh end prints a mode line.
- [ ] **Step 7: Commit.** `-m "fix(bootstrap): codex_cli&&auth, gstack setup </dev/null+timeout, truthful install mode"`

### Task 10: Runtime playbook migration + backfill (playbook.md, gitignored)

**Files:**
- Modify: `skills/holy-grail/references/playbook.md` (machine-local, not pushed)

- [ ] **Step 1 (RED):** `grep -c $'—' skills/holy-grail/references/playbook.md` → expect > 0 (em-dashes present); 3 separate adversarial/security singletons present; no `trigger:`/`run_count:` fields.
- [ ] **Step 2: migrate existing entries** to the Task 1 schema (add `trigger`, `scope`, `last_confirmed_run`); add `run_count` reflecting actual runs so far (estimate from entries, e.g. 5).
- [ ] **Step 3: backfill-merge** the three singletons (codex-iterate-to-SHIP, red-team-access-control, panel-on-the-plan-for-money) into one promoted Always-apply lesson with count >= 3; remove the three originals.
- [ ] **Step 4: remove all em-dashes** from playbook.md.
- [ ] **Step 5 (GREEN):** em-dash count == 0; the 3 singletons are now 1 promoted lesson; `grep -c "run_count:" ...` == 1.
- [ ] **Step 6:** This file is gitignored. Do NOT commit it. Just save. (Confirm `git status --porcelain skills/holy-grail/references/playbook.md` shows nothing to commit.)

### Task 11: Docs sync (plugin.json + README.md + frontmatter)

**Files:**
- Modify: `.claude-plugin/plugin.json`
- Modify: `README.md`
- Modify: `skills/holy-grail/SKILL.md` (frontmatter description)

- [ ] **Step 1 (RED):** `grep -ci "fire-and-forget\|focus question\|new features first" .claude-plugin/plugin.json README.md` → low/0.
- [ ] **Step 2: update plugin.json description + SKILL.md frontmatter description** to reflect fire-and-forget + leads-with-features + the one focus question (keep trigger-focused, third person, the gstack-upgrade/paywall exclusions).
- [ ] **Step 3: update README**: the finish protocol (PR not gate), the cadence, the teammate-playbook note (runtime playbook.md is created from the seed on first run), the cross-project memory note.
- [ ] **Step 4 (GREEN):** the grep > 0; both descriptions match; em-dash lint == 0; `python3 -c "import json;json.load(open('.claude-plugin/plugin.json'))"` valid.
- [ ] **Step 5: Commit.** `-m "docs: sync descriptions + README to v2 (fire-and-forget, cadence, memory)"`

### Task 12: Test-prompts + final validation gauntlet

**Files:**
- Modify: `skills/holy-grail/tests/test-prompts.md`
- Validation only across all files.

- [ ] **Step 1: add test cases** to test-prompts.md: (a) cross-project routing (a non-NewU stack target routes generically), (b) propose-only (stops after plan), (c) multi-repo (N PRs), (d) fire-and-forget finish (ends at PR + notify, no blocking gate), (e) self-learning merge (a repeat-trigger run increments count, no duplicate), (f) persona precedence (Design-only focus excludes Feature Strategist; payments screen includes Security).
- [ ] **Step 2 (RED->GREEN): dispatch the validation subagent**: it reads the full v2 skill + all test-prompts (original 4 + the 6 new) and reports MATCH/MISMATCH for each, plus a harsh check for any NEW contradiction introduced. Fix any MISMATCH inline and re-dispatch until all GREEN.
- [ ] **Step 3: final lint sweep**: `grep -rn $'—' .` across shipped files == 0; `wc -l skills/holy-grail/SKILL.md` < 500; `bash -n scripts/bootstrap.sh install.sh` pass; plugin.json valid JSON.
- [ ] **Step 4: Commit + push.** `-m "test: v2 validation cases + final gauntlet (all routing GREEN)"` then `git push origin main`.
- [ ] **Step 5: final cluster review**: dispatch one code-reviewer subagent across the whole v2 diff (`git diff <pre-v2-sha> HEAD`) for any remaining contradiction, overclaim, or broken reference. Fix Critical/Important, re-verify, push.

---

## Self-review (writing-plans)

- **Spec coverage:** every spec subsystem maps to a task — self-learning loop (T1) + cross-project split (T2) + run-state (T3) + autonomy/cadence (T4) + honesty (T5) + persona precedence (T6) + de-dup/parallel/conditional-panel (T7) + observability/multi-repo/propose-only/blast-radius (T8) + bootstrap (T9) + runtime backfill (T10) + docs (T11) + validation (T12). No gaps.
- **Placeholder scan:** verification steps use concrete grep/bash/wc commands; content lives in the spec. The one soft spot (gstack clone pin "if resolvable") is intentionally conditional because the ref may not exist; the fallback (note the risk) is specified.
- **Type consistency:** field names are consistent across T1/T2/T10 (`trigger`, `scope`, `count`, `confidence`, `last_confirmed_run`, `run_count`); `state.md`/`outcomes.md` schemas defined once in T3 and referenced in T4/T8.
- **Ordering:** schema (T1) before the runtime migration that uses it (T10); single park/build home (T7) before docs sync (T11); validation last (T12).
