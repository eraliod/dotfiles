# Achievements Plugin — Deferred Test Plan

> **For Claude (when resumed):** This plan finishes the behavioral verification
> of the `achievements` plugin. The plugin is built, reviewed, and partially
> verified (see "Status" below). Pick up the **resume-side tests** once a real
> corpus of achievements exists. Re-run from a fresh session with the plugin
> loaded.

**Goal:** Verify `/resume-bullets` and `/resume` (and re-verify `/self-review`)
against a realistic corpus of real achievement notes, which did not exist at
build time.

**Why deferred:** Ranking, matching, pattern-synthesis, and gap-detection are
only meaningful across many notes spanning several competencies and
technologies. On 2026-06-28 only one real note existed
(`2026-02-02-voiceops-pii-red-catalog.md`), so resume-side behavior could not be
exercised honestly.

---

## Status at time of writing (2026-06-28)

**Verified live (against fixtures or real input):**

- `/self-review` — date-overlap selection (correctly excluded an out-of-window
  note), competency clustering, empty-competency flagging. Tested against
  `plugins/achievements/test-fixtures/achievements/`.
- `/resume-bullets` — ranking, source-note annotation, JD-wording mirroring, and
  honest Gaps section (refused to invent Kafka/dbt/data-quality). Tested against
  fixtures with a synthetic JD. **Re-run needed against real corpus** for a true
  signal.
- `/achievement` — gap-asking (metrics-first), confirm-before-write, first-run
  README bootstrap, and the actual write. Tested with the real VoiceOps
  achievement.

**Not yet run:**

- `/resume` (tailoring a base resume) — never executed.
- `/resume-bullets` against a **real** multi-note corpus (only fixtures so far).
- `/self-review` against a **real** corpus (only fixtures so far).

---

## Precondition before resuming

1. **A real corpus exists.** At least ~8-12 real notes in
   `~/Documents/legion/achievements/`, spanning several competency tags
   (leadership, architecture, reliability, performance, cost-savings,
   mentorship, delivery, data-quality, automation) and varied technologies, with
   a mix of point-date and spanning/ongoing notes across at least two review
   periods. Build this organically with `/achievement` over the coming weeks.
2. **The plugin is loaded** in the session (it is enabled in settings; a fresh
   session picks it up).
3. **A base resume exists** for `/resume`: create
   `~/Documents/legion/achievements/resume-base.md` as a markdown master resume
   (jobs with bullet lists). Until then, `/resume` should stop and say so —
   that's itself a test (see Test C0).

---

## Test A — `/self-review` against the real corpus

Run: `/achievements:self-review H1 2026` (and a second period that has notes).

Pass criteria:

- Only notes whose `date`..`date_end` span overlaps the window appear; notes
  outside it are excluded.
- An ongoing note (`ongoing: true`) appears in every period it was active.
- Notes are grouped by competency tag into themes; several small same-competency
  notes collapse into one theme (not listed individually).
- Each theme leads with impact and pulls concrete numbers from `metrics`.
- Coverage section lists which notes fed each theme and flags competencies with
  no notes that period.
- `README.md` and `resume-base.md` are NOT treated as achievement notes (the
  skill's scan-skip rule).
- Offers to save to `reviews/<YYYY>-self-review-<period>.md`; on save, reminds to
  run `/legion`; does not run git against the vault.

---

## Test B — `/resume-bullets` against the real corpus

Use 2-3 **real** job descriptions (paste text, a file path, and a URL — exercise
all three input modes). For each:

Run: `/achievements:resume-bullets <JD>`

Pass criteria:

- Bullets are **ranked**, not dumped — irrelevant notes are dropped, not listed.
- Each bullet is `strong verb + what + quantified result`, mirrors the JD's
  wording, and pulls numbers from the source note's `metrics`.
- Each bullet is annotated with its source note filename.
- Small same-competency notes are synthesized into one pattern bullet (e.g.
  several `#mentorship` notes → one leadership bullet that counts them).
- A **Gaps** section honestly names JD requirements with no matching achievement;
  nothing is fabricated. (Pick at least one JD that asks for something you have
  no note for, to force a gap.)
- URL input is fetched; file path is read; pasted text is used directly.
- Offers to save to `resume-drafts/<role-slug>.md` (slug = `company-title`,
  kebab-cased); reminds to `/legion` on save; no git against the vault.

---

## Test C — `/resume` (tailoring), both modes

### C0 — missing base resume (run first, before creating resume-base.md)

Run: `/achievements:resume <some JD>`

Pass: it detects the missing `resume-base.md` and stops with a clear message
telling you to create it. Does not fabricate a resume.

### C1 — interactive mode

Precondition: `resume-base.md` exists. For a vault-safe dry-run, you may point
it at a throwaway copy and write output to `/tmp` (tell it so in the args);
otherwise let it write to `resume-drafts/`.

Run: `/achievements:resume <JD> interactive`

Pass criteria:

- Parses the resume into jobs → bullets, preserving order.
- Classifies each existing bullet as Reword / Replace / Keep, and proposes Add
  candidates for strong unrepresented achievements.
- Presents each change as `old → new` with the rationale (which JD keyword) and
  the source note; lets you accept/reject/edit per bullet.
- Honesty guardrail: existing bullets may be reworded freely, but anything
  **added or quantified** traces to a logged achievement; otherwise it lands in
  a Gaps note, not the resume.
- Writes to `resume-drafts/<role-slug>.md`; **never modifies `resume-base.md`**;
  reminds to `/legion`; no git against the vault.

### C2 — batch mode

Run: `/achievements:resume <JD> batch`

Pass criteria:

- Produces a complete tailored draft in one pass, then shows a whole-document
  diff against the base.
- Same guardrail and never-modify-base behavior as C1.
- Mode is selected by the standalone `batch` token, not by the word appearing
  inside the JD text (try a JD that contains "batch processing" to confirm it
  does NOT misfire).

---

## Cleanup / notes

- Fixtures live at `plugins/achievements/test-fixtures/achievements/` and remain
  useful for regression checks of selection/ranking logic without real data.
- After any test that saves into the vault, run `/legion` to sync.
- If a test fails, treat the command markdown under
  `plugins/achievements/commands/` and the skill references under
  `plugins/achievements/skills/achievements/` as the fix surface; re-review with
  the spec + quality reviewer subagents as during the original build.

## Out of scope

- docx/pdf resume import for `/resume` (markdown base only; future enhancement).
- Any automated/CI test harness — these are manual behavioral runs by design.
