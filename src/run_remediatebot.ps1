<#
.SYNOPSIS
  Agentic-RemediateBot (Simulated) – Remediation Planning + Change Ticket Drafting
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$BacklogPath = Join-Path $RepoRoot "data\vulnerability_backlog_simulated_2026-02-12.csv"
$PolicyPath  = Join-Path $PSScriptRoot "policy.json"

$outPlan = Join-Path $RepoRoot "outputs\remediation_plan_2026-02-12.csv"
$outCRQ  = Join-Path $RepoRoot "outputs\change_request_2026-02-12.md"
$outExec = Join-Path $RepoRoot "outputs\executive_summary_2026-02-12.txt"
$outManifest = Join-Path $RepoRoot "evidence_pack\manifest_2026-02-12.json"

. (Join-Path $PSScriptRoot "score.ps1")
. (Join-Path $PSScriptRoot "draft_change.ps1")
. (Join-Path $PSScriptRoot "evidence_pack.ps1")

Write-Host "== Agentic-RemediateBot ==" -ForegroundColor Cyan
Write-Host "Input:  $BacklogPath"
Write-Host "Policy: $PolicyPath"

if (!(Test-Path $BacklogPath)) { throw "Missing backlog file: $BacklogPath" }
if (!(Test-Path $PolicyPath))  { throw "Missing policy file:  $PolicyPath" }

$policy = Get-Content -Raw -Path $PolicyPath | ConvertFrom-Json
$rows = Import-Csv -Path $BacklogPath

# Enrich: exposure + sensitivity tags (demo)
foreach ($r in $rows) {
  $r | Add-Member -NotePropertyName "InternetFacing" -NotePropertyValue ($(if ($r.Asset -match "^WEB") {"Yes"} else {"No"})) -Force
  $r | Add-Member -NotePropertyName "DataSensitivity" -NotePropertyValue ($(if ($r.Asset -match "^DB" -or $r.Asset -match "^FIN") {"High"} else {"Medium"})) -Force
}

$scored = $rows | ForEach-Object { Get-RiskScore -Row $_ -Policy $policy }

# Sort & export plan
$plan = $scored | Sort-Object RiskScore -Descending
$plan | Export-Csv -NoTypeInformation -Path $outPlan

# Draft change request (top P1/P2 items)
$top = $plan | Where-Object { $_.Priority -in @("P1","P2") } | Select-Object -First 5
$crq = New-ChangeRequestDraft -Items $top -RunDate "2026-02-12"
$crq | Out-File -FilePath $outCRQ -Encoding UTF8

# Evidence pack manifest
$manifest = New-EvidencePackManifest -Plan $plan -RunDate "2026-02-12"
$manifest | ConvertTo-Json -Depth 6 | Out-File -FilePath $outManifest -Encoding UTF8

# Exec summary
$total = @($plan).Count
$p1 = @($plan | Where-Object { $_.Priority -eq "P1" }).Count
$p2 = @($plan | Where-Object { $_.Priority -eq "P2" }).Count
$crit = @($plan | Where-Object { $_.Severity -eq "Critical" }).Count
$high = @($plan | Where-Object { $_.Severity -eq "High" }).Count

$txt = New-Object System.Collections.Generic.List[string]
$txt.Add("AGENTIC-REMEDIATEBOT – EXECUTIVE SUMMARY")
$txt.Add("Date: 2026-02-12")
$txt.Add("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$txt.Add("")
$txt.Add("1) Executive Summary")
$txt.Add("Agentic-RemediateBot demonstrates an automation-first remediation planning workflow that prioritizes vulnerabilities, drafts change tickets, and packages evidence for review. Execution is gated by human approval (Change Management).")
$txt.Add("")
$txt.Add("2) Snapshot")
$txt.Add(" - Total Findings: $total")
$txt.Add(" - Critical: $crit | High: $high")
$txt.Add(" - P1: $p1 | P2: $p2")
$txt.Add("")
$txt.Add("3) Highest Risk Items (Top 3)")
foreach ($t in ($plan | Select-Object -First 3)) {
  $txt.Add(" - [$($t.Priority)] $($t.Asset) $($t.CVE) | Sev=$($t.Severity) CVSS=$($t.CVSS) Exploit=$($t.ExploitAvailable) | Score=$($t.RiskScore)")
  $txt.Add("   Fix: $($t.RecommendedFix)")
  $txt.Add("   Validation: $($t.Validation)")
}
$txt.Add("")
$txt.Add("4) Controls & Governance")
$txt.Add(" - Human-in-the-loop approval required before remediation execution.")
$txt.Add(" - Change ticket drafts include rollback and validation steps for audit readiness.")
$txt.Add("")
$txt.Add("End of Summary")
$txt | Out-File -FilePath $outExec -Encoding UTF8

Write-Host "Done." -ForegroundColor Green
Write-Host "Plan:      $outPlan"
Write-Host "CRQ Draft: $outCRQ"
Write-Host "Exec:      $outExec"
Write-Host "Manifest:  $outManifest"
