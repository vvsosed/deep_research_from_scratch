# Bootstrap with `uv`

This guide walks through bootstrapping the project end-to-end using [`uv`](https://docs.astral.sh/uv/). The repo ships with `pyproject.toml` and `uv.lock`, so `uv` will give you a reproducible environment in one command.

## 1. Install `uv`

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
# Make sure ~/.local/bin is on PATH
export PATH="$HOME/.local/bin:$PATH"
uv --version
```

## 2. Clone and enter the project

```bash
git clone https://github.com/langchain-ai/deep_research_from_scratch
cd deep_research_from_scratch
```

## 3. (Optional) Pin / install Python

`pyproject.toml` requires `>=3.13,<3.14`. `uv` will auto-fetch a matching interpreter, but you can be explicit:

```bash
uv python install 3.13
uv python pin 3.13
```

## 4. Sync the environment

This creates `.venv/` and installs everything from `uv.lock` exactly as locked:

```bash
uv sync
```

To include the dev tools (`mypy`, `ruff`) declared in `[project.optional-dependencies]`:

```bash
uv sync --extra dev
```

## 5. Install Node.js / `npx`

Required only for the MCP server used in `notebooks/3_research_agent_mcp.ipynb`.

```bash
# macOS (Homebrew)
brew install node

# Ubuntu / Debian
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Arch / Manjaro
sudo pacman -S nodejs npm

# Verify
node --version
npx --version
```

## 6. Create your `.env`

The notebooks load env vars via `python-dotenv`. Create `.env` at the project root:

```env
# Required for research agents with external search
TAVILY_API_KEY=your_tavily_api_key_here

# Required for model usage
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Optional: For evaluation and tracing
LANGSMITH_API_KEY=your_langsmith_api_key_here
LANGSMITH_TRACING=true
LANGSMITH_PROJECT=deep_research_from_scratch
```

## 7. Run things

You generally don't need to activate the venv — prefix commands with `uv run`:

```bash
# Jupyter
uv run jupyter notebook

# A one-off Python script / module
uv run python -m deep_research_from_scratch.research_agent

# Lint / format (if you installed --extra dev)
uv run ruff check src/
uv run ruff check src/ --fix
```

If you prefer an activated shell:

```bash
source .venv/bin/activate   # Windows: .venv\Scripts\activate
jupyter notebook
```

## 8. Run the LangGraph dev server

The `Makefile` drives this through `uvx`, so no extra install is required:

```bash
make start    # background, logs in .langgraph_api/dev.log
make status
make logs
make stop
make run      # foreground
```

Override defaults inline if needed:

```bash
make start PYTHON_VERSION=3.13 HOST=0.0.0.0 PORT=2024
```

## Useful day-to-day `uv` commands

- `uv sync` — reinstall to match `uv.lock`
- `uv lock --upgrade` — refresh the lock file
- `uv add <pkg>` / `uv remove <pkg>` — manage `pyproject.toml` deps
- `uv run <cmd>` — run inside the project env without activating it
- `uv tree` — show the resolved dependency graph

## Reference points in this repo

- Bootstrapping prerequisites: `README.md`
- Dependencies and Python version: `pyproject.toml`
- LangGraph dev server wiring through `uvx`: `Makefile`
- Workflow rules (edit `src/`, not `notebooks/`): `AGENTS.md`

That's it — `uv sync` + `.env` is the minimum to get the notebooks runnable, and `make start` brings up the LangGraph dev server.
