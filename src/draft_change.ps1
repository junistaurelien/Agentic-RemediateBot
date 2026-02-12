function New-ChangeRequestDraft {
  param(
    [Parameter(Mandatory=$true)]$Items,
    [Parameter(Mandatory=$true)][string]$RunDate
  )

  $lines = New-Object System.Collections.Generic.List[string]
  $lines.Add("# Change Request Draft – Remediation Window ($RunDate)")
  $lines.Add("")
  $lines.Add("**Purpose:** Approve remediation actions for highest-risk vulnerabilities prioritized by Agentic-RemediateBot.")
  $lines.Add("")
  $lines.Add("## Scope")
  $lines.Add("This change covers P1/P2 findings identified on $RunDate. Execution requires Change Advisory approval and validation evidence.")
  $lines.Add("")
  $lines.Add("## Proposed Implementation Plan")
  $lines.Add("| Priority | Asset | CVE | Fix | Rollback | Validation | Owner |")
  $lines.Add("|---|---|---|---|---|---|---|")
  foreach ($i in $Items) {
    $fix = ($i.RecommendedFix -replace "\|","/")
    $rb  = ($i.Rollback -replace "\|","/")
    $val = ($i.Validation -replace "\|","/")
    $lines.Add("| $($i.Priority) | $($i.Asset) | $($i.CVE) | $fix | $rb | $val | $($i.OwnerTeam) |")
  }
  $lines.Add("")
  $lines.Add("## Risk & Impact")
  $lines.Add("- Reduced exposure for internet-facing and high-sensitivity assets.")
  $lines.Add("- Temporary service restarts may occur during patching.")
  $lines.Add("")
  $lines.Add("## Approval Gate (Human-in-the-loop)")
  $lines.Add("**No remediation actions will be executed until this change is approved.**")
  $lines.Add("")
  return $lines
}
