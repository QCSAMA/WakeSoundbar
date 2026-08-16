# Simplified Chinese Edition

The generic files in the repository root are the only implementation source.
`locales/zh-CN/` is a translation overlay, not a branch and not a second product.
It exists so the Chinese release can be rebuilt and tested without copying
ad-hoc files from an old release archive.

## Files

The Chinese release contains exactly these five files under one root directory:

1. `WakeSoundbar.ps1`
2. `install.bat`
3. `uninstall.bat`
4. `README.md`
5. `LICENSE`

The first four are maintained in `locales/zh-CN/`. `LICENSE` always comes from
the repository root.

## Synchronization Rule

Update generic files first. Then bring the matching Chinese overlay file up to
date in the same change.

- Keep parameters, target filtering, retry behavior, exit codes, scheduled-task
  behavior, and file names identical to generic.
- Translate only comments, README prose, terminal labels, and status messages.
- Do not change hardware behavior only for the Chinese edition.
- When a generic PowerShell logic block changes, copy that block into
  `locales/zh-CN/WakeSoundbar.ps1` first, then translate its user-facing text.
- When generic installer behavior changes, port the same command flow into the
  Chinese batch wrapper before changing any Chinese wording.

Before release, compare the generic and Chinese PowerShell files by function,
parameter list, task registration command, target filter, and exit paths. A
translation must never silently lose a generic bug fix.

## Batch Encoding Contract

Windows `cmd.exe` does not handle multilingual batch source consistently across
console code pages. The Chinese `install.bat` and `uninstall.bat` therefore
have a strict contract:

- ASCII-only source bytes.
- UTF-8 without a BOM.
- CRLF line endings.
- All Chinese text is UTF-8 Base64 passed to the `:say` helper and printed by
  Windows PowerShell.
- All inline PowerShell commands inside the batch files remain ASCII.

Do not put literal Chinese text, a UTF-8 BOM, or editor-converted line endings
into either Chinese batch file. Those changes can turn text into commands and
interrupt installation or removal.

`locales/zh-CN/WakeSoundbar.ps1` and `locales/zh-CN/README.md` use UTF-8 with
a BOM so Windows PowerShell 5.1 reads Chinese text correctly.

## Build And Verify

From the repository root on Windows:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\Build-CNRelease.ps1 -Version 1.0.0
```

The command writes `dist/WakeSoundbar-v1.0.0-CN.zip`. It checks the batch-file
encoding contract, verifies the Chinese PowerShell script with Windows
PowerShell 5.1, and verifies the ZIP has one root directory and exactly five
files.

Before publishing a changed Chinese package, run these manual checks on a real
Chinese Windows console:

1. Extract the ZIP, then run `install.bat` from both Explorer and PowerShell.
2. Confirm Chinese status text is readable, no text is interpreted as a command,
   and the window waits for a keypress after success or failure.
3. Confirm the scheduled task belongs to the current interactive user.
4. Run `uninstall.bat` and confirm it removes the task and installation folder.
5. Perform a real restart-and-logon test when runtime behavior changed.
