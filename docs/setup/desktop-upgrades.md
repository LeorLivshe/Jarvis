# Desktop upgrades checklist

**For:** the Windows desktop (`C:\Users\Leor\Desktop\Claude`)
**Goal:** better output from Claude for design, reasoning and usage, plus a setup that stays reachable while you're away.
**How to use:** work top to bottom and tick each box. Each item says what it improves, the exact command, and how to check it worked.
Background and sources are in [`../research/2026-10-22-skills-shortlist.md`](../research/2026-10-22-skills-shortlist.md).

---

## 0. Before anything (10 min)

- [ ] **Clone this repo:** `git clone https://github.com/LeorLivshe/Jarvis`
- [ ] **Update Claude Code and the desktop app.** Ponytail's status bar needs Claude Code 2.1.290 or later. Check with `claude --version`.
- [ ] **Delete the leftover branch in the `cv` repo:** `git push origin --delete claude/remote-control-session-closure-dgt6ji`

## 1. Reliability: keep sessions alive (20 min)

| | Item | Improves | How | Check |
|---|---|---|---|---|
| [ ] | Fix script | Session drops | Admin PowerShell: `scripts\Fix-RemoteControl.ps1 -DiagnoseOnly`, read the report, then run it without the flag | `powercfg /query` shows sleep set to 0 on AC |
| [ ] | Chrome Remote Desktop | Fixing a hang from your phone | Opened by the fix script. Set a PIN. | Connect from your phone once |
| [ ] | Launch at login | Desktop app back after a reboot | In the Claude desktop app's settings | Reboot, then the app is in the tray |
| [ ] | Wake-on-LAN (optional) | Waking the PC remotely | Enable it in the BIOS and in the network adapter's Advanced tab | - |

## 2. Usage: fewer tokens for the same result

| | Item | Improves | How | Check |
|---|---|---|---|---|
| [ ] | **Ponytail** | Less over-building. In an independent test: about −10% cost, −11% time and −15% code. | `/plugin marketplace add DietrichGebert/ponytail` → `/plugin install ponytail@ponytail` → `/ponytail lite` | A status bar appears above the prompt. `/ponytail` reports the current level. |
| [ ] | Model per agent | Subscription limits | In each `~/.claude/agents/*.md`, set `model:`. Haiku: Content Scheduler, Social Publisher, Asset Manager, Twitter/X Engager, Reddit Community Builder, Analytics Reporter. Sonnet: Content Creator, Social Media Strategist, Growth Hacker, Brand Designer, Canva Designer, Email Campaign Manager, Instagram Curator. Opus: Campaign Orchestrator. | `/agents` lists the right models |
| [ ] | Lean `CLAUDE.md` | Context cost on every turn | Keep the root `CLAUDE.md` under about 100 lines. No `@`-imports of whole docs. Put area notes in subfolder `CLAUDE.md` files. | - |
| [ ] | Habit: `/clear` between unrelated tasks | Context cost | Habit, nothing to install | - |

## 3. Design: better-looking output

| | Item | Improves | How | Check |
|---|---|---|---|---|
| [ ] | **Impeccable** (your one main design skill) | UI quality, plus 62 checks for AI-looking design | `/plugin marketplace add pbakaus/impeccable`, then install from `/plugin`. In the Jarvis repo: `/impeccable init` | `/impeccable critique` runs |
| [ ] | Don't add other design engines | Avoids conflicting instructions | Skip UI/UX Pro Max, Taste Skill and Anthropic's own `frontend-design` (Impeccable includes it) | - |
| [ ] | Browser preview | Claude checks its own UI | Use the desktop app's preview pane or Playwright. **Only** for localhost pages, not social sites. | - |

## 4. Graphics: images, posters, brand assets

| | Item | Improves | How | Check |
|---|---|---|---|---|
| [ ] | **Anthropic example skills** | Posters and art (`canvas-design`), generative art (`algorithmic-art`), themes (`theme-factory`), brand rules (`brand-guidelines`) | `/plugin marketplace add anthropics/skills` → `/plugin install example-skills@anthropic-agent-skills` | "Use canvas-design to make a test poster" produces a PNG |
| [ ] | **Canva connector** (already on claude.ai) | Designs and images with your brand kit, no extra key | Check it's enabled for desktop sessions. Point the Canva Designer agent at it. | Ask for a 1080×1080 test post |
| [ ] | mcp-image (optional) | Photoreal images and edits (Gemini or GPT Image) | Set a **spending limit on the Google or OpenAI account first**, then `claude mcp add mcp-image --scope user --env GEMINI_API_KEY=... --env IMAGE_OUTPUT_DIR=C:/Users/Leor/Pictures/jarvis -- npx -y mcp-image` | One test image is saved to that folder |

## 5. Reasoning: plan before building, verify before saying done

| | Item | Improves | How |
|---|---|---|---|
| [ ] | Use **superpowers** (already installed) | Planning, debugging, checking work | Add one line to each agent's instructions naming its skill. Orchestrator: `writing-plans`. Every agent that ships work: `verification-before-completion`. Anything that breaks: `systematic-debugging`. |
| [ ] | Review commands | Catching bugs and complexity | After a feature: `/code-review`, then `/ponytail-review` |

## 6. Jarvis-specific upgrades

| | Item | Improves | How |
|---|---|---|---|
| [ ] | Agent activity hook | Live agent status in Mission Control | Copy `hooks/` into `Desktop\Claude\jarvis\hooks\`, then merge `hooks/settings-snippet.json` into `%USERPROFILE%\.claude\settings.json` |
| [ ] | $10 API cap | Jarvis API spend | `config.toml`: set the monthly cap to 10 (Phase 0 of the plan) |
| [ ] | Prompt caching in Jarvis | Jarvis API cost | Cache the system prompt and memory block in the Anthropic provider |
| [ ] | Approval gate | Nothing posts publicly without you | Social Publisher, Email, X and Reddit agents queue drafts for your OK |
| [ ] | Build Mission Control | The dashboard | Tell Claude: "Execute the Mission Control plan starting at Phase 0." |

## 7. From the Instagram reel you sent (2026-10-22)

Reel: https://www.instagram.com/reel/Deo74W0qb2G/

> **Not filled in yet.** This environment can't open Instagram, so I couldn't watch the reel. Send the caption or a screenshot of the tools it names, and they'll be checked against their repos and added here.

| | Tool | What it does | Install | Verified? |
|---|---|---|---|---|
| [ ] | _(from reel)_ | | | |
| [ ] | _(from reel)_ | | | |

## Rules for anything new

- Install only from the exact GitHub repo or marketplace named. Skills and plugins can run code and add hooks.
- One design engine at a time.
- Anything billed outside your Claude plan, such as image APIs, gets a spending limit before its key goes in.
- Social sites stay out of Remote Control sessions. Browser automation runs in its own time-limited session.
