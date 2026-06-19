# Week 1 Project: Cloud GRC CI Evidence Gate

## Goal

Build one Bash script that acts like a small cloud security/compliance CI gate.

The script will read local mock evidence files, make a pipeline decision, and write reviewer-friendly artifacts.

Use only Bash and local files. Do not call real AWS, Terraform, OPA, Checkov, GitLab, or any cloud API.

The point of this week is not tool coverage. The point is safe shell behavior: validation, quoting, clear failures, preserved evidence, and correct exit codes.

## What You Are Building

Create this script yourself:

```text
projects/week_1/ci-evidence-gate.sh
```

The script must run in this shape:

```text
./ci-evidence-gate.sh <evidence_dir> <artifact_dir> <environment>
```

Example:

```text
./ci-evidence-gate.sh sample-evidence artifacts/dev dev
```

Allowed environments:

```text
dev
staging
prod
```

The script reads evidence from `<evidence_dir>`, writes output files into `<artifact_dir>`, and uses `<environment>` to decide whether findings pass, fail, or require manual approval.

## Required CI Environment Variables

Before the script does real work, it must require these environment variables:

```text
AWS_REGION
CI_COMMIT_SHA
CI_PIPELINE_ID
```

The values can be fake. This is CI validation practice.

Example setup:

```text
export AWS_REGION=us-east-1
export CI_COMMIT_SHA=abc1234
export CI_PIPELINE_ID=1001
```

## Evidence Folder Contract

Your evidence directory must contain these six files:

```text
identity.txt
terraform-plan.txt
opa-findings.txt
checkov-findings.txt
secrets-scan.txt
metadata.env
```

Every required file must:

- exist
- be a regular file
- be readable
- be non-empty

At least one test path should contain a space, such as:

```text
sample evidence/
```

This proves your quoting works.

## Suggested Mock Evidence

Use simple text that Bash can read.

`identity.txt`:

```text
account_id=111122223333
principal=ci-week1-role
region=us-east-1
```

`terraform-plan.txt`:

```text
CREATE aws_s3_bucket.logs
CHANGE aws_security_group.web
DELETE aws_iam_role.old_ci_role
```

`opa-findings.txt` and `checkov-findings.txt`:

```text
LOW:S3 bucket missing lifecycle rule
MEDIUM:S3 bucket missing object lock
HIGH:Security group allows 0.0.0.0/0 to port 22
```

`secrets-scan.txt`:

```text
PASS:no secrets found
```

or:

```text
HIGH:possible access key found
```

`metadata.env`:

```text
owner=platform-security
service=cloud-grc-workbench
ticket=GRC-001
```

## Output Artifact Contract

Your script must create the artifact directory if it does not exist.

It must write at least these four files:

```text
summary.txt
failed-controls.txt
pipeline.log
metadata-normalized.txt
```

`summary.txt` contains the final decision:

```text
PASS
FAIL
MANUAL_APPROVAL
```

`failed-controls.txt` lists findings that caused failure or manual approval. It may also record lower findings that were allowed.

`pipeline.log` records what the script checked and what decision it made.

`metadata-normalized.txt` includes metadata from `metadata.env` plus:

```text
AWS_REGION
CI_COMMIT_SHA
CI_PIPELINE_ID
environment
```

## Decision Rules

Use this table as the source of truth.

| Situation                                               | Decision        | Exit Code |
| ------------------------------------------------------- | --------------- | --------- |
| Missing arguments                                       | FAIL            | 1         |
| Missing required environment variable                   | FAIL            | 1         |
| Evidence directory missing or unreadable                | FAIL            | 1         |
| Artifact directory cannot be created or written         | FAIL            | 1         |
| Required evidence file missing, unreadable, or empty    | FAIL            | 1         |
| Environment is not `dev`, `staging`, or `prod`          | FAIL            | 1         |
| Any `HIGH` finding in OPA, Checkov, or secrets evidence | FAIL            | 1         |
| Any `MEDIUM` finding in `prod` and no `HIGH` findings   | MANUAL_APPROVAL | 0         |
| Only `LOW` or `MEDIUM` findings in `dev` or `staging`   | PASS            | 0         |
| No findings                                             | PASS            | 0         |

Manual approval exits `0` because the script successfully handed work to a human approval step. It is not a script failure.

Use a `case` statement for environment-specific behavior.

## Recommended Build Sequence

Follow this order. Do not try to build the whole script in one pass.

### Step 1: Create The Script Shell

Add:

- Bash shebang
- `set -euo pipefail`
- named variables for the three arguments
- basic logging idea
- an error function that prints to stderr and exits `1`

Do not process findings yet.

### Step 2: Validate Inputs Before Work

Validate in this order:

1. argument count
2. `AWS_REGION`
3. `CI_COMMIT_SHA`
4. `CI_PIPELINE_ID`
5. environment value
6. evidence directory
7. artifact directory
8. required evidence files

Use safe environment expansion such as `${AWS_REGION:-}` when checking variables under `set -u`.

### Step 3: Create Artifacts

Make sure these files are created or overwritten for each run:

```text
summary.txt
failed-controls.txt
pipeline.log
metadata-normalized.txt
```

Log enough detail to prove:

- which evidence directory was used
- which artifact directory was used
- which environment was selected
- which files were checked

### Step 4: Normalize Metadata

Read `metadata.env` and write a normalized artifact that includes:

- owner
- service
- ticket
- AWS region
- commit SHA
- pipeline ID
- environment

Use this step to practice command substitution, quoting, and simple validation.

### Step 5: Scan Findings

Read these files:

```text
opa-findings.txt
checkov-findings.txt
secrets-scan.txt
```

Detect:

- `HIGH`
- `MEDIUM`
- `LOW`

Record meaningful findings into an array or into `failed-controls.txt`.

Use at least one `while read -r` loop.

### Step 6: Decide Pass, Fail, Or Manual Approval

Apply the decision table.

High severity always fails.

Medium severity in prod becomes manual approval if there is no high severity finding.

Low and medium findings in dev or staging can pass, but they must be recorded.

### Step 7: Add Cleanup Practice

Create a temporary directory with `mktemp -d`.

Register cleanup with `trap`.

Prove cleanup runs on both success and failure. Record this in `pipeline.log` or `debuglog.md`.

### Step 8: Add Pipeline Failure Practice

Use at least one pipeline where `pipefail` matters.

Use `tee` at least once so output is visible and saved.

Inspect `PIPESTATUS` at least once and record what you learned.

Use `$?` at least once in a deliberate place where you explain which command you checked.

## Bash Concepts You Must Use

Your script must intentionally include all of these:

- Bash shebang
- `set -euo pipefail`
- named variables for arguments
- quoted variables for paths and user-controlled values
- command substitution with `$(...)`
- `if`, `elif`, and `else`
- `[[ ]]` tests
- file checks: `-d`, `-f`, `-r`, `-w`, `-x`, `-s`
- string checks: `-z`, `-n`
- at least one integer comparison
- at least one regex validation using `=~`
- a `case` statement for `dev`, `staging`, and `prod`
- a `for` loop over required files
- a `while read -r` loop over at least one evidence file
- `continue` to skip blank lines or comments
- `break` when a fail-fast condition is found
- functions for repeated behavior
- `local` variables inside functions
- an error function that writes to stderr and exits non-zero
- a cleanup function used by `trap`
- an array for required files
- an array for findings or failed controls
- `"${array[@]}"` when looping over arrays
- `"${#array[@]}"` to count array items
- redirects into artifact files
- appends to `pipeline.log`
- `tee`
- `PIPESTATUS`
- `$?`

## Manual Test Scenarios

Run these after the script is built.

1. Missing all arguments.
2. Missing only `AWS_REGION`.
3. Missing only `CI_COMMIT_SHA`.
4. Missing only `CI_PIPELINE_ID`.
5. Evidence directory does not exist.
6. Artifact path points somewhere unwritable or invalid.
7. Required evidence file is missing.
8. Required evidence file exists but is empty.
9. Environment is invalid, such as `qa`.
10. Clean `dev` evidence passes.
11. Clean `prod` evidence passes.
12. `LOW` finding in `dev` records evidence and passes.
13. `MEDIUM` finding in `staging` records evidence and passes.
14. `MEDIUM` finding in `prod` produces `MANUAL_APPROVAL`.
15. `HIGH` OPA finding fails.
16. `HIGH` Checkov finding fails.
17. `HIGH` secrets finding fails.
18. Evidence directory or file path with spaces works correctly.
19. A pipeline command failure is visible in the log.
20. Temporary files are cleaned up after both success and failure.

For each test, record:

```text
command run
expected exit code
actual exit code
important stdout/stderr
artifact files created
what you learned
```

## Evidence File To Save

Create this file yourself:

```text
projects/week_1/evidence.md
```

Include:

- final script path
- mock evidence folder path
- artifact folder path
- at least five command examples with exit codes
- one success artifact summary
- one failure artifact summary
- one manual approval artifact summary
- short explanation of how `set -euo pipefail` changed behavior
- short explanation of one bug caused by missing quotes or bad validation

## Debug Log To Save

Create this file yourself:

```text
projects/week_1/debuglog.md
```

Record real mistakes. Do not hide them.

For every bug, use this format:

```text
symptom:
hypothesis:
test:
fix:
concept learned:
```

Good bugs for this week:

- a variable split because it was not quoted
- `grep | wc -l` behaved differently with `pipefail`
- `set -u` caught a missing variable
- a function leaked a variable because `local` was missing
- a temp directory was not cleaned up until `trap` was added
- the script exited `0` even though a check failed

## Reflection Questions

Answer these after the script works:

1. Which validation happens before any real work starts?
2. Which failure cases return non-zero exit codes?
3. What output proves the expected evidence files were processed?
4. What output proves invalid input failed clearly?
5. Why does CI need stderr separate from stdout?
6. What would go wrong if a `HIGH` finding was printed but the script exited `0`?
7. Why can an unsafe pipeline hide failures without `pipefail`?
8. Where did quoting matter most in your script?
9. What temporary data did you create, and how did you clean it up?
10. What part of this script would later become useful in a real GitLab cloud security pipeline?

## Done Checklist

You are done when:

- `ci-evidence-gate.sh` exists
- `ci-evidence-gate.sh` is executable
- valid clean input passes
- invalid input fails clearly
- high severity evidence blocks the pipeline
- medium severity evidence in prod creates `MANUAL_APPROVAL`
- artifact files are created and readable
- `evidence.md` proves your tests happened
- `debuglog.md` proves you debugged manually
- you can explain every Bash concept used without reading the script line by line

## AI Boundary Reminder

Do not ask AI to write the script.

Allowed AI help:

- explain a Bash concept
- ask debugging questions
- review your completed project against this task
- give a checklist for investigating an error
- rewrite confusing assignment wording

Not allowed:

- writing the script for you
- fixing your script line by line
- giving you a completed implementation
