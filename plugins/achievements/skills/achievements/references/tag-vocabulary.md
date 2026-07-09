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

Extend this list deliberately (it is the retrieval axis for reviews and
resumes); do not invent synonyms (`#coaching` vs `#mentorship`).

## Technology tags (free-form)

Lowercase, hyphenated: `#databricks`, `#terraform`, `#postgres`, `#aws`,
`#redshift`, `#pyspark`, `#github-actions`, etc. Reuse existing spellings; check
sibling notes before coining a new one.

Practice-level tags (e.g. `#iac`, `#ci-cd`, `#streaming`) also live here as
free-form tags — they are NOT competency tags. Keep the controlled competency
list (above) for the review/resume retrieval axis; everything else is free-form.
