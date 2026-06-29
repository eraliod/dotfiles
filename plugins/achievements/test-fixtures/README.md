# Test fixtures

Sample achievement notes used to verify the read-side commands
(`/self-review`, `/resume-bullets`, `/resume`) without touching the real vault.

When verifying a command, point it at this directory instead of
`~/Documents/legion/achievements/` (the command's verification step in the
implementation plan says how). These files are never synced to the vault.

## What each fixture exercises

- `2026-01-15-dlt-ingestion-framework.md` — ongoing/spanning work; rich metrics;
  leadership + architecture competencies. Should appear in every period it was
  active.
- `2026-03-02-vendor-api-dag-rewrite.md` — point-date; percentage metric;
  performance + reliability.
- `2026-04-10-taught-christian-terraform.md` — pattern-only (`metrics: []`);
  mentorship + leadership. Should never be forced into a standalone bullet.
- `2025-11-20-redshift-cost-cut.md` — point-date in the PRIOR period
  (late 2025); cost-savings. Should be EXCLUDED from an H1 2026 review — proves
  the date-overlap filter works.
