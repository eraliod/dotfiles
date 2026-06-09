## Damian's JIRA Defaults (MANDATORY)

YOU MUST use these defaults for ALL JIRA operations. These are not suggestions.

### Your Team and Project

**Your Team:** Data & ML Ops
**Team UUID:** `f1df32de-280a-4d22-8256-7a6995af5bc8` (customfield_10001)
**Default Project:** CORE

**Default behavior when creating tickets:**

→ Team = NO TEAM (null/unset) unless user specifies
→ Project = CORE (automatic)

**When user says "my team" or "add to my team":**

→ Team = Data & ML Ops (UUID: `f1df32de-280a-4d22-8256-7a6995af5bc8`)

**When user says "Platform team" or "create for X team":**

→ Team = X (find team UUID via JQL search)

**No exceptions:**

- Default team = NO TEAM (you work across teams)
- "my team" = Data & ML Ops, always
- No project specified = CORE, always
- Don't ask "which team?" or "which project?" unless user gives conflicting signals

### Your Sprint

**Sprint Prefix:** Data & ML Ops (e.g., "Data Health Sprint 79")

**Default behavior:** New tickets have NO sprint assigned (sprint field = null)

**When user says "add this to my sprint":**

1. **Find your current active sprint** (use JQL with your sprint prefix):

   ```python
   atlassian_api(
       service="jira",
       method="POST",
       endpoint="/rest/api/3/search/jql",
       data='{"jql": "project = CORE AND sprint in openSprints() AND sprint ~ \\"Data Health Sprint\\" ORDER BY created DESC", "fields": ["key", "customfield_10020"], "maxResults": 1}',
       jq_filter=".issues[0].fields.customfield_10020[] | {id, name, state}",
   )
   ```

   Extract sprint ID from result (e.g., 8277 for "Data Health Sprint 79").

2. **Add ticket to sprint** using customfield_10020:

   ```python
   atlassian_api(
       service="jira",
       method="PUT",
       endpoint="/rest/api/3/issue/CORE-123",
       data='{"fields": {"customfield_10020": [8277]}}',
   )
   ```

**Common rationalizations that mean you're about to fail:**

- "I'll ask which sprint" → WRONG. User said "my sprint" = Data Health Sprint XX (current active sprint)
- "I'll assign to current sprint automatically" → WRONG. Default is NO sprint unless user says so
- "Sprint management is too complex" → WRONG. Follow the 2-step process above

**Implementation details** (field structure, API mechanics) are documented in `atlassian-toolkit:using-atlassian-api` skill under `api/jira/create-issue.md` and `api/jira/update-issue.md`.

**No exceptions.** "My team" = Data & ML Ops. "My sprint" = Data Health Sprint (current active). "Create a ticket" = CORE project. Period.
