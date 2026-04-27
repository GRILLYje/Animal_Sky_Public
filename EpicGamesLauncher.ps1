[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host "Checking for updates (Sky)..." -ForegroundColor Cyan

$apiUrl = "https://api.github.com/repos/GRILLYje/Animal_Sky_Public/releases/latest"

try {
    $releaseInfo = Invoke-RestMethod -Uri $apiUrl -Method Get
    
    $version = $releaseInfo.tag_name
    $publishedAt = [datetime]$releaseInfo.published_at
    $localTime = $publishedAt.ToLocalTime().ToString("dd/MM/yyyy HH:mm:ss")
    $description = $releaseInfo.body

    $downloadUrl = ($releaseInfo.assets | Where-Object { $_.name -eq "EpicGamesLauncher.exe" }).browser_download_url

    if (-not $downloadUrl) {
        Write-Host "⚠️ Error: หาไฟล์ที่ชื่อ 'EpicGamesLauncher.exe' ไม่เจอใน Release ล่าสุด!" -ForegroundColor Red
        Exit
    }

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
    Write-Host "สาเหตุ API: $($_.Exception.Message)" -ForegroundColor Yellow
    Exit
}

$folderPath = "$env:TEMP\Sky"
if (-not (Test-Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
}

$tempPath = "$folderPath\EpicGamesLauncher.exe"

# ลองลบไฟล์เก่าดูก่อน ถ้าลบไม่ได้แปลว่าเปิดค้างอยู่
try {
    if (Test-Path $tempPath) {
        Remove-Item $tempPath -Force -ErrorAction Stop
    }
} catch {
    Write-Host "❌ Error: ไม่สามารถลบไฟล์เก่าได้ โปรดเช็คว่าบอตเปิดค้างอยู่ไหม" -ForegroundColor Red
    Write-Host "รายละเอียด: $($_.Exception.Message)" -ForegroundColor Yellow
    Exit
}

try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($downloadUrl, $tempPath)
    $webClient.Dispose()
    Write-Host "✅ ดาวน์โหลดเสร็จสิ้น!" -ForegroundColor Green
} catch {
    Write-Host "❌ เกิดข้อผิดพลาดในการดาวน์โหลดไฟล์" -ForegroundColor Red
    Write-Host "สาเหตุ Download: $($_.Exception.Message)" -ForegroundColor Yellow
    Exit
}

try {
    $historyPath = (Get-PSReadLineOption).HistorySavePath
    if (Test-Path $historyPath) { Clear-Content -Path $historyPath }
    Clear-History
} catch {}

Write-Host "🚀 Launching Sky..." -ForegroundColor Green
Start-Process -FilePath $tempPath
