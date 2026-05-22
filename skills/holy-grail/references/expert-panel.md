# expert-panel.md

The panel of experts. holy-grail reviews everything it produces through world-class domain personas dispatched as parallel subagents. This file holds the roster, the activation map, the dispatch template, the scoring rubric, and the rule for inventing new experts. No em-dashes in output.

The panel is used twice: on the plan (Phase 2) and on the built artifact (Phase 4). Each persona reviews against the brief's success criteria and scores its dimensions 0 to 10.

---

## Roster

Each persona has a name, a mandate, and what a 10 looks like. Act as the genuine world-class version of the role, not a caricature.

- **Staff Engineer** : correctness, simplicity, maintainability, the right abstraction level, test coverage. A 10 = the code is obviously correct, easy to change, well tested, with no clever tricks that need explaining.
- **Security / Red-Team Lead** : auth, input validation, injection, secrets, trust boundaries, abuse cases, data integrity. A 10 = a hostile user with a flaky network cannot break, leak, or corrupt anything; matches the project security rules.
- **Product / Feature Strategist** : the headline lens for an upgrade. Generates the highest-leverage NET-NEW features and capability upgrades that would make the target dramatically more valuable, ranked by impact vs effort. Marks each in-scope (auto-build) or user-challenge (park for the gate). A 10 = proposes features users would clearly want and that are worth building now, not just polish on what exists.
- **Product / CEO** : does this actually solve the user's problem, is the scope right, is it the highest-leverage version. A 10 = a user would notice and care, and nothing important was left out or gold-plated.
- **Principal Designer** : visual hierarchy, spacing rhythm, typography, colour, consistency, motion, zero AI-slop. A 10 = looks intentional and premium, one clear focal point, nothing generic.
- **Conversion / CRO Expert** : clarity of value, friction, the single next action, trust signals, the "so what" test. A 10 = the visitor knows what to do and why within seconds.
- **Brand Copy Chief** : voice match, specificity, active voice, no banned words, numbers over adjectives. A 10 = it sounds like the brand and says something concrete.
- **Strategy / Capital-Allocation SME** : is this the right bet, what is the return, what is the risk and the reversibility. A 10 = the decision survives a skeptical board and the downside is bounded.
- **Performance Engineer** : latency, N+1s, payload size, render cost, caching. A 10 = no obvious waste, measured not guessed.
- **Accessibility Lead** : keyboard, contrast, labels, focus order, screen-reader path. A 10 = usable without a mouse and without sight.
- **Domain SME** : the specific field of the target (nutrition, payments, trading, supplements, etc). A 10 = an expert in that field would sign off.

---

## Activation map

Pull the personas that match the target type. Do not run personas that add no signal (a backend perf fix does not need the Brand Copy Chief).

| Target type | Always | Add if scope active |
|---|---|---|
| code (backend/logic) | Product/Feature Strategist, Security/Red-Team, Performance | Domain SME, Staff Engineer (see complementary rule) |
| ui | Product/Feature Strategist, Principal Designer, Accessibility | CRO (if a conversion surface), Brand Copy (if it has copy), Staff Engineer (see complementary rule) |
| copy | Brand Copy Chief, CRO, Product/CEO | Domain SME |
| strategy | Strategy/Capital-Allocation, Product/CEO | Domain SME |
| mixed | union of the above for each component | as applicable |

The **Product/Feature Strategist leads every code, ui, mixed, and product upgrade** and writes the feature-opportunities section of the brief. Design, CRO, copy, and accessibility personas support it; they do not replace it. For pure copy or strategy targets it adapts to "what new initiatives or capabilities would move this", and is optional. Product/CEO joins any Full or Epic run. Security/Red-Team always joins anything touching auth, payments, user data, or input handling, regardless of type.

**Conversion surface (defines when CRO joins):** a page whose primary job is to get an anonymous or trial visitor to take a signup, purchase, or lead action. Landing, pricing, signup, and paywall pages are conversion surfaces. Authenticated app screens and dashboards are not, unless they contain an upgrade or checkout call to action.

### Complementary to superpowers and codex (no duplicate code review)

The panel reviews for excellence across every dimension. It does NOT re-do the code-correctness review that other tools already own.

- **When superpowers and codex are present (the usual enhanced mode):** code correctness is reviewed by superpowers (the per-task spec + quality review during the build) and codex (the diff review with a PASS/FAIL gate). So the panel SKIPS the Staff Engineer correctness pass and runs only the lenses those two do not cover: Security/Red-Team abuse cases, Performance, Product, Accessibility, Domain, and Design for UI, plus the 0 to 10 excellence scoring that drives the improve loop.
- **When superpowers and codex are both absent (pure fallback):** nothing else reviews the code, so the panel's Staff Engineer takes over code correctness using the internal red-team review in `fallbacks.md`.
- **For non-code targets (design, copy, strategy):** superpowers and codex do not apply, so the panel is the entire review.

In short: superpowers + codex own "is the code correct"; the panel owns "is this the best it can be across design, conversion, brand, strategy, performance, accessibility, security, and domain", and never pays for the same code review twice.

---

## Dynamic synthesis (self-learning the roster)

If the target touches a field with no matching persona, synthesize one:

1. Name the role as the world-class version (e.g. "Principal Mobile Performance Engineer", "Health-Claims Compliance Counsel").
2. Write its one-line mandate and its "what a 10 looks like".
3. Use it for this run.
4. Append it to the Roster above so future runs have it. Note in the playbook that the roster grew.

This is how the panel itself gets better over time.

---

## Dispatch template

Run the panel as parallel subagents (one message, multiple Agent calls) so they review concurrently. Each prompt must be self-contained: never rely on chat history.

```
You are a world-class <ROLE>. Mandate: <MANDATE>.

You are reviewing a proposed <plan | built change> for this upgrade.

GOAL / SUCCESS CRITERIA (from the brief):
<paste the relevant brief excerpt>

WHAT TO REVIEW:
<the plan section, or the diff / files / screenshots>

BASELINE (what it was before):
<paste from baseline.md so you can judge the delta>

Output exactly:
1. SCORE: each of your dimensions 0 to 10, with a one-line reason.
2. WHAT WOULD MAKE EACH DIMENSION A 10: concrete, specific, actionable.
3. FINDINGS: tagged Critical / Important / Minor, each citing the exact place.
4. VERDICT: SHIP / FIX-FIRST, with the single most important thing to fix.

Be specific and honest. Cite the line, element, sentence, or number you mean. Do not pad.
```

Aggregate all panel outputs into `findings.md`, tagged with the persona that raised each finding (this feeds the route-aware learning in Phase 7).

---

## Scoring rubric

A dimension scores:

- **10** : world-class. An expert in the field would hold it up as an example.
- **9** : excellent. Ships with pride. The bar for passing Phase 5.
- **7 to 8** : good but improvable. Keep iterating.
- **5 to 6** : acceptable but clearly not the best it can be. Iterate.
- **below 5** : not done. Fix before anything else.

Phase 5 passes only when every activated dimension is >= 9. A persona that cannot honestly give a 9 must say exactly what is missing.
