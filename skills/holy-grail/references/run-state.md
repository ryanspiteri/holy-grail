# run-state.md

Durable run-state for holy-grail. This makes resume, mid-run kill, the fire-and-forget finish, and outcome metrics real instead of aspirational. No em-dashes in output.

A run works in `.holy-grail/<slug>/` inside the target repo (gitignored). The skill writes these files there.

## state.md (written at the end of every phase)

Update `.holy-grail/<slug>/state.md` at the end of each phase so the run is always resumable and killable. Schema (markdown, human-readable):

```
phase: <0-7, the phase just completed>
intensity: deep | full | epic
focus: [new-features | design | engineering-health | all]
classification: code | ui | copy | strategy | mixed
repos_worktrees: [repo -> worktree path, one line each]
task_index: <current task number within Phase 3, or "n/a">
round: <improve-loop round, 0 for the main pass>
panel_scores_by_round: [round -> dimension: score, ...]
decision_log:
  - <auto-decided fork>: <choice> (<which of the 6 principles>)
predicted_vs_actual: <north-star metric: predicted delta -> actual delta, or "pending">
parked_user_challenge:
  - <large/strategic item deferred to the report>
```

## Resume (Phase 0 step 1)

If `state.md` exists for this target, read it and continue from `phase + 1` (or re-finish the current phase if it was interrupted mid-phase). Restore the decision log so earlier auto-decisions are not re-litigated. If `state.md` is absent, start fresh at Phase 0.

## Kill / checkpoint

Because state.md is current at every phase boundary, the user can stop the run any time and re-invoke later to resume. No special kill command is needed.

## outcomes.md (appended once per completed run)

Append one row to `.holy-grail/<slug>/outcomes.md` (and, optionally, a machine-global roll-up at `~/.holy-grail/outcomes.md`) so calibration is visible over time:

```
| date | target | focus | north-star metric | predicted delta | actual delta |
```

This is what makes the "predicted improvement" claim falsifiable: over runs you can see whether the skill systematically over-predicts.

## Finish protocol (Phase 6, fire-and-forget)

The run does NOT block on approval. To finish:

1. Persist the final `state.md` and append the `outcomes.md` row.
2. Write `report.md` (objective signals and self-assessed scores in separate sections, per SKILL.md Phase 6).
3. For code: commit, push the branch, open a PR with the report. NEVER auto-merge, NEVER auto-deploy.
4. Notify the user via the Telegram reply tool: one-line summary + the PR link.
5. Exit cleanly. No `AskUserQuestion`. The human reviews and merges when they return.

If an interactive run was explicitly requested, a blocking approval gate may be used instead of steps 3 to 5. The default is hands-off.
