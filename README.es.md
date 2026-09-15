# WakeSoundbar

[English](README.md) | [简体中文](README.zh-CN.md) |
[繁體中文](README.zh-TW.md) | [Español](README.es.md) |
[Português (Brasil)](README.pt-BR.md) | [Deutsch](README.de.md) |
[Français](README.fr.md) | [日本語](README.ja.md) | [한국어](README.ko.md) |
[Русский](README.ru.md)

WakeSoundbar es una utilidad ligera para Windows 11 que restaura el audio HDMI
de una barra de sonido o un receptor AV al iniciar sesión cuando el dispositivo
está configurado con **Quitar pantalla del escritorio**. Reactiva la ruta HDMI
retirada para que vuelva a aparecer el dispositivo de audio, sin cambiar la
configuración 4K, HDR, alta frecuencia de actualización o VRR de la pantalla
principal y sin dejar un proceso en segundo plano.

**Ideal para**

- PCs gaming o HTPC
- Barras de sonido o receptores AV conectados por HDMI
- Sistemas en los que el audio HDMI desaparece después de reiniciar

**No está pensado para**

- Audio por Bluetooth, USB o S/PDIF
- Configuraciones que no usan **Quitar pantalla del escritorio**

## Por qué existe

Conecta el monitor y la barra de sonido o el receptor AV al mismo PC por HDMI y Windows trata los dos como pantallas. El modo extendido deja una pantalla fantasma que puede atrapar el puntero o confundir al Escritorio remoto. Duplicar o reflejar parece más sencillo, pero los límites de vídeo de la barra pueden frenar la pantalla principal y afectar a la resolución, la frecuencia de actualización, HDR, VRR o G-Sync. S/PDIF evita la pantalla adicional, pero también renuncia a los formatos multicanal sin pérdida que permite HDMI.

La configuración más limpia es seleccionar la barra de sonido en Windows y activar **Quitar pantalla del escritorio**. La pantalla principal conserva todas sus capacidades, la barra no ocupa espacio en el escritorio y la conexión de audio HDMI queda preparada. El problema es que, en la configuración para la que se creó esta herramienta, cada reinicio deja dormida esa ruta HDMI retirada. Hasta despertarla, la barra no aparece como dispositivo de audio; sin WakeSoundbar tendrías que abrir Configuración y cambiar la opción manualmente después de cada reinicio.

WakeSoundbar automatiza justo ese último paso. Al iniciar sesión localiza la ruta HDMI retirada, la despierta y termina. Se instala una vez y después no hay que abrir Configuración, cambiar modos de pantalla ni dejar una aplicación ejecutándose en segundo plano.

Está pensado para un PC de juegos o un HTPC que mantiene 4K, HDR, alta frecuencia de actualización y VRR en la pantalla principal, mientras una segunda salida HDMI se encarga de Dolby Atmos, TrueHD o LPCM multicanal. La barra puede estar conectada a una GPU dedicada o integrada.

## Instalación

1. Descarga y extrae el ZIP de la [última versión](https://github.com/QCSAMA/WakeSoundbar/releases/latest).
2. Enciende la barra o el receptor AV y conéctalo por HDMI.
3. Abre **Configuración > Sistema > Pantalla > Pantalla avanzada**.
4. Selecciona la barra o el receptor y activa **Quitar pantalla del escritorio**.
5. Haz doble clic en `install.bat`.
6. Cuando Windows pida permiso, selecciona **Sí**.
7. Si aparece una lista numerada, introduce el número de la barra o del receptor.
8. Espera a ver `[SUCCESS]` y pulsa cualquier tecla para cerrar la ventana.

Listo. WakeSoundbar se ejecutará cada vez que esta cuenta de Windows inicie sesión.

Instálalo desde la cuenta de administrador que va a usarlo. Si Windows pide las credenciales de otro administrador, la tarea automática se creará para esa otra cuenta.

## Requisitos

- Windows 11 (probado).
- Windows 10 versión 1809 o posterior también puede funcionar.
- Windows PowerShell 5.1.
- Permisos de administrador para instalar y desinstalar.
- Una GPU, un controlador, una barra o receptor AV y una conexión HDMI compatibles con esta configuración.

La compatibilidad depende del hardware y del controlador de pantalla. Que funcione en un PC no garantiza el mismo resultado en todos.

## Si no funciona

### El instalador no encuentra un destino válido

- Ejecuta el instalador directamente en el PC, no mediante Escritorio remoto.
- Comprueba que la barra o el receptor estén encendidos y conectados por HDMI.
- Comprueba que **Quitar pantalla del escritorio** siga activado.
- Espera unos segundos a que Windows detecte el dispositivo y vuelve a ejecutar `install.bat`.

### Se seleccionó el dispositivo equivocado

Vuelve a ejecutar `install.bat`. El instalador mostrará de nuevo la lista actual.

### Comprobar la tarea automática

Abre PowerShell y ejecuta:

```powershell
Get-ScheduledTask -TaskName WakeSoundbar
Get-ScheduledTaskInfo -TaskName WakeSoundbar
```

Los archivos instalados están en `%ProgramData%\WakeSoundbar`. WakeSoundbar no crea archivos de registro; una ejecución manual muestra el resultado en la terminal.

Al abrir una incidencia, incluye la versión de Windows, la GPU y su controlador, el modelo de la barra o receptor y cómo están conectados los cables HDMI. No publiques identificadores de monitor ni otros datos privados del sistema.

## Desinstalación

1. Haz doble clic en `uninstall.bat`.
2. Acepta la solicitud de permisos de Windows.
3. Espera a ver `[SUCCESS]` y pulsa cualquier tecla.

Esto elimina la tarea automática y todos los archivos instalados por WakeSoundbar.

## Uso avanzado

Ejecutar el script manualmente:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1
```

Opciones útiles para diagnosticar:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -NoSleep
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -IncludeStandardTargets
```

`-IncludeStandardTargets` puede actuar sobre pantallas normales. Úsalo solo cuando estés delante del PC y puedas recuperar la configuración de pantalla.

Seleccionar directamente un destino conocido:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -StableMonitorId RSR66621_0C_07E5_C6
```

Los códigos de salida son `0` para éxito o ninguna acción necesaria, `1` para errores de inicio o de plataforma y `2` si se encontró un destino pero no se pudo activar.

## Cómo funciona

1. El script pide a Windows los destinos de pantalla conectados.
2. Conserva solo los destinos que Windows marca como `SpecialPurpose`.
3. Si elegiste un dispositivo durante la instalación, compara el `StableMonitorId` guardado.
4. Conecta ese destino y llama a `TryApply`.

WakeSoundbar no adivina el dispositivo por su nombre comercial. Eso evita confusiones cuando hay un visor VR, una capturadora u otra pantalla especial conectada.

Por debajo usa `Windows.Devices.Display.Core` para despertar la ruta de pantalla HDMI. No decodifica audio y no puede garantizar que una GPU, un controlador o un formato de audio concreto funcione en todos los equipos.

## Estado de las pruebas

Antes de la primera versión, la configuración del autor completó tres ciclos completos de reinicio e inicio de sesión en Windows 11. Es una prueba real de hardware, pero solo de un PC; otras combinaciones de GPU y controlador pueden comportarse de otra manera.

## Información del proyecto

- Especificación breve: [openspec/spec.md](openspec/spec.md)
- Guía de contribución: [CONTRIBUTING.md](CONTRIBUTING.md)
- Política de seguridad: [SECURITY.md](SECURITY.md)
- Contacto: [qcsama@upwell.freeqiye.com](mailto:qcsama@upwell.freeqiye.com)

WakeSoundbar se publica bajo AGPL-3.0-only. Consulta [LICENSE](LICENSE) para leer el texto completo.
