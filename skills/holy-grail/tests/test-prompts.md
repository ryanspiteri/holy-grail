# test-prompts.md

RED/GREEN validation prompts for holy-grail (skill-creator discipline). Each prompt states what a correct Phase 0 ingestion + routing should select. Run these against the skill via a subagent and confirm the selections match. If they do not, fix the wording in SKILL.md or auto-decisions.md until they do. No em-dashes in output.

A "GREEN" result means the skill, when given the prompt, correctly classifies the target, sets a sensible intensity, and selects the expected phases and reviewers, before doing any work.

---

## Test 1 : backend performance (code)

**Prompt:** "upgrade the admin Clients page load time, it takes 30 seconds"

**Expected routing:**
- Target type: code (with a ui surface named, but the work is backend perf).
- Intensity: Full.
- Ingestion: locate the page route and trace to the resolver/query (route-to-source).
- Reviewers activated: Staff Engineer, Performance Engineer, Security/Red-Team (touches user data). NOT Brand Copy, NOT CRO.
- Second opinion: codex review (or red-team fallback). codex challenge optional.
- Build: worktree + TDD.
- Phase 1 must capture a baseline timing and predict a target.
- Design-review/qa: NOT run (no visual change).

---

## Test 2 : landing page (ui + copy)

**Prompt:** "make the macro-calculator landing page the best it can be"

**Expected routing:**
- Target type: mixed (ui + copy).
- Intensity: Full.
- UI scope active by classification (a landing page is ui), not by keyword count.
- Reviewers activated: Principal Designer, CRO Expert, Brand Copy Chief, Accessibility, Product/CEO.
- Phase 1 benchmarks against best-in-class landing pages.
- Phase 3 explores 2 to 3 variants before converging.
- Phase 4 runs design-review + qa (or fallback) + the panel.
- Phase 6 captures before/after screenshots of the live page.

---

## Test 3 : strategy (no code)

**Prompt:** "upgrade my pricing strategy for the coaching product"

**Expected routing:**
- Target type: strategy.
- Intensity: Full (a strategy doc is reversible; Epic is reserved for a pricing model that ships in code).
- Reviewers activated: Strategy/Capital-Allocation SME, Product/CEO, Domain SME. 
- NO worktree, NO TDD, NO codex code review, NO design-review. This is the key check: the code machinery must NOT run for a pure strategy target.
- Pricing change is a "user challenge" decision class: it is parked for the Phase 6 gate, never auto-decided.
- Output is a strategy document + recommendation, not a diff.

---

## Test 4 : multimodal input (live URL + screenshot)

**Prompt:** "upgrade this <URL of a screen in your own app>" with an attached screenshot of it

**Expected routing:**
- Ingestion: open the URL with browse/gstack, screenshot it, AND read the attached screenshot. Both become the baseline. Do NOT ask the user to describe it in text.
- If the URL maps to a local repo: map the route to its source component; target type ui or mixed; reviewers Principal Designer, Staff Engineer, Accessibility; code machinery runs for the editable source; Phase 6 re-opens the live surface for before/after proof.
- If the URL maps to no local repo (an external or placeholder host such as example.com): degrade to screenshot-only per the route-to-source rule; deliverable is a design or copy spec; NO route-to-source, NO Staff Engineer, NO code machinery.
- CRO joins only if the surface is a conversion surface. A bare dashboard or authenticated app screen is not, unless it has an upgrade/checkout CTA.

---

## Negative test : no false trigger

**Prompt:** "upgrade gstack to the latest version"

**Expected:** holy-grail does NOT activate. This routes to the gstack-upgrade skill. The description's exclusion clause must hold.

**Prompt:** "upgrade my paywall conversion rate"

**Expected:** holy-grail does NOT activate. This routes to paywall-upgrade-cro, named in the description's exclusion clause.
