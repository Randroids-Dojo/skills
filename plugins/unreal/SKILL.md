---
name: unreal
description: "Automate Unreal Engine 5.x editor workflows via PlayUnreal, send Remote Control API commands, write Automation Driver test scripts, and configure CI pipelines for E2E testing. Use when working with UE5 automation, Unreal Engine testing, Remote Control API integration, editor scripting, or .uproject CI pipelines."
---

# Unreal Skill (WIP)

Automate Unreal Engine 5.x with PlayUnreal-style external control via the native Remote Control API and Automation Driver.

**Status**: Work in progress — Quick Reference commands work today; the PlayUnreal Python API below is the target interface (not yet released).

PlayUnreal repo: https://github.com/Randroids-Dojo/PlayUnreal

## Quick Reference

```bash
# Launch editor with Remote Control enabled
UnrealEditor "/path/MyGame.uproject" -ExecCmds="WebControl.StartServer"

# Verify Remote Control is responding (health check)
curl -s http://127.0.0.1:30010/remote/info | jq .

# Packaged build (enable Remote Control)
MyGame.exe -RCWebControlEnable -RCWebInterfaceEnable -ExecCmds="WebControl.StartServer"

# Wait for Remote Control and ping a PlayUnreal automation actor
python plugins/unreal/scripts/rc_wait_ready.py \
  --host 127.0.0.1 --port 30010 \
  --object-path "/Game/Maps/Main.Main:PersistentLevel.PlayUnrealDriver_1"
```

## Setup Checklist

1. Enable **Remote Control API** plugin: Edit → Plugins → search "Remote Control API" → enable → restart editor.
2. Enable **Automation Driver** plugin: Edit → Plugins → search "Automation Driver" → enable → restart editor.
3. Add the **PlayUnrealAutomation** plugin to your `.uproject` `Plugins` array.
4. Place the PlayUnreal driver actor or subsystem in the map.
5. Tag key UMG widgets with automation IDs (`Slot Name` in widget details) for stable selectors.
6. **Verify**: Launch the editor with Remote Control, then run `curl -s http://127.0.0.1:30010/remote/info | jq .` — confirm a JSON response with engine version.
7. Keep Remote Control on LAN/VPN only (not exposed to the internet).

## Selector Strategy

| Selector | Maps to | Example |
|----------|---------|---------|
| `id=StartButton` | `By::Id` | Widget with automation ID "StartButton" |
| `path=#Menu//Start/<SButton>` | `By::Path` | Hierarchy path traversal |
| `text="Start"` | Custom traversal | Finds widget by displayed text |

## PlayUnreal Python (target API — not yet released)

```python
from playunreal import Unreal

async with Unreal.launch(
    uproject="MyGame.uproject",
    map="/Game/Maps/MainMenu",
    remote_control=True,
) as ue:
    page = ue.page()
    await page.locator("id=StartButton").click()
    await page.locator("id=HUDRoot").wait_for_visible()
    await page.screenshot("artifacts/started.png")
```

## Packaged Builds

- Use `-RCWebControlEnable -RCWebInterfaceEnable` flags.
- Ensure presets and assets are staged if using Remote Control presets.

## References

- `references/remote-control.md` — Remote Control API details
- `references/automation-driver.md` — Automation Driver guide
- `references/umg-automation.md` — UMG widget automation
- `references/playunreal.md` — PlayUnreal automation guide
