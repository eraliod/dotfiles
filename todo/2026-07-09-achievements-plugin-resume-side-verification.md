# Achievements Plugin — Resume-Side Verification

## Summary

The achievements plugin shipped in a good first version: capturing achievements
works and has been exercised for real. The resume-facing half — generating
tailored bullets, tailoring a full resume, and self-reviews from real data —
could not be honestly tested yet because only one real achievement note existed
at build time. Once a real corpus of notes has accumulated, we want to run the
deferred verification and fix whatever it surfaces.

## Definition of done

- A real corpus of ~8–12 achievement notes exists in the legion vault, spanning
  several competencies and at least two review periods (built organically via
  `/achievement`).
- Test A (`/self-review`), Test B (`/resume-bullets`), and Test C (`/resume`,
  both interactive and batch modes plus the missing-base-resume case) from the
  deferred test plan all pass against the real corpus.
- Any failures are fixed in the plugin's command/skill markdown and re-verified.
- The already-verified capture-side behavior (`/achievement`) still works — no
  regression from any fixes.

## Implementation suggestion

- The full test plan, pass criteria, and preconditions are already written:
  follow `docs/plans/2026-06-28-achievements-plugin-test-plan.md` verbatim.
- Wait until the corpus precondition is genuinely met — running the tests
  against a thin corpus was rejected at build time because ranking, synthesis,
  and gap-detection are only meaningful across many notes.
- Create `~/Documents/legion/achievements/resume-base.md` before Test C1/C2,
  but run Test C0 (missing base resume) first.
- Out of scope: docx/pdf resume import and any automated/CI test harness —
  these are manual behavioral runs by design.
