---
name: skill-master
description: |
  Embeds accumulated triads from quick-learning into target skills as permanent instructions.
  Reads triads with Adapted=— from triad-index.md, analyzes each skill's existing logic,
  auto-applies new rules when no coverage exists, proposes refinements when partial coverage found.
  Adapted for Qwen Code.

  Use when: "/skill-master", "обучи скиллы", "применить триады к скиллам", "встрой паттерны",
  "skill master", "обработай триады", "embed triads into skills", "apply learned patterns"
  Also triggered by: quick-learning when ≥25 entries with Adapted=— exist.
---

# Skill Master

Embeds accumulated quick-learning triads into target skills. Two outcomes per triad:
- **Auto-apply** — skill has no coverage of this case → add new rule directly
- **Dispute** — skill already has related logic but doesn't cover the specific case → propose refinement to user

## Category → Skill Mapping

| Category | Target skill |
|----------|-------------|
| sequencing | methodology |
| information-gathering | methodology |
| problem-decomposition | methodology |
| scope-management | methodology |
| recovery | methodology |
| communication | methodology |
| tool-selection | methodology |

> Note: with a small number of skills, most triads map to methodology. As you add more skills, update this table.

## Phase 1: Check

1. Count rows with `Adapted: —` in `~/.qwen/skills/quick-learning/references/triad-index.md`
2. If count < 25 → report: "Skill Master: {count}/25 триад накоплено. Запуск при ≥25." and exit.
3. If count ≥ 25 → proceed.

## Phase 2: Load Triads

1. Read `triad-index.md` — collect all rows where `Adapted = —`
2. For each row, load the full entry from `reasoning-patterns.md` by matching the title
3. Group triads by target skill using the Category → Skill mapping above

## Phase 3: Analyze and Apply

For each target skill that has ≥1 triad assigned:

1. Read the target skill's SKILL.md
2. Find the "## Learned Patterns" section. If absent — create it at end of file.
3. For each triad, search for existing logic covering the same trigger or goal
4. Classify each triad:
   - **auto-apply:** no coverage → add rule: "When {trigger} → {action}, to {goal}"
   - **dispute:** partial coverage exists → do NOT edit file, collect for Phase 4
   - **skip:** already fully covered → no changes

5. Apply all auto-apply edits
6. Update `Adapted` in triad-index.md:
   - applied triads → set to `{skill-name}`
   - skipped triads → set to `{skill-name}`
   - disputed triads → leave `Adapted: —`

> In Qwen Code, subagents can be used for parallel processing if multiple skills need updates.
> Define subagents in `.qwen/agents/` with YAML frontmatter:
> ```yaml
> ---
> name: skill-embedder
> description: Embeds triads into a target skill
> model: inherit
> tools: [read_file, edit, write_file, grep_search]
> ---
> ```

## Phase 4: Disputes

Present each dispute to the user one at a time:

```
Dispute: "{pattern title}" → {skill-name}

Триада: {trigger} → {action} → {goal}

Существующее правило:
  "{existing rule text}"

Предлагаю расширить до:
  "{refined rule text covering both cases}"

Применить? [да / нет / пропустить]
```

Wait for user decision before showing the next dispute.

- **да** → apply the refinement, update Adapted in triad-index.md
- **нет** → skip, leave Adapted=— (will appear again next run)
- **пропустить** → mark Adapted: n/a in triad-index.md

## Phase 5: Cleanup

Remove all processed entries from reasoning-patterns.md (auto-applies + да/пропустить decisions). Find each entry by its `### {title}` header and delete it.

## Phase 6: Commit

```bash
git add -A && git commit -m "skill-master: embed {N} triads into {skill list}"
```

## Force-Embed (manual)

User can say "force-embed pattern {N}" to embed a specific triad immediately, bypassing the ≥25 threshold.

## Report

```
Skill Master: обработано {N} триад.
Применено автоматически: {N} правил → {skills list}
Споров решено: {resolved}/{total disputes}
Пропущено (уже покрыто): {N}
Отложено (нет/пропустить): {N}
```
