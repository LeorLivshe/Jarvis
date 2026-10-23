# Desktop upgrades checklist

**For:** the Windows desktop (`C:\Users\Leor\Desktop\Claude`)
**Goal:** better output from Claude for design, reasoning and usage, plus a setup that stays reachable while you're away.
**How to use:** work top to bottom and tick each box. Each item says what it improves, the exact command, and how to check it worked.
Background and sources are in [`../research/2026-10-22-skills-shortlist.md`](../research/2026-10-22-skills-shortlist.md).
**Step-by-step installs:** [`setup-guide.md`](setup-guide.md). Part A is the desktop, Part B is the per-project website kit, Part C is browser tools.

---

## 0. Before anything (10 min)

- [ ] **Clone this repo:** `git clone https://github.com/LeorLivshe/Jarvis jarvis-v2` from `Desktop\Claude` (not plain `Jarvis`, which would clash with your existing `jarvis` folder)
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
| [ ] | Model per agent | Subscription limits | In each `~/.claude/agents/marketing/*.md`, replace the pinned ID in `model:` with `haiku`, `sonnet` or `opus`. Haiku: Content Scheduler, Social Publisher, Asset Manager, Twitter/X Engager, Reddit Community Builder, Analytics Reporter. Sonnet: Content Creator, Social Media Strategist, Growth Hacker, Brand Designer, Canva Designer, Email Campaign Manager, Instagram Curator. Opus: Campaign Orchestrator. | `/agents` lists the right models |
| [ ] | Lean `CLAUDE.md` | Context cost on every turn | Keep the root `CLAUDE.md` under about 100 lines. No `@`-imports of whole docs. Put area notes in subfolder `CLAUDE.md` files. | - |
| [ ] | Habit: `/clear` between unrelated tasks | Context cost | Habit, nothing to install | - |

## 3. Design: better-looking output

| | Item | Improves | How | Check |
|---|---|---|---|---|
| [ ] | **Impeccable** (your one main design skill) | UI quality, plus 62 checks for AI-looking design | `/plugin marketplace add pbakaus/impeccable`, then install from `/plugin`. In the Jarvis repo: `/impeccable init` | `/impeccable critique` runs |
| [ ] | Don't stack design engines | Avoids conflicting instructions | Skip UI/UX Pro Max and Anthropic's own `frontend-design` (Impeccable includes it). Taste Skill is project-only (section 7). | - |
| [ ] | **GSAP official skills** (from the reel) | Correct, smooth animation code: timelines, ScrollTrigger, React | `npx skills add greensock/gsap-skills` | Ask for a scroll animation; it uses `gsap.timeline` and `ScrollTrigger` correctly |
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
| [ ] | Agent activity hook | Live agent status in Mission Control | Merge `hooks/settings-snippet.json` (it runs the hook from this repo; nothing to copy) into `%USERPROFILE%\.claude\settings.json` |
| [ ] | $10 API cap | Jarvis API spend | `config.toml`: set the monthly cap to 10 (Phase 0 of the plan) |
| [ ] | Prompt caching in Jarvis | Jarvis API cost | Cache the system prompt and memory block in the Anthropic provider |
| [ ] | Approval gate | Nothing posts publicly without you | Social Publisher, Email, X and Reddit agents queue drafts for your OK |
| [ ] | Build Mission Control | The dashboard | Tell Claude: "Execute the Mission Control plan starting at Phase 0." |

## 7. Tools from the Instagram reel (researched 2026-10-22)

Reel: https://www.instagram.com/reel/Deo74W0qb2G/ (you supplied the tool names; I checked each one against its own site or repo)

**How these fit your setup:** most are libraries for building **websites in React**. Mission Control is plain HTML with no build step, so they matter when you build a landing page or marketing site, not for Jarvis itself. Only the first group goes on the desktop now.

### 7a. Install now

| | Tool | What it is | Why | How |
|---|---|---|---|---|
| [ ] | **GSAP + official GSAP skills** | Animation library (free, including the former paid plugins) plus GreenSock's own AI skills | Teaches Claude to write correct animation code. It's free and official, so there's no third-party risk. Already listed in section 3. | `npx skills add greensock/gsap-skills` |

### 7b. Add per project, when you build a website or landing page

Install these **inside that project**, not globally.

| | Tool | What it is | Use it for | Notes |
|---|---|---|---|---|
| [ ] | **Taste Skill** (tasteskill.dev, `Leonxlnx/taste-skill`, MIT) | Design skill against generic "AI slop" sites, with GSAP code patterns built in | Landing pages, marketing sites, portfolios. Its own guide says it's **not** meant for dashboards or app screens. | Clashes with Impeccable, so use it only in website projects. `/plugin marketplace add Leonxlnx/taste-skill` → `/plugin install taste-skill@taste-skill`. Install from Leonxlnx only, because a copy exists under another account. |
| [ ] | **21st.dev Magic MCP** | Search and generate React/Tailwind components from a large community library | Building React sites fast | Needs a 21st.dev API key. Check its pricing first, then follow the install command in 21st.dev's docs. |
| [ ] | **Motion** (motion.dev, MIT) | Animation library for React and plain JS, with springs and gestures | React interactions | Use either GSAP or Motion in a project, not both. The official Motion AI Kit (`npx motion-ai`) is part of the paid Motion+ tier. |
| [ ] | **ThreeUI** (threeui.com, `MengTo/threeui`, MIT core) | 160+ free Three.js components and 3D hero sections, each with an agent prompt | 3D hero sections on landing pages | The Pro tier adds MCP access. The free tier is enough to start. |
| [ ] | **React Three Fiber** (`pmndrs/react-three-fiber`) | React renderer for Three.js | Any 3D in a React site. ThreeUI-style scenes build on it. | Only if you go 3D |
| [ ] | **ShaderGradient** (`ruucm/shadergradient`) | Animated 3D shader gradients for React, with Figma and Framer plugins | Hero backgrounds. The Figma plugin also works for **static social graphics**, with no code. | |
| [ ] | **Kokonut UI** (the "Coconut UI" from the reel) | 100+ free React/Tailwind/Motion components on shadcn | Ready-made polished sections | Also available through 21st.dev |
| [ ] | **Bklit UI** (the "Backlit UI" from the reel, `bklit/bklit-ui`, MIT) | Chart components on shadcn: area, bar, sankey, gauge and more | Charts in a React dashboard | Worth it if Mission Control's Usage tab ever moves to React |

### 7c. Use in the browser (no install)

| | Tool | Use it for |
|---|---|---|
| [ ] | **Liquid Logo** (`paper-design/liquid-logo`, demo at liquid.paper.design) | Turning your logo into a liquid-metal animation for brand posts and intros. Upload, export, done. |
| [ ] | **ShaderGradient Figma plugin** | Gradient backgrounds for social posts |

### 7d. Skip

| Tool | Why |
|---|---|
| **Manus** | A separate autonomous agent that charges in credits ($20/month for 4,000). Reviewers report unpredictable credit burn, with one research task using 500–900 credits. It overlaps with what Claude and your agents already do. |
| **Everything Claude Code** (Affaan Mustafa's ECC, MIT) | Very large: 71 agents and 311 skills. Its README warns the plugin advertises its whole catalog to the model (token cost), its rules always load, and native Windows is "supported with limitations". It would also clash with superpowers, Ponytail and your own agents. If one piece interests you, copy that piece by hand after reading it. |
| **Anime.js** (the "Animate.js" from the reel) | Fine library, but it overlaps GSAP and Motion. Pick one animation engine. |
| **liquid-glass-js** (`dashersw/liquid-glass-js`) | An early project: one commit, no releases, unfinished roadmap. It captures the page with html2canvas on every frame, which is heavy on performance. Revisit later. |

## Rules for anything new

- Install only from the exact GitHub repo or marketplace named. Skills and plugins can run code and add hooks.
- One design engine at a time.
- Anything billed outside your Claude plan, such as image APIs, gets a spending limit before its key goes in.
- Social sites stay out of Remote Control sessions. Browser automation runs in its own time-limited session.
