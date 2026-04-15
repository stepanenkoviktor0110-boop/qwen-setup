# Agent Cleaner — автоочистка зависших процессов

При работе с AI-агентами (Qwen Code, Claude Code, Codex) в системе накапливаются «осиротевшие» node-процессы. Их родительский процесс уже завершился, а они продолжают висеть и есть память. Agent Cleaner автоматически находит и убивает такие процессы.

---

## Как работает

Каждые 60 секунд проверяет все `node` процессы и убивает те, у которых одновременно:

- RAM системы > 80%
- Родительский процесс мёртв (процесс осиротел)
- Возраст процесса > 2 минут

VS Code, dev-серверы и живые агенты не затрагиваются — у них живой родитель.

---

## Автоматически

Если запускал `setup-qwen.sh` — cleaner уже работает. Проверь:

```bash
launchctl list | grep agentcleaner
```

Если видишь строку с `com.user.agentcleaner` — работает.

---

## Установка вручную

### 1. Скопируй скрипт

```bash
cp scripts/agent_cleaner.py ~/agent_cleaner.py
chmod +x ~/agent_cleaner.py
```

### 2. Создай LaunchAgent

```bash
cat > ~/Library/LaunchAgents/com.user.agentcleaner.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.agentcleaner</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/python3</string>
        <string>HOMEDIR/agent_cleaner.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>HOMEDIR/agent_cleaner.log</string>
    <key>StandardErrorPath</key>
    <string>HOMEDIR/agent_cleaner.log</string>
</dict>
</plist>
EOF
```

Замени `HOMEDIR` на свой путь (обычно `/Users/твоеимя`):

```bash
sed -i '' "s|HOMEDIR|$HOME|g" ~/Library/LaunchAgents/com.user.agentcleaner.plist
```

### 3. Запусти

```bash
launchctl load ~/Library/LaunchAgents/com.user.agentcleaner.plist
```

---

## Управление

**Проверить статус:**
```bash
launchctl list | grep agentcleaner
```

**Посмотреть лог:**
```bash
cat ~/agent_cleaner.log
```

**Остановить:**
```bash
launchctl unload ~/Library/LaunchAgents/com.user.agentcleaner.plist
```

**Запустить снова:**
```bash
launchctl load ~/Library/LaunchAgents/com.user.agentcleaner.plist
```

**Удалить совсем:**
```bash
launchctl unload ~/Library/LaunchAgents/com.user.agentcleaner.plist
rm ~/Library/LaunchAgents/com.user.agentcleaner.plist
rm ~/agent_cleaner.py
rm ~/agent_cleaner.log
```

---

## Настройки

Открой `~/agent_cleaner.py` и измени константы в начале файла:

```python
CHECK_INTERVAL = 60          # как часто проверять (секунды)
MIN_UPTIME_BEFORE_KILL = 120 # не трогать процессы моложе N секунд
RAM_THRESHOLD = 80           # порог RAM в % для срабатывания
```

После изменения перезагрузи сервис:

```bash
launchctl unload ~/Library/LaunchAgents/com.user.agentcleaner.plist
launchctl load ~/Library/LaunchAgents/com.user.agentcleaner.plist
```
