# 布根地產區整合 - 自動化複製腳本
# 使用方法: 在 PowerShell 中執行此腳本
# .\copy-regions.ps1

$baseDir = "C:\Users\Chungshu\Desktop\Bourgogne"
$targetDir = "$baseDir\Chablisienne-map\public\geojson"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "布根地產區資料整合腳本" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 定義區域對應
$regions = @(
    @{
        Name = "Côte de Nuits"
        Source = "Cote de Nuits-map"
        Target = "Cote-de-Nuits"
    },
    @{
        Name = "Côte de Beaune"
        Source = "00Cote de Beaune-map"
        Target = "Cote-de-Beaune"
    },
    @{
        Name = "Côte Chalonnaise"
        Source = "Côte Chalonnaise-map"
        Target = "Cote-Chalonnaise"
    },
    @{
        Name = "Mâconnais"
        Source = "Maconnais-map"
        Target = "Maconnais"
    },
    @{
        Name = "Beaujolais"
        Source = "06beaujolais-map"
        Target = "Beaujolais"
    }
)

# 複製各區域檔案
foreach ($region in $regions) {
    Write-Host "處理: $($region.Name)" -ForegroundColor Yellow
    
    $sourcePath = "$baseDir\$($region.Source)\public\geojson"
    $targetPath = "$targetDir\$($region.Target)"
    
    # 檢查來源目錄是否存在
    if (-Not (Test-Path $sourcePath)) {
        Write-Host "  ⚠️  來源目錄不存在: $sourcePath" -ForegroundColor Red
        continue
    }
    
    # 建立目標目錄
    Write-Host "  📁 建立目錄: $targetPath" -ForegroundColor Gray
    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
    
    # 複製檔案
    Write-Host "  📋 複製檔案..." -ForegroundColor Gray
    try {
        Copy-Item "$sourcePath\*" -Destination $targetPath -Recurse -Force
        Write-Host "  ✅ $($region.Name) 複製完成" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ 複製失敗: $_" -ForegroundColor Red
    }
    
    Write-Host ""
}

# 整理 Chablis 資料夾（可選）
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "是否要整理 Chablis 資料夾? (Y/N)" -ForegroundColor Yellow
$response = Read-Host

if ($response -eq 'Y' -or $response -eq 'y') {
    Write-Host "整理 Chablis 資料夾..." -ForegroundColor Yellow
    
    $chablisTarget = "$targetDir\Chablis-Region"
    New-Item -ItemType Directory -Path $chablisTarget -Force | Out-Null
    
    # 移動現有資料夾
    $foldersToMove = @("Chablis", "AOC Bourgogne", "Grand Auxerrois")
    
    foreach ($folder in $foldersToMove) {
        $sourcePath = "$targetDir\$folder"
        if (Test-Path $sourcePath) {
            Write-Host "  移動: $folder" -ForegroundColor Gray
            Move-Item $sourcePath -Destination "$chablisTarget\$folder" -Force
        }
    }
    
    # 複製 index.json 到 Chablis-Region
    if (Test-Path "$targetDir\index.json") {
        Copy-Item "$targetDir\index.json" -Destination "$chablisTarget\index.json" -Force
    }
    
    Write-Host "  ✅ Chablis 整理完成" -ForegroundColor Green
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "複製 data 資料夾" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$dataTargetDir = "$baseDir\Chablisienne-map\public\data\regions"
New-Item -ItemType Directory -Path $dataTargetDir -Force | Out-Null

foreach ($region in $regions) {
    $dataSource = "$baseDir\$($region.Source)\public\data"
    
    if (Test-Path $dataSource) {
        Write-Host "複製 $($region.Name) 資料檔案..." -ForegroundColor Gray
        Copy-Item "$dataSource\*.json" -Destination $dataTargetDir -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host "✅ 整合完成！" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "下一步:" -ForegroundColor Yellow
Write-Host "1. 檢查檔案是否正確複製" -ForegroundColor White
Write-Host "2. 執行 'npm run dev' 測試" -ForegroundColor White
Write-Host "3. 查看 INTEGRATION_GUIDE.md 了解更多資訊" -ForegroundColor White
Write-Host ""

# 顯示統計資訊
Write-Host "統計資訊:" -ForegroundColor Cyan
Get-ChildItem $targetDir -Directory | ForEach-Object {
    $fileCount = (Get-ChildItem $_.FullName -Recurse -File).Count
    Write-Host "  $($_.Name): $fileCount 個檔案" -ForegroundColor Gray
}
