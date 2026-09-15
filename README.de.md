# WakeSoundbar

[English](README.md) | [简体中文](README.zh-CN.md) |
[繁體中文](README.zh-TW.md) | [Español](README.es.md) |
[Português (Brasil)](README.pt-BR.md) | [Deutsch](README.de.md) |
[Français](README.fr.md) | [日本語](README.ja.md) | [한국어](README.ko.md) |
[Русский](README.ru.md)

WakeSoundbar ist ein kleines Windows-11-Tool, das den HDMI-Ton einer Soundbar
oder eines AV-Receivers nach der Anmeldung wiederherstellt, wenn das Gerät mit
**Anzeige vom Desktop entfernen** eingerichtet ist. Es weckt den entfernten
HDMI-Anzeigepfad auf, damit das Audiogerät wieder erscheint, ohne die
4K-, HDR-, Bildwiederholraten- oder VRR-Einstellungen des Hauptmonitors zu
verändern und ohne einen Hintergrundprozess laufen zu lassen.

**Geeignet für**

- Gaming-PCs oder HTPCs
- Soundbars oder AV-Receiver mit HDMI-Anschluss
- Systeme, bei denen der HDMI-Ton nach einem Neustart verschwindet

**Nicht geeignet für**

- Bluetooth-, USB- oder S/PDIF-Audio
- Konfigurationen ohne **Anzeige vom Desktop entfernen**

## Warum es das gibt

Schließt du Monitor und Soundbar oder AV-Receiver per HDMI an denselben PC an, behandelt Windows beide als Displays. Der erweiterte Desktop erzeugt einen unsichtbaren Geisterbildschirm, auf dem der Mauszeiger landen kann und der Remote-Desktop-Software verwirrt. Duplizieren oder Spiegeln klingt einfacher, aber die Bildgrenzen der Soundbar können den Hauptmonitor ausbremsen und Auflösung, Bildwiederholrate, HDR, VRR oder G-Sync beeinträchtigen. S/PDIF umgeht den zusätzlichen Bildschirm, verzichtet aber auch auf die verlustfreien Mehrkanalformate von HDMI.

Die sauberste Lösung ist, die Soundbar in Windows auszuwählen und **Anzeige vom Desktop entfernen** zu aktivieren. Der Hauptmonitor behält seine vollständigen Funktionen, die Soundbar belegt keinen Platz auf dem Desktop und die HDMI-Audioverbindung bleibt erhalten. Der Haken: In der Konfiguration, für die dieses Tool gedacht ist, bleibt der entfernte HDMI-Pfad nach jedem Neustart inaktiv. Bis er wieder geweckt wird, taucht die Soundbar nicht als Audiogerät auf. Ohne WakeSoundbar müsstest du deshalb nach jedem Neustart die Einstellungen öffnen und die Option von Hand umschalten.

WakeSoundbar übernimmt genau diesen letzten, lästigen Schritt. Beim Anmelden findet es den entfernten Soundbar-Pfad, weckt ihn auf und beendet sich. Einmal installieren, danach keine Einstellungen öffnen, keinen Anzeigemodus umschalten und keine ständig laufende App.

Gedacht ist das für Gaming-PCs und HTPCs: 4K, HDR, hohe Bildwiederholrate und VRR bleiben am Hauptmonitor erhalten, während ein zweiter HDMI-Ausgang Dolby Atmos, TrueHD oder mehrkanaliges LPCM übernimmt. Die Soundbar kann an einer dedizierten GPU oder an der integrierten Grafik hängen.

## Installation

1. Lade das ZIP aus dem [neuesten Release](https://github.com/QCSAMA/WakeSoundbar/releases/latest) herunter und entpacke es.
2. Schalte die Soundbar oder den AV-Receiver ein und verbinde ihn per HDMI.
3. Öffne **Einstellungen > System > Anzeige > Erweiterte Anzeige**.
4. Wähle die Soundbar oder den Receiver aus und aktiviere **Anzeige vom Desktop entfernen**.
5. Doppelklicke auf `install.bat`.
6. Wenn Windows nach der Berechtigung fragt, wähle **Ja**.
7. Wenn eine nummerierte Liste erscheint, gib die Nummer der Soundbar oder des Receivers ein.
8. Warte auf `[SUCCESS]` und drücke eine beliebige Taste, um das Fenster zu schließen.

Das war es. WakeSoundbar läuft ab jetzt bei jeder Anmeldung dieses Windows-Kontos.

Installiere es in dem Administratorkonto, das WakeSoundbar später verwenden soll. Wenn Windows die Zugangsdaten eines anderen Administrators verlangt, wird die automatische Aufgabe für dieses andere Konto erstellt.

## Voraussetzungen

- Windows 11 (getestet).
- Windows 10 ab Version 1809 kann ebenfalls funktionieren.
- Windows PowerShell 5.1.
- Administratorrechte für Installation und Deinstallation.
- Eine GPU, ein Treiber, eine Soundbar oder ein AV-Receiver und eine HDMI-Verbindung, die diese Konfiguration unterstützen.

Die Kompatibilität hängt von Hardware und Anzeigetreiber ab. Was auf einem PC funktioniert, muss auf einem anderen nicht genauso funktionieren.

## Wenn es nicht funktioniert

### Der Installer findet kein geeignetes Ziel

- Führe den Installer direkt am PC aus, nicht über Remote Desktop.
- Prüfe, ob die Soundbar oder der Receiver eingeschaltet und per HDMI verbunden ist.
- Prüfe, ob **Anzeige vom Desktop entfernen** noch aktiviert ist.
- Warte ein paar Sekunden, bis Windows das Gerät erkannt hat, und führe `install.bat` erneut aus.

### Das falsche Gerät wurde ausgewählt

Führe `install.bat` erneut aus. Der Installer zeigt die aktuelle Geräteliste noch einmal an.

### Automatische Aufgabe prüfen

Öffne PowerShell und führe Folgendes aus:

```powershell
Get-ScheduledTask -TaskName WakeSoundbar
Get-ScheduledTaskInfo -TaskName WakeSoundbar
```

Die installierten Dateien liegen unter `%ProgramData%\WakeSoundbar`. WakeSoundbar legt keine Logdateien an; ein manueller Lauf zeigt das Ergebnis direkt im Terminal.

Wenn du ein Issue eröffnest, nenne Windows-Version, GPU und Treiber, das Soundbar- oder Receiver-Modell und die HDMI-Verkabelung. Veröffentliche keine Monitor-IDs oder andere privaten Systemdaten.

## Deinstallation

1. Doppelklicke auf `uninstall.bat`.
2. Bestätige die Windows-Berechtigungsabfrage.
3. Warte auf `[SUCCESS]` und drücke eine beliebige Taste.

Damit werden die automatische Aufgabe und alle von WakeSoundbar installierten Dateien entfernt.

## Erweiterte Verwendung

Das Skript manuell ausführen:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1
```

Nützliche Diagnoseoptionen:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -NoSleep
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -IncludeStandardTargets
```

`-IncludeStandardTargets` kann normale Desktop-Displays bearbeiten. Verwende es nur, wenn du direkt am PC sitzt und die Anzeigeeinstellungen wiederherstellen kannst.

Ein bekanntes Ziel direkt auswählen:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -StableMonitorId RSR66621_0C_07E5_C6
```

Die Exit-Codes sind `0` für Erfolg oder keine Aktion nötig, `1` für Start- oder Plattformfehler und `2`, wenn ein Ziel gefunden, aber nicht aktiviert werden konnte.

## Funktionsweise

1. Das Skript fragt Windows nach den aktuell verbundenen Display-Zielen.
2. Es behält nur Ziele, die Windows als `SpecialPurpose` markiert.
3. Wenn du bei der Installation ein Gerät ausgewählt hast, wird die gespeicherte `StableMonitorId` abgeglichen.
4. Das Ziel wird verbunden und `TryApply` aufgerufen.

WakeSoundbar wählt Geräte nie anhand des Produktnamens aus. Das verhindert Fehlannahmen, wenn ein VR-Headset, eine Capture-Karte oder ein anderes Spezialdisplay angeschlossen ist.

Im Hintergrund verwendet es `Windows.Devices.Display.Core`, um den HDMI-Displaypfad zu wecken. Es dekodiert kein Audio und kann nicht garantieren, dass jede GPU, jeder Treiber oder jedes Audioformat auf jedem PC funktioniert.

## Getesteter Stand

Vor der ersten Veröffentlichung wurde die Konfiguration des Autors auf einem Windows-11-PC in drei vollständigen Neustart- und Anmeldezyklen erfolgreich getestet. Das ist ein echter Hardwaretest, gilt aber nur für diesen PC; andere GPU- und Treiberkombinationen können sich anders verhalten.

## Projektinformationen

- Kurze Projektspezifikation: [openspec/spec.md](openspec/spec.md)
- Beitragsleitfaden: [CONTRIBUTING.md](CONTRIBUTING.md)
- Sicherheitsrichtlinie: [SECURITY.md](SECURITY.md)
- Kontakt: [qcsama@upwell.freeqiye.com](mailto:qcsama@upwell.freeqiye.com)

WakeSoundbar steht unter der Lizenz AGPL-3.0-only. Den vollständigen Lizenztext findest du in [LICENSE](LICENSE).
