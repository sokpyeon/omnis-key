#!/bin/bash
# OMNIS KEY — Installer
# curl -fsSL https://raw.githubusercontent.com/sokpyeon/omnis-key/main/install.sh | bash

set -e

OMNIS_DIR="$HOME/.omnis-key"
REPO="https://github.com/sokpyeon/omnis-key.git"

echo ""
echo "  ▄██████▄  ███▄▄▄▄    ▄█     ▄████████"
echo "  ███    ███ ███▀▀▀██▄ ███    ███    ███"
echo "  ███    ███ ███   ███ ███▌   ███    █▀ "
echo "  ███    ███ ███   ███ ███▌   ███       "
echo "  ███    ███ ███   ███ ███▌ ▀███████████"
echo "  ███    ███ ███   ███ ███           ███"
echo "  ███    ███ ███   ███ ███     ▄█    ███"
echo "   ▀██████▀   ▀█   █▀  █▀    ████████▀ "
echo ""
echo "  OMNIS KEY — One key. Every engine."
echo "  omniskey.ai"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check Node
if ! command -v node &>/dev/null; then
  echo "❌ Node.js not found. Install from https://nodejs.org (v18+)"
  exit 1
fi
NODE_VER=$(node --version | cut -dv -f2 | cut -d. -f1)
if [ "$NODE_VER" -lt 18 ]; then
  echo "❌ Node.js v18+ required. Found: $(node --version)"
  exit 1
fi

echo "✅ Node $(node --version)"

# Check git
if ! command -v git &>/dev/null; then
  echo "❌ git not found."
  exit 1
fi
echo "✅ git ready"

# Clean previous install
if [ -d "$OMNIS_DIR/repo" ]; then
  echo "── Updating existing install..."
  cd "$OMNIS_DIR/repo" && git pull --quiet
else
  echo "── Cloning omnis-key..."
  mkdir -p "$OMNIS_DIR"
  git clone --depth=1 "$REPO" "$OMNIS_DIR/repo" --quiet
fi
echo "✅ omnis-key cloned"

# Install deps
echo "── Installing dependencies..."
cd "$OMNIS_DIR/repo"
npm install --silent --no-fund --no-audit
echo "✅ Dependencies ready"

# Create workspace
mkdir -p "$OMNIS_DIR/workspace"

# Write the omnis CLI shim
SHIM_DIR="$HOME/.local/bin"
mkdir -p "$SHIM_DIR"
cat > "$SHIM_DIR/omnis" << SHIMEOF
#!/bin/bash
OPENCLAW_STATE_DIR="$OMNIS_DIR" node "$OMNIS_DIR/repo/src/entry.ts" "\$@"
SHIMEOF
chmod +x "$SHIM_DIR/omnis"

# Add to PATH if needed
if [[ ":$PATH:" != *":$SHIM_DIR:"* ]]; then
  echo "" >> "$HOME/.zshrc"
  echo "# OMNIS KEY" >> "$HOME/.zshrc"
  echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.zshrc"
  export PATH="$SHIM_DIR:$PATH"
fi

echo "✅ omnis CLI installed → $SHIM_DIR/omnis"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ OMNIS KEY installed."
echo ""
echo "  Next step — configure your agent:"
echo ""
echo "    omnis setup"
echo ""
echo "  Or configure with env vars directly:"
echo ""
echo "    OMNIS_AGENT_NAME=Yajirobe \\"
echo "    OMNIS_TG_TOKEN=your-token \\"
echo "    OMNIS_CHAT_ID=your-chat-id \\"
echo "    omnis setup --yes"
echo ""
echo "  Docs: omniskey.ai"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
