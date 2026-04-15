#!/bin/bash
set -euo pipefail

# Install Qwen Code safety hooks
# Copies block-dangerous.sh to ~/.qwen/hooks/ and merges hook config into settings.json

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
QWEN_DIR="$HOME/.qwen"
HOOKS_DIR="$QWEN_DIR/hooks"

echo "=== Installing safety hooks ==="

# Create hooks directory
mkdir -p "$HOOKS_DIR"

# Copy hook script
cp "$REPO_DIR/configs/hooks/block-dangerous.sh" "$HOOKS_DIR/block-dangerous.sh"
chmod +x "$HOOKS_DIR/block-dangerous.sh"
echo "✓ Hook script copied to $HOOKS_DIR/block-dangerous.sh"

# Merge settings.json
SETTINGS_FILE="$QWEN_DIR/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    # Settings exist — merge our config with existing
    # Use python3 to merge JSON (available on all macOS)
    python3 - "$SETTINGS_FILE" "$REPO_DIR/configs/settings.json" << 'PYEOF'
import json, sys

settings_path = sys.argv[1]
new_config_path = sys.argv[2]

with open(settings_path) as f:
    existing = json.load(f)

with open(new_config_path) as f:
    new = json.load(f)

# Merge permissions: extend allow/deny lists, don't replace
for key in ['allow', 'deny', 'ask']:
    if key in new.get('permissions', {}):
        existing.setdefault('permissions', {}).setdefault(key, [])
        for item in new['permissions'][key]:
            if item not in existing['permissions'][key]:
                existing['permissions'][key].append(item)

# Merge hooks: add our hooks (with deduplication by command)
for event in new.get('hooks', {}):
    existing.setdefault('hooks', {}).setdefault(event, [])
    existing_commands = set()
    for hook_group in existing['hooks'][event]:
        for h in hook_group.get('hooks', []):
            existing_commands.add(h.get('command', ''))
    for new_group in new['hooks'][event]:
        has_new = False
        for h in new_group.get('hooks', []):
            if h.get('command', '') not in existing_commands:
                has_new = True
        if has_new:
            existing['hooks'][event].append(new_group)

# Set approval mode
existing.setdefault('tools', {})['approvalMode'] = new.get('tools', {}).get('approvalMode', 'yolo')

with open(settings_path, 'w') as f:
    json.dump(existing, f, indent=2, ensure_ascii=False)
PYEOF
    echo "✓ Settings merged into $SETTINGS_FILE"
else
    # No existing settings — copy ours
    cp "$REPO_DIR/configs/settings.json" "$SETTINGS_FILE"
    echo "✓ Settings created at $SETTINGS_FILE"
fi

echo "=== Hooks installed ==="
echo "  YOLO mode: ON (no confirmations)"
echo "  Safety hooks: ON (dangerous commands blocked)"
