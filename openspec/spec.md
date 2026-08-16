# WakeSoundbar OpenSpec

## Objective

At user logon, re-apply a display path for a connected special-purpose display
target so an HDMI soundbar or AVR can renegotiate its link without adding a
normal desktop monitor.

## Scope

- Windows PowerShell 5.1.
- Windows display targets exposed by `Windows.Devices.Display.Core`.
- Default operation on connected `DisplayMonitorUsageKind.SpecialPurpose` targets.
- A small scheduled-task installer and matching uninstaller.
- Human-readable terminal status and meaningful process exit codes.

## Requirements

### R1: Target selection

The default path MUST ignore disconnected and standard desktop targets. An
explicit diagnostic switch MAY include standard targets. If multiple connected
SpecialPurpose targets exist and no stable monitor ID is supplied, the tool
MUST prompt for a numeric selection only in an explicitly interactive run;
otherwise it MUST stop and print the available IDs instead of guessing.
An interactive run MUST ignore a previously saved selection so the user can
change the selected target by rerunning the installer.

### R2: Apply result

The tool MUST count a target as activated only when `TryApply` returns
`DisplayStateOperationStatus.Success`. Partial and failed results MUST be
printed in the terminal.

### R3: Resource ownership

The tool MUST dispose `DisplayManager` in a `finally` block after enumeration
and application, including failure paths.

### R4: Retry behavior

Transient system-state changes and startup target enumeration MAY be retried
with bounded, configurable delays. A stale target snapshot MUST be skipped and
re-enumerated rather than retried indefinitely. The tool MUST NOT loop
indefinitely.

### R5: Installer

The installer MUST be idempotent, register the task for the installing
interactive user at highest privilege, verify task registration, and return a
non-zero code on failure.

### R6: Uninstaller

The uninstaller MUST verify the project installation marker before removing the
task and installation directory.

### R7: Documentation

Documentation MUST distinguish display-pipeline activation from direct audio
endpoint control and MUST describe hardware/driver dependence.

### R8: User feedback

The batch installer and uninstaller MUST print an explicit success or failure
message and wait for a keypress before the visible command window exits.

## Non-goals

- No GUI.
- No permanent Windows service.
- No direct audio mixer or endpoint management.
- No automatic changes to ordinary desktop monitors by default.
- No claim of universal Atmos, HDR, VRR, or refresh-rate support.
