# Security Policy

WakeSoundbar is a local Windows utility. It requests administrator privileges
only to install or remove its scheduled task and files.

Do not include serial numbers, monitor identifiers, or private system
information in a public issue. Terminal output may contain adapter and target
identifiers. `install.log` records setup testing; `last-run.log` is overwritten
by each scheduled execution. Transcripts may also contain account names, SIDs
and local paths. Redact them before sharing. Only Administrators and SYSTEM
may write the installation directory because the task runs elevated.

## Reporting

Please report security issues privately through the repository's configured
security advisory channel or email
[qcsama@upwell.freeqiye.com](mailto:qcsama@upwell.freeqiye.com). Do not include
sensitive details in a public issue.

Supported security fixes target the latest published release.
