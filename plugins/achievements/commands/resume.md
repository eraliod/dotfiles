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
