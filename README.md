# Настройка QWEN

> Пошаговое руководство и скрипты автоматизации для настройки Qwen Code CLI на macOS — от установки до полной рабочей среды с безопасностью, очисткой процессов и методологией AI-разработки.

## О проекте

Qwen Code устанавливается за минуту, но без настройки работает без ограничений — может удалить файлы, засорить систему зависшими процессами, а эффективные паттерны работы с AI-агентом приходится выстраивать с нуля.

Этот проект решает все три проблемы: setup-скрипт, защитные хуки, Agent Cleaner и адаптированная методология — всё в одной команде.

## Структура

- `docs/` — пошаговые гайды (установка → профиль → безопасность → cleaner → методология)
- `scripts/` — автоматизация (setup-qwen.sh, agent_cleaner.py, install-hooks.sh)
- `configs/` — эталонные конфиги (settings.json, хуки, launchd plist)
- `skills/` — навыки для Qwen Code (methodology, quick-learning, skill-master)
- `.claude/skills/project-knowledge/` — документация проекта для AI-агентов

## Быстрый старт

```bash
git clone https://github.com/stepanenkoviktor0110-boop/qwen-setup.git
cd qwen-setup
bash scripts/setup-qwen.sh
```
