function New-EvidencePackManifest {
  param(
    [Parameter(Mandatory=$true)]$Plan,
    [Parameter(Mandatory=$true)][string]$RunDate
  )

  $top = $Plan | Select-Object -First 10
  $manifest = [PSCustomObject]@{
    PackName = "EvidencePack-$RunDate"
    Created  = $RunDate
    Notes    = "Simulated evidence pack manifest. Extend by collecting EDR triage, patch logs, and change approvals."
    Items    = @()
  }

  foreach ($t in $top) {
    $manifest.Items += [PSCustomObject]@{
      Asset = $t.Asset
      CVE   = $t.CVE
      Priority = $t.Priority
      EvidenceSuggested = @(
        "Before/after patch version output",
        "Change approval record",
        "Service health check screenshot",
        "EDR telemetry confirming clean status"
      )
    }
  }
  return $manifest
}
