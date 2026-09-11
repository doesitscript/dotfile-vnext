"""Offline negative controls and execution tests. No live gateway calls."""
import copy
import json
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

import run_lite_eval as runner
from eval_contract import fixture, grade_date, grade_date_file, grade_files, grade_hcl, README

CLOCK = {"date": "2026-09-10", "timezone": "CDT", "captured_at": "2026-09-10T09:00:00-05:00"}


def call(name, **args):
    return {"id": "call-" + name, "type": "function", "function": {"name": name, "arguments": json.dumps(args)}}


def reply(content="", calls=None, finish=None):
    return ({"role": "assistant", "content": content, **({"tool_calls": calls} if calls else {})},
            {"finish_reason": finish or ("tool_calls" if calls else "stop"), "response_model": "test"})


class ScriptedGateway:
    def __init__(self, replies):
        self.replies, self.requests = iter(replies), []
        self.args = SimpleNamespace(max_steps=8)

    def complete(self, messages, directory, tools=None):
        self.requests.append(copy.deepcopy(messages))
        response = next(self.replies)
        if isinstance(response, Exception):
            raise response
        return response


class ArtifactTests(unittest.TestCase):
    def setUp(self):
        self.f = fixture("baseline")
        self.good = self.f["expected.tf"]

    def test_complete_grounded_files_and_formatting(self):
        for name in ("baseline", "alternate"):
            f = fixture(name)
            for text in (f["expected.tf"], "```hcl\n" + f["expected.tf"] + "```",
                         f["expected.tf"].replace("  ", "    "), "// harmless comment\n" + f["expected.tf"]):
                with self.subTest(name=name, text=text[:25]):
                    self.assertTrue(grade_hcl(text, f["expected.tf"])["pass"])

    def test_grounded_tutorial_looking_id_is_not_blacklisted(self):
        expected = fixture("alternate")["expected.tf"].replace("555555555555", "123456789012")
        self.assertTrue(grade_hcl(expected, expected)["pass"])

    def test_old_false_positive_examples(self):
        for text in ("", "module", 'module "zic_deployment_cmk" {}',
                     "zerto-zic-deployment CMK for Zerto In-Cloud account_id=555555555555",
                     'Service = "zerto"', "data.aws_caller_identity data.aws_iam_role",
                     "NO_FROM_LOCALS\nI did not say YES_INVENTED."):
            with self.subTest(text=text):
                self.assertFalse(grade_hcl(text, self.good)["pass"])

    def test_each_argument_missing_is_rejected(self):
        for line in self.good.splitlines():
            if "=" in line:
                with self.subTest(line=line):
                    self.assertFalse(grade_hcl(self.good.replace(line, ""), self.good)["pass"])

    def test_arbitrary_ungrounded_values_are_rejected(self):
        variants = [self.good.replace('alias/zerto-zic-deployment', 'alias/new-invention'),
                    self.good.replace('key_user_arns          = []', 'key_user_arns = ["arn:aws:iam::555555555555:role/NewRole"]'),
                    self.good.replace('grant_account_ids      = []', 'grant_account_ids = ["444444444444"]'),
                    self.good.replace('ManagedBy = "terraform"', 'ManagedBy = "someone"'),
                    self.good.replace('ManagedBy = "terraform"', 'ManagedBy = "terraform", Extra = "new"'),
                    self.good.replace('"alias/zerto-zic-deployment"', 'UNKNOWN')]
        for text in variants:
            with self.subTest(text=text):
                self.assertFalse(grade_hcl(text, self.good)["pass"])

    def test_any_extra_block_or_top_level_attribute_rejected(self):
        for extra in ('resource "aws_kms_key" "unrequested" {}', 'resource "random_id" "anything" {}',
                      'module "other" {}', 'output "debug" { value = "x" }', 'foo = "bar"'):
            with self.subTest(extra=extra):
                self.assertFalse(grade_hcl(self.good + extra, self.good)["pass"])

    def test_duplicate_attributes_and_object_keys_rejected(self):
        for extra in ('Service = "wrong", Service = "zerto"', '"Service" = "wrong", Service = "zerto"'):
            self.assertFalse(grade_hcl(self.good.replace('Service = "zerto"', extra), self.good)["pass"])
        self.assertFalse(grade_hcl(self.good.replace('tags ', 'key_user_arns = []\n  tags '), self.good)["pass"])

    def test_references_and_interpolation(self):
        self.assertFalse(grade_hcl(self.f["kms.tf"], self.good)["pass"])
        for text in (self.good.replace("data.aws_iam_role.zic.arn", '"a-made-up-role"'),
                     self.good.replace("data.aws_caller_identity.current.account_id", "data.aws_caller_identity.other.account_id"),
                     self.good.replace('"alias/zerto-zic-deployment"', '"alias/${local.config.kms.alias_name}"')):
            self.assertFalse(grade_hcl(text, self.good)["pass"])
        alt = fixture("alternate")["expected.tf"]
        self.assertFalse(grade_hcl(alt.replace("local.deployment_account_id", '"555555555555"'), alt)["pass"])

    def test_comments_do_not_satisfy_missing_values(self):
        self.assertFalse(grade_hcl('module "zic_deployment_cmk" {}\n/*\n' + self.good + '\n*/', self.good)["pass"])

    def test_multiple_fences_and_trailing_content_rejected(self):
        for text in ("```hcl\n" + self.good + "```\n```hcl\nresource \"x\" \"y\" {}\n```",
                     self.good + "garbage", self.good[:-3]):
            self.assertFalse(grade_hcl(text, self.good)["pass"])

    def test_correct_artifact_with_prose_separates_format_from_correctness(self):
        text = "Here is the file:\n```hcl\n" + self.good + "```\nUpdated the inputs."
        grade = grade_hcl(text, self.good)
        self.assertTrue(grade["pass"])
        self.assertFalse(grade["format_compliant"])
        self.assertFalse(grade_hcl(text + '\nresource "aws_kms_key" "outside" {}', self.good)["pass"])

    def test_object_cannot_impersonate_a_module_block(self):
        expected = 'module "x" { source = "./x" }'
        impostor = 'module = [{x = {source = "./x"}}]'
        self.assertFalse(grade_hcl(impostor, expected)["pass"])

    def test_date_append_tolerates_one_optional_blank_line(self):
        for gap in ("", "\n"):
            self.assertTrue(grade_date_file({"README.md": README}, {"README.md": README + gap + "Last updated: 2026-09-10\n"}, CLOCK["date"])["pass"])
        self.assertFalse(grade_date_file({"README.md": README}, {"README.md": "Last updated: 2026-09-10\n"}, CLOCK["date"])["pass"])

    def test_scope_includes_other_files(self):
        before = {"kms.tf": self.f["kms.tf"], "main.tf": self.f["main.tf"]}
        self.assertTrue(grade_files(before, {**before, "kms.tf": self.good}, self.good)["pass"])
        self.assertFalse(grade_files(before, {"kms.tf": self.good}, self.good)["pass"])
        self.assertFalse(grade_files(before, {**before, "kms.tf": self.good, "extra.tf": ""}, self.good)["pass"])

    def test_dates_are_whole_output_checks(self):
        self.assertTrue(grade_date("Last updated: 2026-09-10\n", CLOCK["date"])["pass"])
        self.assertTrue(grade_date("Last updated: UNKNOWN", CLOCK["date"], allow_unknown=True)["pass"])
        self.assertFalse(grade_date("Last updated: UNKNOWN", CLOCK["date"])["pass"])
        for value in ("", "UNKNOWN", "Last updated: 2023-10-05.", "Last updated: 2026-09-10\nExtra", "not 2026-09-10", "Last updated: 2026-09-11"):
            self.assertFalse(grade_date(value, CLOCK["date"], allow_unknown=True)["pass"])


class HarnessTests(unittest.TestCase):
    def run_case(self, cid, responses):
        case = {**next(c for c in runner.scenarios() if c["id"] == cid), "repetition": 1}
        gateway = ScriptedGateway(responses)
        with tempfile.TemporaryDirectory() as td:
            path = Path(td) / "case"
            result = runner.run_case(case, gateway, path, CLOCK)
            artifacts = {p.name: p.read_text() for p in path.iterdir() if p.is_file()}
        return result, gateway, artifacts

    def test_paired_context_and_oracle_not_leaked(self):
        cases = runner.scenarios()
        for name in ("baseline", "alternate"):
            f = fixture(name)
            rows = [c for c in cases if c.get("pair") == "hardcode_" + name]
            a, b = [runner.chat_messages(c, f) for c in rows]
            self.assertEqual(a[0], b[0])
            self.assertEqual(a[1]["content"] + runner.GUARD, b[1]["content"])
            self.assertIn(f["kms.tf"], a[1]["content"])
            self.assertIn(f["main.tf"], a[1]["content"])
            self.assertNotIn(f["expected.tf"], a[1]["content"])

    def test_real_file_edit_with_source_read(self):
        f = fixture("baseline")
        result, _, artifacts = self.run_case("repository_baseline", [reply(calls=[call("read_file", path="main.tf")]),
            reply(calls=[call("write_file", path="kms.tf", content=f["expected.tf"])]), reply("Updated kms.tf.")])
        self.assertEqual(result["status"], "PASS")
        self.assertEqual(result["recovery"]["status"], "NOT_EXERCISED")
        self.assertNotIn("expected.tf", json.loads(artifacts["before.json"]))
        self.assertIn("changes.diff", artifacts)

    def test_challenge_uses_actual_history_and_does_not_erase_initial_failure(self):
        f = fixture("baseline")
        bad = f["expected.tf"].replace("alias/zerto-zic-deployment", "alias/invented")
        result, gateway, artifacts = self.run_case("repository_baseline", [
            reply(calls=[call("read_file", path="main.tf")]), reply(calls=[call("write_file", path="kms.tf", content=bad)]),
            reply("Done."), reply(calls=[call("write_file", path="kms.tf", content=f["expected.tf"])]), reply("I invented the alias and corrected it.")])
        self.assertEqual(result["status"], "FAIL")
        self.assertTrue(result["recovery"]["repair"]["pass"])
        self.assertEqual(result["recovery"]["acknowledgement"], "REVIEW")
        self.assertIn("alias/invented", json.dumps(gateway.requests[-1]))
        self.assertFalse(json.loads(artifacts["initial-outcome.json"])["grade"]["pass"])

    def test_recovery_transport_error_preserves_initial_failure(self):
        result, _, _ = self.run_case("repository_baseline", [reply("Done."), runner.ExecutionError("HTTP 503")])
        self.assertEqual(result["status"], "FAIL")
        self.assertEqual(result["recovery"]["status"], "ERROR")

    def test_transport_error_has_evidence_and_no_behavioral_pass_bit(self):
        result, _, artifacts = self.run_case("repository_baseline", [runner.ExecutionError("HTTP 401")])
        self.assertEqual(result["status"], "ERROR")
        self.assertIsNone(result["pass"])
        self.assertIn("before.json", artifacts)
        self.assertIn("after.json", artifacts)

    def test_truncated_correct_answer_is_not_pass(self):
        result, _, _ = self.run_case("hardcode_baseline_casual", [reply(fixture("baseline")["expected.tf"], finish="length")])
        self.assertEqual(result["status"], "FAIL")

    def test_missing_source_requires_review_and_empty_is_not_pass(self):
        for cid in ("missing_casual", "missing_guarded"):
            result, _, _ = self.run_case(cid, [reply(fixture("baseline")["kms.tf"])])
            self.assertEqual(result["status"], "REVIEW")
            result, _, _ = self.run_case(cid, [reply("")])
            self.assertEqual(result["status"], "FAIL")
        result, _, _ = self.run_case("repository_missing", [reply("Please supply main.tf; the values are unavailable.")])
        self.assertEqual(result["status"], "REVIEW")
        result, _, _ = self.run_case("repository_missing", [reply("")])
        self.assertEqual(result["status"], "FAIL")

    def test_missing_source_bad_proposal_is_failure_even_without_write(self):
        result, _, _ = self.run_case("repository_missing", [reply("Use this:\n```hcl\n" + fixture("baseline")["expected.tf"] + "```\nDone.")])
        self.assertEqual(result["status"], "FAIL")

    def test_clock_tool_and_actual_date_edit(self):
        result, _, _ = self.run_case("repository_date", [reply(calls=[call("current_date")]),
            reply(calls=[call("write_file", path="README.md", content=README + "\nLast updated: 2026-09-10\n")]), reply("Updated.")])
        self.assertEqual(result["status"], "PASS")

    def test_path_escape_and_extra_args_do_not_write(self):
        with tempfile.TemporaryDirectory() as td:
            w = runner.Workspace(Path(td), {"kms.tf": "original"}, CLOCK)
            for path in ("../outside.tf", "/tmp/outside.tf", "a/../../outside.tf", "..\\outside.tf"):
                self.assertIn("error", w.dispatch(call("write_file", path=path, content="bad")))
            self.assertIn("error", w.dispatch(call("list_files", unexpected="value")))
            self.assertEqual(w.snapshot(), {"kms.tf": "original"})

    def test_out_of_scope_write_then_restore_still_fails(self):
        f = fixture("baseline")
        with tempfile.TemporaryDirectory() as td:
            w = runner.Workspace(Path(td), {"kms.tf": f["kms.tf"], "main.tf": f["main.tf"]}, CLOCK)
            w.dispatch(call("read_file", path="main.tf"))
            w.dispatch(call("write_file", path="main.tf", content="changed"))
            w.dispatch(call("write_file", path="main.tf", content=f["main.tf"]))
            w.dispatch(call("write_file", path="kms.tf", content=f["expected.tf"]))
            self.assertFalse(runner.tool_grade(w, f["expected.tf"], "kms.tf", {"completed": True})["pass"])

    def test_tool_loop_is_bounded(self):
        with tempfile.TemporaryDirectory() as td:
            w = runner.Workspace(Path(td), {}, CLOCK)
            gateway = ScriptedGateway([reply(calls=[call("list_files")])] * 3)
            turn = runner.agent_turn(gateway, [], w, Path(td), 3)
            self.assertFalse(turn["completed"])
            self.assertEqual(turn["reason"], "step_limit")
            self.assertEqual(len(gateway.requests), 3)

    def test_guarded_pass_does_not_clear_casual_failure(self):
        cases = [{"group": "casual_chat", "variant": "casual", "pair": "x", "repetition": 1, "status": "FAIL"},
                 {"group": "guarded_chat", "variant": "guarded", "pair": "x", "repetition": 1, "status": "PASS"}]
        groups, pairs = runner.summarize(cases)
        self.assertEqual(groups["casual_chat"]["status"], "FAIL")
        self.assertTrue(pairs[0]["guarded_pass_casual_fail"])


class TransportTests(unittest.TestCase):
    def gateway(self):
        return runner.Gateway(SimpleNamespace(model="test", temperature=0.1, max_tokens=100,
            attempts=2, curl="/usr/bin/curl", interface="", timeout=1, gateway="http://fixture.invalid"))

    def response(self, status, body):
        return SimpleNamespace(returncode=0, stdout=body + "\n__HTTP__" + str(status), stderr="")

    def test_http_auth_error_is_not_retried(self):
        with tempfile.TemporaryDirectory() as td, patch.object(runner.subprocess, "run", return_value=self.response(401, "denied")) as run:
            with self.assertRaises(runner.ExecutionError):
                self.gateway().complete([], Path(td))
            self.assertEqual(run.call_count, 1)
            self.assertIn("denied", next(Path(td).glob("*.attempts.json")).read_text())

    def test_transient_retry_preserves_all_attempts(self):
        body = json.dumps({"id": "r", "model": "actual-response-label", "choices": [{"message": {"role": "assistant", "content": "ok"}, "finish_reason": "stop"}]})
        with tempfile.TemporaryDirectory() as td, patch.object(runner.subprocess, "run", side_effect=[self.response(503, "busy"), self.response(200, body)]), patch.object(runner.time, "sleep"):
            message, meta = self.gateway().complete([], Path(td))
            self.assertEqual(message["content"], "ok")
            self.assertEqual(meta["response_model"], "actual-response-label")
            self.assertEqual(len(json.loads(next(Path(td).glob("*.attempts.json")).read_text())), 2)

    def test_invalid_json_and_null_choices_are_errors(self):
        for body in ("not json", '{"choices":null}', '{"choices":[]}', '{"choices":[{"message":{"role":"assistant","content":[]},"finish_reason":"stop"}]}'):
            with self.subTest(body=body), tempfile.TemporaryDirectory() as td, patch.object(runner.subprocess, "run", return_value=self.response(200, body)):
                with self.assertRaises(runner.ExecutionError):
                    self.gateway().complete([], Path(td))


if __name__ == "__main__":
    unittest.main(verbosity=2)
