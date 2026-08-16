# WakeSoundbar

[English](README.md) | [简体中文](README.zh-CN.md)

WakeSoundbar 是一个轻量、无图形界面的 Windows PowerShell 工具。它会在用户登录时，
重新应用已连接的 `SpecialPurpose` 显示目标路径，适用于在 Windows 中设置为
“从桌面删除显示器”的 HDMI 回音壁和 AVR。

项目使用 Windows `Windows.Devices.Display.Core` API。它不直接控制音频终端，
而是请求显示子系统激活目标，使 HDMI 链路及其音频能力能够重新完成协商。

本项目采用 GNU Affero General Public License v3.0，详见 [LICENSE](LICENSE)。

## 解决的问题

WakeSoundbar 面向 PC 游戏和家庭影院用户的重叠场景：桌面 PC 或 HTPC 驱动
4K HDR 高刷新率主显示器，同时通过另一条 HDMI 连接回音壁或 AVR，以使用
Dolby Atmos、Dolby TrueHD 等多声道音频格式。

Windows 通常会把音频设备的 EDID 当作另一台显示器。扩展桌面会产生幽灵屏，
可能困住鼠标指针并干扰远程桌面软件；复制显示器则可能限制主游戏显示器的
分辨率、刷新率、HDR、VRR 或 G-Sync。S/PDIF 虽然不会产生额外显示路径，
但无法承载与 HDMI 相同的无损多声道格式。

将回音壁或 AVR 配置为专用显示器，可以在保留 HDMI 显示和音频能力的同时，
把该目标从桌面移除。但在某些显卡和驱动组合上，这条管线会在开机后保持休眠。
WakeSoundbar 会在登录时重新应用选定的专用显示路径，并且不会把它重新加入桌面。
只要 Windows 能通过 `Windows.Devices.Display.Core` 暴露目标，回音壁或 AVR
既可以连接独立显卡，也可以连接核显。

## 系统要求

- Windows 10 1809（内部版本 17763）或更高；主要测试平台为 Windows 11。
- Windows PowerShell 5.1。
- 已连接并配置为专用显示器的显示目标。
- 安装和注册计划任务需要管理员权限。
- 显卡、驱动、回音壁或 AVR 以及 HDMI 拓扑支持目标模式。

功能依赖具体硬件和驱动。在一台机器上成功，不代表所有设备组合都能得到相同结果。

## 快速开始

1. 从[最新 Release](https://github.com/QCSAMA/WakeSoundbar/releases/latest)
   下载 ZIP 并解压。
2. 在 Windows 11 中打开 **设置 > 系统 > 显示 > 高级显示**，选择回音壁或 AVR，
   启用 **从桌面删除显示器**。
3. 双击 `install.bat`。脚本会请求一次 UAC 提权，并在管理员窗口中继续。
4. 如果存在多个专用显示目标，按提示输入数字选择回音壁或 AVR。选择结果会用于以后登录。
5. 检查安装窗口中的首次运行结果。
6. 此后计划任务会在完成提权安装的账户登录时运行。

安装器无论成功或失败都会显示明确结果，并等待按任意键后退出。

卸载时双击 `uninstall.bat`，同意 UAC 提权即可。卸载器同样会显示结果并等待按键。

安装器应当从实际使用 WakeSoundbar 的管理员账户运行。标准账户可以在 UAC 窗口中
输入另一个管理员账户的凭据，但计划任务随后会属于该管理员账户。

## 手动运行

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1
```

常用诊断参数：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -NoSleep
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -IncludeStandardTargets
```

`-IncludeStandardTargets` 仅用于受控环境中的诊断，可能影响普通桌面显示器。
正常流程只处理 `SpecialPurpose` 目标。多显示设备环境还可以通过
`-StableMonitorId` 显式限制目标。

交互安装检测到多个 `SpecialPurpose` 目标时，会显示数字菜单，并把选中的稳定 ID
保存到安装目录下的 `target-id.txt`。隐藏运行的登录任务不会等待输入。
也可以手动指定目标：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -StableMonitorId RSR66621_0C_07E5_C6
```

重新运行 `install.bat` 会忽略旧选择并重新显示当前可用目标，无需手动编辑 ID 文件。

脚本退出码：`0` 表示成功或无需操作，`1` 表示初始化或平台错误，`2` 表示发现了
符合条件的目标，但没有成功激活。部分成功返回 `0`，具体结果会打印在终端中。

`No eligible SpecialPurpose targets found` 表示当前 Windows API 快照中没有符合条件的目标。
已经处于活动状态的专用显示器仍可能被视为候选目标；实际判定依据是 API 返回的
`UsageKind`，而不是 Windows 设置界面中的设备名称。

## 工作原理

1. 枚举当前显示目标。
2. 筛选已连接的 `SpecialPurpose` 目标，并可选按 `StableMonitorId` 限制。
3. 获取目标所有权并创建空的 `DisplayState`。
4. 连接目标并调用 `TryApply`。
5. 显示子系统尚未暴露目标时进行有限次数的重新枚举，最后释放 `DisplayManager`。

具体显卡驱动、DWM 会话、回音壁或 AVR 的行为不由 WinRT API 保证。
远程桌面会话和正在变化的显示拓扑可能导致获取目标失败。

## 故障排查

### 找不到符合条件的目标

- 在本地交互会话中运行首次测试，不要通过远程桌面运行。
- 确认回音壁或 AVR 已开机，并通过 HDMI 连接。
- 确认 Windows 已将它设置为“从桌面删除显示器”。
- 等待显示子系统识别设备后重新运行 `install.bat`。

### 需要切换目标

重新运行 `install.bat`。交互安装会忽略已保存的选择，并重新列出当前符合条件的目标。

### 检查计划任务

```powershell
Get-ScheduledTask -TaskName WakeSoundbar
Get-ScheduledTaskInfo -TaskName WakeSoundbar
```

程序和 `target-id.txt` 位于 `%ProgramData%\WakeSoundbar`。WakeSoundbar 不创建运行日志；
手动执行时，诊断信息会直接打印到终端。

## 已测试状态

首个版本发布前，作者在一台 Windows 11 机器上完成了三次重启和登录周期验证。
这属于特定硬件环境的验证结果，不代表所有显卡和驱动都具备通用兼容性。

## OpenSpec

项目范围、要求和非目标记录在 [`openspec/spec.md`](openspec/spec.md)。
该规范有意保持精简：这是单脚本工具，不是服务或通用显示管理器。

## 开发检查

仓库中的 GitHub Actions 会解析 PowerShell 脚本、运行 PSScriptAnalyzer，
并检查源代码和英文文档是否保持 ASCII。硬件激活必须手动测试，
因为托管 CI 运行器没有目标显示拓扑。

## 联系方式

项目相关问题可发送邮件至
[qcsama@upwell.freeqiye.com](mailto:qcsama@upwell.freeqiye.com)。
安全问题请优先参照 [`SECURITY.md`](SECURITY.md) 使用私密报告渠道。

## 许可证说明

本项目使用 AGPL-3.0-only 许可证。AGPL 允许商业使用和分发，但必须遵守许可证条件。
网络源代码提供义务适用于许可证所述的受覆盖修改版本；准确条款以 `LICENSE` 正文为准。
