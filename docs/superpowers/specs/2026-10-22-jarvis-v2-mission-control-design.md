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
4. **Token tracker.** Tokens and spend over time, broken down by model, agent and department.
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

> **Check first:** I haven't seen the agent `.md` files, their `model:` settings, or the Jarvis source beyond `server/api.py` and `app.py`. Phase 0 of the plan confirms these before anything is built.

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
budget_usd_month = 5.0          # optional; feeds the budget bars and alerts
```

- **Loader check:** every name must match an agent file, and there must be no cycles. Anything left unassigned goes in an "Unassigned" box, so a new agent never disappears from the chart.
- **Model per agent:** read from the agent file's `model:` field (`opus`, `sonnet`, `haiku` or `inherit`), then replaced by the model actually seen in its most recent run.

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

## 5. Token tracker

**Sources**, read incrementally into a new table `token_usage` in `jarvis.db`. Byte offsets per file are stored so each file is only read once.

| Source | What it gives |
|---|---|
| `usage.jsonl` (Jarvis) | per request: tier, model, cost |
| `%USERPROFILE%\.claude\projects\**\*.jsonl` (Claude Code transcripts) | per assistant message: `model` and `usage` (input, output, cache read, cache write); subagent ("sidechain") messages link back to the agent |

**Views:**
- **Totals:** today, 7 days and month to date, in tokens and dollars, with a budget bar against the **$10** monthly cap.
- **Two kinds of usage, kept apart:**
  - **Jarvis API spend** (Jarvis's own Anthropic key) is real money and counts against the $10 cap.
  - **Claude Code usage** runs on your Claude plan. It's shown as tokens, plus an API-equivalent dollar figure for comparison only, and never counts against the $10.
- **Default department split of the $10:** Marketing Command $2.50, Creative Studio $2.50, Strategy & Growth $2.00, Channels & Publishing $1.50, Jarvis voice and chat $1.50.
- **Stacked area chart:** tokens per day by model.
- **Bars:** spend by department and by agent. You can open any one and see its runs.
- **Cache hit rate:** cache reads divided by total input. A low rate tells you where prompt caching is missing.
- **Rolling 5-hour window:** an estimate of tokens used. Plan limits aren't available locally, so it's labelled as an estimate.

**Prices:** a `pricing.toml` table holds price per million tokens for each model, so you can update it without changing code. It covers Qwen ($0) and the Anthropic models you use.

## 6. Alerts

Alerts show on the page and as a tray balloon, with optional phone push via ntfy.sh or Pushover in Phase 6.

- An agent is stalled for more than N minutes. This is the 2026-10-22 case: a browser screenshot call hung for more than 5 minutes.
- An agent is waiting on you for more than N minutes.
- A department or the whole system reaches 80% of its monthly budget.
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
- History beyond what's stored in `token_usage`.
