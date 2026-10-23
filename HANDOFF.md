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

1. **Get the files onto the desktop.** In PowerShell: `cd $HOME\Desktop\Claude` then `git clone https://github.com/LeorLivshe/Jarvis jarvis-v2`. Use the name `jarvis-v2`: Windows treats `Jarvis` and your existing `jarvis` app folder as the same name.
2. **Run the fix script.** Open PowerShell with **Run as administrator**, then:
   ```powershell
   cd $HOME\Desktop\Claude\jarvis-v2
   powershell -ExecutionPolicy Bypass -File .\scripts\Fix-RemoteControl.ps1 -DiagnoseOnly   # look first
   powershell -ExecutionPolicy Bypass -File .\scripts\Fix-RemoteControl.ps1                 # then apply
   ```
   Read `RemoteControl-Diagnosis.txt` on your Desktop.
3. **Set up remote access.** Finish Chrome Remote Desktop setup (the script opens the page). Then a hang while you're out is fixable from your phone.
4. **Make the desktop app start with Windows.** In the Claude desktop app, turn on launch at login.
5. **Start a Claude Code session in the `Desktop\Claude\jarvis-v2` folder** and paste the prompt below. It reads `CLAUDE.md` and works through the upgrades, then Mission Control, in order. It will hand you the `/plugin` commands to type yourself.
6. **Tidy up.** Delete the leftover branch `claude/remote-control-session-closure-dgt6ji` from the `cv` repo: `git push origin --delete claude/remote-control-session-closure-dgt6ji`, or use the trash icon at github.com/LeorLivshe/cv/branches.

## Files

| File | What it is |
|---|---|
| `scripts/Fix-RemoteControl.ps1` | Diagnoses the disconnect, then sets: no sleep, network adapters stay powered, no surprise Windows Update restarts, QuickEdit off. `-RegisterRemoteControlTask` is optional. |
| `docs/superpowers/specs/2026-10-22-jarvis-v2-mission-control-design.md` | Design spec: org chart, live agent state, API cost tracker ($10 cap, API key only), alerts |
| `docs/superpowers/plans/2026-10-22-jarvis-v2-mission-control-plan.md` | Phased build plan and the ranked improvement list |
| `hooks/jarvis_agent_hook.py` | Claude Code hook that logs agent activity for the dashboard (tested) |
| Mockup | https://claude.ai/artifact/1wf6LpPG92pUZNg5zCwycK (clickable; sample data) |
| `hooks/settings-snippet.json` | Hook configuration to merge into `%USERPROFILE%\.claude\settings.json` |

## Prompt to paste into the desktop session

```
Read CLAUDE.md, HANDOFF.md and docs/setup/setup-guide.md. I've done HANDOFF steps 1-4.
Walk me through setup-guide Part A in order: give me any /plugin or other slash
commands to type in one block, run the terminal steps yourself, and show me agent-file
edits before making them. Tick items off in docs/setup/desktop-upgrades.md as we go.
Then ask me before backing up the app code (CLAUDE.md task 3), and after that
execute the Mission Control plan starting at Phase 0.
```

## Bring the app code into this repo

The Jarvis source currently lives only on the desktop. The desktop session handles this (CLAUDE.md task 3): it puts the code under `app/` after checking that `.env`, `data\`, `models\`, `dist\` and `build\` are git-ignored.
