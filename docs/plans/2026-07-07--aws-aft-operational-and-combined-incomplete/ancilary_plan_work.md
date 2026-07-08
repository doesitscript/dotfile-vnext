# Ancillary Plan Work

## Purpose

This note captures implementation-support work recovered from clipped conversation output that helped finish the AWS AFT operational/combined pack effort but is not fully preserved in the main plan packet.

Primary clipped-chat anchor:

- Conversation fragment beginning with: `I’m at the file-write stage now. This pass will create the governed packet and ...`
- Follow-on troubleshooting fragment beginning with: `The pasted failure was masking the real script errors.`

Reference artifact consulted:

- `/Users/joshc/.codex/attachments/402c2a9a-8437-483c-b12d-b0d69136fd2b/pasted-text.txt`

## Review Of The Local Plan File

Local plan reviewed:

- [README.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-07-07--aws-aft-operational-and-combined-incomplete/README.md)

### Found In The Local Plan File

- The plan packet does record the governed packet creation, sibling output root correction, Context7 gate, required file outputs, and the final verification receipt.
- The plan packet now records retention of the regeneration helper at `build_aft_packs.py`.
- The verification receipt records that malformed-source handling was explicit and that no local image artifacts were created.

### Not Fully Found In The Local Plan File

- The plan file does not preserve the concrete debugging sequence that unblocked the build helper after the first file-write attempt failed.
- The plan file does not explicitly record that the login-shell wrapper message was misleading and that the real failure surfaced only when the helper was run outside that wrapper path.
- The plan file does not spell out the two concrete script defects recovered during troubleshooting:
  - missing `kind` on comment-derived page specs, causing `KeyError: 'kind'`
  - literal `\\n` text being written instead of real newlines, causing invalid generated JSON
- The plan file does not preserve the intermediate validation counts reported in the conversation:
  - `VERIFY_OK`
  - `operational_files=13`
  - `combined_files=11`
  - `page_index_entries=12`
  - `section_index_entries=8`
- The plan file does not separately document the later best-effort improvement pass on `draft-aft-lambda-vulnerability-remediation.md`, where the malformed OneNote table extraction was upgraded to recover the missing Overview, pre-flight, state-validation, and code-block content.

## Ancillary Implementation Work Recovered From Clipped Chat

### 1. Initial Bulk-Write Attempt Failed In A Non-Obvious Way

- The first generator run was attempted inline from the shell during the file-write stage.
- The shell wrapper later surfaced `the input device is not a TTY`, which was not the real content-generation defect.
- This meant the work had to pivot from trusting the wrapper output to directly inspecting generated artifacts and script behavior.

### 2. Temporary Helper Was Introduced To Make The Build Debuggable

- A temporary generator helper was created first as `.tmp_aft_build.py`.
- That helper existed to make the extraction and synthesis path reproducible while debugging the failed inline generation path.
- The helper was later removed once the durable plan-scoped script path was established.

### 3. Real Script Error 1: Missing `kind` On Page Specs

- Running the helper outside the login-shell wrapper exposed the first real failure:

  ```text
  KeyError: 'kind'
  ```

- Root cause:
  - the overview page spec carried `kind`
  - the comment-derived page specs did not
- Fix applied:
  - default `kind = "page"` was added during the page-spec enrichment step

### 4. Real Script Error 2: Invalid JSON From Literal `\\n`

- After the `kind` fix, validation exposed a second real failure:

  ```text
  json.decoder.JSONDecodeError: Extra data
  ```

- Root cause:
  - the helper was writing literal `\\n` text into JSON and markdown outputs instead of real newline characters
- Fix applied:
  - newline handling was corrected across generated content and JSON writes
- Result:
  - `page-index.json` and `section-index.json` became valid JSON again

### 5. Structural Verification Was Re-Run After The Fixes

- After the script repairs, a verification pass confirmed:

  ```text
  VERIFY_OK
  operational_files=13
  combined_files=11
  page_index_entries=12
  section_index_entries=8
  ```

- This validation supported the completion claims later reflected in the plan packet.

### 6. Durable Regeneration Script Was Preserved In The Packet

- After the build stabilized, the temporary helper logic was preserved in the governed packet as:
  - [build_aft_packs.py](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-07-07--aws-aft-operational-and-combined-incomplete/build_aft_packs.py)
- This preservation step is partially reflected in the README key changes, but the troubleshooting path that justified keeping the script is not.

### 7. Post-Plan Best-Effort Improvement To The Vulnerability-Remediation Page

- The original plan only required malformed content to be preserved and explicitly annotated.
- After the main build was complete, a best-effort improvement pass went further:
  - identified that the vulnerability-page parser was extracting the wrong malformed table cell
  - corrected the extraction to recover the main content body instead of a later partial fragment
  - recovered missing sections such as:
    - `Overview`
    - `Pre-flight activities`
    - `Validate AFT Terraform state`
    - `Prepare Terraform configuration`
    - `Update module source`
    - `Run Terraform plan`
    - `FAQs`
  - converted embedded shell/HCL/plan snippets into fenced code blocks
  - repaired the broken AFT GitHub reference
- This improvement is beyond the original minimal plan obligation of “preserve and annotate malformed content.”

## Why This Note Exists

The main plan README remains the right canonical artifact for scope, obligations, diagrams, and verification. This note exists so the debugging and post-plan cleanup work that materially supported completion is not lost just because the original conversation output was clipped.
