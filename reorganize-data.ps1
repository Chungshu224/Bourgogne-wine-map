# 重新整理 public/data 資料夾結構，對應 geojson 的分類方式
$dataBase = "public\data"

Write-Host "=== 重新整理資料夾結構 ===" -ForegroundColor Green

# 創建新的資料夾結構
$folders = @(
    "Cote-de-Nuits",
    "Cote-de-Beaune", 
    "Cote-Chalonnaise",
    "Maconnais",
    "Beaujolais"
)

foreach ($folder in $folders) {
    $path = "$dataBase\$folder"
    if (-not (Test-Path $path)) {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
        Write-Host "✓ 創建資料夾: $folder" -ForegroundColor Cyan
    }
}

Write-Host "`n開始移動檔案..." -ForegroundColor Yellow

# Côte de Nuits 的村莊
$coteDeNuitsFiles = @(
    "00Villages-introduction.json",
    "01Marsannay.json",
    "02Fixin.json", 
    "03Brochon.json",
    "04Gevrey Chambertin.json",
    "05Morey-Saint-Denis.json",
    "06Chambolle Musigny.json",
    "07Flagey-Echézeaux.json",
    "08Vosne-Romanée.json",
    "09Vougeot.json",
    "10Nuits-Saint-Georges.json"
)

Write-Host "`nCôte de Nuits:" -ForegroundColor Cyan
foreach ($file in $coteDeNuitsFiles) {
    $source = "$dataBase\regions\$file"
    $dest = "$dataBase\Cote-de-Nuits\$file"
    if (Test-Path $source) {
        Copy-Item $source $dest -Force
        Write-Host "  ✓ $file" -ForegroundColor Gray
    }
}

# Côte de Beaune 的村莊
$coteDeBeauneFiles = @(
    "01Pernand-Vergelesses.json",
    "02Ladoix.json",
    "03Aloxe-Corton.json",
    "04Savigny-lès-Beaune.json",
    "05Chorey-lès-Beaune.json",
    "06Beaune.json",
    "07Pommard.json",
    "08Volnay.json",
    "09Monthélie.json",
    "10Saint-Romain.json",
    "11Auxey-Duresses.json",
    "12Meursault.json",
    "13Blagny.json",
    "14Puligny-Montrachet.json",
    "15Chassagne-Montrachet.json",
    "16Saint-Aubin.json",
    "17Santenay.json",
    "18Maranges.json"
)

Write-Host "`nCôte de Beaune:" -ForegroundColor Cyan
foreach ($file in $coteDeBeauneFiles) {
    $source = "$dataBase\regions\$file"
    $dest = "$dataBase\Cote-de-Beaune\$file"
    if (Test-Path $source) {
        Copy-Item $source $dest -Force
        Write-Host "  ✓ $file" -ForegroundColor Gray
    }
}

# Côte Chalonnaise 的村莊
$coteChalonnaisFiles = @(
    "01Bouzeron.json",
    "02Rully.json",
    "03Mercurey.json",
    "04Givry.json",
    "05Montagny.json",
    "Regional.json"
)

Write-Host "`nCôte Chalonnaise:" -ForegroundColor Cyan
foreach ($file in $coteChalonnaisFiles) {
    $source = "$dataBase\regions\$file"
    $dest = "$dataBase\Cote-Chalonnaise\$file"
    if (Test-Path $source) {
        Copy-Item $source $dest -Force
        Write-Host "  ✓ $file" -ForegroundColor Gray
    }
}

# 保留 Chablis 和 Grand Auxerrois 在根目錄（已經存在）
Write-Host "`nChablis & Grand Auxerrois (保持原位置):" -ForegroundColor Cyan
Write-Host "  ✓ Chablis.json" -ForegroundColor Gray
Write-Host "  ✓ Grand Auxerrois.json" -ForegroundColor Gray
Write-Host "  ✓ AOC Bourgogne.json" -ForegroundColor Gray

Write-Host "`n完成！資料夾結構已重新整理" -ForegroundColor Green
Write-Host "`n新的結構:" -ForegroundColor Yellow
Write-Host "public/data/"
Write-Host "  ├─ Chablis.json (Chablis 總覽)"
Write-Host "  ├─ Grand Auxerrois.json"
Write-Host "  ├─ AOC Bourgogne.json"
Write-Host "  ├─ Cote-de-Nuits/ (11 個村莊)"
Write-Host "  ├─ Cote-de-Beaune/ (18 個村莊)"
Write-Host "  ├─ Cote-Chalonnaise/ (6 個檔案)"
Write-Host "  ├─ Maconnais/ (待補充)"
Write-Host "  ├─ Beaujolais/ (待補充)"
Write-Host "  └─ regions/ (舊資料，可保留備份)" -ForegroundColor DarkGray
