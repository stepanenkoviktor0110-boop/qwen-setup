# Deployment & Operations

## Purpose
Deployment process and distribution for AI agents.

---

## Deployment Platform

**Platform:** GitHub repository (public or private)

**Type:** Documentation + scripts distribution (no server, no hosting)

**Why this platform:** Users clone the repo and run the setup script locally. No infrastructure needed.

---

## Access Information

**SSH Access:** Not applicable — no server deployment.

**Repository:** https://github.com/stepanenkoviktor0110-boop/qwen-setup

---

## Environment Variables

No environment variables required for the project itself.

Qwen Code uses `DASHSCOPE_API_KEY` (if using API key auth) or OAuth (browser login). These are configured during setup, not stored in this repo.

---

## Deployment Triggers

**Distribution:** Manual — user clones repo and runs setup script.

**Updates:** Push to `master` branch. Users pull latest and re-run setup script.

---

## Pre-Deploy Checklist

- [ ] All scripts tested on clean macOS
- [ ] All paths and commands verified against current Qwen Code version
- [ ] No secrets or personal data in committed files
- [ ] README.md sequence matches actual guide order

---

## Rollback Procedure

**User rollback:** Re-run setup script — it's idempotent (checks existing state before acting).

**Qwen Code uninstall:** `npm uninstall -g @qwen-code/qwen-code`

**Agent Cleaner removal:** `launchctl unload ~/Library/LaunchAgents/com.user.agentcleaner.plist`

---

## Environments

**Production:** GitHub repo `master` branch — stable, verified guides and scripts.

**Development:** `dev` branch — work in progress.

---

## Monitoring & Observability

### Logging

**Agent Cleaner log:** `~/agent_cleaner.log` — records what processes were killed and when.

**Qwen Code logs:** Built-in, accessible via `--debug` flag.

### Error Tracking

**Tool:** None — local scripts, no error aggregation.

### Health Checks

**Agent Cleaner:** `launchctl list | grep agentcleaner` — check if running.

**Hooks:** Attempt a blocked command in Qwen Code session — should see block message.
