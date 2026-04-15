#!/bin/bash
set -euo pipefail

# Full Qwen Code setup for macOS
# Installs Node.js, Qwen Code, safety hooks, Agent Cleaner, methodology skills

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
QWEN_DIR="$HOME/.qwen"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; exit 1; }
step() { echo -e "\n${YELLOW}=== $1 ===${NC}"; }

# ─── Step 1: Node.js ────────────────────────────────────────

step "Шаг 1/6: Node.js"

install_node() {
    if command -v brew &>/dev/null; then
        echo "Устанавливаю через Homebrew..."
        brew install node@22
        ok "Node.js установлен через Homebrew"
    else
        echo "Homebrew не найден. Скачиваю Node.js напрямую..."
        # Detect architecture
        ARCH=$(uname -m)
        if [ "$ARCH" = "arm64" ]; then
            NODE_URL="https://nodejs.org/dist/v22.15.0/node-v22.15.0-darwin-arm64.tar.gz"
        else
            NODE_URL="https://nodejs.org/dist/v22.15.0/node-v22.15.0-darwin-x64.tar.gz"
        fi
        NODE_DIR="$HOME/.node"
        rm -rf "$NODE_DIR"
        mkdir -p "$NODE_DIR"
        echo "Скачиваю Node.js v22 ($ARCH)... (~45MB, подожди 1-2 минуты)"
        curl -fL --progress-bar "$NODE_URL" | tar xz -C "$NODE_DIR" --strip-components=1
        # Add to PATH for current session
        export PATH="$NODE_DIR/bin:$PATH"
        # Add to shell profile for future sessions
        SHELL_RC="$HOME/.zshrc"
        if ! grep -q '.node/bin' "$SHELL_RC" 2>/dev/null; then
            echo '' >> "$SHELL_RC"
            echo '# Node.js (installed by qwen-setup)' >> "$SHELL_RC"
            echo 'export PATH="$HOME/.node/bin:$PATH"' >> "$SHELL_RC"
        fi
        # Verify
        if command -v node &>/dev/null; then
            ok "Node.js $(node --version) установлен в $NODE_DIR"
        else
            fail "Не удалось установить Node.js. Скачай вручную: https://nodejs.org/"
        fi
    fi
}

if command -v node &>/dev/null; then
    NODE_VER=$(node --version)
    NODE_MAJOR=$(echo "$NODE_VER" | sed 's/v\([0-9]*\).*/\1/')
    if [ "$NODE_MAJOR" -ge 20 ]; then
        ok "Node.js $NODE_VER уже установлен"
    else
        warn "Node.js $NODE_VER слишком старый (нужен v20+)"
        install_node
    fi
else
    echo "Node.js не найден. Устанавливаю..."
    install_node
fi

# ─── Step 2: Qwen Code ──────────────────────────────────────

step "Шаг 2/6: Qwen Code"

if command -v qwen &>/dev/null; then
    ok "Qwen Code уже установлен ($(qwen --version 2>/dev/null || echo 'version unknown'))"
    echo "Обновляю до последней версии..."
    npm install -g @qwen-code/qwen-code@latest
    ok "Qwen Code обновлён"
else
    echo "Устанавливаю Qwen Code..."
    npm install -g @qwen-code/qwen-code@latest
    ok "Qwen Code установлен"
fi

# ─── Step 3: User Profile ───────────────────────────────────

step "Шаг 3/6: Профиль пользователя"

mkdir -p "$QWEN_DIR"
QWEN_MD="$QWEN_DIR/QWEN.md"

if [ -f "$QWEN_MD" ] && grep -q "## User Profile" "$QWEN_MD"; then
    ok "Профиль уже заполнен в $QWEN_MD"
else
    echo ""
    echo "Ответь на 6 вопросов — это поможет агенту общаться с тобой эффективнее."
    echo "Просто напиши ответ и нажми Enter."
    echo ""

    read -rp "1. Кем ты работаешь / чем занимаешься? " ROLE
    echo ""
    echo "2. Приходилось ли писать код или работать с терминалом?"
    echo "   a) Нет, никогда"
    echo "   b) Пробовал немного"
    echo "   c) Использую регулярно"
    read -rp "   Ответ (a/b/c): " CODE_EXP
    case "$CODE_EXP" in
        a|A) CODE_EXP_TEXT="Не писал код и не работал с терминалом" ;;
        b|B) CODE_EXP_TEXT="Немного пробовал писать код или работать с терминалом" ;;
        c|C) CODE_EXP_TEXT="Регулярно пишет код и работает с терминалом" ;;
        *)   CODE_EXP_TEXT="$CODE_EXP" ;;
    esac

    echo ""
    echo "3. Какие продукты хочешь создавать с помощью агента?"
    echo "   (боты, сайты, приложения, аналитика данных, автоматизация, другое)"
    read -rp "   Ответ: " GOALS

    echo ""
    echo "4. В какой сфере планируешь применять агента?"
    echo "   (работа, учёба, хобби, фриланс, свой бизнес, другое)"
    read -rp "   Ответ: " DOMAIN

    echo ""
    echo "5. Как предпочитаешь получать ответы?"
    echo "   a) Кратко и по делу"
    echo "   b) С объяснениями"
    echo "   c) Пошагово, как для новичка"
    read -rp "   Ответ (a/b/c): " STYLE
    case "$STYLE" in
        a|A) STYLE_TEXT="Кратко и по делу, без лишних объяснений" ;;
        b|B) STYLE_TEXT="С объяснениями ключевых моментов" ;;
        c|C) STYLE_TEXT="Пошагово, подробно, как для новичка" ;;
        *)   STYLE_TEXT="$STYLE" ;;
    esac

    echo ""
    echo "6. На каком языке общаться?"
    echo "   a) Русский"
    echo "   b) English"
    echo "   c) Оба"
    read -rp "   Ответ (a/b/c): " LANG
    case "$LANG" in
        a|A) LANG_TEXT="Русский" ;;
        b|B) LANG_TEXT="English" ;;
        c|C) LANG_TEXT="Русский и English (оба)" ;;
        *)   LANG_TEXT="$LANG" ;;
    esac

    # Write to QWEN.md (using printf to safely handle special chars in user input)
    PROFILE_BLOCK="
## User Profile

- **Роль:** ${ROLE}
- **Опыт с кодом:** ${CODE_EXP_TEXT}
- **Цели:** ${GOALS}
- **Сфера:** ${DOMAIN}
- **Стиль общения:** ${STYLE_TEXT}
- **Язык:** ${LANG_TEXT}"

    if [ -f "$QWEN_MD" ]; then
        printf '%s\n' "$PROFILE_BLOCK" >> "$QWEN_MD"
    else
        printf '%s\n' "# Global Instructions" > "$QWEN_MD"
        printf '%s\n' "$PROFILE_BLOCK" >> "$QWEN_MD"
    fi

    ok "Профиль сохранён в $QWEN_MD"
fi

# ─── Step 4: Safety Hooks ───────────────────────────────────

step "Шаг 4/6: Безопасность"

bash "$SCRIPT_DIR/install-hooks.sh"

# ─── Step 5: Agent Cleaner ──────────────────────────────────

step "Шаг 5/6: Agent Cleaner"

CLEANER_PATH="$HOME/agent_cleaner.py"
CLEANER_LOG="$HOME/agent_cleaner.log"
PLIST_NAME="com.user.agentcleaner"
PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_NAME.plist"

# Copy script
cp "$REPO_DIR/scripts/agent_cleaner.py" "$CLEANER_PATH"
chmod +x "$CLEANER_PATH"
ok "Скрипт скопирован в $CLEANER_PATH"

# Create plist from template
mkdir -p "$HOME/Library/LaunchAgents"
sed -e "s|AGENT_CLEANER_PATH|$CLEANER_PATH|g" \
    -e "s|AGENT_CLEANER_LOG|$CLEANER_LOG|g" \
    "$REPO_DIR/configs/com.user.agentcleaner.plist" > "$PLIST_PATH"
ok "LaunchAgent создан: $PLIST_PATH"

# Load service
if launchctl list | grep -q "$PLIST_NAME" 2>/dev/null; then
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
fi
launchctl load "$PLIST_PATH"
ok "Agent Cleaner запущен (проверяет каждые 60 сек)"

# ─── Step 6: Methodology Skills ─────────────────────────────

step "Шаг 6/6: Навыки (Skills)"

SKILLS_DIR="$QWEN_DIR/skills"
mkdir -p "$SKILLS_DIR"

if [ -d "$REPO_DIR/skills/methodology" ]; then
    cp -r "$REPO_DIR/skills/methodology" "$SKILLS_DIR/"
    ok "Навык: methodology"
fi

if [ -d "$REPO_DIR/skills/quick-learning" ]; then
    cp -r "$REPO_DIR/skills/quick-learning" "$SKILLS_DIR/"
    ok "Навык: quick-learning"
fi

if [ -d "$REPO_DIR/skills/skill-master" ]; then
    cp -r "$REPO_DIR/skills/skill-master" "$SKILLS_DIR/"
    ok "Навык: skill-master"
fi

# ─── Done ────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}=== Готово! ===${NC}"
echo ""
echo "Что установлено:"
echo "  ✓ Node.js $(node --version)"
echo "  ✓ Qwen Code (запуск: qwen)"
echo "  ✓ Профиль пользователя ($QWEN_MD)"
echo "  ✓ YOLO-режим + защитные хуки"
echo "  ✓ Agent Cleaner (launchd, лог: $CLEANER_LOG)"
echo "  ✓ Навыки: methodology, quick-learning, skill-master"
echo ""
echo "Запусти Qwen Code:"
echo "  qwen"
echo ""
echo "При первом запуске откроется браузер для авторизации."
