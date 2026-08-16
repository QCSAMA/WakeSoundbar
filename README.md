# WakeSoundbar

[English](README.md) | [&#31616;&#20307;&#20013;&#25991;](README.zh-CN.md)

Connect a monitor and a soundbar or AVR to the same PC over HDMI, and Windows
treats both as displays. Extending the desktop leaves a phantom screen that can
catch the pointer or confuse remote desktop software. Duplicating or mirroring
sounds simpler, but the soundbar's video limits can hold back the main display,
costing you resolution, refresh rate, HDR, VRR, or G-Sync. S/PDIF avoids the
extra screen, but also gives up the lossless multichannel formats available
over HDMI.

The cleanest setup is to select the soundbar in Windows and enable
**Remove display from desktop**. The main display keeps its full capabilities,
the soundbar no longer takes up desktop space, and the HDMI audio connection
is preserved. The catch is that, in the setup this tool targets, every reboot
leaves that removed HDMI path asleep. Until it is woken again, the soundbar
does not appear as an audio device, so you would otherwise have to open
Settings and toggle the option by hand after every restart.

WakeSoundbar automates that last, tedious step. At logon it finds the removed
soundbar path, wakes it, and exits. You install it once; after that there is no
Settings window to open, no display mode to toggle, and no background app left
running.

This is the setup WakeSoundbar was built for: a gaming PC or HTPC keeping 4K,
HDR, high refresh rate, and VRR on the main display while a second HDMI output
handles Dolby Atmos, TrueHD, or multichannel LPCM. The soundbar can be connected
to either a dedicated GPU or integrated graphics.

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

That is it. WakeSoundbar will now run whenever this Windows account logs on.

Install it while signed in to the administrator account that will use it. If
Windows asks for credentials for a different administrator, the automatic task
will be created for that account instead.

## Requirements

- Windows 11 (tested).
- Windows 10 version 1809 or newer may work as well.
- Windows PowerShell 5.1.
- Administrator access for installation and removal.
- A GPU, driver, soundbar or AVR, and HDMI connection that support this setup.

Compatibility ultimately depends on the hardware and display driver. Success
on one PC does not guarantee the same result on every system.

## If It Does Not Work

### The installer cannot find an eligible target

- Run the installer directly on the PC, not through Remote Desktop.
- Make sure the soundbar or AVR is on and connected over HDMI.
- Check that **Remove display from desktop** is still enabled.
- Give Windows a few seconds to detect the device, then run `install.bat` again.

### The wrong device was selected

Run `install.bat` again. The installer will offer a fresh device list.

### Check the automatic task

Open PowerShell and run:

```powershell
Get-ScheduledTask -TaskName WakeSoundbar
Get-ScheduledTaskInfo -TaskName WakeSoundbar
```

Installed files are stored in `%ProgramData%\WakeSoundbar`. WakeSoundbar does
not create log files. A manual run prints the result in the terminal.

When opening an issue, include your Windows version, GPU and driver, soundbar
or AVR model, and how the HDMI cables are connected. Leave monitor IDs and
other private system details out of public issues.

## Uninstall

1. Double-click `uninstall.bat`.
2. Approve the Windows permission prompt.
3. Wait for `[SUCCESS]`, then press any key.

This removes the automatic task and every file installed by WakeSoundbar.

## Advanced Use

Run the script manually:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1
```

For troubleshooting, these options are also available:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -NoSleep
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -IncludeStandardTargets
```

`-IncludeStandardTargets` may act on ordinary desktop displays. Use it only
while you are at the PC and can restore its display settings.

To select one known target directly:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -StableMonitorId RSR66621_0C_07E5_C6
```

Exit codes are `0` for success or no action needed, `1` for startup or platform
errors, and `2` when a target was found but could not be activated.

## How It Works

1. The script asks Windows for the currently connected display targets.
2. It keeps only targets Windows marks as `SpecialPurpose`.
3. If you selected a device during installation, it matches the saved
   `StableMonitorId`.
4. It connects that target and calls `TryApply`.

WakeSoundbar never guesses from a product name. That matters on PCs with a VR
headset, capture card, or another special display attached.

Under the hood it uses `Windows.Devices.Display.Core` to wake the HDMI display
path. It does not decode audio, and it cannot promise that a particular GPU,
driver, or audio format will work.

## Tested Status

Before the first release, the author's Windows 11 setup completed three full
restart-and-logon tests successfully. That is a real hardware test, but only
for one PC; other GPU and driver combinations may behave differently.

## Project Information

- Small project specification: [`openspec/spec.md`](openspec/spec.md)
- Contribution guide: [`CONTRIBUTING.md`](CONTRIBUTING.md)
- Security policy: [`SECURITY.md`](SECURITY.md)
- Contact: [qcsama@upwell.freeqiye.com](mailto:qcsama@upwell.freeqiye.com)

WakeSoundbar is licensed under AGPL-3.0-only. See [LICENSE](LICENSE) for the
full license text.
