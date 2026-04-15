# Project Context

## Purpose
This file provides high-level project overview for AI agents. Helps agents understand WHAT we're building and WHY.

---

## Project Overview

**Name:** Настройка QWEN (qwen-setup)

**Description:** Step-by-step guide and automation scripts for setting up Qwen Code CLI on macOS — from installation to a fully configured development environment with security, process cleanup, and AI development methodology.

The project packages the author's Claude Code methodology (quick-learning, skill-master) into portable scripts and configs that work with Qwen Code CLI.

---

## Target Audience

**Primary users:** Developers and tech-savvy users who want to use Qwen Code CLI as their AI coding assistant on macOS.

**Use case:** Need a complete, production-ready setup — not just "install and run", but security hardening, orphaned process cleanup, and a structured methodology for AI-assisted development.

**Experience range:** Mixed — starts with beginner-friendly installation, gradually introduces advanced configuration (methodology, skills, hooks).

---

## Core Problem

Qwen Code CLI installs quickly but ships with no safety rails. Running in YOLO mode (no confirmations) speeds up work but risks destructive commands. Node processes from CLI agents (Qwen, Claude, Codex) accumulate and crash the system. The AI development methodology that makes agents effective (quick-learning, skill-master) exists only in Claude Code's ecosystem and needs manual adaptation for Qwen.

We solve this by providing a single setup script, protective hooks, a cross-platform process cleaner, and pre-configured methodology skills — all documented step by step.

---

## Key Features

- **Automated setup** - One script (`setup-qwen.sh`) installs and configures everything on macOS
- **Security hooks** - YOLO mode with PreToolUse hooks blocking destructive commands (rm -rf, force push, writes outside project)
- **Agent Cleaner** - Python daemon (launchd) that auto-kills orphaned node processes when RAM exceeds threshold
- **Methodology adaptation** - Quick-learning and skill-master skills ported from Claude Code to Qwen Code
- **User profiling** - 6 onboarding questions (role, code experience, product goals, activity domain, communication style, language) saved to QWEN.md global memory so the agent adapts its tone and explanations
- **Modular documentation** - Separate guides for each topic, usable independently

---

## Out of Scope

- Windows/Linux installation guides (macOS only for now)
- Porting all 59 Claude Code skills (only methodology core: methodology, quick-learning, skill-master)
- Building a GUI or web interface
- Qwen Code plugin/extension development
- CI/CD pipeline setup for user projects
