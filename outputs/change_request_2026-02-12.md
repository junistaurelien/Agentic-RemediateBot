# Change Request Draft – Remediation Window (2026-02-12)

**Purpose:** Approve remediation actions for highest-risk vulnerabilities prioritized by Agentic-RemediateBot.

## Proposed Implementation Plan
| Priority | Asset | CVE | Fix | Rollback | Validation | Owner |
|---|---|---|---|---|---|---|
| P1 | WEB-SRV-01 | CVE-2023-1234 | Apply KB5031234; restart; validate service health | Uninstall KB5031234; restore IIS config backup | Confirm version; run health check; verify WAF logs | Windows Server |
| P2 | DB-SRV-02 | CVE-2022-5678 | yum update package-x; restart service | yum downgrade package-x; restore snapshot | rpm -q package-x; run app smoke test | Linux Server |

## Approval Gate (Human-in-the-loop)
**No remediation actions will be executed until this change is approved.**
