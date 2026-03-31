# OMNIS KEY

> One key. Every engine.

OMNIS KEY is a COSMIC-native agent OS — an OpenClaw fork built for the JourdanLabs intelligence stack.

---

## ⚠️ Important

**This project provides the OMNIS KEY runtime.**

Advanced intelligence features (COSMIC, AURORA, VELLUM, LUNA) are **NOT included** and require separate licensed access via `api.omniskey.ai`.

Without an API key:
- Basic LLM execution works
- COSMIC intelligence is unavailable
- AURORA scoring is unavailable
- LUNA persistent memory is unavailable

To unlock full capabilities: [omniskey.ai](https://omniskey.ai)

---

## Install

```bash
npm install -g omnis-key
omnis init
omnis run "your prompt"
```

## With COSMIC Intelligence

```bash
export OMNIS_API_KEY=your-key-here
omnis run "analyze mineral rights in Ward County TX"
```

## Plugin System

```bash
omnis install cosmic-meteor    # mineral & energy intelligence
omnis install cosmic-nebula    # agriculture & natural resources
omnis install cosmic-quasar    # quantitative scoring & ranking
```

Plugins are thin API wrappers. Intelligence lives at `api.omniskey.ai`.

---

## Architecture

```
omnis-key (this repo — MIT)
    └── Calls api.omniskey.ai for:
         ├── AURORA  — output quality gate
         ├── VELLUM  — chain-of-custody
         ├── LUNA    — persistent memory
         ├── NOVA    — causal reasoning
         ├── PULSAR  — adversarial testing
         └── COSMIC  — domain intelligence engines
```

"Let them copy the tool. Make it impossible to copy the mind."

---

## License

MIT — fork freely. The shell is yours.
The intelligence lives at `api.omniskey.ai`.

MIT License · Copyright (c) 2025 Peter Steinberger (original OpenClaw)  
OMNIS KEY fork by JourdanLabs · omniskey.ai

---

*Built by JourdanLabs*
