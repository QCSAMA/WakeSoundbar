# WakeSoundbar

[English](README.md) | [简体中文](README.zh-CN.md)

勾选 **从桌面删除显示器** 后，重启电脑，HDMI 回音壁或功放可能没有声音。
WakeSoundbar 就是为了解决这个问题。

只需安装一次。以后每次登录 Windows，它都会自动检查回音壁。它不会增加第二桌面，
不会打开设置窗口，也不会留下一个常驻程序。

## 这个工具适合你吗？

如果下面几项都符合，可以尝试 WakeSoundbar：

- 回音壁或功放通过第二个 HDMI 接口连接电脑。
- 主显示器需要保留 4K、HDR、高刷新率、VRR 或 G-Sync。
- 已经为回音壁或功放启用 **从桌面删除显示器**。
- 重启后，HDMI 音频偶尔会消失。

回音壁可以接独立显卡，也可以接核显。

## 安装

1. 从[最新 Release](https://github.com/QCSAMA/WakeSoundbar/releases/latest)
   下载 ZIP 并解压。
2. 打开回音壁或功放，并确认 HDMI 已连接。
3. 打开 **设置 > 系统 > 显示 > 高级显示**。
4. 选择回音壁或功放，启用 **从桌面删除显示器**。
5. 双击 `install.bat`。
6. Windows 询问是否允许更改时，点击 **是**。
7. 如果出现数字列表，输入回音壁或功放前面的数字。
8. 看到 `[SUCCESS]` 后，按任意键关闭窗口。

以后每次登录这个 Windows 账户，WakeSoundbar 都会自动运行。

请在实际使用 WakeSoundbar 的管理员账户中安装。如果在权限窗口里输入了另一个
管理员账户，自动任务会属于那个管理员账户。

## 它解决了哪些麻烦？

- **扩展桌面：** 会多出一个看不见的屏幕，鼠标可能跑进去，远程软件也可能切错屏。
- **复制桌面：** 可能限制主显示器的分辨率、刷新率、HDR、VRR 或 G-Sync。
- **S/PDIF：** 不会产生第二屏幕，但无法传输与 HDMI 相同的无损多声道格式。

WakeSoundbar 让回音壁继续保持“从桌面删除”的状态，只唤醒它的 HDMI 连接。

## 系统要求

- 已测试系统为 Windows 11。
- Windows 10 1809 或更高版本也可能可用。
- Windows PowerShell 5.1。
- 安装和卸载时需要管理员权限。
- 显卡、驱动、回音壁或功放以及 HDMI 连接需要支持当前设置。

不同硬件和驱动的表现可能不同。一台电脑成功，不代表所有电脑都能成功。

## 如果没有生效

### 安装器提示找不到目标

- 直接在这台电脑上运行安装器，不要通过远程桌面运行首次测试。
- 确认回音壁或功放已经开机，HDMI 已连接。
- 检查 **从桌面删除显示器** 是否仍然开启。
- 等待 Windows 识别设备，再运行一次 `install.bat`。

### 选错了设备

重新运行 `install.bat`。安装器会再次显示数字列表。

### 检查自动任务

打开 PowerShell，运行：

```powershell
Get-ScheduledTask -TaskName WakeSoundbar
Get-ScheduledTaskInfo -TaskName WakeSoundbar
```

安装文件位于 `%ProgramData%\WakeSoundbar`。WakeSoundbar 不会生成日志文件。
手动运行时，结果会直接显示在终端中。

反馈问题时，请提供 Windows 版本、显卡和驱动、回音壁或功放型号、HDMI 连接方式。
不要在公开 Issue 中粘贴显示器 ID 或其他私人系统信息。

## 卸载

1. 双击 `uninstall.bat`。
2. 同意 Windows 权限请求。
3. 看到 `[SUCCESS]` 后，按任意键。

卸载器会删除自动任务和所有 WakeSoundbar 安装文件。

<details>
<summary><strong>展开高级用法和技术原理</strong></summary>

## 高级用法

手动运行脚本：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1
```

常用诊断参数：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -NoSleep
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -IncludeStandardTargets
```

`-IncludeStandardTargets` 可能操作普通桌面显示器。它只适合在可控电脑上排查问题。

直接指定一个已知目标：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -StableMonitorId RSR66621_0C_07E5_C6
```

退出码：`0` 表示成功或无需操作，`1` 表示启动或系统错误，`2` 表示找到了目标，
但没有成功激活。

## 工作原理

下面内容只供想了解技术细节的用户参考：

1. 脚本读取 Windows 当前连接的显示目标。
2. 只保留 Windows 标记为 `SpecialPurpose` 的目标。
3. 如果保存过选择，再按 `StableMonitorId` 进行匹配。
4. 连接选中的目标并调用 `TryApply`。

脚本不会根据产品名称猜测设备。这样可以避免误选 VR 头显、采集设备或其他特殊显示器。

WakeSoundbar 使用 `Windows.Devices.Display.Core`。它负责唤醒 HDMI 显示路径，
不负责解码音频，也不保证某一种音频格式一定可用。

</details>

## 已测试情况

首个版本发布前，作者在一台 Windows 11 电脑上完成了三次重启和登录测试。
这只能证明该电脑的设置有效，不代表所有显卡和驱动都能兼容。

## 项目信息

- 简要项目规范：[`openspec/spec.md`](openspec/spec.md)
- 贡献说明：[`CONTRIBUTING.md`](CONTRIBUTING.md)
- 安全说明：[`SECURITY.md`](SECURITY.md)
- 联系邮箱：[qcsama@upwell.freeqiye.com](mailto:qcsama@upwell.freeqiye.com)

WakeSoundbar 使用 AGPL-3.0-only 许可证。完整条款见 [LICENSE](LICENSE)。
