# Week 1 Theory: Bash for Safe CI Evidence Gates

This file is a lookup guide for building a small Bash CI gate. It is not meant to be memorized. Use it when you are stuck on a specific question like:

- How do I check if a directory exists?
- How do I read one line from a file?
- How do I read many lines from a file?
- How do I validate an AWS account ID?
- How do I fail clearly when evidence is bad?

The project context is cloud security and compliance. The goal is not fancy Bash. The goal is a script that reads local evidence, validates assumptions, writes artifacts, and exits correctly.

## Index

Line numbers are for quick lookup in this file. If you edit this file later, rerun `rg -n "^## |^### " weeks/week-01-bash-ci-safety/theory.md` to refresh them.

| Looking for                         | Line |
| ----------------------------------- | ---- |
| CI gate mental model                | 61   |
| Shell execution, exit codes, `$?`   | 94   |
| Safe script header and strict mode  | 126  |
| Variables and quoting               | 149  |
| `printf` vs `echo`                  | 195  |
| `if`, `elif`, `else`, `[[ ]]`       | 227  |
| Directory and file checks           | 281  |
| Arguments and environment variables | 346  |
| Reading files overview              | 387  |
| Reading one-line files              | 389  |
| Reading whole multi-line files      | 411  |
| Reading line-by-line evidence       | 422  |
| Skipping blank lines and comments   | 453  |
| Stopping a loop early with `break`  | 465  |
| Parsing `key=value` metadata        | 476  |
| Regex validation basics             | 527  |
| Incremental validation examples     | 559  |
| AWS account ID validation           | 563  |
| AWS region validation               | 601  |
| Environment validation              | 635  |
| Commit SHA validation               | 662  |
| Pipeline ID validation              | 691  |
| Metadata owner validation           | 722  |
| Service name validation             | 748  |
| Ticket ID validation                | 759  |
| Tag key lowercase validation        | 770  |
| Tag value lowercase validation      | 790  |
| Severity validation                 | 801  |
| Finding line validation             | 812  |
| Terraform mock plan validation      | 843  |
| Resource address validation         | 880  |
| Validation ladder                   | 906  |
| `case` for known choices            | 935  |
| Arrays and loops for required files | 965  |
| Counting findings                   | 1001 |
| Redirects and artifacts             | 1029 |
| Pipes, `pipefail`, `PIPESTATUS`     | 1072 |
| Functions                           | 1108 |
| Security/compliance examples        | 1155 |
| Project decision rules              | 1232 |
| Exit codes                          | 1249 |
| Debugging checklist                 | 1284 |
| Common mistakes                     | 1336 |
| Project build order                 | 1411 |
| Mini reference                      | 1436 |

## Fast Query Map

Use this section when you know the project step or the kind of problem, but not the exact Bash concept name.

| If you are trying to...                                  | Search/read these sections                                                                                        |
| -------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Understand what the script is supposed to do overall     | `CI gate mental model`, `Project decision rules`, `Project build order`                                           |
| Start the script safely                                  | `Safe script header and strict mode`, `Arguments and environment variables`, `Exit codes`                         |
| Accept `<evidence_dir> <artifact_dir> <environment>`     | `Arguments and environment variables`, `Variables and quoting`, `Environment validation`                          |
| Check required CI variables                              | `Arguments and environment variables`, `AWS region validation`, `Commit SHA validation`, `Pipeline ID validation` |
| Check whether directories and files are valid            | `Directory and file checks`, `Arrays and loops for required files`, `Validation ladder`                           |
| Handle paths that contain spaces                         | `Variables and quoting`, `Arrays and loops for required files`                                                    |
| Create or write artifact files                           | `Redirects and artifacts`, `printf vs echo`, `Functions`                                                          |
| Read simple one-line evidence like `secrets-scan.txt`    | `Reading one-line files`, `Severity validation`, `Finding line validation`                                        |
| Read multiple findings from `opa-findings.txt`           | `Reading line-by-line evidence`, `Finding line validation`, `Counting findings`                                   |
| Parse `HIGH:message`, `MEDIUM:message`, or `LOW:message` | `Finding line validation`, `Severity validation`, `case for known choices`, `Counting findings`                   |
| Extract and normalize `metadata.env` values              | `Parsing key=value metadata`, `Metadata owner validation`, `Service name validation`, `Ticket ID validation`      |
| Decide `PASS`, `FAIL`, or `MANUAL_APPROVAL`              | `Project decision rules`, `Counting findings`, `case for known choices`, `Exit codes`                             |
| Understand why a command failed or exited early          | `Shell execution, exit codes, $?`, `Pipes, pipefail, PIPESTATUS`, `Debugging checklist`                           |
| Add cleanup with temporary directories                   | `Functions`, `Exit codes`, `Debugging checklist`                                                                  |
| Avoid common Bash mistakes                               | `Common mistakes`, `Variables and quoting`, `printf vs echo`                                                      |

### Project Step Lookup

| Project step               | Main theory to inspect                                                                                 |
| -------------------------- | ------------------------------------------------------------------------------------------------------ |
| Step 1: script shell       | `Safe script header and strict mode`, `Shell execution, exit codes, $?`, `Functions`                   |
| Step 2: validate inputs    | `Arguments and environment variables`, `Directory and file checks`, `Validation ladder`                |
| Step 3: create artifacts   | `Redirects and artifacts`, `printf vs echo`, `Variables and quoting`                                   |
| Step 4: normalize metadata | `Parsing key=value metadata`, `Regex validation basics`, metadata validation sections                  |
| Step 5: scan findings      | `Reading line-by-line evidence`, `Finding line validation`, `Severity validation`, `Counting findings` |
| Step 6: decide result      | `Project decision rules`, `case for known choices`, `Exit codes`                                       |
| Step 7: cleanup practice   | `Functions`, `Exit codes`, `Debugging checklist`                                                       |
| Step 8: pipeline practice  | `Pipes, pipefail, PIPESTATUS`, `Debugging checklist`                                                   |

## 1 - The CI Gate Mental Model

A CI gate is a sequence of checks. Each check should answer one question.

Typical order:

1. Did the user call the script correctly?
2. Are required environment variables present?
3. Do required directories exist?
4. Do required files exist, are they readable, and are they non-empty?
5. Is the content shaped correctly?
6. Does any evidence require failure?
7. Does any evidence require manual approval?
8. What artifacts prove what happened?
9. What exit code should the CI runner receive?

Do not start by trying to solve everything. Build one check at a time.

Good check shape:

```bash
if [[ bad_condition ]]; then
    printf 'ERROR: explain the exact problem\n' >&2
    exit 1
fi
```

Good log shape:

```bash
printf '%s\n' "checked identity.txt" >> "$ARTIFACT_DIR/pipeline.log"
```

## 2 - Shell Execution Model[]

Bash reads a line, expands variables, performs word splitting and globbing when allowed, then runs a command.

Key ideas:

| Concept   | Meaning                                    |
| --------- | ------------------------------------------ | ---------------------------------------------------------------- |
| Command   | A program or shell builtin being run       |
| Exit code | `0` means success. Non-zero means failure  |
| `$?`      | Exit code of the previous command          |
| Pipeline  | `cmd1                                      | cmd2`, where stdout of left command feeds stdin of right command |
| Subshell  | Child shell created by `$(...)` or `(...)` |

Example:

```bash
grep 'HIGH' findings.txt
status=$?
printf 'grep exit code was %d\n' "$status"
```

Important: under `set -e`, a failing command can exit the script before you inspect `$?`. If you intentionally want to inspect a command's status, put the command in an `if`:

```bash
if grep 'HIGH' "$FINDINGS_FILE" >/dev/null; then
    printf '%s\n' "HIGH finding found"
else
    printf '%s\n' "No HIGH finding found"
fi
```

## 3 - Safe Script Header[]

For CI-style Bash scripts:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

Meaning:

| Setting           | Meaning                                     |
| ----------------- | ------------------------------------------- |
| `set -e`          | Exit when a command fails                   |
| `set -u`          | Error on unset variables                    |
| `set -o pipefail` | A pipeline fails if any command in it fails |

Useful caution:

- `set -e` is helpful, but it can surprise you.
- Commands inside `if`, `while`, and the left side of `&&` or `||` are special cases.
- For learning, write explicit `if` checks so you can see the decision.

## 4 - Variables and Quoting

Bash variables are strings.

Assignment:

```bash
NAME="cloud-grc-workbench"
COUNT=5
EMPTY=""
```

No spaces around `=`.

Use variables:

```bash
printf '%s\n' "$NAME"
```

Quote variables by default:

```bash
file_name="terraform plan.txt"
printf '%s\n' "$file_name"
```

Why quoting matters:

```bash
FILE="my evidence.txt"
ls $FILE      # wrong: becomes two words
ls "$FILE"    # right: stays one path
```

Rules of thumb:

| Situation                | Pattern                |
| ------------------------ | ---------------------- |
| Path variable            | `"$FILE"`              |
| User input               | `"$VALUE"`             |
| Environment variable     | `"${AWS_REGION:-}"`    |
| Array expansion          | `"${FILES[@]}"`        |
| Regex right side of `=~` | usually unquoted       |
| Literal text             | single quotes are fine |

## 5 - `printf` vs `echo`

Use `echo` for quick terminal experiments.

Use `printf` in scripts.

```bash
printf '%s\n' "$MESSAGE"
```

Why:

- `printf` makes newlines explicit.
- `printf` is predictable across shells.
- `printf` handles values starting with `-` safely.
- `printf` is better for logs and artifacts.

Common forms:

```bash
printf '%s\n' "$VALUE"
printf '%s=%s\n' "$KEY" "$VALUE"
printf 'count=%d\n' "$COUNT"
printf 'ERROR: %s\n' "$MESSAGE" >&2
```

When unsure:

```bash
printf '%s\n' "$something"
```

## 6 - Conditionals

Prefer `[[ ... ]]` in Bash.

```bash
if [[ "$ENVIRONMENT" == "prod" ]]; then
    printf '%s\n' "production rules apply"
elif [[ "$ENVIRONMENT" == "staging" ]]; then
    printf '%s\n' "staging rules apply"
else
    printf '%s\n' "other environment"
fi
```

Spacing matters:

```bash
[[ "$a" == "$b" ]]   # valid
[[ "$a" == "$b"]]    # invalid
```

Common tests:

| Test                 | Meaning              |
| -------------------- | -------------------- |
| `[[ -d "$DIR" ]]`    | directory exists     |
| `[[ ! -d "$DIR" ]]`  | directory is missing |
| `[[ -f "$FILE" ]]`   | regular file exists  |
| `[[ -r "$FILE" ]]`   | readable             |
| `[[ -w "$DIR" ]]`    | writable             |
| `[[ -x "$SCRIPT" ]]` | executable           |
| `[[ -s "$FILE" ]]`   | exists and not empty |
| `[[ -z "$VALUE" ]]`  | string is empty      |
| `[[ -n "$VALUE" ]]`  | string is not empty  |
| `[[ "$A" == "$B" ]]` | string equality      |
| `[[ "$A" != "$B" ]]` | string inequality    |

Integer comparisons:

```bash
if [[ "$high_count" -gt 0 ]]; then
    printf '%s\n' "fail"
fi
```

| Test  | Meaning               |
| ----- | --------------------- |
| `-eq` | equal                 |
| `-ne` | not equal             |
| `-lt` | less than             |
| `-le` | less than or equal    |
| `-gt` | greater than          |
| `-ge` | greater than or equal |

## 7 - Directory and File Checks

Do not use `ls | grep` to test if a path exists. Use Bash file tests.

Check whether an output directory is missing:

```bash
if [[ ! -d "$ARTIFACT_DIR" ]]; then
    mkdir "$ARTIFACT_DIR"
fi
```

This reads as: "if not a directory, create it."

Check an input directory:

```bash
if [[ ! -d "$EVIDENCE_DIR" ]]; then
    printf 'ERROR: evidence directory not found: %s\n' "$EVIDENCE_DIR" >&2
    exit 1
fi
```

Check a required file:

```bash
if [[ ! -f "$FILE" ]]; then
    printf 'ERROR: required file missing: %s\n' "$FILE" >&2
    exit 1
fi
```

Check readable:

```bash
if [[ ! -r "$FILE" ]]; then
    printf 'ERROR: file is not readable: %s\n' "$FILE" >&2
    exit 1
fi
```

Check non-empty:

```bash
if [[ ! -s "$FILE" ]]; then
    printf 'ERROR: file is empty: %s\n' "$FILE" >&2
    exit 1
fi
```

Useful sequence:

```bash
if [[ ! -f "$FILE" ]]; then
    printf 'ERROR: missing file: %s\n' "$FILE" >&2
    exit 1
elif [[ ! -r "$FILE" ]]; then
    printf 'ERROR: unreadable file: %s\n' "$FILE" >&2
    exit 1
elif [[ ! -s "$FILE" ]]; then
    printf 'ERROR: empty file: %s\n' "$FILE" >&2
    exit 1
fi
```

## 8 - Arguments and Environment Variables

Script arguments:

```bash
printf 'arg count: %d\n' "$#"
printf 'script name: %s\n' "$0"
printf 'first arg: %s\n' "$1"
```

Check argument count:

```bash
if [[ "$#" -ne 3 ]]; then
    printf 'Usage: %s <evidence_dir> <artifact_dir> <environment>\n' "$0" >&2
    exit 1
fi
```

Assign arguments to named variables:

```bash
EVIDENCE_DIR="$1"
ARTIFACT_DIR="$2"
ENVIRONMENT="$3"
```

Required environment variable under `set -u`:

```bash
if [[ -z "${AWS_REGION:-}" ]]; then
    printf '%s\n' "ERROR: AWS_REGION is required" >&2
    exit 1
fi
```

Why `${AWS_REGION:-}`:

- If `AWS_REGION` is unset, it becomes an empty string for this check.
- Without `:-`, `set -u` would make Bash fail immediately.

## 9 - Reading Files[]

### One small single-line file

For a file like:

```text
PASSED
```

Use:

```bash
scan_result="$(<"$SECRETS_FILE")"
```

Then compare:

```bash
if [[ "$scan_result" == "PASSED" ]]; then
    printf '%s\n' "secret scan passed"
fi
```

### Whole file as one variable

This preserves newlines inside the variable:

```bash
plan_text="$(<"$PLAN_FILE")"
printf '%s\n' "$plan_text"
```

This is useful when copying the whole file content into an artifact. It is less useful when each line needs a decision.

### Multi-line file, one record per line

For evidence like:

```text
CREATE aws_s3_bucket.logs
CHANGE aws_security_group.web
DELETE aws_iam_role.old_ci_role
```

Use:

```bash
while IFS= read -r line; do
    if [[ -z "$line" ]]; then
        continue
    fi

    printf 'record: %s\n' "$line"
done < "$PLAN_FILE"
```

Meaning:

| Part             | Meaning                            |
| ---------------- | ---------------------------------- |
| `IFS=`           | Do not trim whitespace             |
| `read -r`        | Do not treat backslashes specially |
| `line`           | Variable receiving one line        |
| `< "$PLAN_FILE"` | File feeds the loop                |

### Skip comments and blank lines

```bash
while IFS= read -r line; do
    if [[ -z "$line" || "$line" == \#* ]]; then
        continue
    fi

    printf 'usable record: %s\n' "$line"
done < "$FILE"
```

### Stop early with `break`

```bash
while IFS= read -r line; do
    if [[ "$line" == HIGH:* ]]; then
        printf '%s\n' "found high severity"
        break
    fi
done < "$FINDINGS_FILE"
```

## 10 - Reading `key=value` Metadata

For:

```text
owner=platform-security
service=cloud-grc-workbench
ticket=GRC-001
```

Read and split:

```bash
while IFS='=' read -r key value; do
    if [[ -z "$key" ]]; then
        continue
    fi

    printf 'key=%s value=%s\n' "$key" "$value"
done < "$METADATA_FILE"
```

Avoid this for untrusted evidence:

```bash
source metadata.env
```

Reason: `source` executes shell code. Evidence should be treated as data.

Simple key handling:

```bash
if [[ "$key" == "owner" ]]; then
    owner="$value"
elif [[ "$key" == "service" ]]; then
    service="$value"
elif [[ "$key" == "ticket" ]]; then
    ticket="$value"
fi
```

Check for malformed metadata line:

```bash
if [[ "$line" != *=* ]]; then
    printf 'ERROR: metadata line is not key=value: %s\n' "$line" >&2
    exit 1
fi
```

## 11 - Regex Basics for Validation

Bash regex uses `=~` inside `[[ ... ]]`.

```bash
if [[ "$VALUE" =~ ^[0-9]+$ ]]; then
    printf '%s\n' "numbers only"
fi
```

Important:

- The regex goes on the right side of `=~`.
- Usually do not quote the regex.
- `^` means start of string.
- `$` means end of string.
- `[0-9]` means one digit.
- `[0-9]+` means one or more digits.
- `[0-9]{12}` means exactly 12 digits.

Examples:

| Regex             | Meaning                            |
| ----------------- | ---------------------------------- | ------- | ------------------------- |
| `^[0-9]+$`        | only digits                        |
| `^[0-9]{12}$`     | exactly 12 digits                  |
| `^[a-z]+$`        | lowercase letters only             |
| `^[a-z0-9-]+$`    | lowercase letters, numbers, hyphen |
| `^[A-Z]+$`        | uppercase letters only             |
| `^[A-Z]+-[0-9]+$` | ticket like `GRC-001`              |
| `^(dev            | staging                            | prod)$` | one of three environments |

## 12 - Incremental Validation Patterns

Start with a weak check. Then make it stricter.

### AWS account ID

Level 1: value is present.

```bash
if [[ -z "$account_id" ]]; then
    printf '%s\n' "ERROR: account_id is required" >&2
    exit 1
fi
```

Level 2: digits only.

```bash
if [[ ! "$account_id" =~ ^[0-9]+$ ]]; then
    printf 'ERROR: account_id must contain digits only: %s\n' "$account_id" >&2
    exit 1
fi
```

Level 3: exactly 12 digits.

```bash
if [[ ! "$account_id" =~ ^[0-9]{12}$ ]]; then
    printf 'ERROR: account_id must be exactly 12 digits: %s\n' "$account_id" >&2
    exit 1
fi
```

Level 4: avoid obvious placeholder accounts.

```bash
if [[ "$account_id" == "000000000000" || "$account_id" == "111111111111" ]]; then
    printf 'ERROR: account_id looks like a placeholder: %s\n' "$account_id" >&2
    exit 1
fi
```

### AWS region

Level 1: present.

```bash
if [[ -z "${AWS_REGION:-}" ]]; then
    printf '%s\n' "ERROR: AWS_REGION is required" >&2
    exit 1
fi
```

Level 2: basic shape.

```bash
if [[ ! "$AWS_REGION" =~ ^[a-z]{2}-[a-z]+-[0-9]+$ ]]; then
    printf 'ERROR: AWS_REGION has invalid shape: %s\n' "$AWS_REGION" >&2
    exit 1
fi
```

Level 3: allowlist for your project.

```bash
case "$AWS_REGION" in
    us-east-1|us-west-2|eu-west-1)
        printf 'AWS region accepted: %s\n' "$AWS_REGION"
        ;;
    *)
        printf 'ERROR: unsupported AWS_REGION: %s\n' "$AWS_REGION" >&2
        exit 1
        ;;
esac
```

### Environment name

Regex version:

```bash
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    printf 'ERROR: invalid environment: %s\n' "$ENVIRONMENT" >&2
    exit 1
fi
```

`case` version:

```bash
case "$ENVIRONMENT" in
    dev|staging|prod)
        printf 'environment accepted: %s\n' "$ENVIRONMENT"
        ;;
    *)
        printf 'ERROR: invalid environment: %s\n' "$ENVIRONMENT" >&2
        exit 1
        ;;
esac
```

Use `case` when each environment has different behavior.

### Git commit SHA

Level 1: present.

```bash
if [[ -z "${CI_COMMIT_SHA:-}" ]]; then
    printf '%s\n' "ERROR: CI_COMMIT_SHA is required" >&2
    exit 1
fi
```

Level 2: hex characters only.

```bash
if [[ ! "$CI_COMMIT_SHA" =~ ^[0-9a-fA-F]+$ ]]; then
    printf 'ERROR: CI_COMMIT_SHA must be hex: %s\n' "$CI_COMMIT_SHA" >&2
    exit 1
fi
```

Level 3: common short or full SHA length.

```bash
if [[ ! "$CI_COMMIT_SHA" =~ ^[0-9a-fA-F]{7,40}$ ]]; then
    printf 'ERROR: CI_COMMIT_SHA must be 7 to 40 hex characters: %s\n' "$CI_COMMIT_SHA" >&2
    exit 1
fi
```

### CI pipeline ID

Level 1: present.

```bash
if [[ -z "${CI_PIPELINE_ID:-}" ]]; then
    printf '%s\n' "ERROR: CI_PIPELINE_ID is required" >&2
    exit 1
fi
```

Level 2: integer only.

```bash
if [[ ! "$CI_PIPELINE_ID" =~ ^[0-9]+$ ]]; then
    printf 'ERROR: CI_PIPELINE_ID must be numeric: %s\n' "$CI_PIPELINE_ID" >&2
    exit 1
fi
```

Level 3: must be positive.

```bash
if [[ "$CI_PIPELINE_ID" -le 0 ]]; then
    printf 'ERROR: CI_PIPELINE_ID must be positive: %s\n' "$CI_PIPELINE_ID" >&2
    exit 1
fi
```

Important: only use `-le`, `-gt`, etc. after proving the value is numeric.

### Metadata owner

Example policy: lowercase team slug only.

```bash
if [[ ! "$owner" =~ ^[a-z0-9-]+$ ]]; then
    printf 'ERROR: owner must use lowercase letters, numbers, and hyphen: %s\n' "$owner" >&2
    exit 1
fi
```

This rejects:

```text
Platform-Security
platform_security
platform security
```

This accepts:

```text
platform-security
security123
```

### Service name

Example policy: lowercase service slug.

```bash
if [[ ! "$service" =~ ^[a-z][a-z0-9-]*$ ]]; then
    printf 'ERROR: service must start with lowercase letter and use lowercase letters, numbers, hyphen: %s\n' "$service" >&2
    exit 1
fi
```

### Ticket ID

Example policy: `ABC-123`, uppercase project key, digits after hyphen.

```bash
if [[ ! "$ticket" =~ ^[A-Z]+-[0-9]+$ ]]; then
    printf 'ERROR: ticket must look like GRC-001 or SEC-123: %s\n' "$ticket" >&2
    exit 1
fi
```

### Tag key lowercase rule

Example policy: tag keys must not contain uppercase letters.

```bash
if [[ "$tag_key" =~ [A-Z] ]]; then
    printf 'ERROR: tag key must not contain uppercase letters: %s\n' "$tag_key" >&2
    exit 1
fi
```

Stricter version:

```bash
if [[ ! "$tag_key" =~ ^[a-z0-9:/._-]+$ ]]; then
    printf 'ERROR: tag key has invalid characters: %s\n' "$tag_key" >&2
    exit 1
fi
```

### Tag value lowercase rule

Example policy: values for controlled tags must be lowercase slugs.

```bash
if [[ ! "$tag_value" =~ ^[a-z0-9-]+$ ]]; then
    printf 'ERROR: tag value must be lowercase slug: %s\n' "$tag_value" >&2
    exit 1
fi
```

### Severity value

Allow only known severities:

```bash
if [[ ! "$severity" =~ ^(LOW|MEDIUM|HIGH)$ ]]; then
    printf 'ERROR: invalid severity: %s\n' "$severity" >&2
    exit 1
fi
```

### Finding line format

For:

```text
HIGH:Security group allows 0.0.0.0/0 to port 22
```

Basic shape:

```bash
if [[ ! "$line" =~ ^(LOW|MEDIUM|HIGH):.+$ ]]; then
    printf 'ERROR: malformed finding line: %s\n' "$line" >&2
    exit 1
fi
```

Extract severity using parameter expansion:

```bash
severity="${line%%:*}"
message="${line#*:}"
```

Meaning:

| Expression    | Meaning                           |
| ------------- | --------------------------------- |
| `${line%%:*}` | everything before the first colon |
| `${line#*:}`  | everything after the first colon  |

### Terraform plan action

For:

```text
CREATE aws_s3_bucket.logs
```

Basic shape:

```bash
if [[ ! "$line" =~ ^(CREATE|CHANGE|DELETE)[[:space:]]+.+$ ]]; then
    printf 'ERROR: malformed terraform plan line: %s\n' "$line" >&2
    exit 1
fi
```

Get the first word:

```bash
action="${line%% *}"
```

Validate action:

```bash
case "$action" in
    CREATE|CHANGE|DELETE)
        printf 'terraform action accepted: %s\n' "$action"
        ;;
    *)
        printf 'ERROR: unknown terraform action: %s\n' "$action" >&2
        exit 1
        ;;
esac
```

### Resource address

For:

```text
aws_s3_bucket.logs
```

Basic Terraform-like address:

```bash
if [[ ! "$resource" =~ ^[a-z0-9_]+\.[a-zA-Z0-9_-]+$ ]]; then
    printf 'ERROR: invalid resource address: %s\n' "$resource" >&2
    exit 1
fi
```

Stricter lowercase resource name:

```bash
if [[ ! "$resource" =~ ^[a-z0-9_]+\.[a-z0-9_-]+$ ]]; then
    printf 'ERROR: resource address must be lowercase: %s\n' "$resource" >&2
    exit 1
fi
```

## 13 - Validation Style: Build a Ladder

For any input, validate in this order:

1. Is it present?
2. Is it the expected type or shape?
3. Is it within allowed values?
4. Does it violate a security or compliance rule?

Example: `account_id`

```text
present -> digits only -> 12 digits -> not placeholder
```

Example: `owner`

```text
present -> allowed characters -> lowercase -> known team if needed
```

Example: finding line:

```text
present -> contains colon -> severity is known -> message is non-empty -> decision rule
```

Do not write the strictest version first. Start with a simple check, run it, then tighten it.

## 14 - `case` for Known Choices

Use `case` when values come from a small known set.

```bash
case "$ENVIRONMENT" in
    dev)
        printf '%s\n' "dev rules"
        ;;
    staging)
        printf '%s\n' "staging rules"
        ;;
    prod)
        printf '%s\n' "prod rules"
        ;;
    *)
        printf 'ERROR: unknown environment: %s\n' "$ENVIRONMENT" >&2
        exit 1
        ;;
esac
```

Cloud security examples where `case` fits:

- environment: `dev`, `staging`, `prod`
- severity: `LOW`, `MEDIUM`, `HIGH`
- Terraform action: `CREATE`, `CHANGE`, `DELETE`
- decision: `PASS`, `FAIL`, `MANUAL_APPROVAL`
- cloud provider: `aws`, `azure`, `gcp`

## 15 - Loops and Arrays

Array of required files:

```bash
required_files=(
    "identity.txt"
    "terraform-plan.txt"
    "opa-findings.txt"
    "checkov-findings.txt"
    "secrets-scan.txt"
    "metadata.env"
)
```

Loop:

```bash
for name in "${required_files[@]}"; do
    file_path="$EVIDENCE_DIR/$name"
    printf 'checking file: %s\n' "$file_path"
done
```

Why quote `"${required_files[@]}"`:

- Each array item stays one item.
- File names with spaces do not break.

Count items:

```bash
file_count="${#required_files[@]}"
printf 'required file count: %d\n' "$file_count"
```

## 16 - Counting Findings

Simple counters:

```bash
low_count=0
medium_count=0
high_count=0
```

Increment:

```bash
high_count=$((high_count + 1))
```

Use in a decision:

```bash
if [[ "$high_count" -gt 0 ]]; then
    decision="FAIL"
elif [[ "$medium_count" -gt 0 && "$ENVIRONMENT" == "prod" ]]; then
    decision="MANUAL_APPROVAL"
else
    decision="PASS"
fi
```

## 17 - Redirects and Artifacts

Redirects:

```bash
command > out.txt          # overwrite stdout
command >> out.txt         # append stdout
command 2> err.txt         # stderr
command > out.txt 2>&1     # stdout and stderr together
```

Write artifact:

```bash
printf '%s\n' "$decision" > "$ARTIFACT_DIR/summary.txt"
```

Append log:

```bash
printf '%s\n' "checked required files" >> "$ARTIFACT_DIR/pipeline.log"
```

Write error to stderr:

```bash
printf 'ERROR: %s\n' "$message" >&2
```

Use paths instead of changing directory:

```bash
printf '%s\n' "FAIL" > "$ARTIFACT_DIR/summary.txt"
```

This is easier to reason about than:

```bash
cd "$ARTIFACT_DIR"
printf '%s\n' "FAIL" > summary.txt
cd ..
```

## 18 - Pipes and `pipefail`

Pipeline:

```bash
grep 'HIGH' "$FINDINGS_FILE" | wc -l
```

With `set -o pipefail`, the pipeline fails if any command fails.

Important learning point:

- `grep` exits `1` when it finds no matches.
- That is not always an error in your logic.
- If "no match" is expected, use `if grep ...`.

Good pattern:

```bash
if grep 'HIGH' "$FINDINGS_FILE" >/dev/null; then
    printf '%s\n' "HIGH found"
else
    printf '%s\n' "No HIGH found"
fi
```

`PIPESTATUS`:

```bash
some_command 2>&1 | tee "$ARTIFACT_DIR/tool.log"
tool_status="${PIPESTATUS[0]}"
printf 'tool exit code: %d\n' "$tool_status"
```

Use this when you need to capture output with `tee` but still know whether the original command failed.

## 19 - Functions

Functions reduce repeated behavior.

Simple error function:

```bash
die() {
    local message="$1"
    printf 'ERROR: %s\n' "$message" >&2
    exit 1
}
```

Use:

```bash
die "AWS_REGION is required"
```

Small logging function:

```bash
log_info() {
    local message="$1"
    printf '%s\n' "$message" >> "$ARTIFACT_DIR/pipeline.log"
}
```

Rules:

- Use `local` inside functions.
- Keep functions small.
- A function should usually do one kind of thing.
- `exit` inside a function exits the whole script.

Good beginner function ideas:

- `die`
- `log_info`
- `require_env`
- `require_file`
- `validate_account_id`
- `validate_metadata_line`

Do not make functions first if you are still learning. Write the check once, understand it, then turn repeated checks into functions.

## 20 - Security and Compliance Validation Examples

These are examples to look up when designing checks.

### No public SSH finding

```bash
if [[ "$line" == *"0.0.0.0/0"* && "$line" == *"port 22"* ]]; then
    printf 'ERROR: public SSH finding: %s\n' "$line" >&2
    exit 1
fi
```

### S3 bucket encryption text

```bash
if [[ "$line" == *"encryption disabled"* ]]; then
    printf 'ERROR: encryption finding: %s\n' "$line" >&2
    exit 1
fi
```

### Required metadata keys

After parsing metadata, check:

```bash
if [[ -z "$owner" ]]; then
    printf '%s\n' "ERROR: metadata owner is required" >&2
    exit 1
fi

if [[ -z "$service" ]]; then
    printf '%s\n' "ERROR: metadata service is required" >&2
    exit 1
fi

if [[ -z "$ticket" ]]; then
    printf '%s\n' "ERROR: metadata ticket is required" >&2
    exit 1
fi
```

### Owner must be lowercase

```bash
if [[ "$owner" =~ [A-Z] ]]; then
    printf 'ERROR: owner must be lowercase: %s\n' "$owner" >&2
    exit 1
fi
```

### Tags must not use uppercase keys

```bash
if [[ "$tag_key" =~ [A-Z] ]]; then
    printf 'ERROR: tag key contains uppercase letters: %s\n' "$tag_key" >&2
    exit 1
fi
```

### Prod requires stricter rules

```bash
if [[ "$ENVIRONMENT" == "prod" && "$medium_count" -gt 0 ]]; then
    decision="MANUAL_APPROVAL"
fi
```

### Any HIGH fails

```bash
if [[ "$high_count" -gt 0 ]]; then
    decision="FAIL"
fi
```

## 21 - Decision Rules for This Project

Useful decision order:

1. Validation failure means `FAIL` and `exit 1`.
2. Any `HIGH` finding means `FAIL` and `exit 1`.
3. Any `MEDIUM` finding in `prod` means `MANUAL_APPROVAL` and `exit 0`.
4. `LOW` or `MEDIUM` in `dev` or `staging` can pass, but must be recorded.
5. No findings means `PASS` and `exit 0`.

Why manual approval exits `0`:

- The script successfully reached a controlled handoff state.
- It did not crash.
- It did not hide a failure.
- The artifact says `MANUAL_APPROVAL`.

## 22 - Exit Codes

| Exit code | Meaning                                                                 |
| --------- | ----------------------------------------------------------------------- |
| `0`       | Script completed successfully                                           |
| `1`       | Validation failure, security failure, missing evidence, command failure |
| `2`       | Often used for bad usage, but `1` is fine for this project              |

Use:

```bash
exit 0
```

only for:

- `PASS`
- intended `MANUAL_APPROVAL`

Use:

```bash
exit 1
```

for:

- missing arguments
- missing env vars
- missing files
- empty files
- malformed evidence
- HIGH severity finding
- command failure

## 23 - Debugging Checklist

When stuck, check in this order:

1. Syntax:

```bash
bash -n projects/week_1/ci-evidence-gate.sh
```

2. Current directory:

```bash
pwd
```

3. Files visible from here:

```bash
ls
```

4. Does the file exist?

```bash
[[ -f "$FILE" ]]
```

5. Is the variable empty?

```bash
printf 'VALUE=[%s]\n' "$VALUE"
```

6. Is the path being written where you think?

```bash
printf 'artifact path: %s\n' "$ARTIFACT_DIR/pipeline.log"
```

7. Did the previous command fail?

```bash
printf 'status=%d\n' "$?"
```

8. Does the file have hidden spaces or missing newlines?

```bash
sed -n '1,20p' "$FILE"
```

## 24 - Common Mistakes

Missing spaces in `[[ ]]`:

```bash
[[ "$x" == "yes"]]   # wrong
[[ "$x" == "yes" ]]  # right
```

Running commands inside `[[ ]]`:

```bash
if [[ ls | grep output ]]; then   # wrong
```

Use path tests:

```bash
if [[ -d "output" ]]; then
    printf '%s\n' "output exists"
fi
```

Writing to the wrong directory after `cd`:

```bash
cd output
cd ..
printf '%s\n' "message" > pipeline.log
```

That writes `pipeline.log` outside `output`.

Clearer:

```bash
printf '%s\n' "message" > "output/pipeline.log"
```

Using `cat` when Bash can read the file:

```bash
value="$(cat "$FILE")"   # works
value="$(<"$FILE")"      # Bash built-in style
```

Using `source` for evidence:

```bash
source metadata.env      # risky for untrusted evidence
```

Parse it as data instead.

Using integer comparison before numeric validation:

```bash
if [[ "$CI_PIPELINE_ID" -gt 0 ]]; then
    ...
fi
```

Better order:

```bash
if [[ ! "$CI_PIPELINE_ID" =~ ^[0-9]+$ ]]; then
    printf '%s\n' "ERROR: not numeric" >&2
    exit 1
fi

if [[ "$CI_PIPELINE_ID" -gt 0 ]]; then
    printf '%s\n' "positive"
fi
```

## 25 - Project Build Order

Use this order if you are building incrementally:

1. Create artifact directory safely.
2. Write a test line to `pipeline.log`.
3. Read `secrets-scan.txt`.
4. Decide pass/fail only from secret scan.
5. Validate one required file.
6. Validate all required files with an array and loop.
7. Read `metadata.env` line by line.
8. Validate metadata keys.
9. Read OPA findings line by line.
10. Count `LOW`, `MEDIUM`, `HIGH`.
11. Add Checkov findings.
12. Add Terraform plan reading.
13. Add environment-specific `case`.
14. Write `summary.txt`.
15. Write `failed-controls.txt`.
16. Write `metadata-normalized.txt`.
17. Replace hardcoded paths with arguments.
18. Turn repeated checks into functions.

Do not skip from step 1 to step 18. The learning is in the middle.

## 26 - Mini Reference

Create directory if missing:

```bash
if [[ ! -d "$DIR" ]]; then
    mkdir "$DIR"
fi
```

Read one-line file:

```bash
value="$(<"$FILE")"
```

Read many lines:

```bash
while IFS= read -r line; do
    printf '%s\n' "$line"
done < "$FILE"
```

Check digits only:

```bash
[[ "$value" =~ ^[0-9]+$ ]]
```

Check exactly 12 digits:

```bash
[[ "$account_id" =~ ^[0-9]{12}$ ]]
```

Check lowercase slug:

```bash
[[ "$value" =~ ^[a-z0-9-]+$ ]]
```

Check no uppercase:

```bash
[[ ! "$value" =~ [A-Z] ]]
```

Append to log:

```bash
printf '%s\n' "$message" >> "$ARTIFACT_DIR/pipeline.log"
```

Write stderr:

```bash
printf 'ERROR: %s\n' "$message" >&2
```

Fail:

```bash
exit 1
```

Pass:

```bash
exit 0
```
