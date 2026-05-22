# holy-grail v2 design

Date: 2026-05-22. Status: approved, ready for writing-plans. No em-dashes in this doc (the skill's own rule).

## Context

holy-grail is a global, cross-project Claude Code skill: it runs on EVERY project Ryan works on, not just NewU. It conducts superpowers + gstack + codex to take any target (code, ui, copy, strategy) from its current state toward the best version, with one up-front focus question and one approval gate before shipping.

A three-expert analysis (plus the runtime playbook evidence from real runs on NewU leads, Entwine, and the ONEST money path) found the single-run engine genuinely works (it has caught real shippable-grade defects that green tests missed), but the skill describes more than it implements. This v2 fixes that.

## Overarching purpose (the autonomy model)

holy-grail is a fire-and-forget upgrader. The user runs it, optionally answers one up-front focus question (or puts the focus in the command), then leaves. It then autonomously upgrades, improves, ADDS NEW FEATURES, tests, reviews, and writes, repeats that full cycle 3 more times, then does a final check, with ZERO further prompting. The user returns to something dramatically improved.

Two consequences that shape the whole design:

1. **No prompting after the start.** The only acceptable interactive prompt is the single up-front focus question, answered before the user walks away (and skippable if the focus is in the command). There are NO mid-run questions and NO blocking approval gate. Auto-decide every fork via the principles; for a genuine user-challenge fork, decide the safe default, log it, and surface it in the final report rather than blocking.
2. **It ends at a PR, not a merge.** The run completes all work and ends by opening a PR (with the full report) and notifying via Telegram. The human reviews and merges asynchronously when they return. This keeps the one safety line (never auto-merge or auto-deploy) while being fully hands-off. "Leave and come back" means come back to a finished, tested, reviewed PR.

**Loop cadence (explicit):** the core cycle is build/improve/add-features/test/review/write. Run it as the main pass PLUS 3 improvement rounds PLUS a distinct final check (4 cycles + final verification). Stop a round early only if there is genuinely nothing worthwhile left; default to running the full cadence so the result is dramatically, not marginally, improved.

## Goals

1. Make the self-learning loop real (it currently accumulates, never merges, promotes, or decays).
2. Make run-state real (state.md is referenced but never written; resume is fake).
3. Make the claims honest (drop banned words, label self-assessed scores as such, separate from objective signals).
4. Make the flow coherent (resolve persona-layer precedence, loop convergence, de-dup, parallel build).
5. Add observability, multi-repo handling, a project-context primitive, a propose-only mode.
6. Harden bootstrap/install for fresh machines.
7. **Cross-project correctness: keep the skill strictly project-agnostic, and separate universal lessons from project-specific ones so cross-project use never cross-contaminates.**

## Non-goals

- No new external dependencies. Still self-contained with fallbacks.
- Do not weaken the safety floors: never auto-merge or auto-deploy, always review before the PR. (The blocking human gate is removed in favor of ending at a PR the human merges asynchronously; the no-auto-merge line stays absolute.)
- Not rewriting the proven engine (codex-iterate-to-SHIP, red-team-on-access-control stay).

## Cross-project principle (the framing constraint)

The skill must work identically on any repo or stack. Concretely:

- **No hardcoded project assumptions** anywhere in the shipped files (already mostly true; audit and remove any remaining).
- **Two-tier memory:**
  - **Universal playbook** (`references/playbook.md`, per-machine, gitignored, seeded from `playbook.seed.md`): holds only generalizable process/technique lessons that apply across projects. The "Always-apply" block lives here.
  - **Project memory** (`.holy-grail/project.md` inside each target repo): holds that project's conventions and project-specific lessons. Travels with the project. Never pollutes other projects.
- **Project-context primitive:** at Phase 0, read the host `CLAUDE.md` (and `.holy-grail/project.md` if present) as authoritative project context: stack, test command, deploy method, merge policy, repos, brand voice. Stops per-run rediscovery and missed conventions.
- **Phase 7 routing of lessons:** the retro decides per lesson, does this generalize beyond this project? Universal -> universal playbook. Project-specific -> the project's `.holy-grail/project.md`.

## Design by subsystem

### A. Self-learning loop (trigger-indexed + merge + promote + decay)

- Lesson schema gains: `trigger:` (retrieval condition, e.g. `irreversible-external-action`, `access-control-diff`, `money-column-migration`, `live-url-fixed-port`, `parallel-subagents`), `scope:` (universal | project), `last_confirmed_run:` (integer).
- A global **run counter** at the top of the playbook, incremented every Phase 7.
- **Phase 0 retrieval (trigger-driven):** after reading the brief scope, list the conditions this run hits; load (a) the Always-apply block, (b) universal lessons whose `trigger` matches, (c) the current project's `.holy-grail/project.md`. Cap: Always-apply + up to 8 trigger-matched lessons ranked by confidence then count. State which lessons are being applied.
- **Phase 7 merge-before-append:** for each candidate lesson, search existing lessons for the same `trigger` + corrective action. If matched, increment `count`, append this run to evidence, bump `confidence`, set `last_confirmed_run`. Only append a new entry when nothing matches.
- **Promotion:** when `count >= 3` or clearly structural, copy the lesson into SKILL.md's "Learned additions" / the Always-apply block, log it in the Changelog, and verify it now appears in SKILL.md.
- **Decay (now executable):** new singletons start at `confidence: low`; `current_run - last_confirmed_run > 10 && confidence: low -> delete`.
- **One-time backfill:** merge the three existing adversarial/security singletons (codex-iterate-to-SHIP, red-team-access-control, panel-on-the-plan-for-money) into one promoted Always-apply lesson, so the file starts honest.

### B. Durable run-state

- Define and WRITE `.holy-grail/<slug>/state.md` at the end of each phase: `phase`, `intensity`, `focus`, `classification`, `decision_log` (auto-decided forks), `repos_worktrees`, `task_index`, `panel_scores_by_round`, `predicted_vs_actual`.
- **Resume:** Phase 0 step 1 reads state.md and continues from `phase`.
- **Kill/checkpoint:** state is always current, so stopping any time is safe.
- **Finish protocol (default, hands-off):** Phase 6 does NOT block. It persists state, opens a PR (with the full report), notifies via the Telegram reply tool, and exits. The human reviews and merges asynchronously. There is no blocking approval gate in the default fire-and-forget mode. (An interactive blocking gate exists only if the user explicitly asks to run interactively.)
- **Outcomes ledger:** append predicted/actual north-star delta per run to `.holy-grail/<slug>/outcomes.md` (and a machine-global roll-up) so calibration is visible over time.

### C. Honesty (ambition as aim, honest on results)

- Remove banned words from the instructions: "world-class", "cannot be bettered", and similar. Keep the name holy-grail and the goal of aiming for the best version.
- Panel 0-10 scores are labelled **self-assessed** everywhere, and the Phase 6 report puts them in a separate section from **objective signals** (tests pass, codex PASS/FAIL, QA health, real metric delta).
- **Cadence over plateau:** the default is the full cadence (main pass + 3 improvement rounds + final check). A round stops early ONLY when every dimension >= 9 (self-assessed) AND no open Critical/Important finding AND the last cycle's additions moved no north-star metric. Default to completing the cadence, because the user wants dramatic, not marginal, improvement.
- **Proof split:** in-run = local/preview proof (screenshot of the dev/preview build); production proof = post-merge, post-deploy, possibly async, and for mobile may be impossible in-loop. The report states which kind was achieved.

### D. Flow consistency + convergence

- **Persona precedence, stated once in expert-panel.md:** target type gives the candidate set -> the focus question filters it (intersection) -> the complementary rule drops the panel's correctness pass when codex is present -> Security/Red-Team is an always-on floor for auth/payments/user-data/input. Resolve the conflict where the Design focus drops the Feature Strategist (the lead persona): if a focus is chosen, run that focus's personas; the Feature Strategist leads only when New features or All is in focus.
- **Convergence without limiting features:** the run is bounded by the fixed cadence (main + 3 rounds + final check), the per-intensity subagent budget, and the blast-radius cap. Within those bounds, adding new features across cycles is expected and desired (it is the point of the skill). Defects loop until clear within each cycle. Only user-challenge-class items (new product direction, spend, pricing, legal, irreversible) are deferred to the report, not built.
- **Core Invariants cleanup:** move the auto-build authorization OUT of the locked Core Invariants (it is a capability decision) into the Autonomy section. The locked block keeps only true safety floors, and the Phase-6 "blocking human gate" invariant is replaced by "never auto-merge or auto-deploy; the run ends at a PR and the human merges asynchronously" (the PR merge is the approval, done when the user returns).
- **De-dup:** define the park/build classification and the value-vs-effort bar exactly once (in auto-decisions.md section 4) and reference it from the phases. Consolidate the overlapping Operating Principles / Autonomy / Red-flags so each rule appears once. Trim SKILL.md.
- **Parallel build codified (Phase 3):** fan independent features to parallel subagents on strictly disjoint file sets; serialize schema + migration-journal edits to one agent. Resolve the "Never batch" contradiction (one task at a time applies WITHIN a feature; independent features may parallelize).
- **Conditional plan-panel (Phase 2):** run the full parallel persona panel on the PLAN only for Epic / money / auth / multi-tenant targets; otherwise codex-on-the-plan suffices.

### E. Observability + new capabilities

- **Run ledger** in the Phase 6 report: phases run, intensity, subagents dispatched, improve rounds used, codex passes.
- **Soft subagent budget per intensity** (Deep <= 5, Full <= 15, Epic <= 30); exceeding forces a checkpoint, not silent continuation. Counterweight to "boil the lake".
- **Multi-repo handling:** Phase 0 detects N target repos; the plan uses N worktrees / N PRs and flags cross-repo contract changes (e.g. an API schema change consumed by a frontend and a mobile app).
- **propose-only mode:** a modifier that runs Phases 0 to 2 + panel and stops with a brief + plan, no build.
- **Blast-radius cap:** an auto-built feature that exceeds 10 changed files, or touches the database schema or a migration, escalates to the gate instead of building silently.

### F. Robustness (bootstrap.sh / install.sh)

- codex usability keys off `codex_cli && codex_auth`, not a bare `OPENAI_API_KEY`. The skill warns AT RUNTIME when the "independent" review is the self-played fallback.
- gstack `./setup` runs with `</dev/null` and a `timeout`, and the clone is pinned to a reviewed ref (not blind HEAD execution).
- ruflo detection is not cwd-dependent.
- `install.sh` reads back `capabilities.json` at the end and reports the actual mode (for example "FALLBACK: superpowers and codex are not active") instead of an unconditional "done".

## Files to change

- `skills/holy-grail/SKILL.md` (most: phases 0/2/3/5/6/7, principles, invariants, autonomy, red-flags, frontmatter description)
- `skills/holy-grail/references/auto-decisions.md` (single home for park/build + value bar; multi-repo; budgets; propose-only; proof split)
- `skills/holy-grail/references/expert-panel.md` (persona precedence; self-assessed labeling)
- `skills/holy-grail/references/playbook.seed.md` (new schema, run counter, Always-apply block, trigger field)
- `skills/holy-grail/references/playbook.md` (runtime: backfill-merge the 3 security singletons; em-dash cleanup) [gitignored, machine-local]
- `skills/holy-grail/references/run-state.md` (NEW: state.md + outcomes.md schema + gate-while-away protocol)  OR fold into auto-decisions
- `scripts/bootstrap.sh`, `install.sh` (robustness fixes)
- `.claude-plugin/plugin.json`, `README.md` (description sync, teammate-playbook note)
- `tests/test-prompts.md` (add cases: cross-project routing, propose-only, multi-repo, gate-while-away, self-learning merge)

## Verification

- **Self-learning:** simulate two runs hitting the same trigger; confirm the second MERGES (count -> 2) instead of appending a duplicate; confirm a count-3 lesson promotes into SKILL.md + Changelog; confirm a low-confidence stale lesson decays. Backfill merge reduces the 3 security singletons to 1 promoted lesson.
- **Run-state:** confirm state.md is written after each phase and a simulated resume continues from the recorded phase.
- **Honesty:** grep shipped files for banned words (none); report template separates self-assessed scores from objective signals.
- **Cross-project:** confirm no hardcoded project name in shipped files; a project-specific lesson lands in `.holy-grail/project.md`, not the universal playbook.
- **Flow:** the 4 original RED/GREEN routing tests still pass; new tests (propose-only, multi-repo, gate-while-away) route as expected; persona precedence resolves the Design-focus-vs-Feature-Strategist case deterministically.
- **Robustness:** bootstrap with `OPENAI_API_KEY` set but no codex CLI reports `codex:false`; install.sh on a fallback machine reports FALLBACK mode.
- **No em-dashes** anywhere in shipped files. SKILL.md stays under 500 lines after de-dup.
