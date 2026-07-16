# Damian's PR Review Defaults (MANDATORY)

YOU MUST follow these rules for ALL PR reviews — whether invoked via the
pr-review-toolkit plugin (`/review-pr` and its agents), another review skill,
or an ad-hoc "review this PR" request.

## GitHub is read-only during reviews

- Neither you nor any subagent may write to GitHub during a review. No PR
  comments, no inline review comments, no approvals or change requests, no
  labels, no edits to titles/descriptions, no commits, no pushes.
- `gh` usage is limited to reads: `gh pr view`, `gh pr diff`, `gh pr checks`,
  `gh api` GETs, and the like.
- Surface ALL findings to Damian in the conversation. He decides what (if
  anything) lands on GitHub, and posts it himself or explicitly asks you to.
- Pass this constraint down: when dispatching review subagents, include the
  read-only instruction in their prompts. A subagent posting a comment is a
  failure of YOUR dispatch, not the subagent.

## Context before judgment: JIRA tickets and planning documents

- Before judging the diff, gather the intent behind it: read the associated
  JIRA ticket(s) and any planning documents they link (Confluence briefs,
  design docs, epics).
- Finding the ticket: branch names follow `TICKET-123/description`; PR titles
  and descriptions often link tickets too.
- Review the PR against that context — does it satisfy the ticket's
  acceptance criteria? Does it match the agreed plan? Flag scope creep and
  silent deviations from the plan as findings.
- If you cannot confidently identify the relevant ticket or planning
  documents, or they seem stale/contradictory, ASK Damian to confirm which
  ones apply before proceeding. Do not guess at intent.

## Comment quality is in scope (hooks can't judge it)

- Flag comments that narrate the change ("now we…", "refactored to…"),
  restate what the code plainly does, or ramble as essays/preamble. A good
  comment states one durable, non-obvious thing the code itself cannot say.
- When flagging a comment, always include a proposed fix for Damian's review:
  a concise rewrite (usually one line), or "delete — the code says this" when
  nothing durable remains. Show it as before/after so he can judge at a
  glance.
- Treat this as a substance finding, not a style nit — but SURFACE it for
  Damian's judgment rather than deleting or rewriting comments yourself.
  Quote the comment, say why it falls short, and let him calibrate. There is
  deliberately no hard rule here.
