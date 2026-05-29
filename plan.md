# 6-Month DevSecOps Semester Execution Plan

> **Role target:** Cloud Security & Compliance Engineer with practical DevSecOps execution ability.
>
> **Primary final artifact:** a real GitLab CI/CD platform that runs Terraform with AWS OIDC, policy gates, evidence export, drift detection, and auditor-readable documentation.
>
> **Source material:** `DevsecopsChecklist.md`, `pipelineGrind.md`, and `TerraformChecklist.md`.
>
> **Pace:** 8-10 focused hours per week for 24 weeks. Treat this as a semester plan, not a cram plan.

---

## Operating Rules

- **Weekly timebox:** 8-10 hours split across 3-5 sessions.
- **Weekly output:** one concrete artifact: script, policy, Terraform module, CI config, report, doc, evidence bundle, or verified pipeline run.
- **Evidence-first mindset:** every technical task should leave something inspectable by a future reviewer.
- **Commit habit:** commit often with messages that cite the risk, control, feature, or pipeline gap being closed.
- **Learning log:** add 4-8 lines each week to the relevant repo notes: what changed, proof it works, what remains.
- **No fake confidence:** if a pipeline step is mocked, simulated, or skipped, mark it clearly and schedule its removal.
- **Arc discipline:** finish the tangible output for the current arc before starting unrelated tools.
- **Carry-over rule:** move slipped work to the Carry-over / Gap Log. Do not compress future weeks blindly.
- **Platform context habit:** update `Compliance-Oriented-Cloud-Security-Platform/context.md` whenever a major platform decision changes.

---

## End-State Definition

By the end of this semester, the goal is not just to "know tools." The goal is to independently build, debug, and explain a cloud security/compliance delivery pipeline.

Final platform must demonstrate:

- [ ] GitLab CI/CD pipeline with stages for `terraform fmt`, `validate`, `plan`, policy checks, security scans, manual approval, `apply`, drift detection, and evidence export.
- [ ] AWS authentication through OIDC or a tightly scoped IAM role, with no static long-lived CI keys.
- [ ] Terraform using secure provider, backend, state, module, and validation patterns.
- [ ] OPA/Rego policies that block insecure Terraform plans and emit structured findings.
- [ ] Bash wrappers that orchestrate tools safely and produce artifact folders.
- [ ] boto3 automation that can inventory AWS resources and produce JSON reports for pipeline consumption.
- [ ] Git command over real job workflows: rebase, worktree, cherry-pick, stash, conflict resolution, reflog recovery, signed commits, tags, and protected branch flow.
- [ ] GitHub Actions literacy: read, explain, and harden existing workflows.
- [ ] GitLab CI ownership: author, modularize, debug, and secure real pipelines.
- [ ] Evidence artifacts that include metadata, checksums, commit SHA, actor, timestamp, branch, and pipeline ID.
- [ ] Compliance narrative mapping each gate to risk, control, failure behavior, owner, and evidence location.

---

## 24-Week Progress Tracker

- [ ] **Week 1** - Bash fundamentals and CI script safety
- [ ] **Week 2** - Bash orchestration wrapper and Python automation refresh
- [ ] **Week 3** - boto3 identity, sessions, regions, S3 inventory
- [ ] **Week 4** - boto3 EC2, IAM, error handling, mini-auditor
- [ ] **Week 5** - Advanced Git branch, conflict, stash, and recovery drills
- [ ] **Week 6** - Git rebase, worktree, cherry-pick, signed commits, release flow
- [ ] **Week 7** - GitHub Actions workflow reading and security hardening
- [ ] **Week 8** - Terraform language foundations and secure HCL review
- [ ] **Week 9** - Terraform providers, backend, state, modules, and validation
- [ ] **Week 10** - GitLab project setup and first real `.gitlab-ci.yml`
- [ ] **Week 11** - GitLab Terraform validate/plan/apply pipeline
- [ ] **Week 12** - AWS OIDC for GitLab CI and least-privilege CI role
- [ ] **Week 13** - OPA/Rego fundamentals and unit tests
- [ ] **Week 14** - Core Terraform plan policies for S3, EC2, IAM, and security groups
- [ ] **Week 15** - OPA/Conftest GitLab gate with control mappings
- [ ] **Week 16** - Secret scanning, Checkov, Prowler, dependency scan, and SBOM
- [ ] **Week 17** - Evidence bundle, artifact metadata, checksums, and plan integrity
- [ ] **Week 18** - Drift detection, Terraform state security, and retention policy
- [ ] **Week 19** - SCM security: branch protection, CODEOWNERS, audit trail
- [ ] **Week 20** - Alerts, escalation doc, control narrative, traceability matrix
- [ ] **Week 21** - Platform refactor planning and GitHub Actions to GitLab mapping
- [ ] **Week 22** - Platform GitLab pipeline implementation and real auth
- [ ] **Week 23** - Platform security gates, evidence, drift, and gap closure
- [ ] **Week 24** - End-to-end validation, retrospective, portfolio polish

---

## Month 1 - Automation Base: Bash, Python, boto3

### Week 1 - Bash Fundamentals and CI Safety

- [ ] Review variables, quoting, `if`, `case`, loops, functions, arrays, command substitution, pipes, redirects, and environment variables.
- [ ] Annotate one existing CI/helper script and explain each block in notes.
- [ ] Write a practice script that accepts args, validates env vars, loops through files, and writes output.
- [ ] Add `set -euo pipefail` to real scripts where appropriate.
- [ ] Add `trap` cleanup for temporary files or directories.
- [ ] Replace silent failures with clear error messages and non-zero exits.
- [ ] **Artifact:** one safe Bash script and a short note explaining its failure behavior.
- [ ] **Done when:** the script succeeds with valid input and fails clearly with invalid input.

### Week 2 - Bash Tool Wrapper and Python Automation Refresh

- [ ] Build or improve a Bash wrapper that runs Terraform, OPA/Conftest, Checkov, Prowler, and AWS CLI commands.
- [ ] Store outputs in timestamped artifact folders.
- [ ] Ensure wrapper exits non-zero on real security or execution failures.
- [ ] Refresh Python basics: functions, files, JSON, CSV, exceptions, `argparse`, and `venv`.
- [ ] Create a small Python CLI that reads JSON and filters output from CLI args.
- [ ] Add `if __name__ == "__main__"`, type hints, useful docstrings, and pinned dependencies.
- [ ] **Artifact:** a Bash orchestration wrapper plus a small Python reporting CLI.
- [ ] **Done when:** the wrapper produces artifacts and the Python CLI runs from a fresh venv.

### Week 3 - boto3 Identity, Sessions, Regions, and S3

- [ ] Use `boto3.Session()` with named profiles.
- [ ] Require explicit region selection.
- [ ] Call `sts.get_caller_identity()` before audit operations.
- [ ] Practice both client and resource interfaces and document when to use each.
- [ ] List S3 buckets and read encryption configuration.
- [ ] Read S3 public access block settings.
- [ ] Use paginators where needed.
- [ ] Export normalized JSON for S3 inventory.
- [ ] **Artifact:** S3 inventory script with identity proof and JSON output.
- [ ] **Done when:** the script proves caller identity and reports S3 encryption/public-access state.

### Week 4 - boto3 EC2, IAM, Error Handling, and Mini-Auditor

- [ ] Describe EC2 instances and extract ID, name, state, VPC, subnet, public IP, and tags.
- [ ] Filter EC2 output by state and tag.
- [ ] List IAM users, roles, and attached policies.
- [ ] Parse IAM policy documents and flag wildcard actions or resources.
- [ ] Handle pagination across IAM calls.
- [ ] Catch `botocore.exceptions.ClientError` and print AWS error code and message.
- [ ] Handle `AccessDenied`, missing resources, and empty result sets cleanly.
- [ ] Build a mini-auditor for S3 encryption and public access block.
- [ ] Make the mini-auditor exit non-zero on violations.
- [ ] **Artifact:** AWS mini-auditor that emits JSON and fails on planted S3 violations.
- [ ] **Done when:** one planted violation produces a clear finding and non-zero exit.

---

## Month 2 - Git, GitHub Actions, and Terraform Foundations

### Week 5 - Advanced Git Part 1: Branches, Conflicts, and Recovery

- [ ] Practice `git switch -c`, feature branches, upstream tracking, and branch cleanup.
- [ ] Open a PR/MR-style flow and avoid direct commits to `main`.
- [ ] Deliberately create and resolve a merge conflict.
- [ ] Explain conflict markers and the chosen resolution in the commit message or notes.
- [ ] Practice `stash save`, `stash pop`, `stash list`, and `stash drop`.
- [ ] Practice `reflog` recovery of a "lost" commit.
- [ ] **Artifact:** throwaway repo with commits proving branch flow, conflict resolution, stash, and reflog recovery.
- [ ] **Done when:** you can recover from a bad local Git move without panic.

### Week 6 - Advanced Git Part 2: Rebase, Worktree, Cherry-Pick, Signing

- [ ] Practice interactive rebase squash and reword.
- [ ] Practice resolving conflicts during rebase.
- [ ] Use `git worktree` for parallel branch work.
- [ ] Use `git cherry-pick` to move one fix between branches.
- [ ] Create tags and understand release tag use.
- [ ] Configure GPG or SSH commit signing.
- [ ] Verify signed commits show in GitHub or GitLab.
- [ ] **Artifact:** Git drill repo with signed commits, rebased branch, worktree branch, cherry-pick, and tag.
- [ ] **Done when:** you can explain when to merge, rebase, cherry-pick, stash, and use worktree.

### Week 7 - GitHub Actions Read and Harden

- [ ] Read an existing workflow and identify triggers, jobs, steps, artifacts, env vars, secrets, matrix strategies, and reusable workflow calls.
- [ ] Draw a simple workflow map in notes.
- [ ] List every security-relevant step and whether it blocks merge or deploy.
- [ ] Pin actions to full commit SHA where practical.
- [ ] Pin tool versions instead of using `latest`.
- [ ] Remove or justify `continue-on-error: true` on security steps.
- [ ] Configure or document branch protection, required checks, review requirements, and conversation resolution.
- [ ] Add or update `CODEOWNERS` for workflows, OPA policies, Terraform modules, and CI config.
- [ ] **Artifact:** hardened GitHub Actions workflow or detailed hardening diff plan.
- [ ] **Done when:** a failing security check blocks the workflow and protected files require review.

### Week 8 - Terraform Language Foundations

- [ ] Review variables with explicit `type`, `description`, `default`, `sensitive`, validation, and `nullable = false`.
- [ ] Practice locals, conditionals, `for` expressions, `try`, `lookup`, `coalesce`, `merge`, `flatten`, `jsonencode`, `regex`, and `can`.
- [ ] Use security-relevant data sources: `aws_caller_identity`, `aws_region`, `aws_partition`, `aws_iam_policy_document`, VPC/subnet/KMS lookups.
- [ ] Practice `for_each` over `count` for stable security resource identity.
- [ ] Use lifecycle protections such as `prevent_destroy` for KMS, state buckets, and log buckets.
- [ ] Practice `moved` or `import` blocks in a sandbox.
- [ ] **Artifact:** Terraform sandbox showing secure variables, locals, IAM policy document, `for_each`, and lifecycle controls.
- [ ] **Done when:** you can read a non-trivial `.tf` file cold and explain what changes in a plan.

### Week 9 - Terraform Providers, Backend, State, and Modules

- [ ] Pin Terraform CLI version with `required_version`.
- [ ] Pin AWS provider version in `required_providers`.
- [ ] Configure explicit region and provider `default_tags`.
- [ ] Practice provider `assume_role` pattern.
- [ ] Configure S3 backend with DynamoDB locking in a sandbox.
- [ ] Ensure backend bucket has encryption, versioning, and Block Public Access.
- [ ] Create module structure with `main.tf`, `variables.tf`, `outputs.tf`, and `versions.tf`.
- [ ] Add secure module defaults and variable validation for security-sensitive inputs.
- [ ] **Artifact:** small secure Terraform module plus root using remote-state-style configuration.
- [ ] **Done when:** `terraform init`, `fmt`, `validate`, and `plan` work and state security is documented.

---

## Month 3 - GitLab CI/CD and Real AWS Authentication

### Week 10 - GitLab Project Setup and First Pipeline

- [ ] Create or verify a GitLab project.
- [ ] Configure SSH or token-based auth.
- [ ] Push a sandbox repo.
- [ ] Confirm runner availability and tags.
- [ ] Create `.gitlab-ci.yml` with `stages`, jobs, `script`, `variables`, `artifacts`, `needs`, `rules`, and `when: manual`.
- [ ] Keep jobs small and named by purpose.
- [ ] Set artifact paths and expiry.
- [ ] **Artifact:** first GitLab pipeline that runs successfully and uploads a simple artifact.
- [ ] **Done when:** GitLab CI lint passes and the runner executes the pipeline.

### Week 11 - GitLab Terraform Pipeline

- [ ] Add `terraform fmt -check`.
- [ ] Add `terraform validate`.
- [ ] Add `terraform plan -out=tfplan`.
- [ ] Export `terraform show -json tfplan > tfplan.json`.
- [ ] Upload binary plan and JSON plan as artifacts.
- [ ] Add manual `apply` stage that consumes the saved plan.
- [ ] Add checksum creation for the saved plan.
- [ ] Split jobs into local templates with `include: local:`.
- [ ] Use hidden base jobs such as `.base-terraform`, `extends`, and YAML anchors.
- [ ] **Artifact:** modular GitLab Terraform pipeline.
- [ ] **Done when:** plan artifacts are created and apply uses the exact saved plan.

### Week 12 - AWS OIDC and Least-Privilege CI Role

- [ ] Configure GitLab as an OIDC identity provider in AWS.
- [ ] Create an IAM role with trust policy scoped to project, branch, and audience.
- [ ] Assume the role through STS in CI.
- [ ] Remove static AWS access keys from CI.
- [ ] Validate with `aws sts get-caller-identity` in pipeline logs.
- [ ] Document exact CI role permissions and why each is needed.
- [ ] Use a custom least-privilege policy instead of broad managed policies.
- [ ] Explicitly deny or avoid `iam:*` and `organizations:*` unless justified.
- [ ] Write rollback and break-glass notes for auth misconfiguration.
- [ ] **Artifact:** GitLab CI pipeline authenticated to AWS with OIDC and documented IAM role policy.
- [ ] **Done when:** CI reaches AWS with zero static keys and least-privilege notes are reviewable.

---

## Month 4 - Policy-as-Code and Security Gates

### Week 13 - OPA/Rego Fundamentals and Tests

- [ ] Write `deny` rules that emit structured findings.
- [ ] Include severity, control ID, resource, and message fields.
- [ ] Keep sample Terraform-plan-like JSON inputs beside tests.
- [ ] Write `opa test` cases for passing and failing inputs.
- [ ] Add tests for missing fields and malformed resources.
- [ ] Make test command runnable locally and in CI.
- [ ] **Artifact:** first Rego package with structured deny output and unit tests.
- [ ] **Done when:** `opa test` passes and intentionally breaking a rule fails tests.

### Week 14 - Core Terraform Plan Policies

- [ ] Deny public S3 access.
- [ ] Deny missing S3 encryption.
- [ ] Deny EC2 instances without IMDSv2 enforcement.
- [ ] Deny IAM wildcard actions or resources.
- [ ] Deny security group ingress from `0.0.0.0/0` except explicitly documented allowed cases.
- [ ] Add clear finding messages for every rule.
- [ ] Make policy traversal recurse through nested Terraform `child_modules`.
- [ ] **Artifact:** OPA policy bundle covering S3, EC2, IAM, and security groups.
- [ ] **Done when:** planted insecure Terraform resources are caught with useful findings.

### Week 15 - OPA/Conftest GitLab Gate and Control Mapping

- [ ] Add `controls` fields to every deny rule.
- [ ] Map findings to ISO 27001, NIST CSF, and/or CIS AWS controls.
- [ ] Run `opa eval` or `conftest test` against `tfplan.json` in GitLab CI.
- [ ] Save policy findings JSON as an artifact.
- [ ] Fail the pipeline when any `deny` result fires.
- [ ] Confirm the policy bundle can move into the platform repo without path or input-shape rewrites.
- [ ] **Artifact:** GitLab policy gate that blocks insecure Terraform plans and exports findings.
- [ ] **Done when:** a failing policy gate can be traced from Rego rule to control ID to artifact.

### Week 16 - Security Scanning Tools and SBOM

- [ ] Install `gitleaks` locally as a pre-commit hook and test with a fake AWS key.
- [ ] Add `gitleaks detect` or `trufflehog` to CI and fail on findings.
- [ ] Archive secret scan report as an artifact.
- [ ] Generate `.gitleaks.toml` baseline for justified false positives only.
- [ ] Run Checkov against Terraform in CI with a pinned version.
- [ ] Output Checkov JSON and JUnit formats and fail on high/critical findings.
- [ ] Run Prowler against a sandbox AWS account with a read-only role.
- [ ] Archive Prowler JSON and HTML reports.
- [ ] Run `pip-audit` or `safety` against Python dependencies and fail on critical CVEs.
- [ ] Generate CycloneDX SBOM with `syft` or `cyclonedx-bom`.
- [ ] **Artifact:** CI security scan suite with reports and SBOM.
- [ ] **Done when:** planted secret and high/critical IaC issue fail CI and produce evidence.

---

## Month 5 - Evidence, Drift, State, SCM Security, and Compliance Narrative

### Week 17 - Evidence Bundle and Artifact Integrity

- [ ] Archive `tfplan`, `tfplan.json`, OPA findings, Checkov report, Prowler report, secret scan report, dependency report, and SBOM.
- [ ] Make artifact paths predictable.
- [ ] Generate SHA256 checksum for each artifact.
- [ ] Include git commit SHA, actor, UTC timestamp, pipeline run ID, and branch or tag.
- [ ] Store metadata beside artifacts.
- [ ] Generate checksum for saved `tfplan` after plan stage.
- [ ] Recompute checksum before apply and abort on mismatch.
- [ ] **Artifact:** complete evidence bundle with metadata and plan integrity verification.
- [ ] **Done when:** a tampered plan fails before apply and evidence ties back to actor and commit.

### Week 18 - Drift Detection, State Security, and Retention

- [ ] Add scheduled CI drift job using `terraform plan -detailed-exitcode`.
- [ ] Treat exit code `0` as clean and `2` as drift detected.
- [ ] Export drift plan JSON when drift exists.
- [ ] Archive drift evidence.
- [ ] Notify Slack or email with drifted resources, pipeline link, and timestamp.
- [ ] Lock down remote state bucket with encryption, versioning, Block Public Access, and least-privilege bucket policy.
- [ ] Document Terraform state plaintext-secret risk.
- [ ] Document artifact expiry, storage location, and retention mapping to ISO 27001 Clause 7.5 or chosen framework.
- [ ] Decide whether checksum signing or artifact attestation is required.
- [ ] **Artifact:** scheduled drift pipeline plus state and retention documentation.
- [ ] **Done when:** a drift scenario produces evidence and a received notification.

### Week 19 - SCM Security and Audit Controls

- [ ] Require PR/MR reviews on protected branches.
- [ ] Require all status checks to pass.
- [ ] Disable force push and branch deletion.
- [ ] Enforce CODEOWNERS for `.gitlab-ci.yml`, `.github/workflows/`, `*.rego`, Terraform modules, and `CODEOWNERS`.
- [ ] Require pipeline-change commits to reference ticket, control, or risk.
- [ ] Verify signed commits where required.
- [ ] Confirm Git history on CI/policy files functions as an audit trail.
- [ ] **Artifact:** SCM protection configuration and short audit-control note.
- [ ] **Done when:** CI and policy changes cannot bypass review.

### Week 20 - Alerts, Escalation, and Compliance Documentation

- [ ] Send OPA, Checkov, secret, and dependency-CVE failures to a dedicated security channel.
- [ ] Include pipeline link, failure reason, commit SHA, and actor in alerts.
- [ ] Write escalation documentation: owner, response time, override process, and approval requirements.
- [ ] Create a pipeline architecture diagram.
- [ ] Write the control narrative for each gate: check, risk, mapped control, failure behavior, owner, and evidence.
- [ ] Build traceability matrix: gate, description, control IDs, and evidence location.
- [ ] **Artifact:** architecture diagram, control narrative, traceability matrix, and escalation doc.
- [ ] **Done when:** an assessor can trace a gate from diagram to control to artifact.

---

## Month 6 - Platform Refactor and Portfolio-Ready Validation

### Week 21 - Platform Refactor Mapping

- [ ] Reopen `pipelineGrind.md`, `Compliance-Oriented-Cloud-Security-Platform/context.md`, `pipelinefix.md`, and `DEVSECOPS_PIPELINE_GAP_ANALYSIS.md`.
- [ ] Map existing GitHub Actions workflows to GitLab CI stages and templates.
- [ ] Identify which jobs are real, mocked, skipped, or only documented.
- [ ] Define final GitLab stage order: validate, plan, policy, scan, approval, apply, drift, evidence.
- [ ] Define required artifacts per stage.
- [ ] Decide template boundaries for Terraform, OPA, scanning, evidence, and notification jobs.
- [ ] **Artifact:** GitHub Actions to GitLab migration map and implementation checklist.
- [ ] **Done when:** every existing workflow behavior has a GitLab destination or explicit deprecation reason.

### Week 22 - Platform GitLab Pipeline and Real Auth

- [ ] Branch or fork `Compliance-Oriented-Cloud-Security-Platform`.
- [ ] Add top-level `.gitlab-ci.yml`.
- [ ] Add local GitLab templates for Terraform, policy, scanning, evidence, and notifications.
- [ ] Wire GitLab OIDC to AWS or a tightly scoped role.
- [ ] Replace mock provider credentials and `skip_* = true` patterns in deployable paths.
- [ ] Make apply real, manual, and based on the saved plan.
- [ ] Verify plan checksum before apply.
- [ ] **Artifact:** platform GitLab pipeline with real AWS identity and manual apply path.
- [ ] **Done when:** pipeline reaches AWS with real identity and no static CI keys.

### Week 23 - Platform Gates, Evidence, Drift, and Gap Closure

- [ ] Add OPA/Conftest gate using the semester policy bundle.
- [ ] Add Checkov, secret scanning, dependency scanning, SBOM, and Prowler where appropriate.
- [ ] Ensure negative regression scenarios fail when bad config passes.
- [ ] Fix drift exit-code capture and export drift evidence.
- [ ] Add metadata and checksums to evidence artifacts.
- [ ] Fill or remove empty CI/workflow stubs.
- [ ] Pin tool versions: Checkov, tfsec if used, TFLint, Conftest, OPA, Python tools, Terraform, provider versions.
- [ ] Replace mocked Infracost with real Infracost or document why it remains out of scope.
- [ ] **Artifact:** platform pipeline with blocking security gates and complete evidence output.
- [ ] **Done when:** every security gate can fail the pipeline and exports reviewable evidence.

### Week 24 - End-to-End Validation and Portfolio Polish

- [ ] Run full pipeline against sandbox AWS: validate, plan, scan, policy gate, approval, apply, evidence.
- [ ] Confirm every required artifact is produced.
- [ ] Confirm every blocking gate fails on a planted bad change.
- [ ] Confirm notifications fire and include required context.
- [ ] Confirm drift job detects a controlled drift scenario.
- [ ] Write retrospective: what broke, what was misconfigured, what took longer, and what you would change.
- [ ] Update README or portfolio notes with architecture, controls, evidence, and screenshots/log snippets.
- [ ] Prepare a short interview explanation of the platform: threat model, controls, pipeline flow, tradeoffs, and failure modes.
- [ ] **Artifact:** final E2E validation report, retrospective, and portfolio-ready project documentation.
- [ ] **Done when:** another engineer can clone/read the project and understand the pipeline without verbal explanation.

---

## Platform Gap Backlog

Close these during Month 6. They are not bonus work; they are the proof that the platform is real.

### Critical - Pipeline Claims More Than It Does

- [ ] `Internal-IT/engineering/ci-cd/scripts/run-apply.sh` simulates apply; make apply real.
- [ ] `workloads/ayka-portal/provider.tf` uses mock credentials and `skip_* = true`; wire real auth through GitLab OIDC or a scoped IAM role.
- [ ] Drift detection workflow does not write to `$GITHUB_OUTPUT`; fix exit-code capture or replace with GitLab-native output handling.
- [ ] Negative regression scenarios use `continue-on-error: true`; invert the logic so they fail when bad config passes.

### High - Correctness and Repeatability

- [ ] Pin all tool versions: Checkov, tfsec if used, TFLint, Conftest, OPA, Terraform, Python tools, and provider versions.
- [ ] Stop using unpinned `pip install` in pipeline paths.
- [ ] Turn refresh back on for `terraform plan`; `-refresh=false` hides drift before apply.
- [ ] Fill or remove empty stub files in `ci-cd/pipelines/core/` and `ci-cd/pipelines/compliance/`.
- [ ] Write the intentionally bad VPC in the VPC control-validation scenario where `main.tf` is empty.
- [ ] Add the missing IAM negative scenario that the README claims exists.

### Medium - Audit Credibility

- [ ] Make evidence more immutable with retention, actor ID, checksums, signing, or artifact attestation.
- [ ] Verify the saved plan binary by checksum before apply.
- [ ] Replace mocked Infracost with real Infracost or document why it remains out of scope.
- [ ] Fill or remove empty workflow stubs: `promote-stage.yml`, `promote-prod.yml`, `rollback.yml`, `secrets-scan.yml`, `iam-diff-check.yml`.
- [ ] Fix the workflow named "PR Compliance" if it triggers on `push` instead of `pull_request`, or rename it to match behavior.
- [ ] Update OPA logic that only descends one level of `child_modules`; recurse properly.

### Identity Layer - Separate Track

- [ ] Reopen `Compliance-Oriented-Cloud-Security-Platform/Internal-IT/plan.md` Phases 0-4.
- [ ] Resolve duplicate IAM attachments.
- [ ] Resolve incompatible break-glass implementations.
- [ ] Prevent employees from being in multiple tiers simultaneously.
- [ ] Consolidate source of truth across HR data, Entra ID, and AWS Identity Center.
- [ ] Separate AWS Organization bootstrap concerns from day-2 governance concerns.

---

## Key Files To Reopen

| Purpose                          | Path                                                                                                               |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Canonical DevSecOps checklist    | `DevsecopsChecklist.md`                                                                                            |
| Navigation map and platform gaps | `pipelineGrind.md`                                                                                                 |
| Terraform study depth            | `TerraformChecklist.md`                                                                                            |
| Platform last-state log          | `Compliance-Oriented-Cloud-Security-Platform/context.md`                                                           |
| Platform open gaps               | `Compliance-Oriented-Cloud-Security-Platform/pipelinefix.md`                                                       |
| Platform full roadmap            | `Compliance-Oriented-Cloud-Security-Platform/DEVSECOPS_PIPELINE_GAP_ANALYSIS.md`                                   |
| Identity remediation             | `Compliance-Oriented-Cloud-Security-Platform/Internal-IT/plan.md`                                                  |
| Pipeline architecture            | `Compliance-Oriented-Cloud-Security-Platform/Internal-IT/engineering/ci-cd/architecture.md`                        |
| Control mapping                  | `Compliance-Oriented-Cloud-Security-Platform/Internal-IT/engineering/policy-as-code/metadata/control-mapping.yaml` |
| OPA command reference            | `rego-workbench/index.md`                                                                                          |
| Rego pattern reference           | `rego-workbench/rego-core/rules.rego`                                                                              |
| OPA mini-project                 | `rego-workbench/docs/04-compliance-delivery/11-mini-project-roadmap.md`                                            |
| boto3 next steps                 | `python-sandbox/boto3/plan.md`                                                                                     |
| Python goal context              | `python-sandbox/context.md`                                                                                        |
| DevSecOps macro roadmap          | `DevSecOps/DevOps_Learning_Roadmap.md`                                                                             |
| GitLab setup notes               | `Gitlab-pipeline/setup.md`                                                                                         |
| Git exercises                    | `cloud-sec-platform-git-flow/achievements.md`                                                                      |
| Git reference                    | `cloud-sec-platform-git-flow/Implementation.md`                                                                    |

---

## Weekly Review Template

Use this at the end of each week.

```md
## Week N Review

- Completed:
- Evidence:
- Commands or pipeline runs verified:
- What broke:
- What I still cannot explain clearly:
- Carry-over:
- Next week first action:
```

---

## When Stuck

- [ ] For "where is X in the platform", read `graphify-out/GRAPH_REPORT.md` or use `graphify query` if available.
- [ ] For "what was I doing", run `git log --oneline -20` inside the platform repo.
- [ ] For "what is the gap again", reopen `pipelinefix.md` and `pipelineGrind.md`.
- [ ] For "is this real or simulated", search the platform for `echo`, `simulated`, `mock`, `skip_`, `continue-on-error`, and `-refresh=false`.
- [ ] For "what should this control map to", inspect existing control mappings before inventing new IDs.

---

## Semester Completion Criteria

This plan is complete when:

1. Every week has an artifact, not just notes.
2. The final GitLab pipeline runs end-to-end against a real sandbox AWS account with no mocked apply or fake credentials.
3. OPA, Checkov, secret scanning, dependency scanning, and drift checks can fail the pipeline.
4. Evidence artifacts include plan files, policy findings, scan reports, SBOM, checksums, metadata, and retention settings.
5. Terraform state security is documented and implemented for the sandbox backend.
6. GitHub Actions can be read and hardened, even though GitLab is the final platform target.
7. Advanced Git workflows are practiced in a repo with visible commits: rebase, worktree, cherry-pick, stash, reflog, signed commits, tags, and protected branch flow.
8. boto3 automation can inventory AWS and produce JSON suitable for CI artifacts.
9. Bash wrappers safely orchestrate tools and fail clearly.
10. A compliance assessor can open the repo, read the control narrative, trace each gate to a framework control, and find the matching evidence without verbal explanation.

---

## Carry-over / Gap Log

Record slipped work here. Clear carry-over before starting unrelated new work.

- [ ] _(none yet)_
