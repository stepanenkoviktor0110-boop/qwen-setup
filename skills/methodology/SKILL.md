---
name: methodology
description: |
  AI-First development methodology: spec-driven pipeline, project structure,
  skills ecosystem, quality gates. Adapted for Qwen Code.

  Use when: "изучи методологию", "как работает методология",
  "how does the methodology work", "explain the workflow"
---

# AI-First Development Methodology

## What Is This

A structured development approach for AI agents. Every feature goes through a pipeline: idea → spec → architecture → tasks → implementation → documentation update. Each stage has quality checks.

Core problems it solves:
- **Context loss between sessions** — distributed knowledge base persists across sessions
- **Quality without human review** — reviewers at every stage
- **Scope creep** — specs approved before coding starts

---

## Development Pipeline

### Step 1: User Spec

**What:** Structured interview to capture requirements in human-readable form.

**Process:**
- Agent reads Project Knowledge files to understand the project
- Scans codebase for relevant code, patterns, integration points
- Runs interview with the user (general → code-informed → edge cases)
- Creates `user-spec.md` from interview data
- User reviews and approves

**Output:** `work/{feature}/user-spec.md` (status: approved)

### Step 2: Tech Spec

**What:** Technical architecture, decisions, testing strategy, implementation plan.

**Process:**
- Reads approved user-spec
- Researches codebase, checks dependencies
- Asks technical clarification questions
- Creates `tech-spec.md` with architecture, decisions, testing strategy, implementation tasks
- User reviews and approves

**Output:** `work/{feature}/tech-spec.md` (status: approved)

### Step 3: Task Decomposition

**What:** Break tech-spec into atomic task files.

**Process:**
- For each Implementation Task in tech-spec, creates a task file with acceptance criteria, context files, dependencies
- Groups tasks into waves (parallel execution units)
- User reviews and approves

**Output:** `work/{feature}/tasks/*.md` (validated)

### Step 4: Implementation

**What:** Execute tasks one by one or in waves.

**Process:**
- Read task file and all its Context Files
- Write code following TDD: test first → implement → verify
- Commit implementation (code + tests pass)
- Self-review or request user review
- Write entry to `decisions.md`, update task status → done

### Step 5: Done

**What:** Finalize feature, update project knowledge, archive.

**Process:**
- Update affected Project Knowledge files (architecture.md, patterns.md, deployment.md)
- Move `work/{feature}/` → `work/completed/{feature}/`
- Commit changes

---

## Project Structure

### Project Knowledge — the Knowledge Base

All project documentation lives in `.qwen/skills/project-knowledge/references/`. Single source of truth.

| File | Content |
|------|---------|
| `project.md` | Purpose, audience, core features, scope |
| `architecture.md` | Tech stack, structure, dependencies, data model |
| `patterns.md` | Code conventions, git workflow, testing, business rules |
| `deployment.md` | Platform, env vars, CI/CD, monitoring |

**QWEN.md is minimal.** It contains only the project name, a reference to project-knowledge skill, and default branch. All real information lives in Project Knowledge files.

### Work Items

```
work/{feature}/
├── user-spec.md          # Requirements
├── tech-spec.md          # Architecture
├── decisions.md          # Decisions made during implementation
├── tasks/
│   ├── 1.md              # Atomic task files
│   ├── 2.md
│   └── 3.md
└── logs/                 # Working logs
```

Completed features are archived to `work/completed/{feature}/`.

### Global Structure `~/.qwen/`

```
~/.qwen/
├── skills/               # Skills (methodology, workflow, quality)
├── commands/             # Custom slash commands
├── agents/               # Subagent definitions
├── hooks/                # Automation hooks
├── settings.json         # Configuration
└── QWEN.md               # Global instructions
```

---

## Key Principles

- **Spec before code.** User Spec → Tech Spec → Tasks → Code. Code starts only after specs are approved.
- **Commit after each result.** Planning: draft → approval. Execution: code (tests pass) → review fixes → status.
- **PK = single source of truth.** All project docs in `.qwen/skills/project-knowledge/references/`. QWEN.md is minimal.
- **Just-in-time context.** Read only what's needed. Task files list Context Files explicitly.

---

## Quick Start

**New project:**
Create project → fill project knowledge (interview + docs) → start features

**New feature:**
User spec → tech spec → task decomposition → implementation → done

**Ad-hoc coding (no spec):**
Just describe what you need and start coding with TDD approach.
