# WakeSoundbar

WakeSoundbar is a small Windows PowerShell utility that re-applies a display
path for a connected `SpecialPurpose` display target at user logon. It is
intended for HDMI-connected soundbars and AVRs configured in Windows as
displays removed from the desktop.

The project uses the Windows `Windows.Devices.Display.Core` API. It does not
control an audio endpoint directly; it asks the display stack to activate the
target so that the HDMI link and its audio capabilities can be negotiated.

Licensed under the GNU Affero General Public License v3.0. See [LICENSE](LICENSE).

## Requirements

- Windows 10 version 1809 (build 17763) or newer; Windows 11 is the tested target.
- Windows PowerShell 5.1.
- A connected display target configured as a special-purpose display.
- Administrator privileges for installation and scheduled-task registration.
- A GPU, driver, soundbar/AVR, and HDMI topology that support the desired mode.

The feature is hardware- and driver-dependent. A successful run on one machine
does not guarantee the same result on another machine.

## Quick Start

1. Configure the soundbar/AVR display in Windows so it is removed from the desktop.
2. Run `install.bat` as administrator.
3. If multiple special-purpose targets exist, choose the soundbar/AVR by number
   when prompted. The choice is saved for future logons.
4. Review the initial result printed in the installer window.
5. The task runs for the installing user at logon.

The installer keeps its window open after completion. Press any key after
reviewing the success or failure message.

To remove the task and installed files, run `uninstall.bat` as administrator.

The uninstaller also prints an explicit result and waits for a keypress before
closing.

## Manual Run

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1
```

Useful diagnostics:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -NoSleep
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -IncludeStandardTargets
```

`-IncludeStandardTargets` is intentionally opt-in and may affect ordinary
display targets. The normal path only considers `SpecialPurpose` targets.
For a multi-display machine, `-StableMonitorId` can restrict the run to a
known monitor identifier.

If more than one connected `SpecialPurpose` target is found during an
interactive install, the tool shows a numbered menu and saves the chosen
stable ID in `target-id.txt` under the installation directory. A hidden logon
run never prompts. Manual explicit selection remains available:

Running `install.bat` again deliberately starts a fresh interactive selection,
so you can switch to a different target without editing the ID file.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -StableMonitorId RSR66621_0C_07E5_C6
```

The script exits with code `0` for success or a no-op, `1` for initialization
or platform errors, and `2` when eligible targets were found but none could be
activated. Partial success returns `0` and is reported in the terminal.

`No eligible SpecialPurpose targets found` means the current Windows API
snapshot did not expose a matching target. An already active special-purpose
display may still be reported as an eligible target; the decisive value is the
reported `UsageKind`, not the Windows UI label alone.

## How It Works

1. Enumerates current display targets.
2. Filters connected `SpecialPurpose` targets, optionally by `StableMonitorId`.
3. Acquires each target and creates an empty `DisplayState`.
4. Connects the target and calls `TryApply`.
5. Re-enumerates briefly if the display stack has not exposed the target yet,
   then releases `DisplayManager` ownership.

The observed behavior of a particular GPU driver, DWM session, soundbar, or
AVR is not guaranteed by the WinRT API. Remote Desktop sessions and changing
display topology can make acquisition fail.

## OpenSpec

The small project contract and non-goals are recorded in
[`openspec/spec.md`](openspec/spec.md). It is deliberately short: this is a
single-script utility, not a service or a general display manager.

## Development Checks

The repository includes a GitHub Actions workflow that parses the PowerShell
script and runs PSScriptAnalyzer. Hardware activation remains a manual test
because hosted CI runners do not have the target display topology.

## License Notes

This project is licensed under AGPL-3.0-only. AGPL permits commercial use and
distribution subject to its conditions. Network source-availability terms
apply to covered modified versions as described by the license; consult the
canonical text in `LICENSE` for the exact obligations.
