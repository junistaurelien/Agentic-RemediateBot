# Playbook – Internet-Facing Critical Patch (P1)

**Date Context:** 2026-02-12 (Simulated)

## Trigger
- Severity: Critical
- Exploit Available: Yes
- Internet Facing: Yes

## Actions
- Validate exposure (WAF/Firewall logs)
- Schedule emergency change window (CAB)
- Apply patch + restart services
- Validate service health + security controls
- Capture evidence and close ticket
