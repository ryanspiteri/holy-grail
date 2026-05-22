# auto-decisions.md

The routing brain for holy-grail. SKILL.md reads this at Phase 0 to ingest the input, classify the target, set intensity, check capabilities, and to auto-decide forks during the run. No em-dashes anywhere in shipped output.

---

## 0. Ingestion matrix (Phase 0, first thing)

The target can arrive in any modality. Detect it and capture a baseline before doing anything else.

| Input looks like | How to detect | What to do | Baseline captured |
|---|---|---|---|
| Live URL | starts with `http://`/`https://`, or "this page/tab/screen" + a link | Open with `browse`/`gstack`, screenshot it, then map the route to source (see route-to-source below) | screenshot + the source files behind it |
| Screenshot / image | a file path ending `.png/.jpg/.jpeg/.webp`, or an attached image in the message | Read it visually. Treat it as both the current state and the "make this better" target | the image itself + any on-screen text transcribed |
| File / folder path | an absolute or repo-relative path that exists | Read the file or list the folder | the current contents |
| Figma link | `figma.com/file` or `figma.com/design` | Use the `figma` skill to pull frames/specs | the design frames |
| Plain description | none of the above | Proceed on the description. If it names a thing in the repo, locate it first | the described current state |

If two modalities arrive together (a URL plus a screenshot), use both: the screenshot is the "what is wrong / what good looks like" signal, the URL is the editable surface.

### Route-to-source mapping (for live URLs in a known repo)

Goal: turn a page the user points at into the files you can actually edit.

1. Identify the app and router. For the NewU portal the React routes live in `newu.portal/src/routes/` and screens in `newu.portal/src/screens/<area>/`. For other repos, find the router config (search `createBrowserRouter`, `<Route`, `router`, `pages/`, `app/`).
2. Match the URL path to the route element, then to the screen/page component.
3. Trace the component's data layer: the API endpoint, GraphQL resolver/mutation, and model it touches. Record these in `baseline.md` as the edit surface.
4. If the URL is production and the repo is local, confirm the local code is the same version (git branch, last deploy) before editing.
5. If the URL maps to no local repo at all (an external or unknown host, or a placeholder), degrade to screenshot-only mode: the live capture plus any supplied screenshot are the baseline, the deliverable is a design or copy spec or a recommendation, and the code machinery (worktree, TDD, codex diff review) does NOT run because there is no editable source. Say this in the announce line.

---

## 1. Target classification

Classify into one primary type (a target can be mixed; pick the dominant and note secondaries). This selects which reviewers and phases run.

- **code** : source files, a feature, a bug, performance, an API, a data model, tests, infra.
- **ui** : a screen, page, component, layout, visual design, a flow a user sees.
- **copy** : marketing copy, landing page text, emails, product strings, naming.
- **strategy** : a business decision, pricing, positioning, a plan, a go-to-market, a doc.
- **mixed** : clearly two or more (e.g. a landing page = ui + copy; a new feature with a UI = code + ui).

### Scope detection (which review tracks activate)

Two ways a track activates. Classification wins over the keyword counter.

1. **Classification first (authoritative).** If the target type from above is `ui` or `mixed` with a ui part, UI scope IS active regardless of keyword count. A landing page, a dashboard, a screen, a component are ui by classification, full stop. Likewise a target classified `code` with an API/CLI/SDK part has DX scope active.
2. **Keyword counter (only promotes a borderline `code` target to also run a track).** Use this when classification landed on plain `code` but the work might still touch a surface:
   - **UI scope** also active only when the change will alter what the user sees. Promote on 1+ inherently visual noun (dashboard, landing page, screen, modal, layout, form) OR 2+ of: component, button, sidebar, nav, navigation, dialog, hero, card, menu, responsive, mobile view. A purely non-visual change behind a surface (load time, latency, a query, the data or API behind a page) does NOT promote UI scope even though a page is named. The test is "does the pixels the user sees change", not "is a surface mentioned".
   - **DX scope** also active when the product is a developer tool, or 2+ of: API, endpoint, REST, GraphQL, webhook, CLI, command, flag, SDK, package, npm, pip, import, developer docs, MCP, agent, library, integration.
   - **CRO scope** active when the surface has a conversion action: a signup, checkout, upgrade, purchase, or primary lead call to action. Landing, pricing, signup, and paywall pages qualify. A bare dashboard or authenticated app screen does not, unless it carries an upgrade or checkout CTA.

UI scope active adds the Principal Designer persona + design-review/qa in Phase 4. DX scope active adds the DX persona. CRO scope active adds the Conversion/CRO persona. A pure backend perf fix (type `code`, no ui/dx surface) has neither active, so no design-review (do not waste the round).

**Code machinery runs only for code.** Worktree, TDD, and codex diff review/challenge run only when the target type is `code`, or for the code portion of a `mixed` target. Pure `strategy` and pure `copy` targets never run them. Their second opinion is codex consult on the document, and their review is the expert panel plus the internal red-team.

---

## 2. Intensity right-sizing

Set intensity at Phase 0. The floor is always thorough: every run does brief, plan, build, review, verify, retro. Intensity only adds depth for bigger targets. Never run the full ceremony on a trivial change, and never skip the floor on a big one.

| Intensity | When | What changes vs the floor |
|---|---|---|
| **Deep** | small, contained, low blast radius (a copy tweak, one-component fix, a typo, a single function) | One review round. Panel = the 1 to 2 most relevant personas. Skip variant exploration. Skip worktree if the change is a few lines (still branch). |
| **Full** (default) | a normal feature, page, or fix | The pipeline as written. Panel = all activated personas. Up to 3 improve rounds. |
| **Epic** | large, cross-cutting, high blast radius (a subsystem, a redesign, a pricing model that ships in code, anything touching auth/payments/data integrity) | Wider panel + an extra adversarial round. Mandatory codex challenge. Mandatory worktree. Consider splitting into sequenced sub-upgrades, each run through the floor. |

Deliverable disambiguation: a change that ships to production (a live pricing model, an auth change) is Epic. A document or recommendation about the same thing (a pricing strategy doc) is Full, because the doc is reversible and only acting on it is high blast radius. Either way, the direction itself is parked as a user-challenge fork for Phase 6.

Right-sizing rule of thumb: if doing the full panel would take longer than the change itself and the change is genuinely low-risk, drop to Deep. If you are unsure, go one level up, not down. Quality bar never drops with intensity, only breadth does.

---

## 3. Capability map (what is installed)

Read `~/.holy-grail/capabilities.json` (written by `scripts/bootstrap.sh`). If absent or older than 24h, run bootstrap to (re)build it. Shape:

```json
{ "superpowers": true, "codex": false, "gstack": false, "browser": true, "ruflo": true, "git": true, "updated": "<iso8601>" }
```

Route each conducted step to its native skill when present, else to `references/fallbacks.md`:

| Step | Native (if present) | Fallback (always available) |
|---|---|---|
| brainstorm + plan | superpowers brainstorming + writing-plans | fallbacks.md "Brief and plan" |
| build | superpowers subagent-driven-development + TDD | fallbacks.md "Subagent build loop" |
| second opinion on brief/plan/diff | codex consult/review/challenge | fallbacks.md "Internal red-team review" |
| plan panel | autoplan | expert-panel.md manual dispatch |
| UI review | design-review + qa + gstack | fallbacks.md "Design and QA review" + browser screenshots |
| memory | ruflo memory_store/search | auto-memory files + the playbook only |

State the mode in the announce line, e.g. "running enhanced (superpowers + codex), gstack fallback for QA".

---

## 3.5 Design and asset toolchain

For ui, design, and brand-facing targets, use these when available (detected at runtime by whether the skill or tool is in your list). The fallback for all of them is the Principal Designer persona plus the browser. Never ship a generic AI-slop UI even in pure fallback mode.

| Need | Tool (use if present) | Fallback |
|---|---|---|
| Establish a design system, or no `DESIGN.md` exists | `design-consultation` | infer the system from the existing UI, write a short `DESIGN.md` |
| Explore visual directions before building | `design-shotgun` | produce 2 to 3 distinct directions yourself, screenshot each, pick the strongest |
| Build distinctive, non-generic UI code | `frontend-design` | Principal Designer + Staff Engineer personas, hand-written components, no default library look |
| Pull or push Figma designs | `figma` skills | read the supplied screenshot or spec instead |
| Generate or edit visual assets (icons, hero images, illustrations, OG images, backgrounds) | `nano-banana-pro` or `higgsfield-generate` | use an existing asset or a CSS/SVG treatment, never fake it with stretched stock |
| Plan-stage design critique | `plan-design-review` | the Principal Designer persona reviews the plan (Phase 2) |
| Built-UI visual critique | `design-review` + `qa` | the design and QA fallback in `references/fallbacks.md` |

Hard rule for any ui target: a custom palette, intentional 4/8px spacing, one clear focal point, distinctive typography, no purple-gradient-on-white, no default Inter-on-white. If a `DESIGN.md` exists it is the source of truth and overrides personal taste.

---

## 4. The 6 auto-decision principles

When a fork appears mid-run and it is not a genuine taste or strategy call, decide it yourself using these, log the decision in `state.md`, and keep moving. Only stop at Phase 6.

1. **Completeness** : prefer the option that fully solves the stated problem over the one that partially solves it cheaply.
2. **Boil the lake** : when AI makes the marginal cost near zero, do the complete thing, not the minimal thing.
3. **Pragmatic** : do not add abstraction, config, or generality the target does not need yet.
4. **DRY with judgment** : reuse existing code/patterns found in Phase 0; three similar lines beat a premature abstraction.
5. **Explicit over implicit** : choose the option a future reader understands without tribal knowledge.
6. **Bias to action** : if both options are reasonable and reversible, pick the better-looking one and note it. Do not stall.

### Decision classification

- **Mechanical** (naming, file placement, obvious lib choice, test structure): decide silently via the principles.
- **Taste** (a close design call, two reasonable UX directions, a borderline scope question): decide via the principles BUT flag it in the Phase 6 report so the user can override.
- **User challenge** (changes the product's direction, spends real money, alters pricing/positioning, touches a legal/compliance boundary, irreversible): never auto-decide. Park it for the Phase 6 gate, or ask the single Phase 0 scoping question if it blocks starting.

---

## 5. Quality bars and stop conditions

The improve loop (Phase 5) continues until ALL of these hold, or the 3-round cap is hit:

- codex (or the internal red-team fallback) returns PASS: no unaddressed P1/Critical findings.
- every activated expert-panel dimension scores >= 9/10.
- for code: tests pass (fresh run, real output), build is green.
- for ui: QA health is green, no Critical/High visual issues open.
- every success criterion in the brief is met (line by line check against `baseline.md`).

If the cap is hit with a bar unmet, do not loop forever and do not silently ship. Record the specific unmet bar and the best remaining option in the Phase 6 report, and let the user decide at the gate.
