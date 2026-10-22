# Skills shortlist: design, reasoning, usage and graphics

**Date:** 2026-10-22
**Status:** Recommendations only. Nothing is installed yet. Approve or strike items, then install them at the desktop.

Skills and plugins can run code and add hooks. Install only from the exact repos named here.

## Install (in priority order)

| # | What | Why | Install (in Claude Code on the desktop) |
|---|---|---|---|
| 1 | **Ponytail** (`DietrichGebert/ponytail`, MIT) | Usage. Stops Claude over-building, so it writes less code and uses fewer tokens. JetBrains' independent 80-task test measured about **−10% cost, −11% time and −15% code** with no quality difference it could detect. The author claims −22% tokens, but that's self-reported. It also adds `/ponytail-review` (complexity review) and a cost and token bar above the prompt. | `/plugin marketplace add DietrichGebert/ponytail` then `/plugin install ponytail@ponytail`. Start with `/ponytail lite`. |
| 2 | **Impeccable** (`pbakaus/impeccable`, Apache-2.0) | Design. Builds on Anthropic's frontend-design skill and adds 24 commands (`critique`, `audit`, `polish`, `typeset`, `colorize`, `layout`, `animate` and more) plus 62 rule-based checks for "AI-looking" UI. Use it as your **one** main design engine for Mission Control and any web UI. | `/plugin marketplace add pbakaus/impeccable`, then install it from `/plugin`. In the Jarvis repo, run `/impeccable init`. |
| 3 | **Anthropic example skills** (`anthropics/skills`) | Graphics. Adds `canvas-design` (posters and visual art as PNG or PDF), `algorithmic-art` (generative art), `theme-factory` (colour and font themes) and `brand-guidelines`. These suit the Brand Designer and Canva Designer agents. | `/plugin marketplace add anthropics/skills` then `/plugin install example-skills@anthropic-agent-skills` |
| 4 | **Canva connector** (already connected on claude.ai) | Graphic generation without a new API key. It has `generate-design`, `generate-image`, brand templates and export. Point the Canva Designer agent at it. | Nothing to install. Check that it's enabled for Claude Code sessions on the desktop. |

## Optional

| What | When | Notes |
|---|---|---|
| **mcp-image** (`shinpr/mcp-image`, MIT) | Only if you need image generation beyond what Canva does: photoreal images, edits, Gemini or GPT Image. | `claude mcp add mcp-image --env GEMINI_API_KEY=... --env IMAGE_OUTPUT_DIR=C:/Users/Leor/Pictures/jarvis -- npx -y mcp-image`. **Billed separately** to Google, OpenAI or BytePlus, not the $10 Anthropic cap, so set a spending limit on that account first. |
| **Vercel web design guidelines** | Pre-ship accessibility and interaction audit for web UI | Partly overlaps with Impeccable's `audit`. Add it only if Impeccable misses things. |

## Skip (and why)

- **UI/UX Pro Max:** a style engine that clashes with Impeccable. Guides consistently say to pick one, not stack them.
- **Taste Skill:** verified later (`Leonxlnx/taste-skill`). Use it per project for landing pages only. See `docs/setup/desktop-upgrades.md` section 7.
- **Anthropic `frontend-design` on its own:** Impeccable already includes an extended version, and installing both duplicates the instructions.
- **Bulk "awesome" lists** (1,000+ skills, unvetted): too much risk and noise. Pick individual skills from them only after checking each repo.

## Reasoning

You already have the **superpowers** plugin: brainstorming, writing-plans, systematic-debugging, verification-before-completion, test-driven-development and code-review. Adding another reasoning pack would mostly duplicate it. Instead:
- name the relevant superpowers skill in each agent's instructions. For example, Campaign Orchestrator uses `writing-plans`, and every agent that ships work uses `verification-before-completion`;
- keep using brainstorming, then spec, then plan, as we did for Mission Control.

## Usage habits (subscription limits)

Usage habits from community guides (none are official Anthropic docs):
- **Keep `CLAUDE.md` short.** Don't `@`-import whole docs into it, because that text loads on every turn. Put area-specific notes in subfolder `CLAUDE.md` files, which only load when Claude works there.
- **Run `/clear` between unrelated tasks.** A long, stale context costs more per turn than a fresh one.
- **Give each agent the right model** (`model:` in its frontmatter): Haiku for scheduling and publishing, Sonnet for content and design, Opus for the Orchestrator only.
- **Keep browser and screen-control work in its own session** with a time limit. That's what hung the Remote Control session on Oct 22.

## Suggested agent mapping

| Agent | Add |
|---|---|
| Brand Designer | Impeccable (`colorize`, `typeset`), theme-factory, brand-guidelines |
| Canva Designer | Canva connector, canvas-design |
| Content Creator | nothing new (Impeccable `clarify` for UI copy is optional) |
| Campaign Orchestrator | superpowers `writing-plans` (already installed) |
| Anything that writes code (Jarvis itself) | Ponytail, Impeccable |

## Sources

- Ponytail: [repo](https://github.com/DietrichGebert/ponytail) · [JetBrains test](https://blog.jetbrains.com/ai/2026/07/ponytail-skill-claude-tested/) · [Flavio Copes deep dive](https://flaviocopes.com/ponytail/)
- Impeccable: [repo](https://github.com/pbakaus/impeccable)
- Anthropic skills: [repo](https://github.com/anthropics/skills) · [skill list](https://github.com/anthropics/skills/tree/main/skills)
- mcp-image: [repo](https://github.com/shinpr/mcp-image)
- Design skill roundups: [Firecrawl](https://www.firecrawl.dev/blog/best-claude-code-skills) · [Snyk](https://snyk.io/articles/top-claude-skills-ui-ux-engineers/) · [Chase AI](https://www.chaseai.io/blog/claude-code-frontend-design-skills)
- Plugin install docs: [Claude Code](https://code.claude.com/docs/en/plugins/install)
- CLAUDE.md and context tips: [DataCamp](https://www.datacamp.com/tutorial/claude-code-best-practices) · [Shuttle](https://www.shuttle.dev/blog/2025/10/16/claude-code-best-practices)
