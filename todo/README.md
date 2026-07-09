# Todo

This directory holds ideas and future work items for the project. Since this
isn't backed by a Jira board, these markdown files serve as a lightweight
ticket system — a place to capture work we want to do later without losing
the rationale.

## Naming

Files are named `YYYY-MM-DD-short-description.md`, where the date is when the
idea was captured. The date prefix keeps related ideas chronological and makes
it easy to see how long an item has been waiting.

## Ticket structure

Each ticket has three sections:

- **Summary** — 2–3 sentences in plain language describing what we want and
  why. No technical details. Anyone (not just future-me) should be able to
  read this and understand the goal.
- **Definition of done** — Bullet points listing the concrete outcomes that
  would let us close the ticket. If an item isn't met, the work isn't done.
- **Implementation suggestion** — Technical detail on how the work might be
  approached. This is a suggestion, not a binding plan — the person who picks
  the ticket up should feel free to revise it.

## Closing tickets

When a ticket is completed, delete the file. The git history retains the
discussion. If a ticket becomes obsolete, delete it too and note the reason
in the commit message.
