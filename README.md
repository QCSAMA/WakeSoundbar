# WakeSoundbar

[English](README.md) | [&#31616;&#20307;&#20013;&#25991;](README.zh-CN.md)

WakeSoundbar fixes a Windows problem: an HDMI soundbar or AVR may stay asleep
after a restart when **Remove display from desktop** is enabled.

Install it once. WakeSoundbar checks the soundbar at every logon. It does not
add a second desktop, open Settings, or leave an app running in the background.

## Is This for You?

WakeSoundbar may help if all of these are true:

- Your soundbar or AVR is connected to a second HDMI output.
- Your main display uses features such as 4K, HDR, high refresh rate, VRR, or
  G-Sync.
- You enabled **Remove display from desktop** for the soundbar or AVR.
- HDMI audio sometimes disappears after a restart.

The soundbar may be connected to a dedicated GPU or an integrated GPU.

## Install

1. Download and extract the ZIP from the
   [latest release](https://github.com/QCSAMA/WakeSoundbar/releases/latest).
2. Turn on the soundbar or AVR and connect it over HDMI.
3. Open **Settings > System > Display > Advanced display**.
4. Select the soundbar or AVR and enable **Remove display from desktop**.
5. Double-click `install.bat`.
6. When Windows asks for permission, select **Yes**.
7. If a numbered list appears, enter the number for the soundbar or AVR.
8. Wait for `[SUCCESS]`, then press any key to close the window.

WakeSoundbar will now run automatically when this Windows account logs on.

Use the administrator account that will run WakeSoundbar. If another
administrator account is entered at the permission prompt, the automatic task
will belong to that account instead.

## What It Avoids

- **Extend desktop:** creates an invisible second screen, traps the pointer,
  and can confuse remote desktop software.
- **Duplicate desktop:** can limit the main display's resolution, refresh rate,
  HDR, VRR, or G-Sync.
- **S/PDIF:** avoids a second display, but cannot carry the same lossless
  multichannel formats as HDMI.

WakeSoundbar keeps the soundbar removed from the desktop and wakes only its
HDMI connection.

## Requirements

- Windows 11 is the tested system.
- Windows 10 version 1809 or newer may also work.
- Windows PowerShell 5.1.
- Administrator permission during installation and removal.
- Compatible GPU, driver, soundbar or AVR, and HDMI connection.

Hardware and drivers differ. A setup that works on one PC may not work on
another PC.

## If It Does Not Work

### The installer says no eligible target was found

- Run the installer directly on the PC, not through Remote Desktop.
- Make sure the soundbar or AVR is on and connected over HDMI.
- Check that **Remove display from desktop** is still enabled.
- Wait a few seconds for Windows to detect the device, then run `install.bat`
  again.

### The wrong device was selected

Run `install.bat` again. The installer will show the numbered list again.

### Check the automatic task

Open PowerShell and run:

```powershell
Get-ScheduledTask -TaskName WakeSoundbar
Get-ScheduledTaskInfo -TaskName WakeSoundbar
```

Installed files are stored in `%ProgramData%\WakeSoundbar`. WakeSoundbar does
not create log files. A manual run prints the result in the terminal.

When reporting a problem, include the Windows version, GPU and driver, soundbar
or AVR model, and HDMI connection layout. Do not post monitor IDs or other
private system details in a public issue.

## Uninstall

1. Double-click `uninstall.bat`.
2. Approve the Windows permission prompt.
3. Wait for `[SUCCESS]`, then press any key.

This removes the automatic task and all installed WakeSoundbar files.

<details>
<summary><strong>Advanced use and technical details</strong></summary>

## Advanced Use

Run the script manually:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1
```

Useful diagnostic options:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -NoSleep
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -IncludeStandardTargets
```

`-IncludeStandardTargets` may act on normal desktop displays. Use it only for
diagnosis on a controlled PC.

To select one known target directly:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -StableMonitorId RSR66621_0C_07E5_C6
```

Exit codes are `0` for success or no action needed, `1` for startup or platform
errors, and `2` when a target was found but could not be activated.

## How It Works

For users who want the technical details:

1. The script lists connected Windows display targets.
2. It keeps only targets marked `SpecialPurpose` by Windows.
3. It optionally matches the saved `StableMonitorId`.
4. It connects the selected target and calls `TryApply`.

The script does not select devices by product name. This avoids guessing when
VR headsets, capture devices, or other special displays are connected.

WakeSoundbar uses `Windows.Devices.Display.Core`. It wakes the HDMI display
path; it does not decode audio or guarantee a specific audio format.

</details>

## Tested Status

Before the first release, the author tested the setup through three Windows 11
restart and logon cycles on one PC. This confirms that setup only. It does not
guarantee support for every GPU or driver.

## Project Information

- Small project specification: [`openspec/spec.md`](openspec/spec.md)
- Contribution guide: [`CONTRIBUTING.md`](CONTRIBUTING.md)
- Security policy: [`SECURITY.md`](SECURITY.md)
- Contact: [qcsama@upwell.freeqiye.com](mailto:qcsama@upwell.freeqiye.com)

WakeSoundbar is licensed under AGPL-3.0-only. See [LICENSE](LICENSE) for the
full license text.
