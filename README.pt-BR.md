# WakeSoundbar

[English](README.md) | [简体中文](README.zh-CN.md) |
[繁體中文](README.zh-TW.md) | [Español](README.es.md) |
[Português (Brasil)](README.pt-BR.md) | [Deutsch](README.de.md) |
[Français](README.fr.md) | [日本語](README.ja.md) | [한국어](README.ko.md) |
[Русский](README.ru.md)

O WakeSoundbar é um utilitário leve para Windows 11 que restaura o áudio HDMI
da soundbar ou do receiver AV ao entrar no sistema quando o dispositivo está
configurado como **Remover tela da área de trabalho**. Ele reativa o caminho HDMI
removido para que o dispositivo de áudio volte a aparecer, sem alterar as
configurações 4K, HDR, alta taxa de atualização ou VRR da tela principal e sem
manter um processo em segundo plano.

**Ideal para**

- PCs de jogos ou HTPCs
- Soundbars ou receivers AV conectados por HDMI
- Sistemas em que o áudio HDMI desaparece depois de reiniciar

**Não é indicado para**

- Áudio por Bluetooth, USB ou S/PDIF
- Configurações que não usam **Remover tela da área de trabalho**

## Por que isso existe

Conecte o monitor e a soundbar ou o receiver AV ao mesmo PC por HDMI e o Windows trata os dois como telas. No modo estendido, aparece uma tela fantasma que pode prender o cursor ou confundir o acesso remoto. Duplicar ou espelhar parece mais simples, mas as limitações de vídeo da soundbar podem reduzir a resolução e a taxa de atualização da tela principal e atrapalhar HDR, VRR ou G-Sync. O S/PDIF evita a tela extra, mas também abre mão dos formatos multicanal sem perdas que o HDMI oferece.

A configuração mais limpa é selecionar a soundbar no Windows e ativar **Remover tela da área de trabalho**. A tela principal mantém todos os recursos, a soundbar não ocupa espaço na área de trabalho e a conexão de áudio HDMI fica preservada. O problema é que, na configuração que este projeto atende, todo reinício deixa esse caminho HDMI removido adormecido. Até ser reativada, a soundbar não aparece como dispositivo de áudio; sem o WakeSoundbar, seria preciso abrir as Configurações e alternar essa opção manualmente depois de cada reinício.

O WakeSoundbar automatiza exatamente essa última etapa. Ao entrar no Windows, ele encontra o caminho HDMI removido, o reativa e encerra. Você instala uma vez; depois disso não precisa abrir as Configurações, alternar o modo de tela nem deixar um aplicativo rodando em segundo plano.

Ele foi feito para PCs de jogos e HTPCs que mantêm 4K, HDR, alta taxa de atualização e VRR na tela principal, enquanto uma segunda saída HDMI cuida de Dolby Atmos, TrueHD ou LPCM multicanal. A soundbar pode estar ligada a uma GPU dedicada ou integrada.

## Instalação

1. Baixe e extraia o ZIP da [versão mais recente](https://github.com/QCSAMA/WakeSoundbar/releases/latest).
2. Ligue a soundbar ou o receiver AV e conecte-o por HDMI.
3. Abra **Configurações > Sistema > Tela > Tela avançada**.
4. Selecione a soundbar ou o receiver e ative **Remover tela da área de trabalho**.
5. Dê dois cliques em `install.bat`.
6. Quando o Windows pedir permissão, escolha **Sim**.
7. Se aparecer uma lista numerada, informe o número da soundbar ou do receiver.
8. Espere aparecer `[SUCCESS]` e pressione qualquer tecla para fechar a janela.

Pronto. O WakeSoundbar será executado sempre que esta conta do Windows entrar no sistema.

Instale usando a conta de administrador que realmente usará o programa. Se o Windows pedir as credenciais de outro administrador, a tarefa automática será criada para essa outra conta.

## Requisitos

- Windows 11 (testado).
- O Windows 10 versão 1809 ou mais recente também pode funcionar.
- Windows PowerShell 5.1.
- Permissão de administrador para instalar e desinstalar.
- GPU, driver, soundbar ou receiver AV e conexão HDMI compatíveis com essa configuração.

A compatibilidade depende do hardware e do driver de vídeo. Funcionar em um PC não garante o mesmo resultado em todos os outros.

## Se não funcionar

### O instalador não encontra um destino válido

- Execute o instalador diretamente no PC, e não pelo acesso remoto.
- Confirme que a soundbar ou o receiver está ligado e conectado por HDMI.
- Verifique se **Remover tela da área de trabalho** continua ativado.
- Aguarde alguns segundos para o Windows detectar o dispositivo e execute `install.bat` novamente.

### O dispositivo errado foi selecionado

Execute `install.bat` novamente. O instalador mostrará a lista atual de dispositivos.

### Verificar a tarefa automática

Abra o PowerShell e execute:

```powershell
Get-ScheduledTask -TaskName WakeSoundbar
Get-ScheduledTaskInfo -TaskName WakeSoundbar
```

Os arquivos instalados ficam em `%ProgramData%\WakeSoundbar`. O WakeSoundbar não cria arquivos de log; uma execução manual mostra o resultado no terminal.

Ao abrir uma issue, informe a versão do Windows, a GPU e o driver, o modelo da soundbar ou receiver e como os cabos HDMI estão ligados. Não publique IDs de monitor nem outros dados privados do sistema.

## Desinstalação

1. Dê dois cliques em `uninstall.bat`.
2. Confirme a solicitação de permissão do Windows.
3. Espere aparecer `[SUCCESS]` e pressione qualquer tecla.

Isso remove a tarefa automática e todos os arquivos instalados pelo WakeSoundbar.

## Uso avançado

Executar o script manualmente:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1
```

Opções úteis para diagnóstico:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -NoSleep
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -IncludeStandardTargets
```

`-IncludeStandardTargets` pode atuar em telas normais da área de trabalho. Use-o apenas quando estiver diante do PC e puder recuperar as configurações de tela.

Para selecionar diretamente um destino conhecido:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -StableMonitorId RSR66621_0C_07E5_C6
```

Os códigos de saída são `0` para sucesso ou nenhuma ação necessária, `1` para erro de inicialização ou da plataforma e `2` quando um destino foi encontrado, mas não pôde ser ativado.

## Como funciona

1. O script pede ao Windows os destinos de tela conectados.
2. Mantém apenas os destinos marcados pelo Windows como `SpecialPurpose`.
3. Se você escolheu um dispositivo durante a instalação, compara o `StableMonitorId` salvo.
4. Conecta esse destino e chama `TryApply`.

O WakeSoundbar não escolhe dispositivos pelo nome do produto. Isso evita adivinhações quando há headset VR, placa de captura ou outra tela especial conectada.

Por baixo dos panos, usa `Windows.Devices.Display.Core` para acordar o caminho de vídeo HDMI. Ele não decodifica áudio e não pode garantir que uma GPU, um driver ou um formato de áudio específico funcione em todos os PCs.

## Estado dos testes

Antes da primeira versão, a configuração do autor passou por três ciclos completos de reinício e login no Windows 11. É um teste real de hardware, mas feito em apenas um PC; outras combinações de GPU e driver podem se comportar de forma diferente.

## Informações do projeto

- Especificação curta: [openspec/spec.md](openspec/spec.md)
- Guia de contribuição: [CONTRIBUTING.md](CONTRIBUTING.md)
- Política de segurança: [SECURITY.md](SECURITY.md)
- Contato: [qcsama@upwell.freeqiye.com](mailto:qcsama@upwell.freeqiye.com)

WakeSoundbar é distribuído sob a licença AGPL-3.0-only. Consulte [LICENSE](LICENSE) para ver o texto completo.
