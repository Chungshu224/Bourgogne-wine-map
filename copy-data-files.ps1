# 複製各產區的 data JSON 資訊檔案
$sourceBase = "C:\Users\Chungshu\Desktop\Bourgogne"
$targetBase = "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\data"

Write-Host "開始複製產區資料檔案..." -ForegroundColor Green

# 1. 從 Côte de Nuits 複製
Write-Host "`n複製 Côte de Nuits 資料..." -ForegroundColor Cyan
$sourceDir = "$sourceBase\Cote de Nuits-map\public\data"
if (Test-Path $sourceDir) {
    $files = Get-ChildItem "$sourceDir" -File -Filter "*.json" | Where-Object { $_.Name -ne 'geojson-index.json' }
    foreach ($file in $files) {
        $targetPath = "$targetBase\regions\$($file.Name)"
        Copy-Item $file.FullName $targetPath -Force
        Write-Host "  ✓ $($file.Name)" -ForegroundColor Gray
    }
}

# 2. 從 Côte de Beaune 複製
Write-Host "`n複製 Côte de Beaune 資料..." -ForegroundColor Cyan
$sourceDir = "$sourceBase\00Cote de Beaune-map\public\data"
if (Test-Path $sourceDir) {
    $files = Get-ChildItem "$sourceDir" -File -Filter "*.json" | Where-Object { $_.Name -ne 'geojson-index.json' }
    foreach ($file in $files) {
        $targetPath = "$targetBase\regions\$($file.Name)"
        Copy-Item $file.FullName $targetPath -Force
        Write-Host "  ✓ $($file.Name)" -ForegroundColor Gray
    }
}

# 3. 從 Côte Chalonnaise 複製
Write-Host "`n複製 Côte Chalonnaise 資料..." -ForegroundColor Cyan
$sourceDir = "$sourceBase\Côte Chalonnaise-map\public\data"
if (Test-Path $sourceDir) {
    $files = Get-ChildItem "$sourceDir" -File -Filter "*.json" | Where-Object { $_.Name -ne 'geojson-index.json' }
    foreach ($file in $files) {
        $targetPath = "$targetBase\regions\$($file.Name)"
        Copy-Item $file.FullName $targetPath -Force
        Write-Host "  ✓ $($file.Name)" -ForegroundColor Gray
    }
}

# 4. 從 Mâconnais 複製 (如果有單獨的資料檔)
Write-Host "`n檢查 Mâconnais 資料..." -ForegroundColor Cyan
$sourceDir = "$sourceBase\Maconnais-map\public\data"
if (Test-Path $sourceDir) {
    $files = Get-ChildItem "$sourceDir" -File -Filter "*.json" | Where-Object { $_.Name -ne 'geojson-index.json' }
    if ($files.Count -gt 0) {
        foreach ($file in $files) {
            $targetPath = "$targetBase\regions\$($file.Name)"
            Copy-Item $file.FullName $targetPath -Force
            Write-Host "  ✓ $($file.Name)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  (無額外資料檔案)" -ForegroundColor Gray
    }
}

# 5. 從 Beaujolais 複製
Write-Host "`n檢查 Beaujolais 資料..." -ForegroundColor Cyan
$sourceDir = "$sourceBase\06beaujolais-map\public\data"
if (Test-Path $sourceDir) {
    $files = Get-ChildItem "$sourceDir" -File -Filter "*.json" | Where-Object { $_.Name -ne 'geojson-index.json' }
    if ($files.Count -gt 0) {
        foreach ($file in $files) {
            $targetPath = "$targetBase\regions\$($file.Name)"
            Copy-Item $file.FullName $targetPath -Force
            Write-Host "  ✓ $($file.Name)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  (無額外資料檔案)" -ForegroundColor Gray
    }
}

Write-Host "`n完成！所有產區資料已複製到 public\data\regions\" -ForegroundColor Green

# 統計結果
$totalFiles = (Get-ChildItem "$targetBase\regions" -File -Filter "*.json").Count
Write-Host "總共 $totalFiles 個JSON檔案" -ForegroundColor Yellow
