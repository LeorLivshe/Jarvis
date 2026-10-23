# Setup guide: tools that improve production

Step-by-step installs for the tools picked in [`desktop-upgrades.md`](desktop-upgrades.md). There are two parts:

- **Part A: desktop, once.** Makes every Claude session better.
- **Part B: website project kit.** Run inside each new website or landing-page project only.

Commands in `code` run in **Claude Code** (the ones starting with `/`) or in a **terminal** (everything else). Do Part A in order, and check each step before moving on.

---

## Part A: desktop (about 45 min)

### A1. Update first
```powershell
claude --version        # needs 2.1.290 or newer for Ponytail's status bar
npm --version           # Node.js 18+ (22+ if you add mcp-image)
```
Update the Claude desktop app from its menu if it offers an update.

### A2. Ponytail: less over-building, fewer tokens
```
/plugin marketplace add DietrichGebert/ponytail
/plugin install ponytail@ponytail
/ponytail lite
```
- **Check:** a bar appears above the prompt showing cost and tokens, and `/ponytail` prints the current level.
- **Later:** try `/ponytail full` on coding work. After a feature, run `/ponytail-review`.
- **Undo:** `/ponytail off`, or uninstall from `/plugin`.

### A3. Impeccable: your one design skill
```
/plugin marketplace add pbakaus/impeccable
/plugin
```
In the menu, install **Impeccable**, then restart Claude Code. In each project that has a UI (including the Jarvis repo):
```
/impeccable init
```
This creates `PRODUCT.md`, which records your product and brand decisions for Claude to follow.
- **Check:** `/impeccable critique` reviews a page.
- **Commands you'll use most:** `critique`, `audit`, `polish`, `typeset`, `colorize`, `layout`, `animate`.

### A4. Anthropic example skills: posters, art, themes, brand
```
/plugin marketplace add anthropics/skills
/plugin install example-skills@anthropic-agent-skills
```
- **Check:** "Use canvas-design to make a 1080×1350 poster for [topic]" saves a PNG.
- **Skills it adds:** `canvas-design`, `algorithmic-art`, `theme-factory`, `brand-guidelines`, plus a few others you can ignore.
- **Tip:** run "Use brand-guidelines to write down my brand" once, and keep the result in your project.

### A5. GSAP official skills: correct animation code
```powershell
npx skills add greensock/gsap-skills
```
Pick **Claude Code** when asked, and choose **user/global** scope so every project gets it.
- **Check:** ask "add a GSAP scroll-triggered fade-in". It should use `gsap.registerPlugin(ScrollTrigger)` and `useGSAP` in React.

### A6. Canva: graphics with your brand kit
It's already connected on claude.ai. In the desktop app, open **Settings → Connectors**, check **Canva** is on, and allow it for Claude Code.
- **Check:** "Use Canva to make a 1080×1080 Instagram post about [topic] using my brand kit."
- **Agent:** add one line to `Canva Designer.md`: *"Use the Canva connector for every design; never invent brand colours, read them from the brand kit."*

### A7. Model per agent: protects your subscription limits
Edit each file in `%USERPROFILE%\.claude\agents\marketing\` and set the `model:` line in the frontmatter. Today they hold pinned IDs (`claude-haiku-4-5-20251001`, `claude-sonnet-4-6`); replace them with the short names below so each agent follows the current model:

| `model: haiku` | `model: sonnet` | `model: opus` |
|---|---|---|
| Content Scheduler, Social Publisher, Asset Manager, Twitter/X Engager, Reddit Community Builder, Analytics Reporter | Content Creator, Social Media Strategist, Growth Hacker, Brand Designer, Canva Designer, Email Campaign Manager, Instagram Curator | Campaign Orchestrator |

Add the matching skill line to each agent's instructions:
- **Orchestrator:** *"Plan with the writing-plans skill before assigning work."*
- **Every agent that delivers something:** *"Use verification-before-completion before saying a task is done."*
- **Brand and Canva Designer:** *"Use Impeccable and brand-guidelines for any visual decision."*

**Check:** `/agents` shows the models.

### A8. Agent activity hook: live status in Mission Control
The hook runs from this repo (`jarvis-v2\hooks\`), so there's nothing to copy, and it keeps working after the app code moves into `app/`. It uses `C:\Python312\python.exe` directly, so it doesn't depend on PATH.

Merge the `"hooks"` block from `hooks\settings-snippet.json` into `%USERPROFILE%\.claude\settings.json`. If that file already has `"hooks"`, add these entries next to the existing ones.
- **Check:** run any subagent, then open `%APPDATA%\Jarvis\agent_events.jsonl`. It should have new lines.

### A9. Optional: mcp-image (photoreal images through Gemini)
1. Set a monthly spending limit on your Google AI Studio account.
2. Create a Gemini API key there.
3. Run:
```powershell
claude mcp add mcp-image --scope user --env GEMINI_API_KEY=YOUR_KEY --env IMAGE_OUTPUT_DIR=C:/Users/Leor/Pictures/jarvis -- cmd /c npx -y mcp-image
```
(`cmd /c` is needed for `npx`-based servers on native Windows.)

**Check:** `claude mcp list` shows `mcp-image` connected. Ask for one test image.

---

## Part B: website project kit (per project, about 20 min)

Use this when you build a landing page, marketing site or portfolio. **Don't** install these globally, because they're for React sites only.

### B1. Create the project
```powershell
npx create-next-app@latest my-site      # TypeScript: yes, Tailwind: yes, App Router: yes
cd my-site
npx shadcn@latest init
```

### B2. Taste Skill: marketing-site design (this project only)
```powershell
npx skills add https://github.com/Leonxlnx/taste-skill
```
Choose **Claude Code** and **project** scope. Pick the main frontend skill: the README calls it the v2 default, and one guide lists it as `design-taste-frontend`. For an existing page, also add `redesign-skill`.
- **Why project scope:** Taste Skill and Impeccable would give conflicting instructions if both were always on. In this project, tell Claude: *"Use Taste Skill for design; use Impeccable only for `audit`."*
- **Source:** install only from `Leonxlnx/taste-skill`, because a copy exists under another account.

### B3. Animation: pick one engine per project
**GSAP (default):** the skills from A5 already teach Claude GSAP.
```powershell
npm install gsap @gsap/react
```
**Or Motion,** if you prefer React-style declarative animation:
```powershell
npm install motion
```
In code: `import { motion } from "motion/react"`. Skip the Motion AI Kit unless you subscribe to Motion+.

### B4. 21st.dev Magic MCP: find and generate components
1. Create a key at **21st.dev/mcp**. Old Magic keys no longer work.
2. Run:
```powershell
npx @21st-dev/cli@latest init --client claude
```
3. Paste the key when asked, then restart Claude Code.
- **Use:** ask in plain words, for example *"search 21st for a pricing section with three tiers"*. The old `/ui` command is gone. Generating new UI only works if AI access is enabled on your 21st account.

### B5. Kokonut UI: ready-made sections
Add the registry to `components.json`:
```json
"registries": { "@kokonutui": "https://kokonutui.com/r/{name}.json" }
```
Then add components as you need them:
```powershell
npx shadcn@latest add https://kokonutui.com/r/utils.json
npx shadcn@latest add @kokonutui/particle-button
```

### B6. ShaderGradient: animated hero backgrounds
```powershell
npm i @shadergradient/react @react-three/fiber three three-stdlib camera-controls
npm i -D @types/three
```
1. Design the gradient at **shadergradient.co/customize** and copy its URL.
2. Use it in the hero:
```tsx
import { ShaderGradientCanvas, ShaderGradient } from '@shadergradient/react'

<ShaderGradientCanvas style={{ position: 'absolute', inset: 0 }} pixelDensity={1.5}>
  <ShaderGradient control="query" urlString="PASTE_SHADERGRADIENT_URL" />
</ShaderGradientCanvas>
```
- **Accessibility:** respect `prefers-reduced-motion`. Impeccable `audit` flags it if you forget.

### B7. Optional 3D: ThreeUI and React Three Fiber
```powershell
npm install @designcodeio/threeui
```
```tsx
import { AtTheHorizon } from "@designcodeio/threeui";
import "@designcodeio/threeui/style.css";
```
- Some components need runtime files: copy `node_modules/@designcodeio/threeui/lib-dist/assets/` into `public/`.
- For your own 3D scenes: `npm install three @react-three/fiber @react-three/drei`.

### B8. Optional charts: Bklit UI
```powershell
npx shadcn@latest add @bklit/line-chart
```

---

## Part C: browser tools (no install)

| Tool | Steps |
|---|---|
| **Liquid Logo** | 1. Open **liquid.paper.design**. 2. Upload your logo as an SVG or PNG on a transparent background. 3. Tune the settings. 4. Export it, or screen-record it for Reels and intros. |
| **ShaderGradient (Figma plugin)** | In Figma: **Plugins → search "ShaderGradient" → Run**. Design the gradient and export it as a PNG background for posts. |

---

## When something goes wrong

- **A plugin isn't showing:** run `/reload-plugins` or restart Claude Code.
- **Two design skills are fighting:** check `/plugin` and the project's `.claude/skills` folder. Keep Impeccable global, and Taste Skill only in website projects.
- **An MCP server won't start on Windows:** make sure the command uses `cmd /c npx ...`, then check `claude mcp list`.
- **Something got slow or expensive:** run `/ponytail` to check it's on, `/clear` between tasks, and check that the agent's `model:` isn't Opus by accident.
