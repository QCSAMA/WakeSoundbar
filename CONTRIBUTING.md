# Contributing

Keep changes small and focused. This project intentionally has no service,
background daemon, bundled dependency, or GUI.

Before opening a pull request:

1. Run the PowerShell parser and PSScriptAnalyzer checks locally.
2. Test installation, logon execution, and uninstallation on a disposable test account.
3. Record Windows build, GPU driver, HDMI topology, and result for hardware changes.
4. Do not commit monitor identifiers or private system details.

Hardware-dependent changes should include a manual test note. Do not claim
universal support from a single machine.
