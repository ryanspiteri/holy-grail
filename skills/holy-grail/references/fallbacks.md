# fallbacks.md

Built-in, standalone versions of each conducted skill. Used when `capabilities.json` shows the native skill is absent. These keep holy-grail fully functional with zero ecosystem installed. They are deliberately lighter than the real skills, but they preserve the discipline: brief, plan, per-task build with review, verification, second opinion. No em-dashes in output.

When the native skill IS present, use it instead. These are the floor, not the ceiling.

---

## Brief and plan (fallback for superpowers brainstorming + writing-plans)

When `superpowers` is absent, produce the spec and plan inline.

**Spec (replaces brainstorming):**
1. Restate the problem in one paragraph: what is wrong or missing today, and why it matters.
2. Define the 10-star outcome: what the best version looks like, concretely.
3. List requirements as testable bullets. Mark each must / should / could.
4. List non-goals so scope cannot creep.
5. Sketch the approach in 3 to 6 sentences. Name the files/areas it touches.
6. Save to `.holy-grail/<slug>/02-spec.md`.

**Plan (replaces writing-plans):**
1. Break the work into tasks of about 2 to 15 minutes each. Order them so each builds on the last and leaves the system working.
2. Each task gets: the files to create/modify, the exact change, and how to verify it (the test to write or the check to run). No "TBD", no placeholders.
3. For code, write the test first in the task text (red), then the implementation (green).
4. Save to `.holy-grail/<slug>/03-plan.md`.

---

## Subagent build loop (fallback for superpowers subagent-driven-development)

When `superpowers` is absent, run the build with the Agent tool directly, one task at a time. Never batch.

For each task in the plan:

1. **Implement.** Dispatch one `general-purpose` agent with the full task text, the relevant file paths, and the instruction to follow TDD (write the failing test, see it fail, make it pass, refactor). Ask it to report status: DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED, plus the diff summary and the verification output it actually ran.
2. **Spec review.** Dispatch a second agent (`code-reviewer` if available, else `general-purpose`) with ONLY the task spec and the diff. Ask: does this implement the task as specified, nothing more, nothing less? Report PASS or a list of gaps.
3. **Quality review.** Dispatch a third agent with the diff. Ask: correctness bugs, security issues, edge cases, dead code, convention violations. Report Critical / Important / Minor.
4. **Iterate.** Fix Critical and Important before moving on. Re-review if you changed anything material. Only then mark the task done and start the next.

Rules: one implementer at a time. Reviewers get crafted context, never the chat history. Use a cheap model for mechanical tasks, the strongest model for architecture and review.

---

## Internal red-team review (fallback for codex consult / review / challenge)

When `codex` is absent, run the second opinion as an adversarial subagent. This is the most important fallback: do not skip the second opinion just because codex is missing.

**Consult (on a brief or plan):** dispatch an agent with the artifact and this brief: "You are a skeptical principal engineer. Find what is missing, wrong, or under-specified. List the top issues by severity. Be specific, cite the part you mean."

**Review (on a diff):** dispatch an agent with the base and head state and this brief: "Review this diff for correctness bugs, security holes, race conditions, missing error handling, and broken edge cases. Output findings tagged [P1]/[P2]/[P3]. A [P1] is a real defect that would break production. Then give a verdict: PASS (no P1) or FAIL (list the P1s)."

**Challenge (adversarial, for Epic / risky code):** dispatch an agent with this brief: "Try to break this. What inputs, sequences, or conditions make it fail, leak, corrupt data, or behave wrong? Assume a hostile user and a flaky network. List concrete attacks and the line they hit."

Treat a FAIL like a codex FAIL: fix the P1s, re-run, do not ship until PASS.

---

## Design and QA review (fallback for design-review / qa / gstack)

When the gstack design and QA skills are absent but a browser is available (`browser: true`), or the user supplied a screenshot:

**Design review:** dispatch the Principal Designer persona (see expert-panel.md) with the before/after screenshots. Score visual hierarchy, spacing rhythm (4/8px), typography, colour use, consistency, motion, and "does this look AI-generated". List specific fixes with the element and the change.

**QA:** with a browser, walk the primary user flow: load the page, interact with the key controls, submit the forms, check the error and empty states, check a mobile width. Capture a screenshot at each step. Record any Critical (blocks the user), High (wrong behaviour), Medium (rough edge), or Cosmetic issue. Without a browser, do a static review of the component + a request for the user to confirm one screenshot.

**Post-ship proof:** after deploy, re-open the live surface and capture before/after screenshots for the report. This is required for any UI target regardless of which tools are present.

---

## Memory (fallback for Ruflo)

When `ruflo` is absent, the self-learning loop still works using files only:

- Read/write learnings to `references/playbook.md` (this is the primary store, always present).
- Optionally mirror a one-line pointer into the host's auto-memory `MEMORY.md` if that system exists in the project.
- Skip all `mcp__ruflo__*` calls. Do not error.

The playbook alone is enough to make the loop real: it is read at Phase 0 and written at Phase 7.
