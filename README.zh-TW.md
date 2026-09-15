# WakeSoundbar

[English](README.md) | [简体中文](README.zh-CN.md) |
[繁體中文](README.zh-TW.md) | [Español](README.es.md) |
[Português (Brasil)](README.pt-BR.md) | [Deutsch](README.de.md) |
[Français](README.fr.md) | [日本語](README.ja.md) | [한국어](README.ko.md) |
[Русский](README.ru.md)

WakeSoundbar 是一個適用於 Windows 11 的輕量工具：當 Soundbar 或 AV 擴大機設定為
**從桌面移除顯示器** 後，它會在登入時自動恢復 HDMI 音訊。它會喚醒被移除的
HDMI 顯示路徑，讓音訊裝置重新出現，同時不改變主螢幕的 4K、HDR、
高更新率或 VRR 設定，也不會留下常駐背景程序。

**適合**

- 遊戲電腦或 HTPC
- 透過 HDMI 連接的 Soundbar 或 AV 擴大機
- 每次重新啟動後 HDMI 音訊裝置消失的系統

**不適合**

- 藍牙、USB 或 S/PDIF 音訊
- 沒有使用 **從桌面移除顯示器** 的設定

## 為什麼需要它

把主螢幕和 Soundbar 或 AV 擴大機都接到同一台電腦的 HDMI，Windows 就會把兩者都當成顯示器。延伸桌面會多出一個看不見的幽靈螢幕，滑鼠可能跑進去，遠端桌面軟體也可能選錯螢幕。複製或鏡像看似簡單，卻可能讓 Soundbar 的影像規格拖累主螢幕，影響解析度、更新率、HDR、VRR 或 G-Sync。改用 S/PDIF 雖然可以避開第二個螢幕，卻也失去 HDMI 能提供的無損多聲道格式。

比較乾淨的做法，是在 Windows 中選取 Soundbar，啟用 **從桌面移除顯示器**。主螢幕可以保留完整規格，Soundbar 不佔用桌面空間，HDMI 音訊連線也能保留。問題是，對這個工具要處理的接法來說，每次重新啟動都會讓被移除的 HDMI 路徑休眠。重新喚醒前，Soundbar 不會出現在音訊裝置中；否則每次重開機後都得進設定手動切換。

WakeSoundbar 自動完成這個最煩人的步驟。登入時，它會找到被移除的 Soundbar 路徑、喚醒 HDMI，然後立即結束。安裝一次後，不必再開設定、不必再切換顯示模式，也不會留下常駐程式。

這正是 WakeSoundbar 的使用情境：遊戲電腦或 HTPC 讓主螢幕維持 4K、HDR、高更新率和 VRR，另一個 HDMI 輸出則負責 Dolby Atmos、TrueHD 或多聲道 LPCM。Soundbar 可以接獨立顯示卡，也可以接內建顯示晶片。

## 安裝

1. 從[最新 Release](https://github.com/QCSAMA/WakeSoundbar/releases/latest) 下載 ZIP 並解壓縮。
2. 開啟 Soundbar 或 AV 擴大機，確認 HDMI 已連接。
3. 開啟 **設定 > 系統 > 顯示器 > 進階顯示器**。
4. 選取 Soundbar 或 AV 擴大機，啟用 **從桌面移除顯示器**。
5. 按兩下 `install.bat`。
6. Windows 詢問是否允許變更時，選擇 **是**。
7. 如果出現編號清單，輸入 Soundbar 或 AV 擴大機前面的編號。
8. 看到 `[SUCCESS]` 後，按任意鍵關閉視窗。

這樣就完成了。之後每次登入這個 Windows 帳戶，WakeSoundbar 都會自動執行。

請在實際使用 WakeSoundbar 的系統管理員帳戶中安裝。如果 Windows 要求輸入另一個系統管理員的認證，排程工作會建立在那個帳戶下。

## 系統需求

- Windows 11（已測試）。
- Windows 10 1809 或更新版本也可能可用。
- Windows PowerShell 5.1。
- 安裝和移除時需要系統管理員權限。
- 顯示卡、驅動程式、Soundbar 或 AV 擴大機，以及 HDMI 連線必須支援這種接法。

實際相容性仍取決於硬體和顯示卡驅動程式。在一台電腦上成功，不代表每台電腦都會一樣。

## 如果沒有作用

### 安裝程式找不到可用目標

- 直接在這台電腦上執行安裝程式，不要透過遠端桌面進行第一次測試。
- 確認 Soundbar 或 AV 擴大機已開機，而且 HDMI 已連接。
- 檢查 **從桌面移除顯示器** 是否仍然啟用。
- 給 Windows 幾秒鐘偵測裝置，再執行一次 `install.bat`。

### 選錯裝置

再次執行 `install.bat`。安裝程式會重新列出目前的裝置。

### 檢查自動工作

開啟 PowerShell 並執行：

```powershell
Get-ScheduledTask -TaskName WakeSoundbar
Get-ScheduledTaskInfo -TaskName WakeSoundbar
```

安裝檔案位於 `%ProgramData%\WakeSoundbar`。WakeSoundbar 不會建立記錄檔；手動執行時，結果會直接顯示在終端機中。

回報問題時，請提供 Windows 版本、顯示卡和驅動程式、Soundbar 或 AV 擴大機型號，以及 HDMI 的接法。不要在公開 Issue 中貼出顯示器 ID 或其他私人系統資訊。

## 移除

1. 按兩下 `uninstall.bat`。
2. 同意 Windows 權限要求。
3. 看到 `[SUCCESS]` 後，按任意鍵。

這會刪除自動工作和 WakeSoundbar 安裝的所有檔案。

## 進階用法

手動執行指令碼：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1
```

排查問題時也可以使用：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -NoSleep
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -IncludeStandardTargets
```

`-IncludeStandardTargets` 可能會操作一般桌面顯示器。只在你人在電腦旁、可以恢復顯示設定時使用。

直接指定已知目標：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -StableMonitorId RSR66621_0C_07E5_C6
```

結束代碼：`0` 表示成功或不需要操作，`1` 表示啟動或平台錯誤，`2` 表示找到目標但無法啟用。

## 工作原理

1. 指令碼向 Windows 取得目前連接的顯示目標。
2. 只保留 Windows 標記為 `SpecialPurpose` 的目標。
3. 如果安裝時選過裝置，就用儲存的 `StableMonitorId` 再次比對。
4. 連接選取的目標並呼叫 `TryApply`。

WakeSoundbar 不會根據產品名稱猜測裝置。電腦同時連接 VR 頭戴裝置、擷取卡或其他特殊顯示器時，這樣可以避免誤選。

底層使用 `Windows.Devices.Display.Core` 喚醒 HDMI 顯示路徑。它不解碼音訊，也無法保證每一種顯示卡、驅動程式或音訊格式都能正常工作。

## 測試情況

第一個版本發佈前，作者在自己的 Windows 11 電腦上完成了三次完整的重新啟動和登入測試。這是實際硬體驗證，但只代表這一台電腦；其他顯示卡和驅動程式組合可能有不同表現。

## 專案資訊

- 簡要專案規格：[openspec/spec.md](openspec/spec.md)
- 貢獻指南：[CONTRIBUTING.md](CONTRIBUTING.md)
- 安全性政策：[SECURITY.md](SECURITY.md)
- 聯絡信箱：[qcsama@upwell.freeqiye.com](mailto:qcsama@upwell.freeqiye.com)

WakeSoundbar 採用 AGPL-3.0-only 授權。完整條款請參閱 [LICENSE](LICENSE)。
