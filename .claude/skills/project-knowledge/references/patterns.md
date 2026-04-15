# Patterns & Conventions

Coding conventions, development workflow, and project-specific practices.

---

## Project-Specific Patterns

### Documentation Style

All user-facing guides (docs/) are written in Russian for a mixed audience (beginners to intermediate). Technical terms, commands, and code stay in English with Russian explanations.

Each guide follows a progressive complexity pattern: start simple, add depth gradually. Every step includes a verification command or expected result so the user knows it worked.

### Script Style

Shell scripts (bash) target macOS. Use `#!/bin/bash` shebang. Include `set -euo pipefail` for safety. Print colored status messages for each step. Check prerequisites before acting.

Python scripts use standard library + psutil only. No frameworks, no virtual environments — keep it simple for non-technical users.

### Configuration Format

All Qwen Code configs use JSON (settings.json). Hook scripts are bash. Skill definitions are Markdown with YAML frontmatter.

Settings.json in Qwen Code is structured by sections: `general`, `model`, `tools`, `permissions`, `security`, `hooks`, `mcpServers`, `env`.

---

## Git Workflow

### Branch Structure

- **`master`** - Stable documentation and scripts. Protected.
- **`dev`** - Active work. All changes go here first, merge to master when verified.

### Branch Decision Criteria

**Direct to `dev`:** Typo fixes, single-file doc updates, config tweaks.

**Feature branch:** New guide sections, new scripts, structural changes to multiple files.

### Testing Requirements

- **On commit:** Manual verification — run scripts on a clean macOS environment (or VM) and confirm each step works.
- **On merge to master:** Full walkthrough of the setup sequence from scratch.

### Security & Quality Gates

- **Pre-commit:** No secrets in committed files. `.gitignore` covers `.env`, `*.key`, `*.pem`.
- **Review:** Documentation accuracy — all commands and paths verified against Qwen Code v0.14+.

---

## Testing & Verification

### Test Infrastructure

No automated test suite. Verification is manual: run the setup script on a clean macOS installation and confirm each step completes successfully.

### Agent Verification Methods

**Shell script output:** Run `setup-qwen.sh` and check exit code + status messages.

**Agent Cleaner:** Check `launchctl list | grep agentcleaner` and verify log file creation.

**Hooks:** Run `qwen` in a test directory, attempt a blocked command (e.g., `rm -rf /`), verify it's blocked.

### User Verification Methods

**Full setup walkthrough:** Follow all guides in sequence on a real Mac. Confirm Qwen Code starts, hooks block dangerous commands, Agent Cleaner runs in background.
