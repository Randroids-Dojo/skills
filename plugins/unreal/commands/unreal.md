# Unreal Development

Develop, test, and automate Unreal Engine 5.x projects.

## Quick Reference

```bash
# Launch editor with Remote Control enabled
UnrealEditor "/path/MyGame.uproject" -ExecCmds="WebControl.StartServer"

# Packaged build (enable Remote Control)
MyGame.exe -RCWebControlEnable -RCWebInterfaceEnable -ExecCmds="WebControl.StartServer"

# Wait for Remote Control and ping a PlayUnreal automation actor
python plugins/unreal/scripts/rc_wait_ready.py \
  --host 127.0.0.1 --port 30010 \
  --object-path "/Game/Maps/Main.Main:PersistentLevel.PlayUnrealDriver_1"
```

## Automation Overview

| | Automation Driver | Remote Control |
|---|---|---|
| Role | UI input + locators | External API transport |
| Runs | In-engine | External client |
| Use for | Click, type, key input | Call Blueprint functions |

## Available Tools

For detailed documentation, read the full SKILL.md at `${CLAUDE_PLUGIN_ROOT}/SKILL.md`.

Key capabilities:
- **PlayUnreal Automation** - External control via Remote Control
- **Automation Driver** - Locators and input sequences
- **Remote Control API** - HTTP/WS endpoints
- **Python Helper Scripts** - `ue_launch.py`, `rc_wait_ready.py`, `run_e2e.py`
