"""Claude Code hook: record agent activity for the Jarvis workspace.

Claude Code runs this for each configured hook event and passes the event as
JSON on stdin. We append one compact line to agent_events.jsonl, which the
Jarvis workspace tails to show who is working, on what, and with which model.

Never blocks Claude: any error is swallowed and the hook always exits 0.
Stdlib only, so it runs with whichever Python is on PATH.
"""
import json
import os
import sys
import time
from pathlib import Path

SUBAGENT_TOOLS = {"Task", "Agent"}


def events_file() -> Path:
    base = os.environ.get("JARVIS_DATA_DIR") or os.path.join(
        os.environ.get("APPDATA") or os.path.expanduser("~"), "Jarvis"
    )
    return Path(base) / "agent_events.jsonl"


def summarize(payload: dict) -> dict:
    event = payload.get("hook_event_name", "")
    tool = payload.get("tool_name") or ""
    tool_input = payload.get("tool_input") or {}
    record = {
        "ts": time.time(),
        "event": event,
        "session_id": payload.get("session_id"),
        "cwd": payload.get("cwd"),
    }
    if tool in SUBAGENT_TOOLS:
        record.update(
            tool=tool,
            tool_use_id=payload.get("tool_use_id"),
            agent=tool_input.get("subagent_type") or "general-purpose",
            task=(tool_input.get("description") or "")[:200],
            model=tool_input.get("model"),
        )
    elif tool:
        record["tool"] = tool
    if event == "UserPromptSubmit":
        record["task"] = (payload.get("prompt") or "")[:200]
    if event in ("SubagentStart", "SubagentStop"):
        record["agent"] = payload.get("agent_type") or payload.get("subagent_type")
        record["agent_id"] = payload.get("agent_id")
    if event == "Notification":
        record["message"] = (payload.get("message") or "")[:200]
    return record


def main() -> None:
    try:
        payload = json.loads(sys.stdin.read() or "{}")
        if not payload.get("hook_event_name"):
            return
        path = events_file()
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("a", encoding="utf-8") as f:
            f.write(json.dumps(summarize(payload)) + "\n")
    except Exception:
        pass


if __name__ == "__main__":
    main()
    sys.exit(0)
