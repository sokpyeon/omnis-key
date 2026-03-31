#!/bin/bash
# OMNIS KEY — One-line installer
# curl -fsSL https://raw.githubusercontent.com/sokpyeon/omnis-key/main/install.sh | bash

set -e

OMNIS_DIR="$HOME/.omnis-key"
OMNIS_PORT="${OMNIS_PORT:-18791}"
REPO="https://github.com/sokpyeon/omnis-key.git"

echo ""
echo "  ██████╗ ███╗   ███╗███╗   ██╗██╗███████╗    ██╗  ██╗███████╗██╗   ██╗"
echo " ██╔═══██╗████╗ ████║████╗  ██║██║██╔════╝    ██║ ██╔╝██╔════╝╚██╗ ██╔╝"
echo " ██║   ██║██╔████╔██║██╔██╗ ██║██║███████╗    █████╔╝ █████╗   ╚████╔╝ "
echo " ██║   ██║██║╚██╔╝██║██║╚██╗██║██║╚════██║    ██╔═██╗ ██╔══╝    ╚██╔╝  "
echo " ╚██████╔╝██║ ╚═╝ ██║██║ ╚████║██║███████║    ██║  ██╗███████╗   ██║   "
echo "  ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝╚══════╝    ╚═╝  ╚═╝╚══════╝   ╚═╝  "
echo ""
echo "  One key. Every engine."
echo "  omniskey.ai"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check dependencies
echo "── Checking dependencies..."

if ! command -v node &> /dev/null; then
  echo "❌ Node.js not found. Install from https://nodejs.org (v18+)"
  exit 1
fi

NODE_VER=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VER" -lt 18 ]; then
  echo "❌ Node.js v18+ required. Found: $(node --version)"
  exit 1
fi

if ! command -v git &> /dev/null; then
  echo "❌ git not found."
  exit 1
fi

echo "✅ Node $(node --version)"
echo "✅ git $(git --version | awk '{print $3}')"

# Clone
echo ""
echo "── Cloning omnis-key..."
rm -rf "$OMNIS_DIR/repo"
mkdir -p "$OMNIS_DIR"
git clone --depth=1 "$REPO" "$OMNIS_DIR/repo" 2>&1 | tail -1
echo "✅ Cloned to $OMNIS_DIR/repo"

# Install deps
echo ""
echo "── Installing dependencies..."
cd "$OMNIS_DIR/repo"
npm install --silent --no-fund --no-audit
echo "✅ Dependencies installed"

# Create workspace
mkdir -p "$OMNIS_DIR/workspace"

# Collect config
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Agent name
read -p "  Agent name (e.g. Yajirobe): " AGENT_NAME
AGENT_NAME="${AGENT_NAME:-Agent}"

# Telegram token
read -p "  Telegram bot token: " TG_TOKEN

# Allowed chat ID
read -p "  Allowed Telegram chat ID (your user ID): " CHAT_ID

# OMNIS API key (optional)
read -p "  OMNIS API key (leave blank to skip — degraded mode): " OMNIS_API_KEY

# Gateway token
GW_TOKEN=$(openssl rand -hex 24)

# Write config
cat > "$OMNIS_DIR/openclaw.json" << EOF
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
          "botToken": "$TG_TOKEN",
          "allowedChatIds": ["$CHAT_ID"]
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
EOF

# Write SOUL.md
cat > "$OMNIS_DIR/workspace/SOUL.md" << SOULEOF
# SOUL.md — $AGENT_NAME

You are **$AGENT_NAME** — running on OMNIS KEY, JourdanLabs' COSMIC-native agent OS.

You are sharp, direct, and focused. You validate things. You execute tasks. You report results clearly.

## Instance Info
- Profile: $OMNIS_DIR
- Port: $OMNIS_PORT
- Bot: Telegram

## OMNIS KEY Intelligence
$(if [ -n "$OMNIS_API_KEY" ]; then echo "COSMIC stack connected via api.omniskey.ai. Full intelligence available."; else echo "Running in degraded mode. Set OMNIS_API_KEY for full COSMIC intelligence."; fi)
SOULEOF

echo ""
echo "✅ Config written"

# Write start script
cat > "$OMNIS_DIR/start.sh" << STARTEOF
#!/bin/bash
OPENCLAW_STATE_DIR="$OMNIS_DIR" node "$OMNIS_DIR/repo/src/entry.ts" gateway start
STARTEOF
chmod +x "$OMNIS_DIR/start.sh"

# Write launchd plist (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
  PLIST="$HOME/Library/LaunchAgents/ai.omniskey.$(echo $AGENT_NAME | tr '[:upper:]' '[:lower:]').plist"
  cat > "$PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>ai.omniskey.$(echo $AGENT_NAME | tr '[:upper:]' '[:lower:]')</string>
    <key>ProgramArguments</key>
    <array>
        <string>$(which node)</string>
        <string>$OMNIS_DIR/repo/src/entry.ts</string>
        <string>gateway</string>
        <string>start</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>OPENCLAW_STATE_DIR</key>
        <string>$OMNIS_DIR</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$OMNIS_DIR/agent.log</string>
    <key>StandardErrorPath</key>
    <string>$OMNIS_DIR/agent.error.log</string>
</dict>
</plist>
EOF
  launchctl load "$PLIST" 2>/dev/null || true
  echo "✅ Launchd service installed — $AGENT_NAME will restart on reboot"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ $AGENT_NAME is ready."
echo ""
echo "  Start:   OPENCLAW_STATE_DIR=$OMNIS_DIR npx --prefix $OMNIS_DIR/repo openclaw gateway start"
echo "  Or:      $OMNIS_DIR/start.sh"
echo ""
echo "  Message your Telegram bot to confirm it's alive."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
