# Theory

## 1 - Shell Execution Model

A shell reads a command line, expands variables and globs, then asks the kernel to run the program.

Key ideas:

- **Fork.** The shell creates a child process. The child runs the command. The parent waits.
- **Exit code.** Every command returns an exit code to the parent. `0` means success. `1-255` means failure. The shell stores the last exit code in `$?`.
- **Pipeline.** `cmd1 | cmd2 | cmd3` — each command runs in its own subshell. The exit code of the whole pipeline is the exit code of the **last** command by default. `pipefail` changes this (see strict mode below).
- **Subshell.** Anything inside `$( ... )` or `( ... )` runs in a child process. Variables set inside a subshell vanish when it exits.

## 2 - Variables and Quoting

Bash has no real types. Everything is a string. The way you quote determines how Bash splits and globs.

### Assignment

```bash
NAME="Ayush"       # no spaces around =
COUNT=5            # still a string internally
EMPTY=""           # empty string
```

### Word splitting and globbing

When Bash expands an **unquoted** variable, it:

1. Splits the value on `$IFS` (space, tab, newline by default).
2. Expands any glob patterns (`*`, `?`, `[...]`) into matching filenames.

```bash
FILE="my document.txt"
ls $FILE      # Bash splits into: ls my document.txt  → error
ls "$FILE"    # Bash treats as one argument: ls "my document.txt"  → works
```

### Rules of thumb

| Situation | Quote? | Why |
|-----------|--------|-----|
| Using a variable as a single argument | Double quotes | Prevents splitting and globbing |
| Defining a literal string | Single or double | Double lets you interpolate `$var` |
| Arithmetic comparison | No quotes needed | In `[[ ]]` context |
| Regex match on right side of `=~` | No quotes | Quoting makes it a literal string |
| Wanting literal `$` or `"` | Single quotes | No interpolation |

### Command substitution

```bash
TODAY=$(date +%Y-%m-%d)
```

`$( ... )` runs the command and captures its stdout. Always quote the result: `"$( ... )"`.

## 3 - Conditionals

### `if`

```bash
if [ -f "$FILE" ]; then
    echo "file exists"
elif [ -d "$FILE" ]; then
    echo "directory exists"
else
    echo "not found"
fi
```

### `[ ]` vs `[[ ]]`

- `[ ]` is the POSIX `test` command. Requires careful quoting.
- `[[ ]]` is a Bash keyword. Does not word-split or glob. Supports `&&`, `||`, `=~` regex. Prefer `[[ ]]`.

### Common test operators

| Operator | Meaning |
|----------|---------|
| `-f` | file exists and is regular file |
| `-d` | directory exists |
| `-e` | path exists |
| `-r` | readable |
| `-w` | writable |
| `-x` | executable |
| `-s` | file exists and is not empty |
| `-n "$VAR"` | string is not empty |
| `-z "$VAR"` | string is empty |
| `"$A" == "$B"` | string equality (inside `[[ ]]`) |
| `"$A" != "$B"` | string inequality |
| `-eq`, `-ne`, `-lt`, `-gt`, `-le`, `-ge` | integer comparison |

### `case`

```bash
case "$MODE" in
    dev)
        echo "dev mode"
        ;;
    prod)
        echo "production mode"
        ;;
    *)
        echo "unknown mode: $MODE" >&2
        exit 1
        ;;
esac
```

Use `case` when you need to match a variable against multiple known values.

## 4 - Loops

### `for`

```bash
for f in "$DIR"/*.txt; do
    echo "Processing $f"
done
```

```bash
for (( i=0; i<5; i++ )); do
    echo "$i"
done
```

### `while`

```bash
while read -r line; do
    echo "$line"
done < input.txt
```

Always use `read -r` — the `-r` prevents backslash interpretation.

### Loop control

- `break` — exit the loop
- `continue` — skip to next iteration

## 5 - Functions

```bash
die() {
    local msg="$1"
    echo "ERROR: $msg" >&2
    exit 1
}
```

- `local` prevents variable leaking into the caller scope. Always use it inside functions.
- Functions run in the **same** process (not a subshell), so `exit` inside a function exits the whole script.
- Arguments to functions: `$1`, `$2`, etc. Just like script arguments, but scoped to the function call.

## 6 - Arrays

```bash
FILES=("config.yaml" "data.csv" "report.txt")

echo "${FILES[0]}"       # first element
echo "${FILES[@]}"        # all elements
echo "${#FILES[@]}"       # count of elements

for f in "${FILES[@]}"; do
    echo "$f"
done
```

Always quote `"${FILES[@]}"` to preserve each element as a single word.

## 7 - Input Validation

Before your script does any work, check:

### Required arguments

```bash
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <directory>" >&2
    exit 1
fi
```

`$#` = number of arguments. `$0` = script name. `$1` = first argument, etc.

### Required environment variables

```bash
if [[ -z "${AWS_REGION:-}" ]]; then
    echo "AWS_REGION is required" >&2
    exit 1
fi
```

`${VAR:-}` syntax: if `VAR` is unset, substitute empty string instead of erroring. This is important under `set -u`.

### File and directory checks

```bash
if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Directory not found: $INPUT_DIR" >&2
    exit 1
fi
```

### Sending errors to stderr

`>&2` redirects output to file descriptor 2 (stderr). Do this for all error messages so they don't mix with normal stdout.

## 8 - Strict Mode

### `set -e`

Exit immediately if any command returns a non-zero exit code. Without this, Bash keeps running after failures.

Caveat: commands in `if` conditions, `||`, `&&` left side, and `while` tests are not affected.

### `set -u`

Treat unset variables as an error. Prevents typos like `$NFAME` silently expanding to empty.

Use `${VAR:-default}` or `${VAR:-}` when a variable is legitimately optional.

### `set -o pipefail`

Make a pipeline fail if **any** command in it fails. Without this, `false | true` succeeds because the last command succeeded.

### Putting it together

```bash
#!/usr/bin/env bash
set -euo pipefail
```

This is the standard safe opening for any CI script. Put it right after the shebang line.

### When strict mode bites you

- `set -e` can cause surprising exits inside `$( ... )` subshells or when you expected to check `$?` yourself.
- Some people prefer `set -uo pipefail` without `-e` and use explicit `exit 1` after error checks. This is also valid and sometimes clearer in CI.

## 9 - Trap and Cleanup

`trap` registers a function or command to run when the script receives a signal or exits.

```bash
cleanup() {
    rm -rf "$TMPDIR"
    echo "Cleaned up $TMPDIR"
}

TMPDIR=$(mktemp -d)
trap cleanup EXIT
```

- `EXIT` fires on script end (normal or error).
- `INT` fires on Ctrl-C.
- `ERR` fires on any command failure (useful for logging).
- You can trap multiple signals: `trap cleanup EXIT INT TERM`

**Why this matters in CI:** If your script creates temp files, crashes halfway through, and doesn't clean up, the runner disk fills up over time. `trap EXIT` ensures cleanup always runs.

## 10 - Redirects

```bash
command > out.txt          # stdout to file (overwrite)
command >> out.txt         # stdout to file (append)
command 2> err.txt         # stderr to file
command > out.txt 2>&1     # stdout and stderr to same file
command >> log.txt 2>&1   # append both to log
command &> log.txt         # shorthand for above (bash only)
command >/dev/null 2>&1   # silence everything
```

In CI, you often want to capture command output for evidence while also showing it in the log. Use `tee`:

```bash
terraform plan 2>&1 | tee "$ARTIFACT_DIR/plan.txt"
```

## 11 - Exit Codes for CI

Your script's exit code tells the CI runner whether the job passed or failed.

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General failure |
| 2 | Misuse of shell builtins or arguments |

Your script should:

- `exit 0` — only when everything worked.
- `exit 1` — on any expected failure (bad input, missing env, tool error).
- Never `exit 0` after something went wrong.

## 12 - Pipes

```bash
grep "ERROR" log.txt | wc -l
```

The output of the left command feeds into the right command. With `pipefail`, if `grep` finds nothing and exits with code 1, the whole pipeline fails. Without `pipefail`, only `wc -l` exit code matters.

### `PIPESTATUS`

```bash
terraform plan 2>&1 | tee plan.txt
echo "terraform exit: ${PIPESTATUS[0]}"
```

`PIPESTATUS` array holds the exit code of each command in the last pipeline. Useful when you need to know which command in a pipeline failed.

## Manual Questions

- [x] What exit code should represent success? → **0**
- [x] What failure cases should produce a non-zero exit? → **Missing args, missing env vars, missing files, command failure, validation failure**
- [x] What input assumptions must be checked before work starts? → **Required args present, required env vars set, input paths exist and are readable, output directories writable**
- [x] What output proves the script processed the expected files? → **File count, file list, processed content, or summary written to output directory**
- [x] What output proves invalid input failed clearly? → **Error message to stderr naming the specific problem, non-zero exit code**