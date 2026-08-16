# WakeSoundbar

[English](README.md) | [简体中文](README.zh-CN.md) |
[繁體中文](README.zh-TW.md) | [Español](README.es.md) |
[Português (Brasil)](README.pt-BR.md) | [Deutsch](README.de.md) |
[Français](README.fr.md) | [日本語](README.ja.md) | [한국어](README.ko.md) |
[Русский](README.ru.md)

모니터와 사운드바 또는 AV 리시버를 같은 PC에 HDMI로 연결하면 Windows는 둘 다 디스플레이로 취급합니다. 데스크톱 확장은 보이지 않는 유령 화면을 만들어 마우스 포인터가 그쪽으로 빠지거나 원격 데스크톱 프로그램이 엉뚱한 화면을 선택하게 할 수 있습니다. 복제나 미러링은 더 간단해 보이지만 사운드바의 영상 규격에 맞추느라 메인 화면의 해상도, 주사율, HDR, VRR, G-Sync가 영향을 받을 수 있습니다. S/PDIF를 쓰면 추가 화면은 피할 수 있지만 HDMI에서 가능한 무손실 멀티채널 오디오 형식도 포기해야 합니다.

가장 깔끔한 방법은 Windows에서 사운드바를 선택하고 **바탕 화면에서 디스플레이 제거**를 켜는 것입니다. 메인 화면의 성능은 그대로 유지하고, 사운드바는 데스크톱 공간을 차지하지 않으며, HDMI 오디오 연결도 보존할 수 있습니다. 문제는 이 도구가 대상으로 하는 구성에서는 재부팅할 때마다 제거된 HDMI 경로가 잠든다는 점입니다. 다시 깨우기 전에는 사운드바가 오디오 장치로 나타나지 않으므로 WakeSoundbar가 없다면 매번 설정을 열어 직접 전환해야 합니다.

WakeSoundbar는 바로 그 번거로운 마지막 단계를 자동화합니다. 로그인할 때 제거된 사운드바 경로를 찾아 HDMI를 깨운 뒤 종료합니다. 한 번 설치하면 설정을 다시 열거나 디스플레이 모드를 바꿀 필요가 없고, 계속 실행되는 백그라운드 앱도 남지 않습니다.

게임용 PC나 HTPC에서 메인 화면의 4K, HDR, 높은 주사율, VRR을 유지하면서 두 번째 HDMI 출력으로 Dolby Atmos, TrueHD 또는 멀티채널 LPCM을 사용하려는 경우에 맞습니다. 사운드바는 외장 GPU와 내장 그래픽 어느 쪽에도 연결할 수 있습니다.

## 설치

1. [최신 릴리스](https://github.com/QCSAMA/WakeSoundbar/releases/latest)에서 ZIP을 내려받아 압축을 풉니다.
2. 사운드바 또는 AV 리시버를 켜고 HDMI로 연결합니다.
3. **설정 > 시스템 > 디스플레이 > 고급 디스플레이**를 엽니다.
4. 사운드바 또는 리시버를 선택하고 **바탕 화면에서 디스플레이 제거**를 켭니다.
5. `install.bat`를 두 번 클릭합니다.
6. Windows에서 권한을 요청하면 **예**를 선택합니다.
7. 번호 목록이 나타나면 사운드바 또는 리시버의 번호를 입력합니다.
8. `[SUCCESS]`가 표시되면 아무 키나 눌러 창을 닫습니다.

이제 끝입니다. 이 Windows 계정으로 로그인할 때마다 WakeSoundbar가 자동으로 실행됩니다.

WakeSoundbar를 사용할 관리자 계정으로 로그인한 상태에서 설치하세요. 다른 관리자 계정의 자격 증명을 입력하면 자동 작업은 그 계정에 만들어집니다.

## 요구 사항

- Windows 11 (테스트 완료).
- Windows 10 version 1809 이상에서도 작동할 수 있습니다.
- Windows PowerShell 5.1.
- 설치와 제거에 필요한 관리자 권한.
- 이 구성과 호환되는 GPU, 드라이버, 사운드바 또는 AV 리시버, HDMI 연결.

호환성은 하드웨어와 디스플레이 드라이버에 따라 달라집니다. 한 PC에서 작동해도 모든 PC에서 같은 결과가 나온다는 보장은 없습니다.

## 작동하지 않을 때

### 설치 프로그램이 적합한 대상을 찾지 못함

- 원격 데스크톱이 아니라 대상 PC에서 설치 프로그램을 직접 실행합니다.
- 사운드바 또는 리시버가 켜져 있고 HDMI로 연결되어 있는지 확인합니다.
- **바탕 화면에서 디스플레이 제거**가 계속 켜져 있는지 확인합니다.
- Windows가 장치를 인식할 때까지 몇 초 기다린 뒤 `install.bat`를 다시 실행합니다.

### 다른 장치를 선택함

`install.bat`를 다시 실행하세요. 현재 장치 목록이 다시 표시됩니다.

### 자동 작업 확인

PowerShell을 열고 실행합니다.

```powershell
Get-ScheduledTask -TaskName WakeSoundbar
Get-ScheduledTaskInfo -TaskName WakeSoundbar
```

설치 파일은 `%ProgramData%\WakeSoundbar`에 있습니다. WakeSoundbar는 로그 파일을 만들지 않으며, 수동 실행 결과는 터미널에 바로 표시됩니다.

Issue를 열 때 Windows 버전, GPU와 드라이버, 사운드바 또는 리시버 모델, HDMI 연결 방식을 적어 주세요. 모니터 ID나 개인 시스템 정보는 공개하지 마세요.

## 제거

1. `uninstall.bat`를 두 번 클릭합니다.
2. Windows 권한 요청을 승인합니다.
3. `[SUCCESS]`가 표시되면 아무 키나 누릅니다.

자동 작업과 WakeSoundbar가 설치한 모든 파일이 삭제됩니다.

## 고급 사용

스크립트를 직접 실행하려면:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1
```

진단에 사용할 수 있는 옵션:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -NoSleep
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -IncludeStandardTargets
```

`-IncludeStandardTargets`는 일반 데스크톱 디스플레이에도 동작할 수 있습니다. PC 앞에서 디스플레이 설정을 되돌릴 수 있을 때만 사용하세요.

알고 있는 대상을 직접 지정하려면:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\WakeSoundbar.ps1 -StableMonitorId RSR66621_0C_07E5_C6
```

종료 코드는 `0`이 성공 또는 작업 불필요, `1`이 시작 또는 플랫폼 오류, `2`가 대상을 찾았지만 활성화하지 못한 경우입니다.

## 작동 원리

1. 스크립트가 Windows에서 현재 연결된 디스플레이 대상을 가져옵니다.
2. Windows가 `SpecialPurpose`로 표시한 대상만 남깁니다.
3. 설치 중 장치를 선택했다면 저장된 `StableMonitorId`와 대조합니다.
4. 해당 대상을 연결하고 `TryApply`를 호출합니다.

WakeSoundbar는 제품 이름으로 장치를 추측하지 않습니다. VR 헤드셋, 캡처 카드 또는 다른 특수 디스플레이가 연결되어 있어도 이름만 보고 잘못 선택하지 않습니다.

내부적으로 `Windows.Devices.Display.Core`를 사용해 HDMI 디스플레이 경로를 깨웁니다. 오디오를 디코딩하지 않으며, 특정 GPU·드라이버·오디오 형식이 모든 PC에서 작동한다고 보장하지도 않습니다.

## 테스트 현황

첫 릴리스 전에 작성자의 Windows 11 환경에서 재부팅과 로그인을 세 번 연속으로 테스트했습니다. 실제 하드웨어 테스트 결과지만 한 대의 PC에 한정되며, GPU와 드라이버 조합에 따라 동작이 달라질 수 있습니다.

## 프로젝트 정보

- 간단한 프로젝트 사양: [openspec/spec.md](openspec/spec.md)
- 기여 안내: [CONTRIBUTING.md](CONTRIBUTING.md)
- 보안 정책: [SECURITY.md](SECURITY.md)
- 연락처: [qcsama@upwell.freeqiye.com](mailto:qcsama@upwell.freeqiye.com)

WakeSoundbar는 AGPL-3.0-only 라이선스로 배포됩니다. 전체 라이선스는 [LICENSE](LICENSE)에서 확인하세요.
