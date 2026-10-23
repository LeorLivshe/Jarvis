# Jarvis v2: Mission Control (design)

**Date:** 2026-10-22
**Status:** Draft. Read it at home before building.
**Builds on:** the workspace design approved in the Remote Control session on 2026-10-22: map plus live status, served by Jarvis at `/workspace`, layered diagram, in-process snapshot polled every 3 s.
**Copy to:** `C:\Users\Leor\Desktop\Claude\docs\superpowers\specs\`

## 1. Goal

Add one web page, served by Jarvis, that shows the whole system at a glance:

1. **System map.** The Jarvis components and the data each one reads and writes. This part was already approved.
2. **Agent org chart.** Which agents oversee which, grouped into departments.
3. **Live state.** For every agent and department: what state it's in, what task it's doing now, and which model it's using.
4. **API cost tracker.** What Jarvis spends through your Anthropic API key, against a $10 monthly cap. Your Claude subscription (Claude Code and the agents) is never counted.
5. **Alerts.** Anything stalled, failing or close to its budget, so you hear about a session like the 2026-10-22 hang without having to check.

It opens from the tray ("Open Mission Control") and from your phone at `http://<pc>:<port>/workspace`. It uses the existing access key.

## 2. What exists today (from the 2026-10-22 session)

- **Jarvis app (Python, Windows):**
  - watchdog, tray, HUD, push-to-talk, and a FastAPI phone server (`server/api.py`, `X-Jarvis-Key`);
  - engine with a router that sends work to Qwen (local, via Ollama), Claude Haiku or Claude Opus;
  - memory in `data/jarvis.db` (SQLite) and a usage log in `usage.jsonl` (cost per request; the monthly cap is currently $20 and v2 lowers it to **$10**);
  - Whisper for speech-to-text; Kokoro, Piper or SAPI for text-to-speech;
  - `config.toml` and logs.
- **Claude Code custom agents on the desktop (14):**
  - Analytics Reporter, Asset Manager, Brand Designer, Campaign Orchestrator, Canva Designer, Content Creator, Content Scheduler, Email Campaign Manager, Growth Hacker, Instagram Curator, Reddit Community Builder, Social Media Strategist, Social Publisher, Twitter/X Engager;
  - plus the built-ins (general-purpose, Explore, Plan, claude-code-guide, statusline-setup).

> **Checked on 2026-10-23:**
> - The agent files are in `%USERPROFILE%\.claude\agents\marketing\`. Their `model:` fields hold pinned IDs (8 Haiku 4.5, 6 Sonnet 4.6), not short names.
> - The Anthropic provider already caches the system prompt and records all four token counts.
> - The cap check is a single `over_cap` test in `core/engine.py`; there's no 80% warning yet.
>
> Phase 0 of the plan still confirms the rest before anything is built.

## 3. Org chart

Agent files don't record who reports to whom, so the hierarchy lives in a small file you edit: `jarvis/workspace/org.toml`. Proposed starting point:

```
Jarvis (you talk to this)                       Opus, router: Qwen / Haiku / Opus
├── Jarvis runtime                              voice, engine, memory, providers
└── Marketing Command: Campaign Orchestrator    lead
    ├── Strategy & Growth: Social Media Strategist (lead)
    │     Growth Hacker · Analytics Reporter
    ├── Creative Studio: Content Creator (lead)
    │     Brand Designer · Canva Designer · Asset Manager
    └── Channels & Publishing: Social Publisher (lead)
          Content Scheduler · Instagram Curator · Twitter/X Engager
          Reddit Community Builder · Email Campaign Manager
Shared helpers (any agent can call): general-purpose · Explore · Plan
```

```toml
# org.toml
[[department]]
id = "strategy"
name = "Strategy & Growth"
lead = "Social Media Strategist"
reports_to = "Campaign Orchestrator"
members = ["Growth Hacker", "Analytics Reporter"]
```

- **Loader check:** every name must match an agent file, and there must be no cycles. Anything left unassigned goes in an "Unassigned" box, so a new agent never disappears from the chart.
- **Model per agent:** read from the agent file's `model:` field (`opus`, `sonnet`, `haiku`, `inherit`, or a full ID such as `claude-sonnet-4-6`, shown as its family), then replaced by the model actually seen in its most recent run.

## 4. Live state

**States** (each has a colour and an icon, so it doesn't rely on colour alone):

| State | Meaning | Source |
|---|---|---|
| Working | task running, events still arriving | hook `PreToolUse` on Task/Agent, tool events |
| Waiting on you | permission prompt or question | hook `Notification` |
| Stalled | working, but no event for more than 3 min (configurable) | no events within the time limit |
| Error | last run ended with an error or failed tool calls | `PostToolUse` error, transcript |
| Idle | finished, nothing running | `PostToolUse` / `SubagentStop` / `Stop` |
| Offline | Jarvis or the Remote Control host can't be reached | probe |

**Rollup:** a department shows its most urgent state (Error > Stalled > Waiting > Working > Idle) and a count, for example "2 working · 1 waiting".

**Agent card:**
- name, department, model chip (Opus, Sonnet, Haiku, or Qwen local);
- current task (the Task tool's `description`), elapsed time;
- tokens and cost for this run, and the last 5 tasks.

**Data path:**
1. `hooks/jarvis_agent_hook.py` (included, already tested) appends one line per hook event to `%APPDATA%\Jarvis\agent_events.jsonl`.
2. `workspace/agent_events.py` reads new lines from the end of that file and reduces them to current state per agent, matching start and finish events by `tool_use_id`.
3. Jarvis's own engine states (listening, thinking, speaking) come from its event bus, as approved before.

Using a file instead of HTTP means the hook still works when Jarvis is off. Jarvis picks up the backlog when it starts.

## 5. API cost tracker

**Scope:** only calls made with Jarvis's Anthropic API key, which are its Haiku (writing) and Opus (hard questions) tiers.
- Claude Code and all 14 agents run on your Claude subscription. They're **not tracked for cost**.
- Qwen runs locally and is free, so it isn't counted either.

**Source:** `usage.jsonl`. The Anthropic provider writes one line per API call:
- time, tier and model;
- `input_tokens`, `output_tokens`, `cache_creation_input_tokens` and `cache_read_input_tokens`, taken from the API response's `usage` field;
- the cost calculated from `pricing.toml`.

The workspace reads the file incrementally into a `api_usage` table in `jarvis.db`, storing its byte offset so each line is read only once.

**Views:**
- **Spend this month against the $10 cap**, plus today's spend and the request count.
- **Spend by model:** Haiku and Opus.
- **Cache hit rate:** cache reads divided by all API input tokens. It shows whether prompt caching is working.
- **Recent API calls:** time, request, model, input and output tokens, cost.

**Cap:**
- **$8 (80%):** warning in the HUD, the tray and the page.
- **$10:** the router stops using Opus. Haiku and Qwen keep working until the 1st of the month.

**Prices:** `pricing.toml` holds the price per million tokens for each Anthropic model you use: input, output, cache write and cache read. You can update it without changing code.

**Optional check:** if you add an Anthropic Admin API key, a daily job can compare Jarvis's total against the cost report in your Anthropic Console and flag any difference.

## 6. Alerts

Alerts show on the page and as a tray balloon, with optional phone push via ntfy.sh or Pushover in Phase 6.

- An agent is stalled for more than N minutes. This is the 2026-10-22 case: a browser screenshot call hung for more than 5 minutes.
- An agent is waiting on you for more than N minutes.
- API spend reaches $8 (80% of the $10 cap), and again at $10.
- The Remote Control host or Ollama can't be reached.

## 7. Page layout

- **Top bar:** overall status, today's spend, and the alert count.
- **Tabs:**
  - **Agents** (default): org chart.
  - **System**: the approved layered map.
  - **Usage**: charts.
  - **Data**: stores, sizes and log tails.
- **Side panel:** opens when you click any node. On a phone it becomes a sheet that slides up from the bottom.
- **Build:** plain HTML, JS and SVG, no build step, which keeps PyInstaller simple. Light and dark themes. Polls every 3 s.

A clickable mockup is published alongside this spec.

## 8. Security

- Every `/api/*` route requires the key, checked in constant time.
- Secrets are masked in snapshots.
- Agent prompts are cut to 200 characters in the event log.
- The workspace is read-only: no buttons that start, stop or publish anything in v2.

## 9. Out of scope (v2)

- Starting, stopping or re-assigning agents from the page.
- Editing config.
- Push updates (SSE).
- History beyond what's stored in `api_usage`.
- Cost tracking for Claude Code or the agents (they run on your subscription).
