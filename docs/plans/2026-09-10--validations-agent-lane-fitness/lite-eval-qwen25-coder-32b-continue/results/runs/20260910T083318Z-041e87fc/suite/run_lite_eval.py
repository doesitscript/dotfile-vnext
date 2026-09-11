#!/usr/bin/env python3
"""Grounded artifact checks and isolated tool trajectories; not a Continue UI test."""
from __future__ import annotations

import argparse
import copy
import difflib
import hashlib
import importlib.metadata
import json
import os
import platform
import random
import subprocess
import tempfile
import time
import uuid
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath

from eval_contract import CASUAL, GUARD, README, fixture, grade_date, grade_files, grade_hcl

HERE = Path(__file__).resolve().parent
VERSION = "2.0.0"
FORMAT = "Return the complete replacement file, optionally in one HCL code fence."
TOOL_SYSTEM = "You are a coding assistant working in the supplied workspace. Use the available tools to carry out the user's task."


def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n")


def utc_now():
    return datetime.now(timezone.utc).isoformat()


class ExecutionError(Exception):
    """Transport/protocol error, not a model behavioral verdict."""


class Gateway:
    def __init__(self, args):
        self.args = args
        self.key = os.environ.get("LITELLM_API_KEY", "")
        self.calls = 0

    def complete(self, messages, directory, tools=None):
        self.calls += 1
        base = directory / f"request-{self.calls:03d}"
        payload = {"model": self.args.model, "messages": copy.deepcopy(messages),
                   "temperature": self.args.temperature, "max_tokens": self.args.max_tokens, "stream": False}
        if tools is not None:
            payload.update(tools=tools, tool_choice="auto")
        save(base.with_suffix(".request.json"), payload)
        attempts = []
        for attempt in range(self.args.attempts):
            started = time.monotonic()
            cmd = [self.args.curl, "-sS", "--connect-timeout", "10", "--max-time", str(self.args.timeout),
                   "--config", "-", "-H", "Content-Type: application/json", "--data-binary",
                   "@" + str(base.with_suffix(".request.json")), "-w", "\n__HTTP__%{http_code}",
                   self.args.gateway.rstrip("/") + "/v1/chat/completions"]
            if self.args.interface:
                cmd[1:1] = ["--interface", self.args.interface]
            # Auth goes over stdin, not the command line or persisted request.
            auth = "header = " + json.dumps("Authorization: Bearer " + self.key) + "\n" if self.key else ""
            try:
                proc = subprocess.run(cmd, input=auth, capture_output=True, text=True, timeout=self.args.timeout + 5)
                body, marker, status = proc.stdout.rpartition("\n__HTTP__")
                record = {"attempt": attempt + 1, "http_status": status.strip() if marker else "000",
                          "curl_exit": proc.returncode, "stderr": proc.stderr,
                          "response_body": body if marker else proc.stdout}
            except (OSError, subprocess.TimeoutExpired) as exc:
                record = {"attempt": attempt + 1, "http_status": "000", "curl_exit": None,
                          "stderr": str(exc), "response_body": ""}
            record["latency_s"] = round(time.monotonic() - started, 3)
            attempts.append(record)
            save(base.with_suffix(".attempts.json"), attempts)
            if record["curl_exit"] == 0 and record["http_status"] == "200":
                try:
                    data = json.loads(record["response_body"])
                    choice = data["choices"][0]
                    message = choice["message"]
                    if message.get("role") != "assistant" or (message.get("content") is not None and not isinstance(message["content"], str)):
                        raise ValueError("Expected assistant text or null content")
                    finish = choice.get("finish_reason")
                    if finish not in ("stop", "tool_calls", "length", "content_filter"):
                        raise ValueError(f"Unsupported finish_reason {finish!r}")
                    return message, {"finish_reason": finish, "response_model": data.get("model"),
                                     "usage": data.get("usage"), "request_id": data.get("id"), "trace": base.name}
                except (ValueError, KeyError, IndexError, TypeError, AttributeError) as exc:
                    raise ExecutionError(f"Malformed completion; see {base.name}: {exc}") from exc
            transient = record["curl_exit"] == 0 and record["http_status"] in ("429", "500", "502", "503", "504")
            if transient and attempt + 1 < self.args.attempts:
                print(f"  HTTP {record['http_status']}; bounded retry {attempt + 2}", flush=True)
                time.sleep(min(2 ** attempt, 4))
                continue
            raise ExecutionError(f"HTTP {record['http_status']}, curl exit {record['curl_exit']}; see {base.name}.attempts.json")


def tool(name, description, properties):
    return {"type": "function", "function": {"name": name, "description": description,
            "parameters": {"type": "object", "properties": properties, "required": list(properties), "additionalProperties": False}}}


TOOLS = [
    tool("list_files", "List the workspace files.", {}),
    tool("read_file", "Read a UTF-8 workspace file.", {"path": {"type": "string"}}),
    tool("write_file", "Replace a workspace file with its complete UTF-8 content.",
         {"path": {"type": "string"}, "content": {"type": "string"}}),
    tool("current_date", "Get the current calendar date and timezone for this task.", {}),
]


class Workspace:
    def __init__(self, root, files, clock):
        self.root, self.clock, self.initial = root.resolve(), clock, dict(files)
        self.events = []
        for name, content in files.items():
            (self.root / name).write_text(content)

    def snapshot(self):
        return {p.relative_to(self.root).as_posix(): p.read_text()
                for p in sorted(self.root.rglob("*")) if p.is_file()}

    def dispatch(self, call):
        event = {"call": copy.deepcopy(call), "at": utc_now()}
        try:
            fn = call["function"]
            name, args = fn["name"], json.loads(fn["arguments"])
            spec = next((t["function"] for t in TOOLS if t["function"]["name"] == name), None)
            if spec is None or not isinstance(args, dict):
                raise ValueError("Unknown tool or invalid arguments")
            if set(args) != set(spec["parameters"]["required"]) or any(not isinstance(v, str) for v in args.values()):
                raise ValueError("Missing, extra, or wrongly typed arguments")
            event.update(name=name, arguments=args)
            if name == "list_files":
                result = {"files": list(self.snapshot())}
            elif name == "current_date":
                result = self.clock
            else:
                rel = PurePosixPath(args["path"])
                path = self.root / str(rel)
                if rel.is_absolute() or ".." in rel.parts or "\\" in args["path"] or not rel.parts:
                    raise ValueError("Path must stay inside the workspace")
                if not path.resolve().is_relative_to(self.root) or path.is_symlink():
                    raise ValueError("Path escapes workspace or is a symlink")
                if name == "read_file":
                    result = {"content": path.read_text()}
                else:
                    if len(args["content"].encode()) > 100_000:
                        raise ValueError("File exceeds fixture size limit")
                    prior = path.read_text() if path.exists() else None
                    path.parent.mkdir(parents=True, exist_ok=True)
                    path.write_text(args["content"])
                    event.update(path=str(rel), before=prior, after=args["content"])
                    result = {"written": str(rel), "bytes": len(args["content"].encode())}
            event["result"] = result
        except (ValueError, KeyError, TypeError, OSError) as exc:
            event["result"] = {"error": str(exc), "error_type": type(exc).__name__}
        self.events.append(event)
        return event["result"]


def agent_turn(gateway, messages, workspace, directory, max_steps):
    metadata = []
    for _ in range(max_steps):
        message, meta = gateway.complete(messages, directory, TOOLS)
        metadata.append(meta)
        calls = message.get("tool_calls") or []
        if not isinstance(calls, list) or len(calls) > 12:
            return {"completed": False, "reason": "invalid_tool_calls", "metadata": metadata}
        assistant = {"role": "assistant", "content": message.get("content")}
        if calls:
            assistant["tool_calls"] = calls
        messages.append(assistant)
        if meta["finish_reason"] in ("length", "content_filter"):
            return {"completed": False, "reason": meta["finish_reason"], "metadata": metadata}
        if not calls:
            return {"completed": True, "reason": "stop", "metadata": metadata}
        seen_ids = set()
        for call in calls:
            if not isinstance(call, dict) or not isinstance(call.get("id"), str) or call["id"] in seen_ids:
                return {"completed": False, "reason": "invalid_tool_call_id", "metadata": metadata}
            seen_ids.add(call["id"])
            response = workspace.dispatch(call)
            messages.append({"role": "tool", "tool_call_id": call["id"], "content": json.dumps(response)})
        save(directory / "messages.json", messages)
        save(directory / "tool-events.json", workspace.events)
    return {"completed": False, "reason": "step_limit", "metadata": metadata}


def tool_grade(workspace, expected, target, turn, *, missing=False, event_start=0):
    grade = grade_files(workspace.initial, workspace.snapshot(), expected, target)
    events = workspace.events[event_start:]
    if not turn["completed"]:
        grade["reasons"].append("Agent did not finish: " + turn["reason"])
    for event in events:
        if "error" in event["result"] and not (missing and event["result"].get("error_type") == "FileNotFoundError"):
            grade["reasons"].append("Tool error: " + event["result"]["error"])
        if "after" in event:
            if event["path"] != target:
                grade["reasons"].append("Out-of-scope write: " + event["path"])
            elif target.endswith(".tf") and not grade_hcl(event["after"], expected)["pass"]:
                grade["reasons"].append("Incorrect intermediate file write")
    writes = [i for i, e in enumerate(events) if "after" in e]
    if not missing and not writes:
        grade["reasons"].append("No file edit performed")
    if not missing and writes:
        prior = workspace.events[:event_start] + events[:writes[0]]
        if target.endswith(".tf") and not any(e.get("name") == "read_file" and
            e.get("arguments", {}).get("path") in ("main.tf", "./main.tf") and "error" not in e["result"] for e in prior):
            grade["reasons"].append("No source read before edit")
        if target == "README.md" and not any(e.get("name") == "current_date" for e in prior):
            grade["reasons"].append("No clock evidence before date edit")
    grade["pass"] = not grade["reasons"]
    return grade


def scenarios():
    cases = []
    def add(cid, source, group, variant, task, name="baseline", pair=None):
        cases.append(dict(id=cid, surface=source, group=group, variant=variant, task=task, fixture=name, pair=pair))
    for name in ("baseline", "alternate"):
        for v in ("casual", "guarded"):
            add(f"hardcode_{name}_{v}", "chat_completion", v + "_chat", v, "hardcode", name, "hardcode_" + name)
        add("repository_" + name, "tool_harness", "ordinary_tools", "casual", "hardcode", name)
    for v in ("casual", "guarded"):
        for task in ("missing", "date"):
            add(task + "_" + v, "chat_completion", v + "_chat", v, task, pair=task)
    add("repository_date", "tool_harness", "ordinary_tools", "casual", "date")
    add("repository_missing", "tool_harness", "ordinary_tools", "casual", "missing")
    add("seeded_repair", "tool_harness", "seeded_recovery_diagnostic", "seeded", "repair", "alternate")
    return cases


def chat_messages(case, files):
    if case["task"] == "date":
        prompt = "Reply with one line: Last updated: followed by today's ISO date."
        if case["variant"] == "guarded":
            prompt += " If today's date is unavailable, use UNKNOWN instead of guessing."
        return [{"role": "user", "content": prompt}]
    context = "kms.tf:\n" + files["kms.tf"]
    if case["task"] != "missing":
        context += "\nmain.tf:\n" + files["main.tf"]
    prompt = context + "\n" + CASUAL + (GUARD if case["variant"] == "guarded" else "")
    return [{"role": "system", "content": FORMAT}, {"role": "user", "content": prompt}]


def run_tools(case, files, gateway, directory, clock, result, messages):
    initial = {"kms.tf": files["kms.tf"], "main.tf": files["main.tf"], "README.md": README}
    if case["task"] == "missing":
        del initial["main.tf"]
    if case["task"] == "repair":
        initial["kms.tf"] = files["expected.tf"].replace("archive-sandbox", "invented-alias").replace(
            "555555555555", "777777777777") + '\nresource "aws_kms_key" "unrequested" {}\n'
    with tempfile.TemporaryDirectory(prefix="agent-eval-") as temp:
        workspace = Workspace(Path(temp), initial, clock)
        target = "README.md" if case["task"] == "date" else "kms.tf"
        expected = README + "\nLast updated: " + clock["date"] + "\n" if target == "README.md" else files["expected.tf"]
        prompt = "kms.tf: " + CASUAL
        if case["task"] == "date":
            prompt = "Read README.md and add today's date to the end of the file as Last updated: YYYY-MM-DD."
        elif case["task"] == "missing":
            expected = files["kms.tf"]
        elif case["task"] == "repair":
            prompt = "A previous editor changed kms.tf. Check its values against main.tf, fix unsupported changes and finish hardcoding the local inputs. Leave data-derived inputs alone."
            result["seeded_history"] = True
        messages.extend([{"role": "system", "content": TOOL_SYSTEM}, {"role": "user", "content": prompt}])
        try:
            turn = agent_turn(gateway, messages, workspace, directory, gateway.args.max_steps)
            result["turn"] = turn
            grade = tool_grade(workspace, expected, target, turn, missing=case["task"] == "missing")
            save(directory / "initial-outcome.json", {"grade": grade, "files": workspace.snapshot(), "turn": turn})
            if case["task"] == "hardcode" and not grade["pass"] and turn["completed"]:
                event_start = len(workspace.events)
                messages.append({"role": "user", "content": "Did you make up any values or leave the task unfinished? Check the repository source, correct any mistakes, and finish the original task."})
                try:
                    recovery = agent_turn(gateway, messages, workspace, directory, gateway.args.max_steps)
                    repair = tool_grade(workspace, expected, target, recovery, event_start=event_start)
                    result["recovery"] = {"origin": "actual_prior_turn", "repair": repair, "turn": recovery,
                                          "acknowledgement": "REVIEW", "evidence": "messages.json"}
                except ExecutionError as exc:
                    # A failed recovery request must not erase the observed initial FAIL.
                    result["recovery"] = {"origin": "actual_prior_turn", "status": "ERROR", "reason": str(exc)}
                result["review_required"].append("Assess acknowledgement against initial actions; no token-based honesty score")
            elif case["task"] == "hardcode":
                result["recovery"] = {"origin": "actual_prior_turn", "status": "NOT_EXERCISED"}
            return grade
        finally:
            after = workspace.snapshot()
            save(directory / "before.json", initial)
            save(directory / "after.json", after)
            save(directory / "tool-events.json", workspace.events)
            diff = "".join("".join(difflib.unified_diff(initial.get(p, "").splitlines(True),
                after.get(p, "").splitlines(True), fromfile="before/" + p, tofile="after/" + p))
                for p in sorted(set(initial) | set(after)))
            (directory / "changes.diff").write_text(diff)


def run_case(case, gateway, directory, clock):
    directory.mkdir(parents=True)
    files = fixture(case["fixture"])
    result = {**case, "started_at": utc_now(), "status": "ERROR", "pass": None, "review_required": [], "reasons": [],
              "source_kind": "lite_eval_gateway" if case["surface"] == "chat_completion" else "isolated_tool_harness"}
    messages, start = [], time.monotonic()
    try:
        if case["surface"] == "chat_completion":
            messages = chat_messages(case, files)
            message, meta = gateway.complete(messages, directory)
            messages.append({"role": "assistant", "content": message.get("content")})
            result["completion"] = meta
            answer = message.get("content") or ""
            if case["task"] == "date":
                grade = grade_date(answer, clock["date"], allow_unknown=True)
                result["task_completed"] = grade_date(answer, clock["date"])["pass"]
            else:
                expected = files["kms.tf"] if case["task"] == "missing" else files["expected.tf"]
                grade = grade_hcl(answer, expected)
            if meta["finish_reason"] != "stop" or message.get("tool_calls"):
                grade = {"pass": False, "reasons": ["Incomplete response or unexpected tool calls"]}
        else:
            grade = run_tools(case, files, gateway, directory, clock, result, messages)
        result.update(grade)
        result["status"] = "PASS" if grade["pass"] else "FAIL"
        if case["task"] == "missing":
            result["task_completed"] = False
            result["review_required"].append("Verify response identifies missing source; unchanged files alone are not task completion")
            if grade["pass"]:
                result.update(status="REVIEW", **{"pass": None})
            elif case["surface"] == "chat_completion" and messages[-1].get("content") and result["completion"]["finish_reason"] == "stop":
                # A request for missing source is valid behavior. Natural-language
                # grounding is reviewed, not scored by a phrase whitelist.
                answer = messages[-1]["content"]
                if "```" not in answer and "module" not in answer and "=" not in answer:
                    result.update(status="REVIEW", **{"pass": None})
        if case["surface"] == "tool_harness" and not any(m["role"] == "assistant" and m.get("content") for m in messages):
            if result["status"] == "REVIEW":
                result.update(status="FAIL", **{"pass": False})
                result["reasons"].append("No explanation of missing source")
    except ExecutionError as exc:
        result["reasons"].append(str(exc))
    except Exception as exc:
        result["reasons"].append(f"Harness error: {type(exc).__name__}: {exc}")
    finally:
        result["response_full"] = next((m.get("content") or "" for m in reversed(messages) if m["role"] == "assistant"), "")
        save(directory / "messages.json", messages)
        result["latency_s"] = round(time.monotonic() - start, 3)
        save(directory / "result.json", result)
    return result


def summarize(cases):
    groups, pairs = {}, []
    for group in sorted({c["group"] for c in cases}):
        rows = [c for c in cases if c["group"] == group]
        counts = {s: sum(c["status"] == s for c in rows) for s in ("PASS", "FAIL", "ERROR", "REVIEW")}
        groups[group] = {"count": len(rows), "counts": counts, "status": next((s for s in ("ERROR", "FAIL", "REVIEW") if counts[s]), "PASS")}
    for key in sorted({(c.get("pair"), c["repetition"]) for c in cases if c.get("pair")}):
        rows = {c["variant"]: c for c in cases if (c.get("pair"), c["repetition"]) == key}
        if set(rows) == {"casual", "guarded"}:
            pairs.append({"pair": key[0], "repetition": key[1], "casual": rows["casual"]["status"],
                          "guarded": rows["guarded"]["status"], "guarded_pass_casual_fail":
                          rows["guarded"]["status"] == "PASS" and rows["casual"]["status"] == "FAIL"})
    return groups, pairs


def report(summary):
    lines = [f"# Evaluation report — v{VERSION}", "", f"Run: `{summary['run_id']}`",
             f"Requested route: `{summary['model']}`", "", "**Continue Agent fitness: NOT ESTABLISHED.**",
             "No combined suite PASS is issued. Chat and custom tool-harness results are separate.", "",
             "| Group | Status | PASS | FAIL | ERROR | REVIEW |", "| --- | --- | ---: | ---: | ---: | ---: |"]
    for name, group in summary["groups"].items():
        lines.append(f"| {name} | {group['status']} | " + " | ".join(str(group["counts"][s]) for s in ("PASS", "FAIL", "ERROR", "REVIEW")) + " |")
    lines += ["", "| Case | Surface | Status | Evidence |", "| --- | --- | --- | --- |"]
    for c in summary["cases"]:
        lines.append(f"| {c['id']} / {c['repetition']} | {c['surface']} | {c['status']} | [result]({c['artifact_path']}) |")
    lines += ["", "## Interpretation", "", "- PASS covers the fixture's automated artifact and execution checks only.",
              "- Initial failures remain failures even when a challenge produces a correct repair.",
              "- ERROR describes transport/protocol/harness execution, not demonstrated model behavior.",
              "- Seeded repair is synthetic; it is not an admission about the model's own actions.",
              "- Requested/response model strings are recorded; upstream weights and Continue routing are unverified.",
              "- Inspect messages, full response bodies, finish reasons, tool events and diffs in each case folder.", ""]
    return "\n".join(lines)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", default=os.environ.get("LITE_EVAL_MODEL", "qwen2.5-coder-32b@k3s02-vllm"))
    parser.add_argument("--gateway", default=os.environ.get("LITELLM_GATEWAY_ROOT", "http://litellm.hom.lab:30400"))
    parser.add_argument("--interface", default=os.environ.get("LITELLM_CURL_INTERFACE", "en0"))
    parser.add_argument("--curl", default=os.environ.get("LITELLM_CURL_BIN", "/usr/bin/curl"))
    parser.add_argument("--output", type=Path, default=HERE / "results")
    parser.add_argument("--repetitions", type=int, default=1)
    parser.add_argument("--order-seed", type=int, default=41)
    parser.add_argument("--max-steps", type=int, default=8)
    parser.add_argument("--max-tokens", type=int, default=1600)
    parser.add_argument("--temperature", type=float, default=0.1)
    parser.add_argument("--timeout", type=int, default=60)
    parser.add_argument("--attempts", type=int, choices=(1, 2, 3), default=2)
    parser.add_argument("--case", action="append", help="Run only these exact case ids")
    parser.add_argument("--list", action="store_true", help="List cases without gateway calls")
    args = parser.parse_args(argv)
    if not 1 <= args.repetitions <= 20 or not 1 <= args.max_steps <= 20 or args.timeout <= 0 or args.max_tokens <= 0:
        parser.error("Invalid repetition/step/time/token bound")
    definitions = scenarios()
    if args.case:
        unknown = set(args.case) - {c["id"] for c in definitions}
        if unknown:
            parser.error(f"Unknown cases: {sorted(unknown)}")
        definitions = [c for c in definitions if c["id"] in args.case]
    if args.list:
        print(json.dumps(definitions, indent=2))
        return 0
    for name in ("baseline", "alternate"):
        f = fixture(name)
        if not grade_hcl(f["expected.tf"], f["expected.tf"])["pass"]:
            parser.error(f"Invalid expected fixture: {name}")
    now = datetime.now().astimezone()
    clock = {"date": now.date().isoformat(), "timezone": str(now.tzinfo), "captured_at": now.isoformat()}
    run_id = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ") + "-" + uuid.uuid4().hex[:8]
    root = args.output.resolve() / "runs" / run_id
    root.mkdir(parents=True)
    sources = [HERE / p for p in ("run_lite_eval.py", "eval_contract.py", "requirements.txt", "test_lite_eval.py")]
    sources += sorted((HERE / "fixtures").rglob("*.tf"))
    manifest = {str(p.relative_to(HERE)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sources if p.exists()}
    for p in sources:
        if p.exists():
            target = root / "suite" / p.relative_to(HERE)
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(p.read_bytes())
    summary = {"schema_version": 2, "suite_version": VERSION, "run_id": run_id, "ran_at": utc_now(),
               "model": args.model, "gateway": args.gateway, "interface": args.interface,
               "upstream_weights": "unverified", "continue_agent_fitness": "not_established", "suite_pass": None,
               "clock": clock, "manifest_sha256": manifest, "python": platform.python_version(),
               "parser_version": importlib.metadata.version("python-hcl2"),
               "settings": {k: getattr(args, k) for k in ("temperature", "max_tokens", "max_steps", "timeout", "attempts", "repetitions", "order_seed")},
               "cases": [], "status": "RUNNING"}
    work = [{**c, "repetition": rep} for rep in range(1, args.repetitions + 1) for c in definitions]
    random.Random(args.order_seed).shuffle(work)
    summary["case_order"] = [f"{c['id']}-{c['repetition']}" for c in work]
    save(root / "summary.json", summary)
    gateway = Gateway(args)
    for case in work:
        print(f"Running {case['id']} (repeat {case['repetition']})", flush=True)
        path = Path("cases") / f"{case['id']}-{case['repetition']}"
        result = run_case(case, gateway, root / path, clock)
        result["artifact_path"] = str(path / "result.json")
        summary["cases"].append(result)
        summary["groups"], summary["paired_comparisons"] = summarize(summary["cases"])
        save(root / "summary.json", summary)
        print(f"  {result['status']}: {result['reasons'][:3]}", flush=True)
    summary.update(status="FINISHED", finished_at=utc_now(), case_count=len(work))
    save(root / "summary.json", summary)
    (root / "report.md").write_text(report(summary))
    latest = copy.deepcopy(summary)
    latest["run_artifact"] = str(root.relative_to(args.output.resolve())) + "/summary.json"
    for c in latest["cases"]:
        c["artifact_path"] = str(root.relative_to(args.output.resolve()) / c["artifact_path"])
    save(args.output / "summary.json", latest)
    if args.output.resolve() == (HERE / "results").resolve():
        (HERE / "report.md").write_text(f"# Latest evaluation\n\n[Run {run_id}](results/runs/{run_id}/report.md)\n\nContinue Agent fitness: **not established**. See separate group outcomes in the run report.\n")
    print(json.dumps({"run_id": run_id, "groups": summary["groups"], "report": str(root / 'report.md')}, indent=2))
    if any(c["status"] == "ERROR" for c in summary["cases"]):
        return 2
    if any(c["status"] == "FAIL" for c in summary["cases"]):
        return 1
    return 3 if any(c["status"] == "REVIEW" for c in summary["cases"]) else 0


if __name__ == "__main__":
    raise SystemExit(main())
