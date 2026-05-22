# playbook.seed.md (shipped template)

This is the SEED. On first run, holy-grail copies it to `playbook.md` (which is gitignored) and writes all learnings there. That keeps each machine's lessons local, so private, business-specific learnings never get committed or pushed, even from a public repo.

The runtime `playbook.md` is the self-learning memory: READ at Phase 0 (load the applicable lessons, state which ones you are applying) and WRITTEN at Phase 7 (merge or append what this run taught). It is the reason the skill gets sharper every run. No em-dashes in output.

This seed holds only universal lessons: generalizable process and technique that apply across any project or stack. Project-specific conventions and lessons never live here. They live in each target repo's `.holy-grail/project.md`. To share a genuinely universal lesson with everyone, add it here in the seed and commit it.

run_count: 0

---

## How to use this file

### Phase 0 retrieval (trigger-driven)

1. After reading the brief scope, list the conditions this run hits (for example: an irreversible external action, an access-control diff, a money-column migration, a fixed-port live URL, parallel subagents).
2. Load the **Always-apply** block in full. It applies to every run regardless of trigger.
3. Then load up to **8** lessons from the trigger-indexed section whose `trigger` matches a condition this run hits. Rank candidates by `confidence` (high before medium before low), then by `count` (higher first). Take the top 8.
4. State out loud which lessons you are applying and which low-value reviewers you are skipping this run.

### Phase 7 merge-before-append

For each candidate lesson this run produced:

1. FIRST search the existing lessons for one with the same `trigger` AND the same corrective action.
2. If a match exists: increment its `count`, append this run to its `evidence`, bump its `confidence` (low to medium to high), and set its `last_confirmed_run` to the current `run_count`. Do NOT add a duplicate entry.
3. ONLY when nothing matches: append a new entry using the template. New singletons START at `confidence: low`.
4. Increment `run_count` by 1 (it is incremented once per Phase 7).
5. Update the Finding ledger for this run's target type.

A lesson is only valid if it is specific and actionable. The required shape is **"Next time, do X, because Y."** A vague observation with no action is discarded, not saved.

### Promotion

When a lesson reaches `count >= 3`, or is clearly structural (it changes how a whole class of runs should behave), copy it into the **Always-apply** section, log it in the Changelog with the date and the lesson title, and then verify it now appears in the Always-apply section before moving on.

### Decay

When `run_count - last_confirmed_run > 10` AND the lesson is `confidence: low`, delete the lesson. Stale, unconfirmed, low-confidence lessons do not earn a permanent slot.

---

## Lesson entry template

```
### <short title>
- trigger: <retrieval condition, e.g. irreversible-external-action | access-control-diff | money-column-migration | live-url-fixed-port | parallel-subagents>
- scope: universal | project
- target type: code | ui | copy | strategy | mixed
- lesson: Next time, do X, because Y.
- evidence: <what happened that proves it>
- confidence: low | medium | high
- count: <times this lesson has recurred>
- last_confirmed_run: <run_count when last confirmed>
```

---

## Always-apply (promoted, runs every time)

These lessons have earned a permanent slot. Load all of them at Phase 0 regardless of trigger.

### Hammer the adversarial reviewer on irreversible/money/access-control diffs
- trigger: irreversible-or-access-control-or-money
- scope: universal
- target type: code
- lesson: On any diff with an irreversible external action, money handling, or access control, run the adversarial reviewer (codex or the red-team fallback) hard and iteratively, including on the plan, until it returns SHIP, because these defect classes surface in waves and a green test suite misses them.
- evidence: backfilled from three confirming runs (codex iterate-to-SHIP, red-team on access control, panel-on-the-plan for money); each independent pass kept finding new high-severity defects that tests had passed.
- confidence: high
- count: 3
- last_confirmed_run: 0

---

## Lessons (trigger-indexed, universal seeds)

These ship as universal starter lessons. Each install grows its own runtime copy via the merge-before-append loop above.

### A second opinion catches real defects single-pass work misses
- trigger: pre-ship-review
- scope: universal
- target type: code
- lesson: Next time, always run codex review (or the internal red-team fallback) before shipping, because an independent reviewer reliably finds correctness or security defects that the implementer missed.
- evidence: across many feature builds, an independent review surfaces a real P1 in a large fraction of changes, not noise.
- confidence: high
- count: 1
- last_confirmed_run: 0

### Measure before estimating a performance win
- trigger: performance-change
- scope: universal
- target type: code
- lesson: Next time, profile or measure the actual bottleneck before predicting the improvement, because the assumed cause is often not the real one and the predicted delta is wrong.
- evidence: perf upgrades that guessed the cause mis-predicted the result; measured ones did not.
- confidence: high
- count: 1
- last_confirmed_run: 0

### Done means verified on the live surface, not just green tests
- trigger: live-url-fixed-port
- scope: universal
- target type: ui
- lesson: Next time, re-open the real surface after deploy and capture before/after screenshots, because a passing test suite does not prove the user sees the improvement.
- evidence: changes that passed tests still looked wrong or did not render until checked on the real surface.
- confidence: high
- count: 1
- last_confirmed_run: 0

### Right-size the pipeline to the target
- trigger: trivial-low-risk-target
- scope: universal
- target type: mixed
- lesson: Next time, drop to Deep intensity for genuinely small, low-risk changes, because running the full panel on a typo wastes the run without improving the thing.
- evidence: full ceremony on trivial targets adds time and no quality.
- confidence: medium
- count: 1
- last_confirmed_run: 0

---

## Finding ledger (route-aware)

Per target type, tally which reviewers produced real fixes (signal) vs findings that were dropped (noise). Future runs of that target type keep high-signal reviewers and drop low-signal ones. Update at Phase 7.

```
| target type | reviewer | real fixes | dropped | keep? |
|-------------|----------|-----------:|--------:|-------|
| (seed: no runs yet) | | | | |
```

---

## Changelog (Always-apply promotions)

Log every lesson promoted into the Always-apply section, with the date and the lesson title, so self-edits are auditable.

```
seed: Hammer the adversarial reviewer on irreversible/money/access-control diffs (backfilled from 3 security singletons)
```
