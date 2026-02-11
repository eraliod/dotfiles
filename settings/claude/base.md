# Claude Core Preferences for Damian Eralio

## Quick Start

You are interacting with Damian Eralio, Staff Data Engineer at Kin Insurance. This file contains core preferences shared across all Claude interfaces.

## Modern CLI Tools (Enforced by PreToolUse Hook)

YOU MUST use modern CLI tools for these operations. Using legacy tools will cause your commands to be blocked.

### Text and Code Search

**FORBIDDEN:** `grep`, `egrep`, `fgrep` - NEVER use these commands

**REQUIRED:**

- **Text search:** `rg "pattern" path/` (ripgrep via Bash tool)
- **Code structure:** `ast-grep --pattern 'structural pattern'` (via Bash tool)

**Examples:**

```bash
# Finding text in files
rg "TODO" src/
rg -i "error" logs/  # case insensitive
rg "class.*Test" --type py  # with file type filter

# Finding code structures
ast-grep --pattern 'class $NAME { $$$ }'  # find class definitions
ast-grep --pattern 'def $FUNC($$$):' --lang python  # find functions
ast-grep --pattern 'import { $$$ } from "$MOD"'  # find imports
```

### File Finding

**FORBIDDEN:** `find` command - NEVER use this command

**REQUIRED:** `fd` (via Bash tool)

**Examples:**

```bash
# Find by name
fd filename
fd "test.*\.py$"  # regex pattern

# Find by extension
fd -e py
fd -e js -e ts  # multiple extensions

# Find in specific directory
fd pattern directory/

# List all files in directory
fd . directory/
```

### Text Processing

**FORBIDDEN:** `sed`, `awk` for text processing

**REQUIRED:**

- **JSON:** `jq` (via Bash tool)
- **YAML/XML:** `yq` (via Bash tool)
- **Text filtering:** `rg` (via Bash tool)

## Pre-commit Hooks (Enforced by Git Workflow)

YOU MUST NEVER bypass pre-commit hooks. No exceptions.

**Forbidden commands - YOU MUST NOT use:**

- `git commit --no-verify`
- `git commit -n`
- `SKIP=<hook> git commit`
- `pre-commit uninstall`
- Any flag, environment variable, or workaround that skips hooks

**When hooks fail:**

1. Read the error output
2. Fix the underlying issue
3. Stage the fixes and any changes the linters/formatters made
4. Commit again (hooks will re-run automatically)

## Python Tooling (Project-Aware)

YOU MUST use the project's package manager for Python tools. Running global `pytest`, `mypy`, or `ruff` in a managed project = broken imports, missing dependencies, wrong versions. Every time.

**Detection signals:**

- `uv.lock` or `[tool.uv]` in pyproject.toml → use `uv run`
- `pixi.toml` or `pixi.lock` → use `pixi run`

**FORBIDDEN in uv/pixi projects:**

- `pytest` (global)
- `mypy` (global)
- `ruff` (global)
- Any Python tool invoked without the project's runner

**REQUIRED:**

```bash
# uv projects
uv run pytest tests/
uv run mypy src/
uv run ruff check .

# pixi projects
pixi run pytest tests/
pixi run mypy src/
pixi run ruff check .
```

**No exceptions.** "It worked with global pytest" means you got lucky—the environment matched by accident. Use the project's tooling.

### Temporary Dependencies (Ultra-Fast Ad-Hoc Usage)

When you need a library for one-off scripts, quick experiments, or CLI tools (even outside any project), use ephemeral dependencies. **This is VASTLY faster and cleaner than pip install.**

**Why this matters:**

- No polluting any environment
- No manual cleanup needed
- Instant isolated execution
- No "did I install this globally?" confusion

**REQUIRED:**

```bash
# For Python packages (PyPI) - use uv (default choice)
uv run --with requests python script.py
uv run --with pandas --with matplotlib analysis.py
uv run --with ruff ruff check .  # one-off tool usage

# For conda packages or non-Python dependencies - use pixi
pixi exec -s gcc python script.py  # need a C compiler
pixi exec -s gdal python geo_script.py  # conda-only package
pixi exec -s jupyterlab jupyter lab  # quick Jupyter session
```

**Common use cases:**

- Quick data analysis with pandas/polars → `uv run --with`
- One-off API calls with requests/httpx → `uv run --with`
- Trying a formatter/linter → `uv run --with`
- Need conda-only packages (GDAL, scientific libs) → `pixi exec -s`
- Need non-Python tools (compilers, system tools) → `pixi exec -s`

**Never use `pip install` for these.** Both `uv` and `pixi` are global CLI tools that handle downloading, caching, isolation, and cleanup automatically. It's literally designed for this exact scenario.

## Databricks Access

We have direct access to Databricks data. Asking Damian for schemas when we can query them ourselves wastes both our time. Guessing at table structures when we can explore them directly leads to broken queries.

### CLI Operations (All Workspaces)

The Databricks CLI works on any workspace via profiles:

```bash
databricks workspace list /Users --profile PROD
databricks clusters list --profile DEV
databricks jobs list --profile SANDBOX
databricks catalogs list --profile ADHOC-ANALYSIS
databricks jobs submit --json '...' --profile DEV
```

Upload notebooks, trigger jobs, check run status. Auth is handled automatically.

### Databricks MCP Server (Preferred)

Use the `databricks-dbsql` MCP tools for SQL queries. This is the default choice for data exploration.

**Token expiry:** A PreToolUse hook (`databricks-mcp-token-check.sh`) monitors OAuth token age. If a Databricks MCP tool call is **blocked by this hook**, the OAuth token has expired. Tell the user:

> The Databricks [PROFILE] MCP server's OAuth token has expired. Restart it via `/mcp` to get a fresh token.

### Databricks Connect (Rare - When SQL Truly Won't Work)

Use databricks-connect only for operations that **cannot** be expressed in SQL:

- Custom Python UDFs
- MLlib / machine learning pipelines
- Iterative algorithms requiring programmatic logic
- Integration with Python libraries (pandas UDFs, numpy)

**If you can write it as a SQL query, use the MCP server instead.**

**Boundaries:**

- **DEV workspace only** — Queries against PROD, SANDBOX, ADHOC-ANALYSIS will fail
- **Read-only** — Write operations are blocked

**Invocation:**

Write your script to `/tmp/spark_query.py` first, then run:

```bash
DATABRICKS_HOST="${DATABRICKS_HOST}" \
DATABRICKS_TOKEN=$(databricks auth token --profile DEV | jq -r '.access_token') \
uvx --from 'databricks-connect==17.2.*' python /tmp/spark_query.py
```

Do NOT add `--with pyspark`—databricks-connect bundles its own pyspark-connect and they conflict.

**Performance:** Exploration without `.limit()` or aggregations = slow transfers. We're exploring, not exporting.

**Version:** 17.2.x required—later versions don't support serverless yet.

## Postgres Access

We have direct access to dev and prod Postgres databases via `psql` through SSH tunnels.

**Read-only** — Do NOT execute anything outside of `SELECT` without explicit permission from Damian.

**Connection requires active SSH tunnels.** Damian's tunnel setup determines dev vs prod. If you get `Connection refused` on localhost, remind Damian to authenticate to the target AWS account and run the `mapdb` script.

**Two RDS instances — port determines which:**

| Instance | Port  |
| -------- | ----- |
| analysis | 15434 |
| shared   | 15632 |

Ask Damian which instance to query if not specified. Do NOT guess.

**Invocation:**

```bash
# Dev — analysis (port 15434)
PGPASSWORD=$RDS_PG_DEV_DOTCOM_PW psql -U $RDS_PG_DEV_DOTCOM_USER -d dot-com -p 15434 -h localhost

# Dev — shared (port 15632)
PGPASSWORD=$RDS_PG_DEV_DOTCOM_PW psql -U $RDS_PG_DEV_DOTCOM_USER -d dot-com -p 15632 -h localhost

# Prod — analysis (port 15434)
PGPASSWORD=$RDS_PG_PROD_DOTCOM_PW psql -U $RDS_PG_PROD_DOTCOM_USER -d dot-com -p 15434 -h localhost

# Prod — shared (port 15632)
PGPASSWORD=$RDS_PG_PROD_DOTCOM_PW psql -U $RDS_PG_PROD_DOTCOM_USER -d dot-com -p 15632 -h localhost
```

## Git Workflow

- **Conventional commits:** `type(scope): subject` format
- **Atomic commits:** One logical change per commit
- **No AI co-authorship:** Never include AI attribution in commits

## Damian's JIRA Defaults (MANDATORY)

YOU MUST read @jira_instructions.md anytime you are asked to work with JIRA
