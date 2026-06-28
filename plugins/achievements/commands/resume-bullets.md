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
5. **Render bullets.** For the top matches, write each as
   "strong verb + what + quantified result", mirroring the JD's wording and
   pulling numbers from `metrics`. Annotate each bullet with its source note
   filename. Combine small same-competency notes into one pattern bullet.
6. **Gaps section.** List JD requirements with **no** matching achievement under
   a heading "Gaps — no achievement on file for X". Never fabricate.
7. **Output to chat**; offer to save to
   `~/Documents/legion/achievements/resume-drafts/<role-slug>.md` (remind to
   `/legion` if saved).
