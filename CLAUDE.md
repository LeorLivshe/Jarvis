# Jarvis: instructions for Claude

Jarvis is Leor's Windows voice assistant (Python: tray, HUD, FastAPI phone server, router across Qwen (local), Claude Haiku and Claude Opus) plus 14 Claude Code marketing agents.

- **This repo** holds the v2 docs, the agent hook, the desktop fix script and the mockup.
- **The app code** lives at `C:\Users\Leor\Desktop\Claude\jarvis` and is not in this repo yet (task 3 below).

## Order of work on the desktop

1. **Leor runs `HANDOFF.md` steps 1–4 himself.** They need an admin PowerShell window and app settings. Don't run `scripts/Fix-RemoteControl.ps1` for him unless he asks.
2. **Desktop upgrades:** follow `docs/setup/setup-guide.md` Part A in order, ticking items in `docs/setup/desktop-upgrades.md`.
   - Commands starting with `/` (`/plugin ...`, `/ponytail`, `/impeccable init`) must be **typed by Leor**. List them for him in one block, then wait.
   - You can run terminal commands (`npx skills add ...`, `claude mcp add ...`) and edit the agent files in `%USERPROFILE%\.claude\agents\`. Show the planned edits first.
3. **Back up the app code:** ask before moving it. Check `.env`, `data\`, `models\`, `dist\` and `build\` are git-ignored. Put the code under an `app/` folder in this repo so it doesn't collide with this repo's `README.md`.
4. **Build Mission Control:** execute `docs/superpowers/plans/2026-10-22-jarvis-v2-mission-control-plan.md` from Phase 0. The spec is in `docs/superpowers/specs/`.

## Decisions already made (don't re-ask)

- **Cost:** track cost only for Jarvis's **Anthropic API key**, with a **$10/month** cap (warning at $8; at $10 Opus pauses, Haiku and Qwen keep working). Claude subscription usage is never costed.
- **Mission Control:** served by Jarvis at `/workspace`. Plain HTML/JS/SVG, no build step, polled every 3 s. Read-only in v2.
- **Design skills:** Impeccable is the single global design skill. Taste Skill is installed only inside website projects.
- **Animation:** one library per project, GSAP by default.
- **Skipped on purpose:** Manus, Everything Claude Code, Anime.js, liquid-glass-js, UI/UX Pro Max.

## Rules

- Never use Instagram or other social sites in the browser pane during a Remote Control session. That hung the session on 2026-10-22.
- Install plugins and skills only from the exact repos named in the docs.
- Anything billed outside the Claude plan (image APIs, 21st.dev) needs a spending limit set first.
- Never commit `.env` or API keys.
