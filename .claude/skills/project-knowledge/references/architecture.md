# Architecture

## Purpose
Technical architecture overview for AI agents. Helps agents understand HOW the system is built.

---

## Tech Stack

**Runtime:** Bash scripts (macOS) + Python 3 (Agent Cleaner)
- **Why:** Native on macOS, no extra dependencies for shell scripts. Python for process management (psutil).

**CLI tool:** Qwen Code (`@qwen-code/qwen-code` npm package, CLI binary: `qwen`)
- **Why:** Free AI coding agent with 1000+ requests/day, open-source, Claude Code-compatible feature set.
- **Install methods:** npm, Homebrew (`brew install qwen-code`), or quick install script.

**Node.js:** v20+ (required by Qwen Code)
- **Why:** Qwen Code runtime dependency.

**Key Qwen Code paths:**
- Global config: `~/.qwen/` (analogous to `~/.claude/`)
- Project config: `.qwen/` (analogous to `.claude/`)
- Instructions file: `QWEN.md` (analogous to `CLAUDE.md`)
- Settings: `~/.qwen/settings.json`
- Skills: `~/.qwen/skills/<name>/SKILL.md`
- Commands: `~/.qwen/commands/<name>.md`
- Agents: `.qwen/agents/<name>.md`

**Tool name mapping (Claude Code → Qwen Code):**
- `Bash` → `run_shell_command`
- `Read` → `read_file`
- `Write` → `write_file`
- `Edit` → `edit`
- `Glob` → `glob`
- `Grep` → `grep_search`

**Database:** None

---

## Project Structure

**docs/** — numbered step-by-step guides (01-installation through 07-skill-master), ordered by setup sequence. Each guide is self-contained but follows the sequence in docs/README.md.

**scripts/** — automation: `setup-qwen.sh` (full setup), `agent_cleaner.py` (process cleanup daemon), `install-hooks.sh` (security hooks installer).

**configs/** — reference configurations: `settings.json` (Qwen settings with hooks and permissions), `hooks/block-dangerous.sh` (PreToolUse hook script), `com.user.agentcleaner.plist` (launchd service definition).

**skills/** — methodology skills adapted for Qwen Code: methodology, quick-learning, skill-master. Each has a SKILL.md with YAML frontmatter.

---

## Key Dependencies

**Critical packages:**
- `@qwen-code/qwen-code` - The CLI agent itself (npm)
- `psutil` - Python library for process monitoring (Agent Cleaner)
- `node` v20+ - Runtime for Qwen Code

No other external dependencies. All scripts use built-in macOS tools (bash, launchctl, pkill).

---

## External Integrations

**Qwen Code API (Alibaba Cloud)**
- **Purpose:** AI model backend for Qwen Code CLI
- **Auth method:** OAuth via browser (Google or GitHub login), handled by Qwen Code automatically

No other external API dependencies.

---

## Data Flow

User runs `setup-qwen.sh` → script installs Node.js (if missing), installs Qwen Code via npm, runs profiling questions and writes answers to `~/.qwen/QWEN.md`, copies security hooks to `~/.qwen/settings.json`, installs Agent Cleaner as launchd service, copies methodology skills to `~/.qwen/skills/`. After setup, Qwen Code reads QWEN.md on every session start, hooks intercept dangerous commands before execution, and Agent Cleaner runs independently in background.

---

## Data Model

**Database:** Not applicable

### Persistent Files

**`~/.qwen/QWEN.md`**
- Purpose: Global agent instructions + user profile
- Key sections: user role, experience, goals, communication preferences, language

**`~/.qwen/settings.json`**
- Purpose: Hooks configuration, MCP servers, approval mode
- Key sections: hooks (PreToolUse block-dangerous), permissions

**`~/Library/LaunchAgents/com.user.agentcleaner.plist`**
- Purpose: launchd service definition for Agent Cleaner
- Auto-starts on login, runs agent_cleaner.py in background

### Sensitive Data

No PII stored. User profile in QWEN.md contains only role/preferences, no personal identifiers.
