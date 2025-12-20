# 整理 public/data 資料夾結構
# 1. 確認村莊資料夾的完整性
# 2. 補充缺失的資料
# 3. 刪除 regions 資料夾

$dataBase = "public\data"

Write-Host "=== 資料夾整理與補充 ===" -ForegroundColor Green

# 檢查當前狀態
Write-Host "`n【當前狀態】" -ForegroundColor Yellow
$folders = @("Cote-de-Nuits", "Cote-de-Beaune", "Cote-Chalonnaise", "Maconnais", "Beaujolais")
foreach ($folder in $folders) {
    $path = "$dataBase\$folder"
    if (Test-Path $path) {
        $count = (Get-ChildItem $path -File).Count
        Write-Host "  ✓ $folder : $count 個檔案" -ForegroundColor Gray
    } else {
        Write-Host "  ✗ $folder : 資料夾不存在" -ForegroundColor Red
    }
}

$regionsCount = (Get-ChildItem "$dataBase\regions" -File -ErrorAction SilentlyContinue).Count
Write-Host "  ℹ regions : $regionsCount 個檔案" -ForegroundColor DarkGray

# 補充 Mâconnais 的資料
Write-Host "`n【補充 Mâconnais 資料】" -ForegroundColor Cyan
$maconnaisData = @"
{
  "name": "Mâconnais",
  "description": "馬貢內（Mâconnais）位於布根地南部，是一個以白酒為主的產區。這裡的葡萄酒通常價格親民，性價比高，以清新果香和礦物質風味著稱。",
  "area": "約 6,800 公頃",
  "altitude": "200-500m",
  "exposition": "東、東南",
  "grapeVarieties": [
    "Chardonnay",
    "Gamay",
    "Pinot Noir"
  ],
  "wineTypes": [
    "白酒",
    "紅酒"
  ],
  "climate": "大陸性氣候，比北部稍溫暖，受到地中海氣候的輕微影響。",
  "soilStructure": "石灰岩、泥灰岩、花崗岩的混合土壤，多樣化的地質為葡萄酒帶來豐富的風味。",
  "wineStyle": "白酒：清新活潑、果香濃郁，帶有礦物感。紅酒：輕盈易飲、果味豐富。",
  "tastingNotes": "白酒：檸檬、青蘋果、榛果、礦物質。紅酒：紅櫻桃、草莓。",
  "agingPotential": "白酒：2-5年（Pouilly-Fuissé 可達 8-10年），紅酒：2-4年",
  "famousWineries": [
    "Domaine de la Bongran",
    "Domaine Ferret",
    "Château de Fuissé",
    "Domaine J.A. Ferret",
    "Domaine Saumaize-Michelin"
  ],
  "grandCrus": [],
  "premierCrus": [],
  "villages": [
    "Pouilly-Fuissé",
    "Pouilly-Loché",
    "Pouilly-Vinzelles",
    "Saint-Véran",
    "Viré-Clessé",
    "Mâcon-Villages"
  ],
  "highlights": [
    "Pouilly-Fuissé：馬貢內最知名的村莊級AOC，以優質白酒聞名",
    "Saint-Véran：性價比極高的白酒產區",
    "Viré-Clessé：2002年升級為村莊級AOC，品質優異"
  ]
}
"@

$maconnaisPath = "$dataBase\Maconnais\Regional.json"
if (-not (Test-Path (Split-Path $maconnaisPath))) {
    New-Item -Path (Split-Path $maconnaisPath) -ItemType Directory -Force | Out-Null
}
$maconnaisData | Out-File -FilePath $maconnaisPath -Encoding UTF8
Write-Host "  ✓ 已創建 Mâconnais\Regional.json" -ForegroundColor Green

# 補充 Beaujolais 的資料
Write-Host "`n【補充 Beaujolais 資料】" -ForegroundColor Cyan
$beaujolaisData = @"
{
  "name": "Beaujolais",
  "description": "薄酒萊（Beaujolais）是布根地最南端的產區，以 Gamay 葡萄和輕盈果香的紅酒聞名於世。這裡的新酒（Beaujolais Nouveau）每年11月第三個星期四全球同步上市，是葡萄酒界的年度盛事。",
  "area": "約 18,000 公頃",
  "altitude": "200-600m",
  "exposition": "東、東南",
  "grapeVarieties": [
    "Gamay",
    "Chardonnay (少量)"
  ],
  "wineTypes": [
    "紅酒",
    "白酒（極少量）",
    "玫瑰紅"
  ],
  "climate": "半大陸性氣候，受到地中海和大西洋的影響，氣候溫和。",
  "soilStructure": "北部：花崗岩土壤（10個列級村莊），南部：石灰岩和黏土。",
  "wineStyle": "紅酒：果香濃郁、輕盈易飲、單寧柔順。Cru級別：結構更複雜、陳年潛力更強。",
  "tastingNotes": "紅莓、櫻桃、覆盆子、香蕉（新酒）、花香、礦物質（列級村莊）。",
  "agingPotential": "Beaujolais/Villages：1-3年，Beaujolais Nouveau：6個月內飲用，Cru Beaujolais：5-10年（某些可達15年）",
  "famousWineries": [
    "Château des Jacques (Louis Jadot)",
    "Domaine Marcel Lapierre",
    "Domaine Jean-Paul Brun",
    "Domaine Chignard",
    "Georges Duboeuf"
  ],
  "grandCrus": [],
  "premierCrus": [],
  "crus": [
    "Morgon",
    "Fleurie",
    "Moulin-à-Vent",
    "Brouilly",
    "Côte de Brouilly",
    "Juliénas",
    "Saint-Amour",
    "Chénas",
    "Chiroubles",
    "Régnié"
  ],
  "highlights": [
    "Morgon：最強勁的 Cru，有陳年潛力",
    "Fleurie：最優雅、花香豐富的 Cru",
    "Moulin-à-Vent：'薄酒萊之王'，結構最複雜",
    "Beaujolais Nouveau：全球矚目的新酒節"
  ],
  "vinificationMethod": "半二氧化碳浸漬法（Semi-carbonic maceration），保留果香和清新口感"
}
"@

$beaujolaisPath = "$dataBase\Beaujolais\Regional.json"
if (-not (Test-Path (Split-Path $beaujolaisPath))) {
    New-Item -Path (Split-Path $beaujolaisPath) -ItemType Directory -Force | Out-Null
}
$beaujolaisData | Out-File -FilePath $beaujolaisPath -Encoding UTF8
Write-Host "  ✓ 已創建 Beaujolais\Regional.json" -ForegroundColor Green

# 驗證所有村莊資料夾的完整性
Write-Host "`n【驗證資料完整性】" -ForegroundColor Yellow
$allComplete = $true
foreach ($folder in $folders) {
    $path = "$dataBase\$folder"
    $fileCount = (Get-ChildItem $path -File -ErrorAction SilentlyContinue).Count
    if ($fileCount -eq 0) {
        Write-Host "  ⚠ $folder 沒有資料檔案" -ForegroundColor Yellow
        $allComplete = $false
    } else {
        Write-Host "  ✓ $folder : $fileCount 個檔案" -ForegroundColor Green
    }
}

# 刪除 regions 資料夾
Write-Host "`n【清理 regions 資料夾】" -ForegroundColor Cyan
$regionsPath = "$dataBase\regions"
if (Test-Path $regionsPath) {
    Write-Host "  正在刪除 regions 資料夾..." -ForegroundColor Gray
    Remove-Item $regionsPath -Recurse -Force
    Write-Host "  ✓ regions 資料夾已刪除" -ForegroundColor Green
} else {
    Write-Host "  ℹ regions 資料夾不存在" -ForegroundColor DarkGray
}

# 最終報告
Write-Host "`n【整理完成】" -ForegroundColor Green
Write-Host "資料夾結構：" -ForegroundColor Yellow
Write-Host "public/data/"
Write-Host "  ├─ Chablis.json (Chablis 總覽)"
Write-Host "  ├─ Grand Auxerrois.json"
Write-Host "  ├─ AOC Bourgogne.json"
Write-Host "  ├─ Cote-de-Nuits/ (11 個村莊)" -ForegroundColor Green
Write-Host "  ├─ Cote-de-Beaune/ (18 個村莊)" -ForegroundColor Green
Write-Host "  ├─ Cote-Chalonnaise/ (6 個檔案)" -ForegroundColor Green
Write-Host "  ├─ Maconnais/ (1 個檔案)" -ForegroundColor Green
Write-Host "  └─ Beaujolais/ (1 個檔案)" -ForegroundColor Green

if ($allComplete) {
    Write-Host "`n✅ 所有產區都有完整的資料說明" -ForegroundColor Green
} else {
    Write-Host "`n⚠ 部分產區資料可能需要進一步補充" -ForegroundColor Yellow
}
