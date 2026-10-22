# Jarvis

A Windows voice assistant with a team of Claude Code agents. This repo holds the **v2 "Mission Control"** work: a dashboard that shows which agents oversee which, what each is doing right now, which model it uses, and how many tokens Jarvis spends.

| Path | What it is |
|---|---|
| [`HANDOFF.md`](HANDOFF.md) | Start here: what to do at the desktop, in order |
| [`docs/superpowers/specs/`](docs/superpowers/specs/) | Mission Control design spec |
| [`docs/superpowers/plans/`](docs/superpowers/plans/) | Phased build plan and ranked improvement ideas |
| [`hooks/`](hooks/) | Claude Code hook that logs agent activity for the dashboard, plus its settings snippet |
| [`scripts/Fix-RemoteControl.ps1`](scripts/Fix-RemoteControl.ps1) | Diagnoses the 2026-10-22 Remote Control drop and keeps the desktop reachable |
| [`docs/research/`](docs/research/) | Skills shortlist: design, reasoning, usage, graphics (not installed yet) |
| [`mockup/`](mockup/) | Source of the clickable mockup ([view it](https://claude.ai/artifact/1wf6LpPG92pUZNg5zCwycK)) |

The Jarvis app code itself is still only on the desktop (`Desktop\Claude\jarvis`). Adding it here is a good next step; see HANDOFF.md.
