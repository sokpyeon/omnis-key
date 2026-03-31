#!/bin/bash
# omnis setup — interactive or env-driven config
# Called after install. Sets up agent identity, Telegram, API key.

set -e

OMNIS_DIR="${OPENCLAW_STATE_DIR:-$HOME/.omnis-key}"
OMNIS_PORT="${OMNIS_PORT:-18791}"
YES_MODE=false

[[ "$*" == *"--yes"* ]] && YES_MODE=true

prompt() {
  local var="$1" msg="$2" default="$3"
  local envval="${!var}"
  if [ -n "$envval" ]; then
    echo "  $msg: $envval  (from env)"
    eval "$var='$envval'"
  elif [ "$YES_MODE" = true ] && [ -n "$default" ]; then
    eval "$var='$default'"
  else
    read -p "  $msg${default:+ [$default]}: " input </dev/tty
    eval "$var='${input:-$default}'"
  fi
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  OMNIS KEY — Agent Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

prompt OMNIS_AGENT_NAME  "Agent name"           "Agent"
prompt OMNIS_TG_TOKEN    "Telegram bot token"   ""
prompt OMNIS_CHAT_ID     "Allowed chat ID"      ""
prompt OMNIS_API_KEY     "OMNIS API key (optional, hit enter to skip)" ""

GW_TOKEN=$(openssl rand -hex 24)

mkdir -p "$OMNIS_DIR/workspace"

# Write config
cat > "$OMNIS_DIR/openclaw.json" << CFGEOF
{
  "gateway": {
    "port": $OMNIS_PORT,
    "token": "$GW_TOKEN"
  },
  "plugins": {
    "entries": {
      "telegram": {
        "enabled": true,
        "config": {
          "botToken": "$OMNIS_TG_TOKEN",
          "allowedChatIds": ["$OMNIS_CHAT_ID"]
        }
      }
    }
  },
  "llm": {
    "default": "anthropic/claude-sonnet-4-5"
  },
  "env": {
    "OMNIS_API_KEY": "$OMNIS_API_KEY"
  }
}
CFGEOF

# Write SOUL.md
cat > "$OMNIS_DIR/workspace/SOUL.md" << SOULEOF
# SOUL.md — $OMNIS_AGENT_NAME

You are **$OMNIS_AGENT_NAME** — running on OMNIS KEY by JourdanLabs.

Sharp. Direct. Focused. You do your job and you do it right.

## Instance
- Profile: $OMNIS_DIR
- Port: $OMNIS_PORT
$([ -n "$OMNIS_API_KEY" ] && echo "- COSMIC: connected via api.omniskey.ai" || echo "- COSMIC: degraded mode (no API key)")
SOULEOF

# launchd (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
  LABEL="ai.omniskey.$(echo $OMNIS_AGENT_NAME | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
  PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
  NODE_PATH=$(which node)

  cat > "$PLIST" << PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$NODE_PATH</string>
        <string>$OMNIS_DIR/repo/src/entry.ts</string>
        <string>gateway</string><string>start</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>OPENCLAW_STATE_DIR</key><string>$OMNIS_DIR</string>
        <key>PATH</key><string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
    </dict>
    <key>RunAtLoad</key><true/>
    <key>KeepAlive</key><true/>
    <key>StandardOutPath</key><string>$OMNIS_DIR/agent.log</string>
    <key>StandardErrorPath</key><string>$OMNIS_DIR/agent.error.log</string>
</dict>
</plist>
PLISTEOF

  launchctl unload "$PLIST" 2>/dev/null || true
  launchctl load "$PLIST"
  echo ""
  echo "✅ $OMNIS_AGENT_NAME started as launchd service ($LABEL)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ $OMNIS_AGENT_NAME is configured and running."
echo ""
echo "  Message your Telegram bot to confirm."
echo "  Profile: $OMNIS_DIR"
echo "  Port:    $OMNIS_PORT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
