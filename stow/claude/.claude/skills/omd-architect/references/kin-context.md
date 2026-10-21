# Kin Insurance: company and data context

Read this before giving Kin-specific advice. Facts here were confirmed by Damian unless marked **open**. When something here conflicts with what the live instance or the repo shows, trust the live source and tell the user this file is stale.

## Contents

- Company
- Data platform
- What is (and isn't) in OpenMetadata
- The POC: why OMD, and in what order
- Constraints
- Open questions
- Where the living POC context is

## Company

Kin Insurance is an insurtech (insurance and technology startup). Its insurance application writes to Postgres, and most analytical data starts there. Insurance vocabulary shows up throughout the catalog (e.g. `policy_term`, bound/in-force/incepted premium, binds, cancellations, eFNOL claims, underwriting). Glossary and metric work should use those terms precisely, and confirm Kin's definitions with owners rather than assuming industry-standard ones.

The user is Damian Eralio, Staff Data Engineer on the Data & ML Ops team. He is standing up the OMD instance and designing how it will be used, working with a governance lead who will own stewardship process.

## Data platform

Medallion architecture on Databricks (Unity Catalog), deployed on AWS:

| Layer        | Where                    | How it gets there                                      |
| ------------ | ------------------------ | ------------------------------------------------------ |
| Source       | Postgres (insurance app) | App writes                                             |
| Bronze       | S3 data lake bucket      | AWS DMS (CDC from Postgres)                            |
| Intermediate | `ingestion` catalog      | DLT / Spark Declarative Pipelines (SDP)                |
| Silver       | `processed` catalog      | DLT/SDP materialized views; **1:1 with source tables** |
| Gold         | SQLMesh projects (below) | SQLMesh models reading `processed`                     |

Other sources (Fivetran, vendor drops, etc.) exist but are out of scope for OMD right now. What matters is that `processed` is the silver layer, whatever its origin.

### Gold: SQLMesh projects

Each SQLMesh project gets two catalogs (Terraform module `sqlmesh_project`, instances in `kin-analytics-terraform/src/terraform/stacks/databricks/workspaces/default/sqlmesh_projects.tf`):

- **Presentation catalog** (named after the project): views users query.
- **Physical catalog** (`sqlmesh_<project>_internal`): SQLMesh's versioned snapshot tables, schemas `sqlmesh__<schema>`.

| Project           | Presentation      | Physical                           | What it is                                                                                                                                                  |
| ----------------- | ----------------- | ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `legacy`          | `legacy`          | `sqlmesh_legacy_internal`          | The older warehouse ported into SQLMesh; Looker-facing (schemas like `dwh`, `edw`, `looker`, `stage_publish_*`). SQLMesh code in repo `kin-dbx-edw-legacy`. |
| `enterprise-data` | `enterprise_data` | `sqlmesh_enterprise_data_internal` | The new gold model (schemas `entity`, `snapshot`, `measure`, `event`, `lookup`, `relationship`, `acquisition`).                                             |

Lineage shape: `processed` → `sqlmesh_<proj>_internal` tables → presentation views. OMD drops lineage edges whose endpoints aren't ingested, so the physical catalog must be ingested for silver→gold lineage to render.

In non-prod workspaces, catalogs are prefixed (`dev_`, `sandbox_`); prod has no prefix.

## What is (and isn't) in OpenMetadata

- **Ingested (or planned):** `processed`, `legacy`, `sqlmesh_legacy_internal`, `enterprise_data`, `sqlmesh_enterprise_data_internal`.
- **Intentionally excluded:** `ingestion` (low-value intermediate state). Also no S3/DMS/Postgres tie-back for now.
- **Connector:** Unity Catalog connector (not the "Databricks" connector) for metadata and lineage, since `processed` lineage is DLT pipeline lineage that the Databricks connector's SQL-log parsing can't see. Service principal `prod_omd_poc_sa`, OAuth M2M, reading the **prod** workspace.

Check the live instance with the MCP for the current asset inventory rather than trusting this list.

## The POC: why OMD, and in what order

**The problem.** Unity Catalog has no good way for data owners in business units to own and edit the descriptions of the tables and columns they know best. OMD offers RBAC, approval of changes, and change tracking/versioning, so it is being trialled as the place to store and manage a **semantic layer** serving both humans and AI.

**Phases** (Damian's order; advise within it, and flag if a later phase should influence an earlier design decision):

1. **Semantic layer with stewardship.** Ownership of tables/columns by teams, RBAC so owners (not just engineers) can edit descriptions, approval workflows for changes, version history. Silver (`processed`) first, then gold.
2. **Broader governance features.** Glossaries, classifications/tags, tiers, certification, metrics, teams, personas, domains/data products, data contracts, data quality. Goal: decide which of these make Kin better data stewards and a better semantic layer.
3. **Context Center.** Moving context that lives in Confluence today into OMD for data users.
4. **AI context.** OMD's capabilities for storing and versioning AI context (markdown files, memories, etc.). **The team does not yet understand why they would use OMD instead of git to version LLM instructions and context.** Treat this as an open research question: investigate what OMD actually offers in 2.0.x, then give an honest comparison (discoverability, linkage to data assets, RBAC/approval by non-engineers, retrieval through MCP/semantic search vs. PR review, diffs, CI, branching). Don't assume OMD wins.

## Constraints

- **Self-hosted open-source OMD only.** Collate (managed SaaS) is out of scope; don't recommend Collate-only features without saying so plainly.
- **POC deployment:** a standalone EC2 instance running OMD and its backing services in Docker, with OMD basic auth and a seeded admin. SSO and Kubernetes are explicitly **not** POC requirements; don't push them into POC work.
- **Production deployment (if adopted):** the supported open-source Kubernetes deployment (OMD's Helm charts), plus **Okta SSO** that Damian will set up with IT. Advise on this when asked about the path to production, and flag POC choices that would make the move harder.
- Infrastructure is Terraform + Terramate in `kin-analytics-terraform` (stack `src/terraform/stacks/omd_poc`); environment changes follow that repo's CLAUDE.md.

## Open questions

- **Business units / data owners:** unknown which business units will steward data. Don't invent team names. When teams/ownership design comes up, help Damian work out how to discover and model them instead of presuming.
- Okta group → OMD team/role mapping: not designed yet (production concern).
- Production Kubernetes details (which cluster, managed DB/search choices): not decided.

## Where the living POC context is

Read these on demand. They change as the POC moves, so prefer them over anything summarized here:

- POC notes: `~/Documents/code/kin-analytics-terraform/docs/temp/omd/`, dated `YYYY-MM-DD-<JIRA>-<topic>.md`. The newest `*-handoff.md` is the current state; earlier files are history.
- Infrastructure: `~/Documents/code/kin-analytics-terraform/src/terraform/stacks/omd_poc/` (README covers environments, connecting via SSM port-forward to `http://localhost:8585`, first login, sandbox stop/start, adding the Databricks connection).
- Databricks grants for the OMD service principal: `src/terraform/stacks/databricks/workspaces/default/` in the same repo.
- JIRA epic **CORE-12214** (OpenMetadata POC) and its child tickets, via the `atlassian-toolkit:using-atlassian-api` skill.
- Environments: shared, durable instance in **analytics-dev**. Sandbox instances are for individual testing and auto-stop nightly at 9 PM CT.
