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

### Decision classification (the single build-vs-park home)

This is the canonical definition of the build-vs-park rule and the value-vs-effort bar. SKILL.md and the phases reference "auto-decisions section 4"; this is what they point to. Define it here, nowhere else.

- **Mechanical** (naming, file placement, obvious lib choice, test structure): decide silently via the principles.
- **Feature improvement = AUTO-BUILD it this run.** A net-new capability that is reversible and clears the value-vs-effort bar. This is the headline of an upgrade: build the features that obviously belong in a better version of this thing. Note each one in the Phase 6 report so the user sees what was added.
- **Taste** (a close design call, two reasonable UX directions): decide via the principles BUT flag it in the Phase 6 report so the user can override.
- **User-challenge fork = do NOT build.** A new product direction, real spend, a pricing/positioning change, a legal/compliance boundary, anything irreversible, or a multi-week effort. Pick the safe default, log it in `state.md`, and surface it prominently in the Phase 6 report (it likely came from the brief's feature opportunities). Ask the single Phase 0 scoping question only if it blocks starting.

**The value-vs-effort bar (defined once here):** an item clears the bar when it (a) moves a real success metric, (b) is reversible, and (c) is not gold-plating. It must fit within "upgrading this target", not "starting a new product". A feature improvement clears this bar; a user-challenge fork does not (it is a new product, costs money, or cannot be undone).

**Blast-radius cap (build-vs-park safety override).** Even an item that classifies as a feature improvement does NOT get built silently this run if it would exceed **10 changed files**, or touch the **database schema or a migration**. Such an item escalates to the Phase 6 report as its own proposed sub-upgrade (with the safe default left in place), exactly like a user-challenge fork. This caps the blast radius of any single auto-built feature.

### Subagent budget per intensity

The counterweight to "boil the lake": adding features is desired, but a single run does not get to dispatch unbounded subagents. Each intensity carries a soft cap on the total subagents dispatched across the run:

| Intensity | Soft subagent cap |
|---|---|
| **Deep** | <= 5 |
| **Full** | <= 15 |
| **Epic** | <= 30 |

Track the running count in `state.md`. When the next dispatch would exceed the cap, do NOT silently continue: write `state.md` (current phase, decision log, remaining work), note in the Phase 6 report that the budget was hit and what is left, and stop at a clean checkpoint. The user can resume to spend more, but the run never burns through subagents unbounded.

### Multi-repo handling (detect at Phase 0)

The target can span more than one repo (e.g. an API plus a frontend plus a mobile app). At Phase 0, after route-to-source, detect how many repos the work touches:

1. **Detect N repos.** If the change spans multiple repos (the host `CLAUDE.md` may list them, or route-to-source lands edits in more than one repo root), record each repo in `state.md`.
2. **Plan N worktrees and N PRs.** One isolated worktree per repo, one PR per repo. Do not edit a second repo from the first repo's worktree.
3. **Flag cross-repo contract changes.** When a change to one repo is a contract other repos consume (a schema, an API/GraphQL shape, a shared type, a webhook payload), flag it explicitly and update every consuming repo in the SAME run, so the API change and the frontend/mobile that read it ship together. A contract change landed in only one repo is an incomplete upgrade.

For a single-repo target this whole subsection is a no-op: one worktree, one PR.

### Propose-only mode (modifier)

When the user says "propose only", "plan only", or "don't build yet" (in the command or the focus answer), run a planning-only pass:

- Run **Phases 0 to 2 plus the expert panel** only: ingest, classify, set intensity, build the brief, write the plan, run the panel on it.
- **STOP there.** Deliver the brief and the plan (with the parked user-challenge forks and the value-vs-effort calls noted). Do NOT build, do NOT open a PR, do NOT touch a worktree's source.
- State in the announce line that this is propose-only. The user reviews the plan and re-runs without the modifier to build it.

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

Keep looping while the panel keeps finding worthwhile improvements. Stop at the excellence plateau (more work would not meaningfully move the outcome) or at the safety cap of 3 rounds. The value-vs-effort bar for an elevation is the one defined in section 4 (moves a real metric, reversible, not gold-plating). Net-new feature improvements that clear that bar are built, not parked. Only genuinely large or strategic expansions (new product direction, pricing, spend, legal, irreversible) park for the Phase 6 gate. If a bar is unmet at the cap, do not loop forever and do not silently ship: record the specific gap and the best remaining option in the Phase 6 report.

### Proof split (in-run vs production)

The proof you can produce inside the run is not the proof of production. Keep them separate and never conflate them:

- **In-run proof** is local/preview only: tests passing on a fresh run, a screenshot of the dev or preview build, QA health on the local surface. This is all the loop can achieve before the PR.
- **Production proof** is post-merge and post-deploy. It is async (it happens after the human merges), and for mobile it may be impossible in-loop. The report states which kind was achieved.

**Never claim production-verified before a merge.** The run ends at a PR; until that PR is merged and deployed, the only honest claim is local/preview verified.
