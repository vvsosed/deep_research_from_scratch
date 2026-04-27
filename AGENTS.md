# Deep Research From Scratch - Repository Guide

## Repository Structure

This repository builds a comprehensive deep research system from scratch using LangGraph, progressing through 5 tutorial notebooks that demonstrate different components and patterns.

```
deep_research_from_scratch/
├── notebooks/                       # Interactive tutorial notebooks (DO NOT MODIFY)
│   ├── 1_scoping.ipynb              # User clarification and brief generation
│   ├── 2_research_agent.ipynb       # Research agent with custom tools
│   ├── 3_research_agent_mcp.ipynb   # Research agent with MCP servers
│   ├── 4_research_supervisor.ipynb  # Multi-agent supervisor coordination
│   ├── 5_full_agent.ipynb           # Complete end-to-end system
│   └── utils.py                     # Shared utilities for notebooks
│
├── src/deep_research_from_scratch/  # Source code under development (MODIFY THESE)
│   ├── multi_agent_supervisor.py
│   ├── prompts.py
│   ├── research_agent.py
│   ├── research_agent_mcp.py
│   ├── state_*.py
│   └── utils.py
│
└── README.md # Comprehensive documentation; has to be kept up to date
```

## 🚨 Important Development Workflow

**The notebooks in `src/` and subfolders are the source under development and should be the ONLY files modified.**

The source code in `notebooks/` is for reference and educational purposes only

### Development Guidelines

- ❌ **DON'T** edit notebooks in `notebooks/` directory
- ❌ **DON'T** run notebook cells to regenerate source code
- ❌ **DON'T** test changes by running the notebooks
- ✅ **Edit**  files in `src` and its subfolders

## System Architecture

The system implements a three-phase deep research workflow:

1. **Scope** : Clarify research scope and generate structured briefs
2. **Research** : Perform research using various agent patterns
3. **Write** : Synthesize findings into comprehensive reports

### Key Components

- **Scoping Agent**: Clarifies user intent and generates research briefs
- **Research Agent**: Iterative research with custom tools or MCP servers
- **Supervisor Agent**: Coordinates multiple research agents for complex topics
- **Full System**: Integrates all components into end-to-end workflow

## Quick Start for Development

To be added soon

## Code Quality and Formatting

### Ruff Formatting Checks

To maintain consistent code formatting across the generated source files, run ruff periodically:

```bash
# Check for formatting issues
uv run ruff check src/

# Auto-fix formatting issues where possible
uv run ruff check src/ --fix

# Check specific file
uv run ruff check src/deep_research_from_scratch/research_agent.py
```

**Common formatting fixes needed:**
- **D212**: Ensure docstring summaries start on the same line as triple quotes
- **I001**: Organize imports properly (standard library → third party → local imports)
- **F401**: Remove unused imports
- **D415**: Add periods to docstring summaries