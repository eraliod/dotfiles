---
title: Config-driven DLT ingestion framework
date: 2026-01-15
ongoing: true
logged: 2026-01-20
scope: company-wide
metrics:
  - "new-source onboarding: weeks -> <1 hour"
  - "MVP delivered in 5 weeks"
  - "12+ analytics engineers self-serve new sources"
tags: [leadership, architecture, ingestion, databricks, iac]
---

# Config-driven DLT ingestion framework

**Headline:** Designed the company-standard YAML-config DLT ingestion framework, cutting new-source onboarding from weeks to under an hour.

## Context

First-wave data platform for the auto-insurance launch. Given technical direction over Postgres-to-cloud ingestion, choosing between the established Redshift platform and the new Databricks workspace.

## Action

Chose Databricks for future-fit and designed a config-driven, pyspark + YAML DLT framework supporting batch and streaming on serverless compute. Added GitHub Actions release gates moving changes through local -> staging -> production. Built it so analytics engineers onboard new sources via YAML alone.

## Result

Now the company standard for ingesting from durable cloud storage, outputting deduplicated SCD2 silver tables. In operation over a year with multiple engineer contributors and 12+ analytics engineers self-serving. A key factor in promotion to Staff.

#leadership #architecture #ingestion #databricks #iac
