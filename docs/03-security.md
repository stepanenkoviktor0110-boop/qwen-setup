# Безопасность: YOLO + защитные хуки

Qwen Code может работать в 4 режимах. По умолчанию он спрашивает разрешение на каждое действие — это безопасно, но медленно. YOLO-режим убирает все подтверждения, но агент может случайно выполнить опасную команду.

Решение: включить YOLO + установить защитные хуки, которые блокируют опасные команды автоматически.

---

## Режимы работы

| Режим | Файлы | Команды | Когда использовать |
|-------|-------|---------|-------------------|
| `plan` | Запрещены | Запрещены | Только чтение и обсуждение |
| `default` | Спрашивает | Спрашивает | Первое знакомство |
| `auto-edit` | Разрешены | Спрашивает | Доверяешь редактирование, но не команды |
| `yolo` | Разрешены | Разрешены | Полное доверие + хуки безопасности |

Переключение в сессии: **Shift+Tab**.

---

## Автоматически

Если запускал `setup-qwen.sh` — хуки уже установлены. Проверь:

```bash
cat ~/.qwen/settings.json | python3 -c "import sys,json; d=json.load(sys.stdin); print('YOLO:', d.get('tools',{}).get('approvalMode','не задан')); print('Hooks:', 'есть' if d.get('hooks') else 'нет')"
```

---

## Вручную

### 1. Скопируй хук-скрипт

```bash
mkdir -p ~/.qwen/hooks
cp configs/hooks/block-dangerous.sh ~/.qwen/hooks/
chmod +x ~/.qwen/hooks/block-dangerous.sh
```

### 2. Настрой settings.json

Открой `~/.qwen/settings.json` (создай, если нет):

```bash
nano ~/.qwen/settings.json
```

Вставь или добавь:

```json
{
  "tools": {
    "approvalMode": "yolo"
  },
  "permissions": {
    "deny": [
      "run_shell_command(rm -rf /)",
      "run_shell_command(rm -rf /*)",
      "run_shell_command(sudo rm -rf *)",
      "run_shell_command(git push --force*)",
      "run_shell_command(git reset --hard*)",
      "run_shell_command(shutdown *)",
      "run_shell_command(reboot *)",
      "run_shell_command(killall *)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "run_shell_command",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.qwen/hooks/block-dangerous.sh",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

---

## Что блокируется

Хук `block-dangerous.sh` перехватывает команды перед выполнением и блокирует:

| Категория | Примеры |
|-----------|---------|
| Удаление системы | `rm -rf /`, `rm -rf ~`, `sudo rm -rf` |
| Деструктивный git | `git push --force`, `git reset --hard`, `git clean -fd` |
| Системные команды | `shutdown`, `reboot`, `killall` |
| Опасные скрипты | `curl ... \| bash`, `wget ... \| sh` |
| Системные настройки macOS | `defaults write`, `defaults delete`, `csrutil` |
| Диски | `diskutil eraseDisk`, `mkfs`, `dd if=` |

Обычные команды (`rm file.txt`, `git push`, `npm install`) **не блокируются** — агент может свободно работать.

---

## Как проверить

Запусти `qwen` и попроси выполнить опасную команду:

```
выполни rm -rf /
```

Агент должен получить блокировку от хука и сообщить об этом.

---

## Настройка

Чтобы добавить или убрать блокируемые команды — отредактируй файл `~/.qwen/hooks/block-dangerous.sh`, массив `DANGEROUS_PATTERNS`.

Чтобы добавить разрешения — отредактируй `permissions.allow` в `~/.qwen/settings.json`.
