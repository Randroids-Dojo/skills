---
name: unreal
description: Develop, test, and automate Unreal Engine 5.x projects (WIP). Covers PlayUnreal automation, Remote Control API, Automation Driver, and CI-friendly E2E flows.
---

# Unreal Skill (WIP)

Automate Unreal Engine 5.x with PlayUnreal style external control.

Status: WIP. PlayUnreal repo: https://github.com/Randroids-Dojo/PlayUnreal

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

## Setup Checklist

- Enable Remote Control and Automation Driver plugins.
- Add the PlayUnrealAutomation plugin to the project.
- Place the PlayUnreal driver actor or subsystem in the map.
- Tag key UMG widgets with automation IDs for stable selectors.
- Keep Remote Control on LAN/VPN only.

## Selector Strategy

- `id=StartButton` maps to Automation Driver `By::Id`.
- `path=#Menu//Start/<SButton>` maps to `By::Path`.
- `text="Start"` can be implemented via custom traversal if needed.

## PlayUnreal Python (target API)

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

- Use `-RCWebControlEnable -RCWebInterfaceEnable`.
- Ensure presets and assets are staged if using Remote Control presets.

## References

- `references/remote-control.md`
- `references/automation-driver.md`
- `references/umg-automation.md`
- `references/playunreal.md`
