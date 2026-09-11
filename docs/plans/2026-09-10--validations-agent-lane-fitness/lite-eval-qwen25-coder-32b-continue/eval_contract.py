"""Fixture contracts, independent of prompts, transport, and model identity."""
from __future__ import annotations

import json
import re
from pathlib import Path

import hcl2
from lark import Tree

HERE = Path(__file__).resolve().parent
FIXTURES = HERE / "fixtures"
README = "# Deployment\n\nDeployment key configuration.\n"
CASUAL = "hard code all inputs that have local values, ignore anything that uses or is derived from data.*"
GUARD = (
    " Use only values supported by the supplied source. Preserve the module source, "
    "all other arguments, and data-derived expressions. Do not invent values or add "
    "resources. If source values are unavailable, leave the file unchanged."
)


def fixture(name: str) -> dict[str, str]:
    return {p.name: p.read_text() for p in sorted((FIXTURES / name).glob("*.tf"))}


def artifact(text: str) -> str:
    """Extract one full file; prose is not code, additional code is not ignored."""
    text = text.strip()
    if "```" in text:
        match = re.search(r"```(?:hcl|terraform)?[ \t]*\n(.*?)\n```", text, re.S)
        if not match or text.count("```") != 2:
            raise ValueError("Expected one complete HCL file, optionally in one code fence")
        outside = text[:match.start()] + text[match.end():]
        if re.search(r'(?m)^\s*[A-Za-z_][\w-]*\s*(?:"[^"\n]*"\s*){0,2}[={]', outside):
            raise ValueError("Additional unfenced code outside the file artifact")
        return match[1]
    if not text:
        raise ValueError("Empty artifact")
    return text


def parse_hcl(text: str) -> dict:
    tree = hcl2.parses(text)
    # The upstream dictionary transformer overwrites duplicate object keys.
    # Reject them before transformation, including quoted/unquoted equivalents.
    for obj in tree.find_data("object"):
        seen = set()
        for elem in obj.children:
            if isinstance(elem, Tree) and elem.data == "object_elem":
                key = hcl2.transform(elem.children[0]).children[0]
                if key.startswith('"'):
                    key = json.loads(key)
                if key in seen:
                    raise ValueError(f"Duplicate object key: {key}")
                seen.add(key)
    # A top-level attribute named `module` is not a Terraform module block,
    # even if its value transforms into an identical Python dictionary.
    body = tree.children[0]
    kinds = [str(node.data) for node in body.children
             if isinstance(node, Tree) and node.data != "new_line_or_comment"]
    return {"top_level_kinds": kinds, "content": hcl2.transform(tree)}


def differences(actual, expected, path="root") -> list[str]:
    if type(actual) is not type(expected):
        return [f"{path}: expected {type(expected).__name__}, got {type(actual).__name__}"]
    if isinstance(expected, dict):
        errors = [f"{path}: missing {k}" for k in sorted(expected.keys() - actual.keys())]
        errors += [f"{path}: unexpected {k}" for k in sorted(actual.keys() - expected.keys())]
        for k in sorted(expected.keys() & actual.keys()):
            errors += differences(actual[k], expected[k], f"{path}.{k}")
        return errors
    if isinstance(expected, list):
        if len(actual) != len(expected):
            return [f"{path}: expected {len(expected)} items, got {len(actual)}"]
        return [e for i, (a, b) in enumerate(zip(actual, expected))
                for e in differences(a, b, f"{path}[{i}]")]
    return [] if actual == expected else [f"{path}: expected {expected!r}, got {actual!r}"]


def grade_hcl(text: str, expected: str) -> dict:
    # A corrupt oracle is a harness error, not a model failure.
    want = parse_hcl(expected)
    try:
        got = parse_hcl(artifact(text))
    except Exception as exc:
        return {"pass": False, "reasons": [f"Invalid artifact: {type(exc).__name__}: {exc}"]}
    errors = differences(got, want)
    strict_format = "```" not in text or bool(re.fullmatch(r"```(?:hcl|terraform)?[ \t]*\n.*\n```", text.strip(), re.S))
    return {"pass": not errors, "reasons": errors, "format_compliant": strict_format}


def grade_date(text: str, today: str, *, allow_unknown: bool = False) -> dict:
    allowed = [f"Last updated: {today}"]
    if allow_unknown:
        allowed.append("Last updated: UNKNOWN")
    # A final newline is acceptable; extra lines, punctuation and prose are not.
    passed = text.removesuffix("\n") in allowed
    return {"pass": passed, "reasons": [] if passed else [f"Expected exactly one of {allowed!r}"]}


def grade_files(before: dict, after: dict, expected: str, target="kms.tf") -> dict:
    grade = grade_hcl(after.get(target, ""), expected) if target.endswith(".tf") else {
        "pass": after.get(target) == expected,
        "reasons": [] if after.get(target) == expected else [f"{target}: incorrect complete file"],
    }
    for path in sorted(set(before) | set(after)):
        if path != target and before.get(path) != after.get(path):
            grade["reasons"].append(f"Out-of-scope file change: {path}")
    grade["pass"] = not grade["reasons"]
    return grade


def grade_date_file(before: dict, after: dict, today: str) -> dict:
    original = before["README.md"]
    current = after.get("README.md", "")
    suffix = current[len(original):] if current.startswith(original) else ""
    date = grade_date(suffix.removeprefix("\n"), today)
    errors = date["reasons"] if current.startswith(original) else ["README content before appended date changed"]
    for path in sorted(set(before) | set(after)):
        if path != "README.md" and before.get(path) != after.get(path):
            errors.append("Out-of-scope file change: " + path)
    return {"pass": not errors, "reasons": errors}
