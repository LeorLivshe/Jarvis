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
4. Open the Anthropic provider and the code that writes `usage.jsonl`. Note whether it already records the `usage` token fields from each API response. If it doesn't, Phase 4.1 adds them.

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

## Phase 4: API cost tracker (Anthropic API key only)
| Task | Files | Tests |
|---|---|---|
| 4.1 Log every API call | Anthropic provider writes `usage` (input, output, cache write, cache read) and the cost to `usage.jsonl` | a fake response is logged with the right tokens and cost |
| 4.2 Pricing | `workspace/pricing.toml`, `pricing.py` | an unknown model is flagged, never silently priced at $0 |
| 4.3 Schema and ingest | `api_usage` table plus stored file offsets; `usage_ingest.py` | reading the file twice doesn't double-count; a half-written last line is skipped |
| 4.4 Cap enforcement | router: warn at $8; at $10, stop routing to Opus | a test at $9.99, $10.00 and the new-month rollover |
| 4.5 API | `GET /api/usage?range=today\|month` | totals match the sum of the rows |
| 4.6 Usage tab | `workspace.html` | spend against the cap, spend by model, cache-hit percentage, recent calls |

Claude Code and agent usage on your subscription is out of scope: nothing reads its transcripts.

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
   - This affects your subscription limits, not the $10 API cap.
3. **Prompt caching in Jarvis's Anthropic provider.** Cache the system prompt and memory block. This is the cheapest way to stay under $10, and the cache-hit figure shows the effect.
4. **Tighter routing under the $10 cap.** Log why each request went to Opus, and review it weekly. Where Haiku would have been good enough, change the routing rules.
5. **Approval gate for anything public.** Social Publisher, Email Campaign Manager and the X and Reddit agents queue posts for your OK instead of publishing them directly.
6. **Reach the desktop from your phone.** Use Chrome Remote Desktop or Tailscale, plus the Mission Control page on your phone, so a stuck session is a 1-minute fix instead of a wait until you're home.
7. **Router regression tests.** Keep about 30 sample prompts with the tier each should get, so changes to the router don't quietly move work onto Opus.
8. **Log rotation and size limits** for `jarvis.log`, `supervisor.log` and `agent_events.jsonl`. Shown on the Data tab.
9. **Memory tidy-up.** Every week, consolidate `jarvis.db` memories (merge duplicates, expire stale ones). Show memory size on the map.
