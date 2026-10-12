# Changelog

## 1.1.0 - 2026-10-12

- Validate hardware before updating deployment, roll back failures, and verify
  an actual scheduled execution before reporting installation success.
- Reject elevation into a different desktop account, protect installed scripts,
  and share setup/removal logic between generic and Chinese editions.
- Delay logon execution 30 seconds, retry failures twice, and write bounded
  installation and runtime transcripts for diagnosis.
- Re-enumerate display targets on retry; report missing targets and partial
  failures with nonzero exit codes instead of silently succeeding.
- Correct Windows edition guidance: Microsoft documented the Specialized Display
  option for Windows 10 Enterprise / Pro for Workstations before Windows 11 24H2.
- Add 22 regression cases and reproducible generic/CN release packages.

Extract the entire ZIP. Setup-WakeSoundbar.ps1 is now required alongside the batch
wrappers. Existing users should rerun install.bat. Exit code 3 now means no
eligible target; code 2 includes partial activation failures. Logs may contain
private device/account identifiers; redact before sharing.

Validated locally by real hardware activation and a scheduled task returning 0.
A cold-boot/login check of this revision and other hardware remain unverified.

## 1.0.0

- Initial HDMI soundbar wake script and per-user logon task.
