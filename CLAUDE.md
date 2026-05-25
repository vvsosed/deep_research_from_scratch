# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

A LangGraph-based deep research system built as a tutorial series. Five notebooks in `notebooks/` demonstrate progressive patterns; the actual source under development lives in `src/deep_research_from_scratch/`.

**Critical rule**: Only edit files under `src/`. The `notebooks/` directory is read-only reference material. The `deprecated/` folder is archived — ignore it entirely when reading, reasoning, or suggesting changes.

## Environment Setup

Requires Python 3.13 and `uv`:

```bash
uv sync              # install locked deps
uv sync --extra dev  # also install ruff and mypy
```

Copy `.env` and fill in keys (all required for full functionality):

```env
TAVILY_API_KEY=...
OPENAI_API_KEY=...
ANTHROPIC_API_KEY=...
LANGSMITH_API_KEY=...          # optional tracing
LANGSMITH_TRACING=true
LANGSMITH_PROJECT=deep_research_from_scratch

# Model overrides (used by src/ modules)
RESEARCH_AGENT_MODEL=anthropic:claude-sonnet-4-20250514
SUMMARIZATION_MODEL=openai:gpt-4.1-mini
COMPRESS_MODEL=openai:gpt-4.1
```

Node.js / `npx` is required only for the MCP agent (`research_agent_mcp.py`).

## Common Commands

```bash
# Run code
uv run python -m deep_research_from_scratch.research_agent

# Lint / format
uvx ruff check src/
uvx ruff check src/ --fix

# LangGraph dev server (registers graphs from langgraph.json)
make start          # background on http://127.0.0.1:2024
make stop
make logs
make run            # foreground
```

## Architecture

The system implements three phases:

1. **Scope** (`research_agent_scope.py`) — clarifies user intent via structured output, then generates a research brief. Exports `scope_research` graph (registered in `langgraph.json`).

2. **Research** — two variants:
   - `research_agent.py` — uses Tavily web search + `think_tool` in a `llm_call → tool_node → compress_research` loop. Exports `researcher_agent`.
   - `research_agent_mcp.py` — same loop but tools come from an MCP filesystem server (launched via `npx`). All nodes are `async`. Exports `agent_mcp` (registered in `langgraph.json`).

3. **Supervisor** (`multi_agent_supervisor.py`) — a `supervisor → supervisor_tools` async loop that delegates to multiple `researcher_agent` instances in parallel via `asyncio.gather`. Uses `ConductResearch` and `ResearchComplete` as LangGraph tools. Exports `supervisor_agent`.

`research_agent_full.py` wires all three phases into the complete end-to-end system.

### State layer

- `state_research.py` — `ResearcherState` / `ResearcherOutputState` for individual researchers; also holds `Summary`, `ClarifyWithUser`, `ResearchQuestion` Pydantic schemas for structured outputs.
- `state_scope.py` — `AgentState`, `AgentInputState`, `ClarifyWithUser`, `ResearchQuestion` for the scoping graph.
- `state_multi_agent_supervisor.py` — `SupervisorState` and the `ConductResearch` / `ResearchComplete` tool schemas.

### Utilities (`utils.py`)

- `tavily_search` — single-query tool wrapping `TavilyClient`; deduplicates and summarizes raw content.
- `think_tool` — reflection tool that creates a deliberate reasoning step before the agent decides what to do next.
- `get_today_str`, `get_current_dir` — shared helpers used across all agents.

### Prompts (`prompts.py`)

All system/human prompts are centralized here. Import from this module rather than defining prompts inline.

## Code Style

Ruff enforces Google-style docstrings (`D` rules), isort (`I`), pyflakes (`F`), and pycodestyle (`E`). E501 (line length) is ignored. Run `uvx ruff check src/ --fix` before committing.

Key ruff rules to watch: D212 (docstring on same line as `"""`), I001 (import order), F401 (unused imports), D415 (period at end of docstring summary).
