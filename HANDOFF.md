# When you get home

## What happened on 2026-10-22 (times in UTC)

- **16:40:** you asked Claude to check your Instagram likes. It opened the browser pane and took a screenshot. That screenshot call never returned.
- **16:46:** you asked "Did you get stuck". The session never answered.
- **16:48:** the connection to the desktop dropped.
- **16:49:** reconnecting failed with "computer unreachable".

The most likely chain:
1. The Claude desktop app hung or crashed in the browser pane.
2. That ended the app's keep-awake hold and the 12-hour keep-awake PowerShell task, since both live inside the app.
3. The PC then went to sleep, or the app was simply gone.

The script below confirms which of these happened.

## Steps (about 20 minutes)

1. **Get the files onto the desktop.** Run `git clone https://github.com/LeorLivshe/Jarvis` (or download the repo as a zip from GitHub).
2. **Run the fix script.** Open PowerShell with **Run as administrator**, then:
   ```powershell
   cd Jarvis
   powershell -ExecutionPolicy Bypass -File .\scripts\Fix-RemoteControl.ps1 -DiagnoseOnly   # look first
   powershell -ExecutionPolicy Bypass -File .\scripts\Fix-RemoteControl.ps1                 # then apply
   ```
   Read `RemoteControl-Diagnosis.txt` on your Desktop.
3. **Set up remote access.** Finish Chrome Remote Desktop setup (the script opens the page). Then a hang while you're out is fixable from your phone.
4. **Make the desktop app start with Windows.** In the Claude desktop app, turn on launch at login.
5. **Start building Jarvis v2.**
   - Copy `docs\superpowers\specs\...` and `docs\superpowers\plans\...` into the same folders under `Desktop\Claude\docs\superpowers\`.
   - Copy `hooks\` into `Desktop\Claude\jarvis\hooks\`.
   - Then tell Claude: "Execute the Mission Control plan starting at Phase 0."

## Files

| File | What it is |
|---|---|
| `scripts/Fix-RemoteControl.ps1` | Diagnoses the disconnect, then sets: no sleep, network adapters stay powered, no surprise Windows Update restarts, QuickEdit off. `-RegisterRemoteControlTask` is optional. |
| `docs/superpowers/specs/2026-10-22-jarvis-v2-mission-control-design.md` | Design spec: org chart, live agent state, token tracker, alerts |
| `docs/superpowers/plans/2026-10-22-jarvis-v2-mission-control-plan.md` | Phased build plan and the ranked improvement list |
| `hooks/jarvis_agent_hook.py` | Claude Code hook that logs agent activity for the dashboard (tested) |
| Mockup | https://claude.ai/artifact/1wf6LpPG92pUZNg5zCwycK (clickable; sample data) |
| `hooks/settings-snippet.json` | Hook configuration to merge into `%USERPROFILE%\.claude\settings.json` |

## Bring the app code into this repo (optional, recommended)

The Jarvis source currently lives only on the desktop. To keep it backed up here, from `Desktop\Claude\jarvis` (it already has a `.gitignore`, so check `.env` is listed in it before you run this):

```powershell
git status --ignored    # confirm .env, data\, models\, dist\ and build\ show as ignored
git remote add origin https://github.com/LeorLivshe/Jarvis
git fetch origin
git merge origin/main --allow-unrelated-histories
git push -u origin HEAD:main
```
