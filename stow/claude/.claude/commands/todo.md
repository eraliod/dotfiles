---
description: Capture a future work item as a dated markdown todo (a lightweight Jira-ticket stand-in)
argument-hint: <short description of the work item>
allowed-tools: Bash(date:*), Bash(git rev-parse:*), Write, Read, Glob
---

# Create a todo

Capture a piece of future work as a markdown file under `todo/`, in lieu of a
Jira ticket. The argument is the topic; you fill in the rest from context.

## Context

- Today's date: !`date +%Y-%m-%d`
- Repo root: !`git rev-parse --show-toplevel 2>/dev/null || pwd`
- Topic from the user: **$ARGUMENTS**

## Step 1: Ensure the `todo/` directory exists

The `todo/` directory lives at the **repo root** shown above (fall back to the
current working directory if not in a git repo).

If `todo/README.md` does **not** already exist, create it with exactly this
content so the directory documents its own purpose:

```markdown
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
```

If `todo/README.md` already exists, leave it untouched.

## Step 2: Compose the ticket

Use the topic from `$ARGUMENTS` plus the current conversation to fill in the
three sections below. **Infer aggressively from context** — only ask the user
a clarifying question if a section is genuinely ambiguous and you cannot make a
reasonable guess. Do not interrogate the user for detail you can reasonably
derive.

Write the ticket to `todo/YYYY-MM-DD-<slug>.md` where:

- `YYYY-MM-DD` is today's date from the Context section.
- `<slug>` is the topic lowercased, with spaces and punctuation collapsed to
  single hyphens (e.g. "Add Tailscale for remote access" →
  `add-tailscale-for-remote-access`). Keep it concise — trim filler words.

The file contents follow this template:

```markdown
# <Title Case version of the topic>

## Summary

<2–3 sentences, plain language, no technical jargon. What do we want and why?
Anyone should be able to read this and understand the goal.>

## Definition of done

- <Concrete, checkable outcome>
- <Another outcome>
- <Include a "no regression" / scope-boundary bullet where relevant>

## Implementation suggestion

- <Technical approach — a suggestion, not a binding plan>
- <Note alternatives considered and why they were rejected, when known>
- <Call out anything explicitly out of scope>
```

## Step 3: Confirm

After writing the file, tell the user the path you created and give a one-line
summary of the ticket. If you had to guess at any section, say which ones so
they can correct them.
