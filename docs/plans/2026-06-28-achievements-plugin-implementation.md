# Achievements Plugin Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a Claude Code marketplace plugin that captures technical achievements as terse, structured markdown notes in the Obsidian "legion" vault and synthesizes them into self-reviews and tailored resume material.

**Architecture:** A new plugin `plugins/achievements/` holds one SKILL.md "brain" (schema, tag vocabulary, terseness philosophy, shared protocols) plus four thin slash commands that load the skill and run a specific workflow. All notes are written to `~/Documents/legion/achievements/`; commands never commit the vault — they defer to the existing `/legion` sync command.

**Tech Stack:** Markdown (commands, SKILL.md, references), JSON (`plugin.json`, `marketplace.json`, `settings.json`), `jq` for JSON validation. No application code.

**Design source:** `docs/plans/2026-06-28-achievements-plugin-design.md` (read it before starting).

**Relevant skills to consult while implementing:**

- @plugin-dev:plugin-structure — plugin directory layout & manifest
- @plugin-dev:command-development — slash command frontmatter & argument patterns
- @plugin-dev:skill-development — SKILL.md structure & progressive disclosure
- @superpowers:writing-skills — skill authoring discipline

**Verification model:** Each task ends with a _structural_ check (JSON validity / files present) and, where the task adds behavior, a _behavioral dry-run_ against fixtures. The plugin-validator agent and skill-reviewer agent run at the end. New/changed commands only appear after Claude Code reloads the plugin (restart the session), so behavioral checks that require the live slash command are explicitly marked "after reload".

**Conventions used throughout:**

- All vault paths use the literal `~/Documents/legion` prefix (matches the pre-approved permission rules used by `/legion`). Never substitute `$HOME` or an absolute path.
- Commands MUST NOT run any `git` command against the vault. They write files and instruct the user to run `/legion`.
- Today's date is obtained inside commands via `!`date +%Y-%m-%d``in the Context section, mirroring`/todo`.

---

## Task 0: Scaffold the plugin and register it

**Files:**

- Create: `plugins/achievements/.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json` (add a `plugins[]` entry)
- Modify: `stow/claude/.claude/settings.json` (add to `enabledPlugins`)

**Step 1: Create the plugin manifest**

Create `plugins/achievements/.claude-plugin/plugin.json`:

```json
{
  "name": "achievements",
  "version": "0.1.0",
  "description": "Capture technical achievements as terse markdown in the legion vault and synthesize self-reviews and tailored resume material"
}
```

**Step 2: Register in the marketplace**

In `.claude-plugin/marketplace.json`, add this object to the end of the `plugins` array (after the `databricks-mcp-custom` entry; add a comma after that entry's closing brace):

```json
{
  "name": "achievements",
  "source": "./plugins/achievements",
  "description": "Achievement tracking: capture wins, build self-reviews and tailored resumes"
}
```

**Step 3: Enable the plugin**

In `stow/claude/.claude/settings.json`, inside the `enabledPlugins` object, add after the `databricks-mcp-custom@dotfile-plugins` line (add a trailing comma to that line):

```json
    "achievements@dotfile-plugins": true,
```

**Step 4: Validate all three JSON files**

Run:

```bash
jq empty plugins/achievements/.claude-plugin/plugin.json && \
jq empty .claude-plugin/marketplace.json && \
jq empty "stow/claude/.claude/settings.json" && echo "ALL JSON VALID"
```

Expected: `ALL JSON VALID`. If any file errors, fix the comma/brace it reports.

**Step 5: Confirm the marketplace lists the plugin**

Run:

```bash
jq -r '.plugins[].name' .claude-plugin/marketplace.json
```

Expected: output includes `achievements`.

**Step 6: Commit**

```bash
git add plugins/achievements/.claude-plugin/plugin.json .claude-plugin/marketplace.json "stow/claude/.claude/settings.json"
git commit -m "feat(achievements): scaffold and register plugin"
```

---

## Task 1: Write the SKILL.md brain + note-schema reference

**Files:**

- Create: `plugins/achievements/skills/achievements/SKILL.md`
- Create: `plugins/achievements/skills/achievements/references/note-schema.md`

**Step 1: Write SKILL.md**

Create `plugins/achievements/skills/achievements/SKILL.md`:

```markdown
---
name: achievements
description: Use when capturing a work achievement, writing a self-review for a period, or producing/tailoring resume material from a job description. Defines where achievement notes live, the note schema, the tag vocabulary, and the terseness philosophy shared by the /achievement, /self-review, /resume-bullets, and /resume commands.
---

# Achievements

Capture technical achievements as terse, structured markdown, then reuse them
for self-reviews, resume bullets, and STAR interview prep. This skill holds the
invariants; the four commands are thin entry points.

## Where notes live

All notes are written to the Obsidian "legion" vault:

- Achievement notes: `~/Documents/legion/achievements/YYYY-MM-DD-<slug>.md`
- Saved self-reviews: `~/Documents/legion/achievements/reviews/`
- Tailored resume drafts: `~/Documents/legion/achievements/resume-drafts/`
- The user's master resume: `~/Documents/legion/achievements/resume-base.md`

Always use the literal `~/Documents/legion` prefix. **Never** run a `git`
command against the vault — after writing files, tell the user to run `/legion`
to sync.

## Core philosophy: terse, but reconstructable

Notes must be short enough that capture is cheap, but structured enough that the
same note can produce a resume bullet, a review paragraph, and a STAR answer.
The body follows a compact STAR with hard sentence caps (see
`references/note-schema.md`). Never write verbose notes.

## The note schema

See `references/note-schema.md` for the full frontmatter + body spec and caps.

## Tags

See `references/tag-vocabulary.md`. Competency tags are a controlled vocabulary
(pick 1-3); technology tags are free-form. Tags appear in BOTH frontmatter
`tags:` and inline `#tags` at the body bottom, kept in sync.

## Shared protocols

- Capturing a new achievement: `references/capture-flow.md`.
- Rendering outputs (resume bullets / review prose / STAR): `references/output-guides.md`.

## Honesty guardrail (downstream commands)

Resume and review output must use only facts present in the notes. When a job
description asks for something with no matching achievement, name it as a gap —
never fabricate. Existing user-written resume bullets are trusted prose and may
be reworded; anything added or quantified must trace to a logged achievement.
```

**Step 2: Write the note-schema reference**

Create `plugins/achievements/skills/achievements/references/note-schema.md` with the full schema (copy the schema, field rationale, date model from the design doc's "Achievement note schema" section). It MUST contain:

- The complete frontmatter template (title, date, optional date_end, optional ongoing, logged, scope, metrics, tags).
- The body template with the exact sentence caps: **Headline 1 sentence; Context <=3; Action <=5; Result <=4.**
- The note that there is no `role` field and why (`scope` kept instead).
- The note that `metrics` mirrors the numbers in Result so resume can grab them.
- The date model: `date` drives the filename; `date_end`/`ongoing` for spans; `logged` is capture date; selection is by span **overlap**.

Use this exact content:

````markdown
# Achievement note schema

Path: `~/Documents/legion/achievements/YYYY-MM-DD-<slug>.md`. The date is the
primary/milestone date; the slug is the headline kebab-cased.

```markdown
---
title: Config-driven DLT ingestion framework
date: 2026-01-15 # milestone / completion / "when it mattered"
date_end: 2026-02-20 # optional — spans only
ongoing: true # optional — still evolving
logged: 2026-06-28 # when captured (today)
scope: company-wide # team | cross-team | company-wide
metrics: # quantified wins; [] if genuinely none
  - "new-source onboarding: weeks -> <1 hour"
  - "MVP delivered in 5 weeks"
tags: [databricks, ingestion, iac, leadership] # competency + tech, mirrors body
---

# Config-driven DLT ingestion framework

**Headline:** <=1 sentence — a draft resume bullet: action verb + win + number.

## Context

<=3 sentences. Situation + your mandate (the S+T of STAR).

## Action

<=5 sentences. What _you_ did and the key decisions/trade-offs.

## Result

<=4 sentences. Outcome, adoption, quantified impact, career effect.

#leadership #ingestion #databricks #iac
```

## Rules

- **Sentence caps are enforced at capture, not suggested.** Headline 1, Context
  <=3, Action <=5, Result <=4.
- **No `role` field** — titles don't travel across companies. `scope` captures
  blast radius, which is an objective, company-relative claim.
- **`metrics` mirrors the numbers in Result** so resume commands grab quantified
  wins without re-parsing prose. Empty list allowed but discouraged.
- **Tags appear twice** — frontmatter `tags:` (machine-queryable) and inline
  `#tags` at body bottom (Obsidian-native). Keep them identical.

## Date model

- `date` — primary/milestone date; drives the filename.
- `date_end` + `ongoing: true` — optional, for work spanning time.
- `logged` — the capture date (today).
- **Selection is by overlap:** a note belongs to a period if its `date`..`date_end`
  span overlaps the period window. A year-long effort appears in every period it
  was active.
````

**Step 3: Validate skill frontmatter**

Run:

```bash
head -4 plugins/achievements/skills/achievements/SKILL.md
fd . plugins/achievements/skills/achievements -t f
```

Expected: frontmatter shows `name: achievements` and a `description:`; the file list shows `SKILL.md` and `references/note-schema.md`.

**Step 4: Commit**

```bash
git add plugins/achievements/skills/achievements/
git commit -m "feat(achievements): add skill brain and note-schema reference"
```

---

## Task 2: Write the tag-vocabulary, capture-flow, and output-guides references

**Files:**

- Create: `plugins/achievements/skills/achievements/references/tag-vocabulary.md`
- Create: `plugins/achievements/skills/achievements/references/capture-flow.md`
- Create: `plugins/achievements/skills/achievements/references/output-guides.md`

**Step 1: Write tag-vocabulary.md**

```markdown
# Tag vocabulary

Every note carries 1-3 **competency tags** (controlled) and any number of
**technology tags** (free-form). Tags go in BOTH frontmatter `tags:` and inline
`#tags`, kept identical.

## Competency tags (controlled — pick 1-3)

- `#leadership` — set technical direction, owned a project/decision
- `#mentorship` — taught, paired, grew another engineer
- `#architecture` — designed systems, made durable structural decisions
- `#reliability` — alerting, resilience, incident reduction, correctness
- `#performance` — latency, throughput, efficiency improvements
- `#cost-savings` — reduced spend / compute / licensing
- `#delivery` — shipped under deadline, drove a launch
- `#data-quality` — dedup, validation, schema/contract enforcement
- `#automation` — removed manual toil, self-service enablement

Extend this list deliberately (it is the retrieval axis for reviews and resumes);
do not invent synonyms (`#coaching` vs `#mentorship`).

## Technology tags (free-form)

Lowercase, hyphenated: `#databricks`, `#terraform`, `#postgres`, `#aws`,
`#redshift`, `#pyspark`, `#github-actions`, etc. Reuse existing spellings; check
sibling notes before coining a new one.
```

**Step 2: Write capture-flow.md**

````markdown
# Capture flow

The inverse of `/todo` (which infers aggressively and rarely asks). A thin
achievement note is useless downstream, so ASK when detail is missing.

1. **Gather** everything from the command argument and the current conversation.
2. **Detect gaps** against what outputs need:
   - HARD (must resolve before writing): at least one **quantified metric**, a
     clear **what-you-personally-did**, an identifiable **date or span**.
   - SOFT (ask if cheap): scope (team/cross-team/company-wide), key
     decisions/trade-offs.
3. **Ask, batched, metrics first.** Use AskUserQuestion. Quantified results carry
   resume bullets, so push for numbers: "now it performs well" -> "By how much —
   runtime, cost, rows processed, error rate?" Accept "no hard number" for small
   pattern-only achievements (see below).
4. **Draft and confirm BEFORE writing.** Present: proposed title + filename slug,
   the headline, a compact summary of Context/Action/Result, and the
   competency + technology tags. Let the user edit any of it inline. Do not write
   until they approve.
5. **Write** to `~/Documents/legion/achievements/YYYY-MM-DD-<slug>.md`, honoring
   the sentence caps in `note-schema.md`.
6. **Bootstrap on first run:** if `~/Documents/legion/achievements/` has no
   `README.md`, create it (template below) before writing the note.
7. **Report** the path and remind the user to run `/legion` to sync. Never run
   git against the vault.

## Small / pattern-only achievements

Some achievements (e.g. mentoring a colleague through a setup) will not become a
standalone resume bullet. Do NOT force a metric. Tag the competency
(`#mentorship`, `#leadership`) and, in the report, note this is a _pattern
contributor_ that strengthens a theme when grouped with similar notes.

## README bootstrap template

Write this to `~/Documents/legion/achievements/README.md` on first run:

```markdown
# Achievements

Terse, structured records of technical achievements, used to build
self-reviews, resume bullets, and STAR interview answers.

## Naming

Flat directory. Files are `YYYY-MM-DD-<slug>.md`, where the date is the
achievement's milestone/completion date and the slug is the headline,
kebab-cased.

## Note structure

YAML frontmatter (title, date, optional date_end/ongoing, logged, scope,
metrics, tags) plus a compact STAR body: a one-sentence Headline, then Context
(<=3 sentences), Action (<=5), Result (<=4), then inline #tags.

## Tags

Competency tags are a small controlled set (#leadership, #mentorship,
#architecture, #reliability, #performance, #cost-savings, #delivery,
#data-quality, #automation); technology tags are free-form. Tags appear in both
the frontmatter and inline.

## Subdirectories

- `reviews/` — saved self-review drafts.
- `resume-drafts/` — resume material tailored to specific roles.
- `resume-base.md` — the master resume (hand-maintained).

## Syncing

These notes are created by the `achievements` Claude Code plugin. They are NOT
auto-committed. Run `/legion` to sync the vault.
```
````

````

**Step 3: Write output-guides.md**

```markdown
# Output guides

How to render achievement notes into each output. Always honor the honesty
guardrail: only facts present in notes; name gaps, never fabricate.

## Resume bullet

`strong action verb + what you did + quantified result`. Pull the number from
the note's `metrics`. One line. Mirror the target job description's wording when
tailoring. Example:
"Designed Kin's standard YAML-config DLT ingestion framework, cutting new-source
onboarding from weeks to under an hour."

## Self-review paragraph

1-2 short paragraphs per competency theme, leading with impact and weaving in
concrete numbers from `metrics`. Prose, not a note dump. Group several small
same-competency notes into one theme (three `#mentorship` notes -> one
"technical leadership" paragraph).

## STAR answer

Expand a single note into Situation/Task (from Context), Action (from Action),
Result (from Result + metrics). Keep it tight; the note already enforces
brevity.

## Pattern synthesis

Small notes that share a competency tag combine into one credible claim. Count
them ("across N initiatives") rather than listing each.
````

**Step 4: Verify the references exist**

Run:

```bash
fd . plugins/achievements/skills/achievements/references -t f
```

Expected: `note-schema.md`, `tag-vocabulary.md`, `capture-flow.md`, `output-guides.md`.

**Step 5: Commit**

```bash
git add plugins/achievements/skills/achievements/references/
git commit -m "feat(achievements): add tag, capture-flow, and output-guide references"
```

---

## Task 3: Write the `/achievement` capture command

**Files:**

- Create: `plugins/achievements/commands/achievement.md`

**Step 1: Write the command**

Create `plugins/achievements/commands/achievement.md`:

```markdown
---
description: Capture a work achievement as a terse, structured markdown note in the legion vault
argument-hint: <the achievement, or leave blank to use conversation context>
allowed-tools: Bash(date:*), Read, Write, Glob, AskUserQuestion, Skill
---

# Capture an achievement

Record a technical achievement as a terse, reusable note. Load the
`achievements` skill first and follow its `references/capture-flow.md` exactly.

## Context

- Today's date: !`date +%Y-%m-%d`
- Achievement directory: `~/Documents/legion/achievements/`
- Raw input from the user: **$ARGUMENTS**

## Steps

1. **Load the skill.** Invoke the `achievements` skill (Skill tool) to load the
   note schema, tag vocabulary, and capture protocol.
2. **Run the capture flow** in `references/capture-flow.md`:
   - Gather from `$ARGUMENTS` + this conversation.
   - Detect gaps; if any HARD requirement is missing (a quantified metric, a
     clear what-you-did, a date/span), ask via AskUserQuestion — metrics first.
     Allow metric-free capture only for small pattern-only achievements.
   - Draft and present title+slug, headline, a compact Context/Action/Result
     summary, and competency+tech tags. **Wait for approval. Do not write yet.**
3. **Bootstrap** the achievements directory README if it does not exist (template
   in `capture-flow.md`).
4. **Write** the note to
   `~/Documents/legion/achievements/<today>-<slug>.md`, honoring the schema and
   sentence caps (Headline 1, Context <=3, Action <=5, Result <=4). Keep
   frontmatter `tags:` and inline `#tags` identical.
5. **Report** the path written and a one-line summary, note whether it is a
   standalone bullet or a pattern contributor, and remind the user to run
   `/legion` to sync. Do not run git against the vault.
```

**Step 2: Structural check**

Run:

```bash
head -5 plugins/achievements/commands/achievement.md
```

Expected: frontmatter with `description:` and `allowed-tools:` present.

**Step 3: Behavioral dry-run (after reload)**

Restart Claude Code so the new command loads, then run the rich DLT example from
the design discussion:

```
/achievements:achievement As a senior data engineer I designed a config-driven DLT ingestion framework on Databricks, MVP in 5 weeks, now the company standard, new-source onboarding dropped from weeks to under an hour, 12+ analytics engineers self-serve, contributed to my Staff promotion.
```

Expected observable behavior:

- It does NOT immediately write. It presents a draft (title/slug, headline,
  Context/Action/Result, tags) and waits for approval.
- Tags include controlled competencies (e.g. `#leadership`, `#architecture`) and
  free-form tech (`#databricks`).
- After approval, it writes `~/Documents/legion/achievements/<date>-<slug>.md`
  and reminds you to run `/legion`.

Then run the thin example and confirm it ASKS for a metric:

```
/achievements:achievement rewrote a legacy data extraction dag that lacked alerting and had poor performance; engaged the vendor API and found a more efficient pull.
```

Expected: it asks for quantification (how much faster / cost / error rate)
before drafting.

**Step 4: Inspect a written note**

```bash
fd . ~/Documents/legion/achievements -t f -e md
cat ~/Documents/legion/achievements/$(fd . ~/Documents/legion/achievements -t f -e md | head -1 | xargs basename)
```

Expected: valid frontmatter, sentence caps respected, tags in both places.

**Step 5: Commit**

```bash
git add plugins/achievements/commands/achievement.md
git commit -m "feat(achievements): add /achievement capture command"
```

---

## Task 4: Create test fixtures for the read-side commands

These let `/self-review`, `/resume-bullets`, and `/resume` be verified without
real vault data. They live in the dotfiles repo, not the vault.

**Files:**

- Create: `plugins/achievements/test-fixtures/achievements/2026-01-15-dlt-ingestion-framework.md`
- Create: `plugins/achievements/test-fixtures/achievements/2026-03-02-vendor-api-dag-rewrite.md`
- Create: `plugins/achievements/test-fixtures/achievements/2026-04-10-taught-christian-terraform.md`
- Create: `plugins/achievements/test-fixtures/achievements/2025-11-20-redshift-cost-cut.md`
- Create: `plugins/achievements/test-fixtures/README.md`

**Step 1: Write four fixture notes** covering distinct cases:

- `2026-01-15-dlt-ingestion-framework.md` — `ongoing: true`, `date_end` absent or far; scope company-wide; tags `[databricks, ingestion, iac, leadership, architecture]`; rich metrics. (Spanning/ongoing case.)
- `2026-03-02-vendor-api-dag-rewrite.md` — point date; tags `[performance, reliability, automation]`; metrics with a percentage.
- `2026-04-10-taught-christian-terraform.md` — point date; tags `[mentorship, leadership, terraform]`; `metrics: []` (pattern-only case).
- `2025-11-20-redshift-cost-cut.md` — point date in the PRIOR period; tags `[cost-savings, redshift]`; metric with a dollar/percent figure. (Tests period filtering — should be EXCLUDED from an H1 2026 review.)

Each must be a valid note per `note-schema.md`. Write realistic but clearly-fake content.

**Step 2: Write test-fixtures/README.md**

```markdown
# Test fixtures

Sample achievement notes used to verify the read-side commands
(`/self-review`, `/resume-bullets`, `/resume`) without touching the real vault.

When verifying a command, point it at this directory instead of
`~/Documents/legion/achievements/` (the command's verification step in the
implementation plan says how). These files are never synced to the vault.
```

**Step 3: Validate fixture frontmatter parses**

Run:

```bash
for f in plugins/achievements/test-fixtures/achievements/*.md; do
  echo "== $f =="
  yq --front-matter=extract '.tags, .date, .scope' "$f"
done
```

Expected: each prints its tags array, date, and scope without a parse error.

**Step 4: Commit**

```bash
git add plugins/achievements/test-fixtures/
git commit -m "test(achievements): add read-side command fixtures"
```

---

## Task 5: Write the `/self-review` command

**Files:**

- Create: `plugins/achievements/commands/self-review.md`

**Step 1: Write the command**

```markdown
---
description: Draft a self-review for a time period by synthesizing achievement notes from the legion vault
argument-hint: <period, e.g. "H1 2026", "2026", "last 6 months", or a date range>
allowed-tools: Bash(date:*), Read, Glob, Write, AskUserQuestion, Skill
---

# Draft a self-review

Synthesize achievement notes into review-ready prose for a period. Load the
`achievements` skill first; use `references/output-guides.md` for rendering.

## Context

- Today's date: !`date +%Y-%m-%d`
- Achievement directory: `~/Documents/legion/achievements/`
- Requested period: **$ARGUMENTS**

## Steps

1. **Load the skill** (Skill tool).
2. **Resolve the period** from `$ARGUMENTS`. Accept `H1 2026`, `H2 2026`,
   `Q2 2026`, `2026`, `last N months`, or `YYYY-MM-DD..YYYY-MM-DD`. If blank, ask
   (default: the current half-year).
3. **Select notes by overlap.** Glob `~/Documents/legion/achievements/*.md`, read
   each note's frontmatter, and include it if its `date`..`date_end` span (a
   point if no `date_end`) overlaps the resolved window. Ongoing notes whose span
   reaches into the window count.
4. **Cluster by competency tag.** Group selected notes under their controlled
   competency tags. Several small same-competency notes form one theme.
5. **Draft the review.** For each theme, write 1-2 short paragraphs leading with
   impact and weaving in numbers from `metrics`. Prose, not a list of notes.
6. **Show coverage.** List which notes fed each theme; flag competencies with no
   notes this period and whether the period is thin.
7. **Output to chat by default.** Then offer to save to
   `~/Documents/legion/achievements/reviews/<YYYY>-self-review-<period>.md`. If
   saved, remind the user to run `/legion`. Do not run git against the vault.
```

**Step 2: Structural check**

```bash
head -5 plugins/achievements/commands/self-review.md
```

Expected: valid frontmatter.

**Step 3: Behavioral dry-run against fixtures (after reload)**

Run:

```
/achievements:self-review H1 2026 — but read notes from plugins/achievements/test-fixtures/achievements/ instead of the vault, and just print the draft (do not save).
```

Expected:

- Includes the DLT (ongoing), DAG-rewrite, and terraform-mentorship fixtures.
- **Excludes** `2025-11-20-redshift-cost-cut.md` (prior period) — this proves the
  overlap filter works.
- Clusters by competency (a leadership/architecture theme, a
  performance/reliability theme, a mentorship theme).
- Coverage section flags that `#cost-savings` has no H1 note.

**Step 4: Commit**

```bash
git add plugins/achievements/commands/self-review.md
git commit -m "feat(achievements): add /self-review command"
```

---

## Task 6: Write the `/resume-bullets` command (MVP)

**Files:**

- Create: `plugins/achievements/commands/resume-bullets.md`

**Step 1: Write the command**

```markdown
---
description: Turn a job description into ranked, tailored resume bullets drawn from your achievement notes
argument-hint: <pasted JD, a path to a JD file, or a URL>
allowed-tools: Read, Glob, WebFetch, Write, Skill
---

# Resume bullets from a job description

Produce resume-ready bullets matched to a job description, drawn only from logged
achievements. Load the `achievements` skill; use `references/output-guides.md`.

## Context

- Achievement directory: `~/Documents/legion/achievements/`
- Job description input: **$ARGUMENTS**

## Steps

1. **Load the skill** (Skill tool).
2. **Obtain the JD.** If `$ARGUMENTS` is a URL, fetch it (WebFetch); if a file
   path, read it; otherwise treat the text as the JD. If empty, ask for it.
3. **Parse the JD** for emphasized themes, required skills, and keywords.
4. **Score achievements.** Glob and read notes; score each by competency + tech
   tag overlap and metric relevance to the JD. Rank; do not dump.
5. **Render bullets.** For the top matches, write `strong verb + what +
quantified result`, mirroring the JD's wording, pulling numbers from
   `metrics`. Annotate each bullet with its source note filename. Combine small
   same-competency notes into one pattern bullet.
6. **Gaps section.** List JD requirements with **no** matching achievement under
   a heading "Gaps — no achievement on file for X". Never fabricate.
7. **Output to chat**; offer to save to
   `~/Documents/legion/achievements/resume-drafts/<role-slug>.md` (remind to
   `/legion` if saved).
```

**Step 2: Structural check**

```bash
head -5 plugins/achievements/commands/resume-bullets.md
```

**Step 3: Behavioral dry-run against fixtures (after reload)**

Provide a short JD emphasizing "streaming data pipelines, performance at scale,
mentoring engineers" and point it at the fixtures dir:

```
/achievements:resume-bullets [paste the JD] — read notes from plugins/achievements/test-fixtures/achievements/ and just print, do not save.
```

Expected:

- Top bullets come from DLT (pipelines), DAG-rewrite (performance), and
  terraform-mentorship (mentoring), each annotated with its source file.
- Numbers from `metrics` appear in the bullets.
- A Gaps section names anything in the JD not covered (e.g. if the JD mentions
  "Kafka" with no matching note).

**Step 4: Commit**

```bash
git add plugins/achievements/commands/resume-bullets.md
git commit -m "feat(achievements): add /resume-bullets command"
```

---

## Task 7: Write the `/resume` tailoring command

**Files:**

- Create: `plugins/achievements/commands/resume.md`

**Step 1: Write the command**

```markdown
---
description: Tailor a base resume to a job description by rewording, replacing, and adding bullets from your achievements
argument-hint: <JD (text/path/URL)> [interactive|batch] [path to base resume]
allowed-tools: Read, Glob, WebFetch, Write, AskUserQuestion, Skill
---

# Tailor a resume to a job description

Edit a base resume to fit a job description, using logged achievements. Load the
`achievements` skill; honor the honesty guardrail and output guides.

## Context

- Achievement directory: `~/Documents/legion/achievements/`
- Master resume (default): `~/Documents/legion/achievements/resume-base.md`
- Input: **$ARGUMENTS**

## Steps

1. **Load the skill** (Skill tool).
2. **Obtain the JD** (URL -> fetch, path -> read, else text). If empty, ask.
3. **Locate the base resume.** Use a path in `$ARGUMENTS` if given, else
   `resume-base.md`. If it does not exist, stop and tell the user to create it.
4. **Choose the mode.** If `$ARGUMENTS` contains `interactive` or `batch`, use
   it; otherwise ask (default: interactive).
5. **Parse the resume** into jobs -> bullets, preserving order and untouched
   prose.
6. **Classify each existing bullet:** Reword (same achievement, rephrased to the
   JD / inject a matching metric), Replace (weak/irrelevant for this JD; swap a
   stronger achievement under the same job), or Keep. Then identify **Add**
   candidates: logged achievements that strongly match the JD but are absent
   under a job.
7. **Apply the mode:**
   - **Interactive:** show each change as `old -> new` with rationale (which JD
     keyword) and source note; accept/reject/edit per bullet.
   - **Batch:** produce the full tailored draft, then show a whole-document diff
     against the base.
8. **Guardrail:** existing user bullets are trusted prose (reword freely);
   anything added or quantified must trace to a logged achievement, else it goes
   in a Gaps note, not the resume.
9. **Write to a copy** at
   `~/Documents/legion/achievements/resume-drafts/<role-slug>.md`. Never modify
   `resume-base.md`. Remind the user to run `/legion`.
```

**Step 2: Structural check**

```bash
head -5 plugins/achievements/commands/resume.md
```

**Step 3: Behavioral dry-run (after reload)**

Create a tiny throwaway base resume for the test (do NOT use the real vault):

```bash
mkdir -p /tmp/achv-test && cat > /tmp/achv-test/resume-base.md <<'EOF'
# Jane Engineer

## Senior Data Engineer, Kin Insurance (2024-present)

- Worked on data ingestion pipelines.
- Improved a data extraction job.
- Helped teammates with infrastructure.
EOF
```

Then:

```
/achievements:resume [paste the streaming/performance/mentoring JD] interactive /tmp/achv-test/resume-base.md — read achievements from plugins/achievements/test-fixtures/achievements/ and print proposed changes only; write the draft to /tmp/achv-test/ instead of the vault.
```

Expected:

- Bullet 1 ("ingestion pipelines") is **reworded** with DLT specifics + a metric.
- Bullet 2 ("extraction job") is **reworded** with the DAG-rewrite percentage.
- Bullet 3 ("helped teammates") is **reworded** toward the mentorship note.
- It proposes an **Add** if a strong fixture match isn't represented.
- It writes to `/tmp/achv-test/`, NOT the vault, and never edits the base.

**Step 4: Clean up the temp test**

```bash
rm -rf /tmp/achv-test
```

**Step 5: Commit**

```bash
git add plugins/achievements/commands/resume.md
git commit -m "feat(achievements): add /resume tailoring command"
```

---

## Task 8: Final validation and review

**Step 1: Validate the whole plugin structure**

Dispatch the `plugin-dev:plugin-validator` agent on `plugins/achievements/`.
Expected: no structural errors (valid plugin.json, commands and skill discovered).

**Step 2: Review the skill quality**

Dispatch the `plugin-dev:skill-reviewer` agent on
`plugins/achievements/skills/achievements/SKILL.md`. Address any
description/triggering feedback.

**Step 3: Re-validate all JSON**

```bash
jq empty plugins/achievements/.claude-plugin/plugin.json \
  .claude-plugin/marketplace.json "stow/claude/.claude/settings.json" && echo OK
```

Expected: `OK`.

**Step 4: Confirm command + skill inventory**

```bash
fd . plugins/achievements -t f | sort
```

Expected: plugin.json, SKILL.md, 4 references, 4 commands, test fixtures + README.

**Step 5: Commit any fixes** from the review agents, then summarize to the user
what was built and remind them: restart Claude Code to load the four commands,
and create `~/Documents/legion/achievements/resume-base.md` before first using
`/resume`.

---

## Out of scope (YAGNI)

- docx/pdf resume import (markdown only for now).
- Any database/index over the notes.
- Auto-syncing the vault from these commands (`/legion` owns that).

```

```
