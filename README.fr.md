# WakeSoundbar

[English](README.md) | [简体中文](README.zh-CN.md) |
[繁體中文](README.zh-TW.md) | [Español](README.es.md) |
[Português (Brasil)](README.pt-BR.md) | [Deutsch](README.de.md) |
[Français](README.fr.md) | [日本語](README.ja.md) | [한국어](README.ko.md) |
[Русский](README.ru.md)

WakeSoundbar est un petit utilitaire pour Windows 11 qui rétablit l'audio HDMI
d'une barre de son ou d'un ampli AV après la connexion, lorsque l'appareil est
configuré avec **Supprimer l'écran du bureau**. Il réveille la liaison HDMI
supprimée afin que le périphérique audio réapparaisse, sans modifier les
réglages 4K, HDR, haute fréquence de rafraîchissement ou VRR de l'écran
principal et sans laisser de processus en arrière-plan.

**Idéal pour**

- Les PC de jeu ou les HTPC
- Les barres de son ou amplis AV connectés en HDMI
- Les systèmes où l'audio HDMI disparaît après un redémarrage

**Pas destiné à**

- L'audio Bluetooth, USB ou S/PDIF
- Les configurations qui n'utilisent pas **Supprimer l'écran du bureau**

## Pourquoi cet outil existe

Branchez l'écran et la barre de son ou l'ampli AV au même PC en HDMI : Windows considère les deux comme des écrans. Le mode Étendre crée un écran fantôme qui peut attirer le pointeur ou perturber le Bureau à distance. Dupliquer ou mettre en miroir semble plus simple, mais les limites vidéo de la barre peuvent brider l'écran principal et affecter la résolution, la fréquence de rafraîchissement, le HDR, le VRR ou le G-Sync. Le S/PDIF évite l'écran supplémentaire, mais il ne transporte pas les mêmes formats multicanaux sans perte que le HDMI.

La configuration la plus propre consiste à sélectionner la barre dans Windows et à activer **Supprimer l'écran du bureau**. L'écran principal garde toutes ses capacités, la barre ne prend pas de place sur le bureau et la liaison audio HDMI reste configurée. Le problème est que, dans la configuration visée par cet outil, chaque redémarrage laisse cette liaison HDMI supprimée en veille. Tant qu'elle n'est pas réveillée, la barre n'apparaît pas comme périphérique audio ; sans WakeSoundbar, il faudrait ouvrir les Paramètres et changer l'option à la main après chaque redémarrage.

WakeSoundbar automatise précisément cette dernière étape. À la connexion, il retrouve la liaison HDMI supprimée, la réveille, puis se ferme. Une seule installation : plus besoin d'ouvrir les Paramètres, de changer le mode d'affichage ou de laisser une application tourner en arrière-plan.

L'outil est pensé pour les PC de jeu et les HTPC qui gardent la 4K, le HDR, une fréquence élevée et le VRR sur l'écran principal, tandis qu'une seconde sortie HDMI prend en charge Dolby Atmos, TrueHD ou le LPCM multicanal. La barre peut être branchée sur un GPU dédié ou sur le circuit graphique intégré.

## Installation

1. Téléchargez et extrayez le ZIP depuis la [dernière version](https://github.com/QCSAMA/WakeSoundbar/releases/latest).
2. Allumez la barre ou l'ampli AV et branchez-le en HDMI.
3. Ouvrez **Paramètres > Système > Affichage > Affichage avancé**.
4. Sélectionnez la barre ou l'ampli et activez **Supprimer l'écran du bureau**.
5. Double-cliquez sur `install.bat`.
6. Lorsque Windows demande l'autorisation, choisissez **Oui**.
7. Si une liste numérotée apparaît, saisissez le numéro de la barre ou de l'ampli.
8. Attendez `[SUCCESS]`, puis appuyez sur une touche pour fermer la fenêtre.

C'est terminé. WakeSoundbar s'exécutera à chaque connexion de ce compte Windows.

Installez-le depuis le compte administrateur qui l'utilisera. Si Windows demande les identifiants d'un autre administrateur, la tâche automatique sera créée pour cet autre compte.

## Prérequis

- Windows 11 (testé).
- Windows 10 version 1809 ou ultérieure peut également fonctionner.
- Windows PowerShell 5.1.
- Des droits administrateur pour l'installation et la désinstallation.
- Un GPU, un pilote, une barre ou un ampli AV et une liaison HDMI compatibles avec cette configuration.

La compatibilité dépend du matériel et du pilote d'affichage. Un résultat positif sur un PC ne garantit pas le même résultat partout.

## En cas de problème

### L'installateur ne trouve aucune cible compatible

- Lancez l'installateur directement sur le PC, pas via le Bureau à distance.
- Vérifiez que la barre ou l'ampli est allumé et relié en HDMI.
- Vérifiez que **Supprimer l'écran du bureau** est toujours activé.
- Attendez quelques secondes que Windows détecte l'appareil, puis relancez `install.bat`.

### Le mauvais appareil a été choisi

Relancez `install.bat`. L'installateur affichera à nouveau la liste actuelle.

### Vérifier la tâche automatique

Ouvrez PowerShell et exécutez :

```powershell
Get-ScheduledTask -TaskName WakeSoundbar
Get-ScheduledTaskInfo -TaskName WakeSoundbar
```

Les fichiers sont installés dans `%ProgramData%\WakeSoundbar`. WakeSoundbar ne crée pas de fichiers journaux ; une exécution manuelle affiche le résultat dans le terminal.

Pour ouvrir un issue, indiquez la version de Windows, le GPU et son pilote, le modèle de la barre ou de l'ampli et le câblage HDMI. Ne publiez pas d'identifiants de moniteur ni d'autres informations privées.

## Désinstallation

1. Double-cliquez sur `uninstall.bat`.
2. Acceptez la demande d'autorisation de Windows.
3. Attendez `[SUCCESS]`, puis appuyez sur une touche.

La tâche automatique et tous les fichiers installés par WakeSoundbar seront supprimés.

## Utilisation avancée

Lancer le script manuellement :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1
```

Options de diagnostic :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -NoSleep
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -IncludeStandardTargets
```

`-IncludeStandardTargets` peut agir sur des écrans de bureau normaux. Utilisez-le uniquement devant le PC, avec la possibilité de rétablir les paramètres d'affichage.

Sélectionner directement une cible connue :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -StableMonitorId RSR66621_0C_07E5_C6
```

Les codes de sortie sont `0` en cas de succès ou d'absence d'action nécessaire, `1` en cas d'erreur de démarrage ou de plateforme et `2` lorsqu'une cible a été trouvée mais n'a pas pu être activée.

## Fonctionnement

1. Le script demande à Windows les cibles d'affichage actuellement connectées.
2. Il ne conserve que celles que Windows marque `SpecialPurpose`.
3. Si vous avez choisi un appareil lors de l'installation, il compare le `StableMonitorId` enregistré.
4. Il connecte cette cible et appelle `TryApply`.

WakeSoundbar ne devine jamais l'appareil à partir de son nom commercial. Cela évite les confusions lorsqu'un casque VR, une carte de capture ou un autre écran spécial est connecté.

Il utilise `Windows.Devices.Display.Core` pour réveiller la liaison d'affichage HDMI. Il ne décode pas l'audio et ne peut pas garantir le fonctionnement d'un GPU, d'un pilote ou d'un format audio donné sur tous les PC.

## État des tests

Avant la première version, la configuration de l'auteur a passé trois cycles complets de redémarrage et de connexion sous Windows 11. C'est un test matériel réel, mais sur un seul PC ; d'autres combinaisons de GPU et de pilotes peuvent se comporter différemment.

## Informations sur le projet

- Spécification courte : [openspec/spec.md](openspec/spec.md)
- Guide de contribution : [CONTRIBUTING.md](CONTRIBUTING.md)
- Politique de sécurité : [SECURITY.md](SECURITY.md)
- Contact : [qcsama@upwell.freeqiye.com](mailto:qcsama@upwell.freeqiye.com)

WakeSoundbar est distribué sous licence AGPL-3.0-only. Consultez [LICENSE](LICENSE) pour le texte complet.
