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

---

## Test 5 : cross-project (non-NewU Python repo)

**Prompt:** "upgrade my Django REST API's auth" on a non-NewU Python repo

**Expected routing:**
- Generic routing: NO NewU assumptions, no hardcoded project context. The skill is project-agnostic.
- Phase 0 recall reads THIS repo's `CLAUDE.md` and `.holy-grail/project.md` as the authoritative project context (stack, test command, deploy, merge policy), not NewU's.
- Target type: code.
- Reviewers: Engineering health personas (Security/Red-Team, Performance, Staff Engineer) plus features as relevant. Security/Red-Team is the always-on floor (auth target).
- Any lesson learned routes to THIS repo's `.holy-grail/project.md` if project-specific, the universal playbook only if it generalizes.

---

## Test 6 : propose-only mode

**Prompt:** "propose how you'd upgrade the checkout, don't build it"

**Expected routing:**
- Propose-only modifier detected ("don't build it").
- Runs Phases 0 to 2 plus the expert panel only: ingest, classify, intensity, brief, plan, panel on the plan.
- STOPS there with the brief + plan (parked user-challenge forks and value-vs-effort calls noted).
- NO build, NO worktree source edits, NO PR.
- Announce line states propose-only.

---

## Test 7 : multi-repo feature (API + web + mobile)

**Prompt:** "upgrade the messaging feature" spanning an API repo + a web repo + a mobile repo

**Expected routing:**
- Phase 0 detects N repos (3); records each in state.md.
- Plan uses N worktrees and N PRs (one isolated worktree + one PR per repo); no editing a second repo from the first's worktree.
- Cross-repo contract changes (API/GraphQL shape, shared type, webhook payload consumed by web + mobile) flagged explicitly and updated in every consuming repo in the SAME run.

---

## Test 8 : fire-and-forget finish (user away)

**Prompt:** any normal code upgrade with the user away

**Expected routing:**
- NO blocking `AskUserQuestion` gate at the finish. The default is hands-off.
- Phase 6 ends by opening a PR (with the report) + Telegram notify + clean exit.
- NEVER auto-merges, NEVER auto-deploys. The human merges asynchronously.

---

## Test 9 : self-learning merge (second run, same trigger)

**Prompt:** a second run hitting trigger "irreversible-external-action"

**Expected behavior:**
- Phase 7 merge-before-append: searches existing lessons for the same trigger + corrective action, finds the match, increments `count`, appends evidence, bumps `confidence`, sets `last_confirmed_run`.
- Does NOT append a duplicate entry.
- `run_count` increments by 1.

---

## Test 10 : persona precedence (Design focus on a payments screen)

**Prompt:** "ui target, focus = Design & UX only, on a payments screen"

**Expected routing:**
- Target type: ui (candidate set includes Feature Strategist, Principal Designer, Accessibility, CRO/Brand as applicable).
- Focus = Design & UX filters the set: Feature Strategist OFF (does not run under a Design & UX only focus).
- Principal Designer, Accessibility ON (CRO/Brand if surface qualifies).
- Security/Red-Team ON regardless (the always-on floor: payments screen touches payments).
