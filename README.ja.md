# WakeSoundbar

[English](README.md) | [简体中文](README.zh-CN.md) |
[繁體中文](README.zh-TW.md) | [Español](README.es.md) |
[Português (Brasil)](README.pt-BR.md) | [Deutsch](README.de.md) |
[Français](README.fr.md) | [日本語](README.ja.md) | [한국어](README.ko.md) |
[Русский](README.ru.md)

WakeSoundbarは、サウンドバーまたはAVアンプを **デスクトップからディスプレイを削除**
に設定したWindows 11環境で、サインイン後にHDMIオーディオを復元する軽量ツールです。
削除されたHDMI表示経路を起こしてオーディオデバイスを再表示します。メイン画面の
4K、HDR、高リフレッシュレート、VRR設定は変更せず、常駐プロセスも残しません。

**向いている環境**

- ゲームPCまたはHTPC
- HDMIで接続したサウンドバーまたはAVアンプ
- 再起動後にHDMIオーディオが消えるシステム

**対象外**

- Bluetooth、USB、S/PDIFオーディオ
- **デスクトップからディスプレイを削除**を使わない構成

## このツールが必要な理由

モニターとサウンドバー／AVアンプを同じPCにHDMIでつなぐと、Windowsは両方をディスプレイとして扱います。拡張表示では見えない「幽霊画面」が増え、マウスポインターが入り込んだり、リモートデスクトップが別の画面を選んだりします。複製やミラーリングは簡単そうに見えますが、サウンドバー側の映像仕様に合わせるため、メイン画面の解像度、リフレッシュレート、HDR、VRR、G-Syncに影響が出ることがあります。S/PDIFなら画面は増えませんが、HDMIで使えるロスレスのマルチチャンネル音声フォーマットを失います。

一番すっきりした構成は、Windowsでサウンドバーを選び、**デスクトップからディスプレイを削除**を有効にする方法です。メイン画面の性能を保ったまま、サウンドバーをデスクトップから外し、HDMIオーディオ接続を残せます。ただし、このツールが対象にしている構成では、再起動するたびに削除したHDMI経路が休止します。もう一度起こすまでサウンドバーはオーディオデバイスとして表示されず、WakeSoundbarがなければ毎回設定を開いて手動で切り替える必要があります。

WakeSoundbarは、その最後の面倒な操作だけを自動化します。サインイン時に削除されたサウンドバーの経路を見つけてHDMIを起こし、処理が終わると終了します。一度インストールすれば、設定を開く必要も、表示モードを切り替える必要も、常駐アプリを残す必要もありません。

ゲームPCやHTPCで、メイン画面の4K、HDR、高リフレッシュレート、VRRを維持しながら、2本目のHDMIでDolby Atmos、TrueHD、マルチチャンネルLPCMを使いたい場合に向いています。サウンドバーは単体GPUにも内蔵GPUにも接続できます。

## インストール

1. [最新リリース](https://github.com/QCSAMA/WakeSoundbar/releases/latest)からZIPをダウンロードして展開します。
2. サウンドバーまたはAVアンプの電源を入れ、HDMIを接続します。
3. **設定 > システム > ディスプレイ > ディスプレイの詳細設定**を開きます。
4. サウンドバーまたはAVアンプを選び、**デスクトップからディスプレイを削除**を有効にします。
5. `install.bat`をダブルクリックします。
6. Windowsが許可を求めたら **はい**を選びます。
7. 番号付きの一覧が出たら、サウンドバーまたはAVアンプの番号を入力します。
8. `[SUCCESS]`が表示されたら、任意のキーを押してウィンドウを閉じます。

これで完了です。このWindowsアカウントでサインインするたびにWakeSoundbarが実行されます。

WakeSoundbarを使う管理者アカウントにサインインした状態でインストールしてください。別の管理者の資格情報を入力した場合、自動タスクはそのアカウント用に作成されます。

## 必要な環境

- Windows 11（テスト済み）。
- Windows 10 version 1809以降でも動作する可能性があります。
- Windows PowerShell 5.1。
- インストールとアンインストールに必要な管理者権限。
- この構成に対応したGPU、ドライバー、サウンドバーまたはAVアンプ、HDMI接続。

互換性はハードウェアとディスプレイドライバーに左右されます。1台のPCで動作しても、すべての環境で同じ結果になるとは限りません。

## 動作しない場合

### インストーラーが対象を見つけられない

- リモートデスクトップ経由ではなく、対象PC上でインストーラーを実行します。
- サウンドバーまたはAVアンプの電源とHDMI接続を確認します。
- **デスクトップからディスプレイを削除**が有効になっているか確認します。
- Windowsがデバイスを検出するまで数秒待ち、`install.bat`をもう一度実行します。

### 違うデバイスを選んだ

`install.bat`をもう一度実行してください。現在のデバイス一覧が再表示されます。

### 自動タスクを確認する

PowerShellを開いて実行します。

```powershell
Get-ScheduledTask -TaskName WakeSoundbar
Get-ScheduledTaskInfo -TaskName WakeSoundbar
```

インストール先は`%ProgramData%\WakeSoundbar`です。WakeSoundbarはログファイルを作成しません。手動実行時の結果はターミナルに表示されます。

Issueを開く場合は、Windowsのバージョン、GPUとドライバー、サウンドバーまたはAVアンプの機種、HDMIの接続方法を記載してください。モニターIDなど個人の環境を特定できる情報は公開しないでください。

## アンインストール

1. `uninstall.bat`をダブルクリックします。
2. Windowsの権限要求を承認します。
3. `[SUCCESS]`が表示されたら、任意のキーを押します。

自動タスクとWakeSoundbarのインストールファイルがすべて削除されます。

## 詳細設定

スクリプトを手動で実行する場合：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1
```

診断用のオプション：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -NoSleep
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -IncludeStandardTargets
```

`-IncludeStandardTargets`は通常のデスクトップディスプレイにも作用する場合があります。PCの前で表示設定を戻せるときだけ使用してください。

既知の対象を直接指定する場合：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -StableMonitorId RSR66621_0C_07E5_C6
```

終了コードは、`0`が成功または操作不要、`1`が起動／プラットフォームエラー、`2`が対象は見つかったが有効化できなかった場合です。

## 仕組み

1. Windowsから現在接続されているディスプレイ対象を取得します。
2. Windowsが`SpecialPurpose`として扱う対象だけを残します。
3. インストール時に選択した場合は、保存された`StableMonitorId`と照合します。
4. 対象を接続し、`TryApply`を呼び出します。

WakeSoundbarは製品名でデバイスを推測しません。VRヘッドセット、キャプチャーボード、その他の特殊ディスプレイが接続されていても、名前だけで誤選択することがありません。

内部では`Windows.Devices.Display.Core`を使ってHDMIディスプレイ経路を起こします。音声のデコードは行わず、特定のGPU、ドライバー、音声フォーマットがすべての環境で動作することを保証するものでもありません。

## テスト状況

初回リリース前に、作者のWindows 11環境で再起動とサインインを3回連続してテストしました。実機での検証結果ですが、1台のPCに限ったものです。GPUやドライバーの組み合わせによって動作が変わる場合があります。

## プロジェクト情報

- 簡易仕様：[openspec/spec.md](openspec/spec.md)
- コントリビューションガイド：[CONTRIBUTING.md](CONTRIBUTING.md)
- セキュリティポリシー：[SECURITY.md](SECURITY.md)
- 連絡先：[qcsama@upwell.freeqiye.com](mailto:qcsama@upwell.freeqiye.com)

WakeSoundbarはAGPL-3.0-onlyでライセンスされています。全文は[LICENSE](LICENSE)を参照してください。
