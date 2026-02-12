function Get-RiskScore {
  param(
    [Parameter(Mandatory=$true)]$Row,
    [Parameter(Mandatory=$true)]$Policy
  )

  $w = $Policy.ScoringWeights

  $cvss = [double]$Row.CVSS
  $exploit = if ($Row.ExploitAvailable -eq "Yes") { 1 } else { 0 }
  $internet = if ($Row.InternetFacing -eq "Yes") { 1 } else { 0 }
  $sensitivity = if ($Row.DataSensitivity -eq "High") { 1 } else { 0 }
  $opRisk = if ($Row.CurrentState -eq "Deferred") { 1 } else { 0 }

  $score = [Math]::Round(($cvss * $w.CVSS) + ($exploit * $w.ExploitAvailable) + ($internet * $w.InternetFacing) + ($sensitivity * $w.DataSensitivity) + ($opRisk * $w.OperationalRisk), 0)

  # Priority mapping
  $priority = "P4"; $sla = 240
  if ($Row.Severity -eq "Critical" -and $Row.ExploitAvailable -eq "Yes") { $priority="P1"; $sla=24 }
  elseif ($Row.Severity -eq "High" -and $Row.ExploitAvailable -eq "Yes") { $priority="P2"; $sla=72 }
  elseif ($Row.Severity -eq "High") { $priority="P3"; $sla=120 }
  elseif ($Row.Severity -eq "Medium") { $priority="P4"; $sla=240 }

  $Row | Add-Member -NotePropertyName "RiskScore" -NotePropertyValue $score -Force
  $Row | Add-Member -NotePropertyName "Priority" -NotePropertyValue $priority -Force
  $Row | Add-Member -NotePropertyName "SLAHours" -NotePropertyValue $sla -Force

  return $Row
}
