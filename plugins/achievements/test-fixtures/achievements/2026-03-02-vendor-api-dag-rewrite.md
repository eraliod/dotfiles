---
title: Vendor API extraction DAG rewrite
date: 2026-03-02
logged: 2026-03-03
scope: team
metrics:
  - "runtime: 95 min -> 12 min (87% faster)"
  - "added alerting; mean time-to-detect failures: hours -> minutes"
tags: [performance, reliability, automation, airflow]
---

# Vendor API extraction DAG rewrite

**Headline:** Rewrote a legacy vendor-extraction DAG to run 87% faster with first-class alerting.

## Context

A legacy data extraction DAG lacked alerting and performed poorly, silently falling behind and requiring manual babysitting.

## Action

Engaged directly with the vendor API and found a more efficient pull pattern that avoided redundant full scans. Rebuilt the DAG around incremental pulls and added failure alerting wired to the team's on-call channel.

## Result

Runtime dropped from 95 minutes to 12 minutes (87% faster), and failures now surface in minutes instead of going unnoticed for hours.

#performance #reliability #automation #airflow
