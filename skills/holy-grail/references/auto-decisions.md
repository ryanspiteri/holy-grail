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

1. Identify the app and router. Find the router config (search `createBrowserRouter`, `<Route`, `router`, `pages/`, `app/`) and the convention for where screens or pages live (commonly `src/routes/`, `src/screens/`, `src/pages/`, or `app/`).
2. Match the URL path to the route element, then to the screen/page component.
3. Trace the component's data layer: the API endpoint, GraphQL resolver/mutation, and model it touches. Record these in `baseline.md` as the edit surface.
4. If the URL is production and the repo is local, confirm the local code is the same version (git branch, last deploy) before editing.
5. If the URL maps to no local repo at all (an external or unknown host, or a placeholder), degrade to screenshot-only mode: the live capture plus any supplied screenshot are the baseline, the deliverable is a design or copy spec or a recommendation, and the code machinery (worktree, TDD, codex diff review) does NOT run because there is no editable source. Say this in the announce line.

---

## 1. Target classification

**Default intent of "upgrade X": lead with net-new features and capabilities that make X dramatically more valuable. Design, copy, and polish are secondary.** Even when the target arrives as a UI or page, the first question is "what new capabilities would make this 10x better", not "how do we make this look nicer". Generate feature opportunities first, then improve the surface around them.

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

Read `~/.holy-grail/capabilities.json` (written by `scripts/bootstrap.sh`). If absent or older than 24h, run bootstrap with no flag to (re)build it (read-only detection). To actually install missing deps, run `bash install.sh` or `scripts/bootstrap.sh --install-deps` (installs superpowers + gstack + codex CLI). Shape:

```json
{ "superpowers": true, "codex": true, "codex_cli": true, "codex_auth": true, "gstack": true, "browser": true, "ruflo": true, "git": true, "updated": "<iso8601>" }
```

`codex` is true when codex is usable (CLI installed AND logged in). `codex_cli` true but `codex_auth` false means the binary is installed but the user has not run `codex login` yet, so use the red-team fallback for the second opinion until they do.

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

## 3.6 Memory model (two tiers, never cross-contaminate)

holy-grail runs on every repo, across different stacks. Memory is split so a lesson learned on one project never leaks into another.

- **Universal lessons** (generalizable process or technique that applies across any project) live in `references/playbook.md`. This file is per-machine and gitignored, seeded from `playbook.seed.md`. The "Always-apply" block lives here. Every lesson here is `scope: universal`. Loaded trigger-driven at Phase 0 per the rules in `playbook.seed.md`.
- **Project-specific conventions and lessons** live in `.holy-grail/project.md` INSIDE the target repo. They travel with that project (committed there) and never load on another. Anything tied to one repo's stack, naming, deploy, or quirks belongs here, not in the universal playbook.
- **Project context is authoritative, not rediscovered.** The host project's `CLAUDE.md` (and `.holy-grail/project.md` if present) is the source of truth for project context: stack, test command, deploy method, merge policy, repos, brand voice. Read it at Phase 0 rather than re-deriving conventions every run. When it states a fact about the project, that fact wins over a guess.

Routing at the retro (Phase 7): for each lesson, decide "does this generalize beyond this project?" Universal goes to `references/playbook.md`; project-specific goes to the target repo's `.holy-grail/project.md`. Never put a project-specific lesson in the universal playbook.

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
- **Feature improvement** (a net-new feature or capability that clears the value-vs-effort bar and is reversible): AUTO-BUILD it this run, do not park it. This is the headline of an upgrade. Note it in the report so the user sees what was added. The value-vs-effort bar: it moves a real success metric, it is not gold-plating, and it fits within "upgrading this target" rather than starting a new product.
- **Taste** (a close design call, two reasonable UX directions): decide via the principles BUT flag it in the Phase 6 report so the user can override.
- **User challenge** (a new product direction, spends real money, alters pricing/positioning, touches a legal/compliance boundary, irreversible, or a multi-week effort): never auto-build. Surface it prominently (it likely came from the brief's feature opportunities) and park it for the Phase 6 gate, or ask the single Phase 0 scoping question if it blocks starting.

The line between "feature improvement" (auto-build) and "user challenge" (park) is the key judgment: build the features that obviously belong in a better version of this thing and are reversible; park the ones that are really a new product, cost money, or cannot be undone.

---

## 5. Quality bars and stop conditions

The improve loop (Phase 5) is an improvement engine, not a fix-until-green loop. Each round it both fixes defects AND elevates: the panel names the highest-leverage improvement, and if it clears the value-vs-effort bar it is folded back into the brief (re-spec), re-planned, rebuilt test-first, and re-verified.

Stop only when BOTH groups hold:

**Correct**
- codex (or the internal red-team fallback) returns PASS: no unaddressed P1/Critical findings.
- for code: tests pass (fresh run, real output), build is green.
- for ui: QA health is green, no Critical/High visual issues open.
- every success criterion in the brief is met (line by line check against `baseline.md`), INCLUDING the high-value feature opportunities marked in-scope (they are built, or the report states why not).

**Excellent**
- every activated expert-panel dimension scores >= 9/10.
- the panel cannot name a further improvement that clears the value-vs-effort bar (the excellence plateau).

Keep looping while the panel keeps finding worthwhile improvements. Stop at the excellence plateau (more work would not meaningfully move the outcome) or at the safety cap of 3 rounds. Value-vs-effort bar for an elevation: it must move a real success metric, be reversible, and not be gold-plating. Net-new feature improvements that clear that bar are built, not parked. Only genuinely large or strategic expansions (new product direction, pricing, spend, legal, irreversible) park for the Phase 6 gate. If a bar is unmet at the cap, do not loop forever and do not silently ship: record the specific gap and the best remaining option in the Phase 6 report.
