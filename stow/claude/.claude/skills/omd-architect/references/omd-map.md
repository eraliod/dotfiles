# OpenMetadata 2.0.x: docs and source map

Verified 2026-10-21 against docs v2.0.x (every URL returned real content) and source tag `2.0.5-release`. `…/` = `https://docs.open-metadata.org/v2.0.x/`. Schema paths abbreviate `openmetadata-spec/src/main/resources/json/schema/` as `schema/`; seed data `openmetadata-service/src/main/resources/json/data/` as `data/`.

## Contents

- Fetching docs efficiently
- Versions and release notes
- 1 Deployment · 2 Auth · 3 Authorization · 4 Change control · 5 Glossary/tags/tiers
- 6 Domains/products/contracts · 7 Metrics/insights · 8 Personas · 9 Databricks/UC
- 10 Context Center · 11 AI and MCP · 12 Lineage/quality · 13 APIs/SDK
- Gaps (no 2.0.x docs)

## Fetching docs efficiently

- Append `.md` to any docs page for clean markdown (e.g. `…/how-to-guides/mcp/reference.md`). Cheapest way to read a page.
- Full page index: `https://docs.open-metadata.org/_llms/v2-0-x.txt` (~1,044 pages), plus `/_llms/v2-0-x/{deployment,connectors,sdk-and-apis}.txt`. Search it when a topic isn't below.
- OpenAPI: `https://docs.open-metadata.org/api-reference/openapi.json`.
- The docs site returns real 404s, so a failed fetch means the page doesn't exist at that path.

## Versions and release notes

- Git: tag `2.0.5-release` (branch `2.0.5` also exists); release line branch `2.0`. **2.0.6** (`2.0.6-release`) is the latest patch; check its notes before recommending an upgrade.
- Release notes (2.0.0–2.0.6 on one page): `…/releases/2.0-release`.
- **Breaking changes hub (best 2.0-specific reading):** `…/deployment/upgrade/breaking-changes/overview`, sub-pages `collaboration`, `data-governance`, `api-and-schema`, `platform-and-security`, `ingestion-and-connectors`, `lineage`, `ui-and-customization`.

  2.0 headlines, useful to correct 1.x-era assumptions:

1. **Context Center** replaces Knowledge Center: Articles (old pages), plus new Documents and Memories. `/knowledge-center/` links break.
2. **Tasks** redesigned as a first-class versioned entity (`/v1/tasks`), each driven by a governance workflow.
3. **Suggestions removed**; they are Tasks now.
4. Announcements become an entity; Activity Stream replaces system feed threads (30-day retention by default).
5. **Custom Intake Forms** (certification, ownership, classification requests).
6. OWL/RDF **ontology import**.
7. **MCP server on by default**, cursor paging; 2.0.2 cut it from 24 tools to 15.
8. Semantic search config moved to `llmConfiguration.embeddings`.
9. Profiler defaults to Dynamic Sampling; cardinality off by default.
10. Ingestion on Python 3.12 / Airflow 3.3; Airflow as internal orchestrator deprecated in 2.1; Great Expectations 0.x removed.

- 2.0.2: users can only be direct members of **Group**-type teams (existing memberships migrated).
- 2.0.5: restores metadata that 2.0 ingestion wiped; bot ingestion no longer overwrites user-set tags/owners; Databricks job lineage fixes.

## 1. Deployment

- `…/deployment/docker`, `…/deployment/kubernetes` (+ `/values`), `…/deployment/bare-metal`, `…/deployment/upgrade`, `…/deployment/minimum-requirements`.
- Minimums: MySQL 8.0.42+ or Postgres; Elasticsearch 9.x or OpenSearch 3.4.0+ (3.0–3.3 have a bug); Airflow 2.10.5.
- Ingestion runners: `…/deployment/ingestion/openmetadata` (Airflow), `…/deployment/ingestion/kubernetes` (native K8s orchestrator, the forward path; relevant to the production Helm design).
- Source: `conf/openmetadata.yaml`, `docker/docker-compose-quickstart/docker-compose{,-postgres}.yml`.

## 2. Authentication

- `…/deployment/security/okta` (OIDC app, auth flow choice, ingestion config), `…/deployment/security/oidc`, `…/deployment/security/basic-auth`, `…/deployment/security/enable-jwt-tokens` (JWKS at `/api/v1/system/config/jwks`), `…/deployment/security/configuration-parameters`, `…/developers/bots`, `…/how-to-guides/guide-for-data-users/personal-access-token`.
- Self-signup: `AUTHENTICATION_ENABLE_SELF_SIGNUP` (default true).
- Source: `schema/configuration/{authenticationConfiguration,authorizerConfiguration}.json`, `schema/auth/personalAccessToken.json`.

## 3. Authorization, teams, ownership

- `…/how-to-guides/admin-guide/roles-policies`, `…/roles-policies/authorization` (conditions `hasDomain()`, `isOwner()`, `matchAnyTag()`, `inAnyTeam()`; bot-domain caveats), `…/roles-policies/resource-scope`, `…/roles-policies/use-cases`, `…/admin-guide/permission-debugger`, `…/admin-guide/teams-and-users/team-structure-openmetadata`, `…/guide-for-data-users/data-ownership`.
- 2.0: task operations `CreateTask`, `EditTask`, `ResolveTask`, `CloseTask`, `ReassignTask`; self-approval guard; seeded `TaskAuthorPolicy`. **Customized seed policies aren't backfilled**, so their users get 403 on tasks until the operations are added.
- Domain-only access: `DomainOnlyAccessRole` → `DomainAccessPolicy` (allow all when `hasDomain()`, deny otherwise).
- Source: seed roles/policies `data/{role,policy}/` (DataSteward, DataConsumer, DomainOnlyAccessRole, …); `schema/entity/policies/{policy.json,accessControl/rule.json}`, `schema/entity/teams/{role,team,persona}.json`.

## 4. Change control: tasks, approvals, versions

- `…/how-to-guides/data-collaboration/tasks`, `…/data-collaboration/request-description`, `…/data-collaboration/request-tags`, `…/data-collaboration/activity-feeds`, `…/guide-for-data-users/versions`, `…/data-governance/glossary/approval`.
- **Governance Workflows have no 2.0.x page**; nearest is `https://docs.open-metadata.org/v2.1.x-SNAPSHOT/how-to-guides/data-governance/governance-workflows` (verify against 2.0.5 source before relying on it).
- Default workflows: `data/governance/workflows/` (`GlossaryApprovalWorkflow`, `DescriptionUpdateTaskWorkflow`, `TagUpdateTaskWorkflow`, `SuggestionTaskWorkflow`, `OwnershipUpdateTaskWorkflow`, …).
- Schemas: `schema/entity/tasks/task.json`, `schema/entity/feed/{thread,suggestion,description}.json`, `schema/governance/workflows/{workflowDefinition,workflowInstance}.json` (node types in `elements/nodes/`).

## 5. Glossary, classification, tiers, certification

- `…/how-to-guides/data-governance/glossary`, `…/glossary/glossary-term` (synonyms, status, versions), `…/glossary/setup`, `…/data-governance/classification`, `…/classification/auto-classification`, `…/auto-classification/auto-pii-tagging`, `…/classification/tiers`, `…/data-governance/intake-forms`, `…/data-governance/ontology`.
- A glossary with no reviewers auto-approves its terms.
- Certification: no dedicated page. It appears as the `EditCertification` operation and in intake forms; check source.

## 6. Domains, data products, data contracts

- `…/how-to-guides/data-marketplace/domains`, `…/data-marketplace/data-products`, `…/data-contracts`, `…/data-contracts/spec`, `…/data-contracts/odcs` (ODCS import/export).
- Source: `schema/entity/domains/{domain,dataProduct}.json`, `schema/entity/datacontract/`.

## 7. Metrics, KPIs, Data Insights

- `…/how-to-guides/data-governance/metrics` (properties, lineage, example JSON), `…/data-insights`, `…/data-insights/kpi`, `…/data-insights/report`.
- Source: `schema/entity/data/metric.json`.

## 8. Personas and landing pages

- `…/how-to-guides/admin-guide/persona-landing-page-customization`, `…/defining-persona`, `…/customizable-landing-page`.
- Personas also feed the MCP `get_persona_context` tool.

## 9. Databricks and Unity Catalog connectors

- `…/connectors/database/unity-catalog` (+ `/yaml`), `…/connectors/ingestion/workflows/metadata/incremental-extraction/unity-catalog`, `…/connectors/database/databricks` (+ `/yaml`, `/troubleshooting`).
- Both: PAT, Databricks OAuth M2M, Azure AD. Need `USE CATALOG`/`USE SCHEMA`/`SELECT`, plus `system.query.history` and `system.access.{table,column}_lineage`.
- Docs list usage and profiler workflows only for the Databricks connector; Unity Catalog lists incremental extraction and lineage. Kin uses Unity Catalog (see kin-context.md), so verify in source before promising UC profiler or usage.
- Source: `schema/entity/services/connections/database/{databricksConnection,unityCatalogConnection}.json`, `ingestion/src/metadata/ingestion/source/database/{databricks,unitycatalog}/`.

## 10. Context Center

- `…/how-to-guides/context-center`, `…/context-center/articles`, `…/context-center/documents`, `…/context-center/memories`.
- **Articles:** long-form pages (migrated Knowledge Center).
- **Memories:** atomic facts typed FAQ / Note / Preference / Runbook / Use Case; visibility Shared, Entity or Private; citation counts. Versioned entity (`changeDescription`, `usageCount`, `status`, source fields).
- **Documents:** uploaded files. Text extracted server-side (PDFBox, Apache POI, Tika/Tesseract OCR: PDF, Office, spreadsheets, CSV/text, images; no archives; 1M chars, 200K indexed; **requires object storage configured**). Extracted Q&A "pills" are served by MCP `company_context`.
- RBAC resources: "Context Memory" and "File".
- `company_context` by `query` needs vector embeddings; by `fqn` it doesn't.
- Source: `openmetadata-service/.../service/drive/ContextFile{ExtractionService,TextExtractor}.java`, `.../resources/context/ContextMemoryResource.java`; `schema/entity/context/contextMemory.json`, `schema/entity/data/{contextFile,contextFileContent,page}.json`.
- **Unverified:** `contextFile.sourceType` lists Confluence, Notion and DriveSync, but whether OSS 2.0.5 implements those syncs, and what generates the Q&A pills (possibly LLM-backed or Collate-only), is unconfirmed. Check source before advising a Confluence migration path.

## 11. AI features and MCP

- `…/how-to-guides/mcp` (OAuth, PAT, bot JWT; bots can't use PATs), `…/mcp/connect` (endpoint `{OM_URL}/mcp`; its "24 tools" is stale), `…/mcp/oauth`, `…/mcp/claude-code`, `…/mcp/reference`, `…/mcp/semantic-search`, `…/deployment/semantic-search`.
- 15 tools (source: `openmetadata-mcp/src/main/resources/json/data/mcp/tools.json`): `search_metadata`, `semantic_search`, `company_context`, `get_entity_details`, `get_user_context`, `get_persona_context`, `find_context`, `get_entity_lineage`, `create_lineage`, `root_cause_analysis`, `create_entity`, `describe_entity_type`, `patch_entity`, `get_test_definitions`, `create_test_case`. Older per-type creates (incl. `create_context_memory`) are folded into `create_entity`.
- Semantic search: embedding providers OpenAI, Bedrock, Google, DJL; index `dataAssetEmbeddings`; covers `contextMemory`, `page`, `metric`, `glossaryTerm`, among others. Config: `schema/configuration/llmConfiguration.json`.
- `…/sdk/ai-sdk` targets **Collate AI Studio** (commercial), not OSS.
- **OMD vs git for AI context:** no doc argues it. What the platform supports, inferred from schemas: memories are versioned entities with change descriptions, RBAC plus per-memory visibility, asset linkage, usage/citation counts, and retrieval by agents via MCP. Build the comparison from these facts, not from marketing.

## 12. Lineage, data quality, observability

- `…/how-to-guides/data-lineage`, `…/data-lineage/manual`, `…/data-lineage/workflow`, `…/connectors/ingestion/workflows/lineage/lineage-workflow-query-logs`, `…/data-quality-observability/quality`, `…/quality/data-quality-as-code`, `…/data-quality-observability/incident-manager`, `…/alerts-notifications`.

## 13. APIs and SDK

- `…/api-reference` (REST), `…/api-reference/authentication`, `…/api-reference/sdk/python` ("SDK 2.0" alongside the original `OpenMetadata` client), `…/connectors/ingestion/workflows/metadata`, `…/connectors/ingestion/workflows/usage`.
- Source: `schema/metadataIngestion/workflow.json`.

## Gaps (no 2.0.x docs; go to source)

Governance Workflows, Certification, Suggestions (removed), OMD-vs-git rationale, Context File sync connectors in OSS, Q&A pill generation.
