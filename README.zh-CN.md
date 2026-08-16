# WakeSoundbar

[English](README.md) | [简体中文](README.zh-CN.md)

主显示器和回音壁都走 HDMI 时，Windows 会把回音壁也当成一块屏幕。用扩展模式，
桌面上会凭空多出一个幽灵屏，鼠标容易跑进去，远程控制也可能切错屏；用复制或镜像，
回音壁的显示规格又可能拖累主屏，分辨率、高刷新率、HDR、VRR、G-Sync 都可能受影响。
改走 S/PDIF 虽然没有第二块屏幕，却也放弃了 HDMI 能承载的无损多声道格式。

比较干净的办法，是在 Windows 里选中回音壁，勾选 **从桌面删除显示器**。这样主屏
可以继续发挥完整规格，回音壁不再占用桌面空间，HDMI 音频链路也能保留下来。
问题是，这套接法每次重启都会让 HDMI 链路重新休眠。不把它唤醒，Windows 就找不到
回音壁这个音频设备；不用 WakeSoundbar 的话，每次开机后都得进设置里手动切一次。

WakeSoundbar 自动做的，就是这一步。每次登录时，它找到被移出桌面的回音壁，
把 HDMI 链路唤醒，然后马上退出。装一次，以后不用再开设置、不用来回切显示模式，
也没有常驻后台。

这正适合游戏 PC 和 HTPC：主屏继续跑 4K、HDR、高刷新率和 VRR，另一条 HDMI
专门负责 Dolby Atmos、TrueHD 或多声道 LPCM。回音壁接独显或核显都可以。

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

到这里就装好了。以后每次登录这个 Windows 账户，WakeSoundbar 都会自动运行。

请登录实际使用 WakeSoundbar 的管理员账户再安装。如果 Windows 权限窗口要求输入
另一个管理员账户，自动任务就会建到那个账户名下。

## 系统要求

- Windows 11，这是目前实测过的平台。
- Windows 10 1809 或更高版本也有可能可用。
- Windows PowerShell 5.1。
- 安装和卸载时需要管理员权限。
- 显卡、驱动、回音壁或功放以及 HDMI 连接本身需要支持这种接法。

最后能不能正常工作，仍然取决于硬件和显卡驱动。一台电脑成功，不代表所有机器
都会得到同样结果。

## 如果没有生效

### 安装器找不到可用目标

- 直接在这台电脑上运行安装器，不要通过远程桌面运行首次测试。
- 确认回音壁或功放已经开机，HDMI 已连接。
- 检查 **从桌面删除显示器** 是否仍然开启。
- 给 Windows 几秒钟识别设备，再运行一次 `install.bat`。

### 选错了设备

重新运行 `install.bat`。安装器会重新列出当前设备。

### 检查自动任务

打开 PowerShell，运行：

```powershell
Get-ScheduledTask -TaskName WakeSoundbar
Get-ScheduledTaskInfo -TaskName WakeSoundbar
```

安装文件位于 `%ProgramData%\WakeSoundbar`。WakeSoundbar 不会生成日志文件。
手动运行时，结果会直接显示在终端中。

提交 Issue 时，请写清 Windows 版本、显卡和驱动、回音壁或功放型号，以及 HDMI
具体怎么接。显示器 ID 和其他私人系统信息不要贴到公开 Issue。

## 卸载

1. 双击 `uninstall.bat`。
2. 同意 Windows 权限请求。
3. 看到 `[SUCCESS]` 后，按任意键。

卸载器会删除自动任务和 WakeSoundbar 安装的全部文件。

## 高级用法

手动运行脚本：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1
```

排查问题时还可以使用这些参数：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -NoSleep
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -IncludeStandardTargets
```

`-IncludeStandardTargets` 可能会操作普通桌面显示器。只有坐在电脑前、能够恢复
显示设置时，才用它排查问题。

直接指定一个已知目标：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -StableMonitorId RSR66621_0C_07E5_C6
```

退出码：`0` 表示成功或无需操作，`1` 表示启动或系统错误，`2` 表示找到了目标，
但没有成功激活。

## 工作原理

1. 脚本从 Windows 获取当前连接的显示目标。
2. 只保留 Windows 标记为 `SpecialPurpose` 的目标。
3. 安装时如果选过设备，就用保存的 `StableMonitorId` 再次匹配。
4. 连接选中的目标，并调用 `TryApply`。

WakeSoundbar 不会看产品名称猜设备。电脑同时接着 VR 头显、采集卡或其他特殊显示器时，
这样更不容易选错。

底层使用的是 `Windows.Devices.Display.Core`，作用是唤醒 HDMI 显示路径。
它不负责解码音频，也无法保证每一种显卡、驱动或音频格式都能正常工作。

## 已测试情况

首个版本发布前，作者在自己的 Windows 11 电脑上连续完成了三次完整重启和登录测试。
这是一次真实硬件验证，但只代表这一台电脑；换一套显卡或驱动，表现仍可能不同。

## 项目信息

- 简要项目规范：[`openspec/spec.md`](openspec/spec.md)
- 贡献说明：[`CONTRIBUTING.md`](CONTRIBUTING.md)
- 安全说明：[`SECURITY.md`](SECURITY.md)
- 联系邮箱：[qcsama@upwell.freeqiye.com](mailto:qcsama@upwell.freeqiye.com)

WakeSoundbar 使用 AGPL-3.0-only 许可证。完整条款见 [LICENSE](LICENSE)。
