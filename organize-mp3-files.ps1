# 整理 mp3 檔案，按照 geojson 資料夾結構
$soundsPath = "public\sounds"
$geojsonPath = "public\geojson"

Write-Host "開始整理 mp3 檔案..." -ForegroundColor Green

# 獲取絕對路徑
$soundsPathFull = Resolve-Path $soundsPath
$geojsonPathFull = Resolve-Path $geojsonPath

# 獲取所有 geojson 檔案及其相對路徑
$geojsonFiles = Get-ChildItem -Path $geojsonPath -Filter "*.geojson" -Recurse

$movedCount = 0
$notFoundCount = 0
$notFoundFiles = @()

foreach ($geojsonFile in $geojsonFiles) {
    # 獲取相對於 geojson 根目錄的路徑
    $geojsonDirFull = $geojsonFile.DirectoryName
    $relativePath = $geojsonDirFull.Replace($geojsonPathFull.Path, "").TrimStart("\")
    
    # 構建對應的 mp3 檔案名稱
    $mp3FileName = $geojsonFile.BaseName + ".mp3"
    
    # 原始 mp3 檔案路徑（在 sounds 根目錄）
    $sourceMp3 = Join-Path $soundsPathFull $mp3FileName
    
    # 目標資料夾
    if ($relativePath) {
        $targetFolder = Join-Path $soundsPathFull $relativePath
    } else {
        $targetFolder = $soundsPathFull
    }
    
    # 目標 mp3 檔案路徑
    $targetMp3 = Join-Path $targetFolder $mp3FileName
    
    # 如果原始檔案存在且目標位置不同
    if (Test-Path $sourceMp3) {
        if ($sourceMp3 -ne $targetMp3) {
            # 創建目標資料夾（如果不存在）
            if (-not (Test-Path $targetFolder)) {
                New-Item -Path $targetFolder -ItemType Directory -Force | Out-Null
            }
            
            # 移動檔案
            Move-Item -Path $sourceMp3 -Destination $targetMp3 -Force
            $movedCount++
            Write-Host "已移動: $mp3FileName -> $relativePath" -ForegroundColor Cyan
        }
    } else {
        $notFoundCount++
        $notFoundFiles += $mp3FileName
    }
}

Write-Host "`n整理完成！" -ForegroundColor Green
Write-Host "已移動檔案數: $movedCount" -ForegroundColor Yellow
Write-Host "找不到的檔案數: $notFoundCount" -ForegroundColor Yellow

if ($notFoundCount -gt 0 -and $notFoundCount -le 20) {
    Write-Host "`n找不到的檔案:" -ForegroundColor Red
    $notFoundFiles | ForEach-Object { Write-Host "  $_" }
}
