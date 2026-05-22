# playbook.seed.md (shipped template)

This is the SEED. On first run, holy-grail copies it to `playbook.md` (which is gitignored) and writes all learnings there. That keeps each machine's lessons local, so private, business-specific learnings never get committed or pushed, even from a public repo.

The runtime `playbook.md` is the self-learning memory: READ at Phase 0 (load applicable lessons, state which you are applying) and WRITTEN at Phase 7 (append what this run taught). It is the reason the skill gets sharper every run. No em-dashes in output.

This seed ships with generic starter lessons. Each install grows its own runtime copy. To share a genuinely generic lesson with everyone, add it here in the seed and commit it.

---

## How to use this file

**At Phase 0:** read the Lessons and the Finding ledger. Find the entries whose `target type` matches this run. State out loud which lessons you are applying and which low-value reviewers you are skipping this run.

**At Phase 7:** append one Lesson entry using the template. Update the Finding ledger. If a lesson has now appeared 3 or more times (its `count` reaches 3) or is structural, promote it into SKILL.md's "Learned additions" section and log it in the Changelog. Decay: if a lesson has `confidence: low` and has not been confirmed in the last 10 runs, delete it.

A lesson is only valid if it is specific, measurable, and actionable. The required shape is **"Next time, do X, because Y (evidence: this run)."** A vague observation with no action is discarded, not saved.

---

## Lesson entry template

```
### <short title>
- date: <YYYY-MM-DD>
- target type: code | ui | copy | strategy | mixed
- intensity: deep | full | epic
- lesson: Next time, do X, because Y.
- evidence: <what happened this run that proves it>
- confidence: low | medium | high
- count: <times this lesson has recurred>
```

---

## Lessons (seeded, generic)

### A second opinion catches real defects single-pass work misses
- date: seed
- target type: code
- intensity: full
- lesson: Next time, always run codex review (or the internal red-team fallback) before shipping, because an independent reviewer reliably finds correctness or security defects that the implementer missed.
- evidence: across many feature builds, an independent review surfaces a real P1 in a large fraction of changes, not noise.
- confidence: high
- count: 1

### Measure before estimating a performance win
- date: seed
- target type: code
- intensity: full
- lesson: Next time, profile or measure the actual bottleneck before predicting the improvement, because the assumed cause is often not the real one and the predicted delta is wrong.
- evidence: perf upgrades that guessed the cause mis-predicted the result; measured ones did not.
- confidence: high
- count: 1

### Done means verified on the live surface, not just green tests
- date: seed
- target type: ui
- intensity: full
- lesson: Next time, re-open the real surface after deploy and capture before/after screenshots, because a passing test suite does not prove the user sees the improvement.
- evidence: changes that passed tests still looked wrong or did not render until checked on the real surface.
- confidence: high
- count: 1

### Right-size the pipeline to the target
- date: seed
- target type: mixed
- intensity: deep
- lesson: Next time, drop to Deep intensity for genuinely small, low-risk changes, because running the full panel on a typo wastes the run without improving the thing.
- evidence: full ceremony on trivial targets adds time and no quality.
- confidence: medium
- count: 1

---

## Finding ledger (route-aware)

Per target type, tally which reviewers produced real fixes (signal) vs findings that were dropped (noise). Future runs of that target type keep high-signal reviewers and drop low-signal ones. Update at Phase 7.

```
| target type | reviewer | real fixes | dropped | keep? |
|-------------|----------|-----------:|--------:|-------|
| (seed: no runs yet) | | | | |
```

---

## Changelog (SKILL.md promotions)

Log every lesson promoted into SKILL.md's "Learned additions" section, with the date and the lesson title, so self-edits are auditable.

```
(none yet)
```
