# Week 1 Project: Cloud GRC CI Evidence Gate

## Mission

Build one safe Bash script that behaves like a tiny cloud security/compliance CI gate.

Your script will inspect local mock evidence files, decide whether a pipeline should pass, fail, or require manual approval, and write a small artifact bundle that a reviewer could inspect later.

This project must use only Bash and local files. Do not call real AWS, Terraform, OPA, Checkov, GitLab, or any cloud API yet.

## Why This Matters

Cloud GRC pipelines are only useful if they fail clearly, preserve evidence, and do not hide broken checks behind successful-looking logs. In real CI, a bad Bash wrapper can accidentally pass a dangerous deployment because of unquoted variables, ignored exit codes, broken pipelines, missing environment validation, or cleanup that never runs.

This project is your first version of a safe CI wrapper.

## Artifact To Build

Create this script yourself:

```text
projects/week_1/ci-evidence-gate.sh
```

Also create a small local test evidence folder yourself, for example:

```text
projects/week_1/sample-evidence/
```

Your script must be runnable like this:

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

## Required Environment Variables

Before doing any work, your script must require these environment variables:

```text
AWS_REGION
CI_COMMIT_SHA
CI_PIPELINE_ID
```

The values can be fake. The point is to practice CI-style environment validation.

Example manual setup:

```text
export AWS_REGION=us-east-1
export CI_COMMIT_SHA=abc1234
export CI_PIPELINE_ID=1001
```

## Required Input Files

Your evidence directory must contain these files:

```text
identity.txt
terraform-plan.txt
opa-findings.txt
checkov-findings.txt
secrets-scan.txt
metadata.env
```

Each required file must exist, be readable, and be non-empty.

Use file names safely. At least one of your test files or folders should include a space in its name so you prove your quoting works.

## Suggested Mock Evidence Content

Use simple text formats that are easy to parse with Bash.

`identity.txt` can contain:

```text
account_id=111122223333
principal=ci-week1-role
region=us-east-1
```

`terraform-plan.txt` can contain lines like:

```text
CREATE aws_s3_bucket.logs
CHANGE aws_security_group.web
DELETE aws_iam_role.old_ci_role
```

`opa-findings.txt` and `checkov-findings.txt` can contain severity records:

```text
LOW:S3 bucket missing lifecycle rule
MEDIUM:S3 bucket missing object lock
HIGH:Security group allows 0.0.0.0/0 to port 22
```

`secrets-scan.txt` can contain:

```text
PASS:no secrets found
```

or:

```text
HIGH:possible access key found
```

`metadata.env` can contain:

```text
owner=platform-security
service=cloud-grc-workbench
ticket=GRC-001
```

## Output Artifacts

Your script must create the artifact directory if it does not exist.

It must write at least these files:

```text
summary.txt
failed-controls.txt
pipeline.log
metadata-normalized.txt
```

`summary.txt` should explain the final decision:

```text
PASS
FAIL
MANUAL_APPROVAL
```

`failed-controls.txt` should list findings that caused failure or approval.

`pipeline.log` should include enough detail to prove what files were checked and what decision was made.

`metadata-normalized.txt` should include normalized metadata from the input plus `AWS_REGION`, `CI_COMMIT_SHA`, `CI_PIPELINE_ID`, and the selected environment.

## Decision Rules

Implement these rules:

1. If required arguments, environment variables, directories, or files are missing, fail immediately.
2. If any required evidence file is empty, fail immediately.
3. If the environment is not `dev`, `staging`, or `prod`, fail immediately.
4. If any `HIGH` severity finding appears in OPA, Checkov, or secrets evidence, the pipeline fails.
5. If a `MEDIUM` severity finding appears in `prod`, the pipeline requires manual approval.
6. If only `LOW` or `MEDIUM` findings appear in `dev` or `staging`, the pipeline may pass but must record the findings.
7. If there are no findings, the pipeline passes.
8. If a command in a pipeline fails, that failure must not be hidden.

Use a `case` statement for environment-specific behavior.

## Required Bash Concepts

Your script must intentionally use every item below.

### Shell Execution And Exit Codes

- Start with a proper Bash shebang.
- Use `set -euo pipefail`.
- Exit `0` only when the gate passes or when manual approval is the intended successful handoff.
- Exit `1` for validation failures, missing evidence, high severity findings, or tool/check failures.
- Use `$?` at least once in a deliberate place where you explain what command you are checking.

### Variables And Quoting

- Store arguments in named variables.
- Quote variables whenever they represent paths, file names, or user-controlled values.
- Include one test path with spaces to prove your quoting is correct.
- Use command substitution with `$(...)` and quote the result when you use it.

### Conditionals

- Use `if`, `elif`, and `else`.
- Prefer `[[ ]]` for tests.
- Use file checks such as `-d`, `-f`, `-r`, `-w`, `-x`, and `-s` where appropriate.
- Use string checks with `-z` and `-n`.
- Use integer comparison for at least one count.
- Use regex validation with `=~` for at least one input or metadata value.

### Case

- Use `case` to handle `dev`, `staging`, and `prod`.
- Include a default branch that fails clearly for an unknown environment.

### Loops

- Use a `for` loop over an array of required file names.
- Use `while read -r` to read at least one evidence file line by line.
- Use `continue` to skip blank lines or comments.
- Use `break` in one loop when a fail-fast condition is detected.

### Functions

- Create small functions for repeated behavior.
- Use `local` variables inside functions.
- Include a function that prints an error to stderr and exits non-zero.
- Include a cleanup function used by `trap`.

### Arrays

- Use an array for required evidence files.
- Use an array for findings or failed controls.
- Loop through arrays with `"${array[@]}"`.
- Use `"${#array[@]}"` to count items.

### Input Validation

- Validate argument count before using `$1`, `$2`, or `$3`.
- Validate required environment variables with safe `${VAR:-}` expansion.
- Validate that the evidence directory exists and is readable.
- Validate that the artifact directory exists or can be created.
- Validate all required files before processing.

### Strict Mode, Trap, And Cleanup

- Use `set -euo pipefail`.
- Create a temporary directory with `mktemp -d`.
- Register cleanup with `trap`.
- Prove cleanup runs on both success and failure.

### Redirects, Pipes, Tee, And PIPESTATUS

- Send errors to stderr with `>&2`.
- Redirect normal output into artifact files.
- Append command output to `pipeline.log`.
- Use `tee` at least once so output is visible and saved.
- Use at least one pipeline where `pipefail` matters.
- Inspect `PIPESTATUS` at least once after a pipeline and record the result.

## Manual Test Scenarios

Run and record every scenario below.

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

## Evidence To Save

Create a notes file yourself:

```text
projects/week_1/evidence.md
```

Include:

- The final script path.
- The mock evidence folder path.
- The artifact folder path.
- At least five command examples with exit codes.
- At least one success artifact summary.
- At least one failure artifact summary.
- At least one manual approval artifact summary.
- A short explanation of how `set -euo pipefail` changed your script behavior.
- A short explanation of one bug caused by missing quotes or bad validation.

## Debug Log

Create this file yourself:

```text
projects/week_1/debuglog.md
```

Record real mistakes. Do not hide them.

For every bug, write:

```text
symptom:
hypothesis:
test:
fix:
concept learned:
```

Good bugs for this week include:

- A variable split because it was not quoted.
- `grep | wc -l` behaved differently with `pipefail`.
- `set -u` caught a missing variable.
- A function leaked a variable because `local` was missing.
- A temp directory was not cleaned up until `trap` was added.
- A script exited `0` even though a check failed.

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

## Done Condition

You are done when:

- `ci-evidence-gate.sh` exists and is executable.
- The script succeeds with valid clean input.
- The script fails clearly with invalid input.
- High severity evidence blocks the pipeline.
- Prod medium severity evidence creates a manual approval result.
- Artifact files are created and readable.
- `evidence.md` proves your tests happened.
- `debuglog.md` proves you debugged manually.
- You can explain every Bash concept used without reading the script line by line.

## Boundary Reminder

Do not ask AI to write the script.

Allowed AI help:

- Explain a Bash concept.
- Ask you debugging questions.
- Review your completed project against the rubric.
- Give a checklist for investigating an error.

Not allowed:

- Writing the script for you.
- Fixing your script line by line.
- Giving you a completed implementation.
