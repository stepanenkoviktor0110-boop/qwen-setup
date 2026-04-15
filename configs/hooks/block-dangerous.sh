#!/bin/bash
# PreToolUse hook: blocks dangerous shell commands
# Exit 0 = allow, Exit 2 = block
# Reads JSON from stdin, checks the command field

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null)

if [ -z "$COMMAND" ]; then
  exit 0
fi

DANGEROUS_PATTERNS=(
  "rm -rf /"
  "rm -rf /*"
  "rm -rf ~"
  "rm -rf ~/"
  "sudo rm -rf"
  "mkfs"
  "dd if="
  ":(){ :|:& };:"
  "> /dev/sda"
  "chmod -R 777 /"
  "curl.*|.*bash"
  "curl.*|.*sh"
  "wget.*|.*bash"
  "wget.*|.*sh"
  "shutdown"
  "reboot"
  "halt"
  "init 0"
  "init 6"
  "killall"
  "pkill -9"
  "git push --force"
  "git push -f"
  "git reset --hard"
  "git clean -fd"
  "defaults write"
  "defaults delete"
  "launchctl unload"
  "networksetup"
  "systemsetup"
  "csrutil"
  "nvram"
  "diskutil eraseDisk"
  "diskutil partitionDisk"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiF "$pattern"; then
    echo '{"decision":"block","reason":"Blocked by safety hook: '"$pattern"'"}'
    exit 2
  fi
done

exit 0
