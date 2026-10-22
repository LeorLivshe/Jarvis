# Jarvis v2: Mission Control (implementation plan)

**Spec:** `2026-10-22-jarvis-v2-mission-control-design.md`
**Copy to:** `C:\Users\Leor\Desktop\Claude\docs\superpowers\plans\`
**Method:** test-driven, one commit per task. Run the existing test suite after every phase.

**For the session at home:** start with Phase 0. Each task lists its files, what to test, and when it counts as done.

---

## Phase 0: Baseline (about 30 min)
1. `pytest` in `jarvis/`. Record what passes and what fails. Fix nothing yet.
2. Read `jarvis/app.py`, `core/events.py`, `server/api.py`, the router, and the usage-log writer. Note the real names, which may differ from the ones in the spec.
3. List `%USERPROFILE%\.claude\agents\*.md` (and the project's `.claude\agents`). Record each agent's `name`, `model` and `tools`, and update the proposed `org.toml`.
4. Open one recent transcript `.jsonl` and confirm three fields: `message.model`, `message.usage`, and how subagent lines are marked (`isSidechain`, agent id). Change Phase 4's parser if any differ.

5. In `config.toml`, change the monthly spend cap from $20 to **$10**. Check that the router's 80% warning now fires at $8.

**Done when:** the spec has been corrected against what's really there, and the baseline test results are recorded.

## Phase 1: System map (the design approved on 2026-10-22)
| Task | Files | Tests |
|---|---|---|
| 1.1 Topology | `workspace/topology.py` | every link points at a real node; layers in order |
| 1.2 Probes | `workspace/probes.py` | each probe with fakes; a probe that raises gives "unknown" plus the error |
| 1.3 Snapshot | `workspace/snapshot.py` | secrets masked; JSON shape |
| 1.4 Routes | `server/api.py`: `GET /workspace`, `GET /api/workspace` | 401 without the key; page served |
| 1.5 Page | `server/static/workspace.html` (System tab) | manual check: desktop and phone widths |
| 1.6 Tray and build | tray menu item; `jarvis.spec` includes `static/` | the built exe serves the page |

## Phase 2: Agent registry and org chart
| Task | Files | Tests |
|---|---|---|
| 2.1 Frontmatter parser | `workspace/agents.py` | handles name, model, tools, a missing model ("inherit"), bad YAML |
| 2.2 Org loader | `workspace/org.py`, `workspace/org.toml` | unknown name gives an error; cycle detected; unassigned agents go to "Unassigned" |
| 2.3 Snapshot section | `snapshot.py` adds `org` | departments, leads and members, each with a configured model |
| 2.4 Agents tab | `workspace.html` | tree layout, model chips, click opens the side panel |

## Phase 3: Live agent state
| Task | Files | Tests |
|---|---|---|
| 3.1 Install hook | copy `hooks/jarvis_agent_hook.py` and merge `settings-snippet.json` into `%USERPROFILE%\.claude\settings.json` | run one subagent and see a line appear in `agent_events.jsonl` |
| 3.2 Event tailer | `workspace/agent_events.py` | resumes from saved offset; ignores a half-written last line |
| 3.3 State reducer | same | start/finish matched by `tool_use_id`; stalled after the time limit; waiting after `Notification`; department rollup order |
| 3.4 UI | `workspace.html` | state colours and icons, task text, elapsed time, department counts |

## Phase 4: Token tracker
| Task | Files | Tests |
|---|---|---|
| 4.1 Schema | migration adds `token_usage(ts, source, session, agent, model, input, output, cache_read, cache_write, cost_usd)` and `ingest_offsets(path, offset)` | the migration can run twice safely |
| 4.2 Pricing | `workspace/pricing.toml`, `pricing.py` | unknown model is counted as $0 and flagged |
| 4.3 Ingest from Jarvis | `usage_ingest.py` reading `usage.jsonl` | incremental; no double counting |
| 4.4 Ingest from Claude Code | same, reading transcripts | assistant lines only; subagent lines credited to the agent; file rotation handled |
| 4.5 API | `GET /api/usage?range=today\|7d\|month&group=model\|agent\|dept` | totals add up across groupings |
| 4.6 Usage tab | `workspace.html` | stacked area chart, bars, budget bar, cache-hit percentage, 5-hour estimate (in SVG) |

## Phase 5: Alerts
- 5.1 `workspace/alerts.py`: rules for stalled, waiting, 80% budget, host or Ollama unreachable. Includes a cool-down so the same alert doesn't repeat.
- 5.2 Show alerts as a tray balloon and as an alert strip on the page.
- 5.3 Optional phone push (ntfy.sh topic set in `config.toml`).

## Phase 6: Improvements (pick in order; see the suggestions below)

---

## Suggested improvements, highest value first

1. **Keep risky automation out of your main session.** The 2026-10-22 drop started when a browser screenshot of Instagram hung for more than 5 minutes inside the Remote Control session. Run browser and computer-use jobs in their own session or agent with a time limit, so a hang can't take the main session down.
2. **Pick models per agent to cut tokens.**
   - Haiku: Scheduler, Publisher, Asset Manager, Curator.
   - Sonnet: Content Creator, Strategist, Brand and Canva Designer, Email.
   - Opus: Campaign Orchestrator and Jarvis's hard tier only.
   - The usage tab will show what this saves.
3. **Prompt caching in Jarvis's Anthropic provider.** Cache the system prompt and memory block. The cache-hit chart will show the effect.
4. **Per-department budgets with automatic downgrade.** At 80% of a budget, the router moves that department one model tier down. At 100% it pauses the department and alerts you.
5. **Approval gate for anything public.** Social Publisher, Email Campaign Manager and the X and Reddit agents queue posts for your OK instead of publishing them directly.
6. **Reach the desktop from your phone.** Use Chrome Remote Desktop or Tailscale, plus the Mission Control page on your phone, so a stuck session is a 1-minute fix instead of a wait until you're home.
7. **Router regression tests.** Keep about 30 sample prompts with the tier each should get, so changes to the router don't quietly move work onto Opus.
8. **Log rotation and size limits** for `jarvis.log`, `supervisor.log` and `agent_events.jsonl`. Shown on the Data tab.
9. **Memory tidy-up.** Every week, consolidate `jarvis.db` memories (merge duplicates, expire stale ones). Show memory size on the map.
