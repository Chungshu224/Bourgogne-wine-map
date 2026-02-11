# 批量標準化 JSON 欄位名稱
# 將舊欄位名稱替換為新的標準欄位名稱

$targets = @(
    # Côte de Nuits (11 files) - 需要處理 geojson 內的嵌套欄位
    "public\data\Cote-de-Nuits\00Villages-introduction.json",
    "public\data\Cote-de-Nuits\01Marsannay.json",
    "public\data\Cote-de-Nuits\02Fixin.json",
    "public\data\Cote-de-Nuits\03Brochon.json",
    "public\data\Cote-de-Nuits\04Gevrey Chambertin.json",
    "public\data\Cote-de-Nuits\05Morey-Saint-Denis.json",
    "public\data\Cote-de-Nuits\06Chambolle Musigny.json",
    "public\data\Cote-de-Nuits\07Flagey-Echézeaux.json",
    "public\data\Cote-de-Nuits\08Vosne-Romanée.json",
    "public\data\Cote-de-Nuits\09Vougeot.json",
    "public\data\Cote-de-Nuits\10Nuits-Saint-Georges.json",
    
    # Côte de Beaune (18 files)
    "public\data\Cote-de-Beaune\01Pernand-Vergelesses.json",
    "public\data\Cote-de-Beaune\02Ladoix.json",
    "public\data\Cote-de-Beaune\03Aloxe-Corton.json",
    "public\data\Cote-de-Beaune\04Savigny-lès-Beaune.json",
    "public\data\Cote-de-Beaune\05Chorey-lès-Beaune.json",
    "public\data\Cote-de-Beaune\06Beaune.json",
    "public\data\Cote-de-Beaune\07Pommard.json",
    "public\data\Cote-de-Beaune\08Volnay.json",
    "public\data\Cote-de-Beaune\09Monthélie.json",
    "public\data\Cote-de-Beaune\10Saint-Romain.json",
    "public\data\Cote-de-Beaune\11Auxey-Duresses.json",
    "public\data\Cote-de-Beaune\12Meursault.json",
    "public\data\Cote-de-Beaune\13Blagny.json",
    "public\data\Cote-de-Beaune\14Puligny-Montrachet.json",
    "public\data\Cote-de-Beaune\15Chassagne-Montrachet.json",
    "public\data\Cote-de-Beaune\16Saint-Aubin.json",
    "public\data\Cote-de-Beaune\17Santenay.json",
    "public\data\Cote-de-Beaune\18Maranges.json",
    
    # Côte Chalonnaise (6 files)
    "public\data\Cote-Chalonnaise\01Bouzeron.json",
    "public\data\Cote-Chalonnaise\02 Rully.json",
    "public\data\Cote-Chalonnaise\03Mercurey.json",
    "public\data\Cote-Chalonnaise\04Givry.json",
    "public\data\Cote-Chalonnaise\05Montagny.json",
    "public\data\Cote-Chalonnaise\Regional.json",
    
    # Mâconnais (1 file)
    "public\data\Maconnais\Regional.json",
    
    # Beaujolais (1 file)
    "public\data\Beaujolais\Regional.json"
)

$replacements = @{
    '"grapes":' = '"grapeVarieties":'
    '"producers":' = '"famousWineries":'
    '"soil":' = '"soilStructure":'
}

$totalFiles = 0
$successFiles = 0
$errorFiles = 0

Write-Host "開始批量標準化 JSON 欄位名稱..." -ForegroundColor Cyan
Write-Host "目標文件數: $($targets.Count)" -ForegroundColor Yellow
Write-Host ""

foreach ($file in $targets) {
    $totalFiles++
    $filePath = Join-Path $PSScriptRoot $file
    
    if (-not (Test-Path $filePath)) {
        Write-Host "[$totalFiles/$($targets.Count)] ❌ 文件不存在: $file" -ForegroundColor Red
        $errorFiles++
        continue
    }
    
    try {
        # 讀取文件內容
        $content = Get-Content $filePath -Raw -Encoding UTF8
        $originalContent = $content
        
        # 執行替換
        $modified = $false
        foreach ($old in $replacements.Keys) {
            $new = $replacements[$old]
            if ($content -match [regex]::Escape($old)) {
                $content = $content -replace [regex]::Escape($old), $new
                $modified = $true
            }
        }
        
        if ($modified) {
            # 寫回文件
            $content | Set-Content $filePath -Encoding UTF8 -NoNewline
            Write-Host "[$totalFiles/$($targets.Count)] ✅ 已更新: $file" -ForegroundColor Green
            $successFiles++
        } else {
            Write-Host "[$totalFiles/$($targets.Count)] ⏭️  無需更新: $file" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "[$totalFiles/$($targets.Count)] ❌ 錯誤: $file - $($_.Exception.Message)" -ForegroundColor Red
        $errorFiles++
    }
}

Write-Host ""
Write-Host "==================== 執行結果 ====================" -ForegroundColor Cyan
Write-Host "總文件數: $totalFiles" -ForegroundColor White
Write-Host "成功更新: $successFiles" -ForegroundColor Green
Write-Host "錯誤數量: $errorFiles" -ForegroundColor $(if ($errorFiles -gt 0) { "Red" } else { "Gray" })
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "欄位替換規則:" -ForegroundColor Yellow
Write-Host "  grapes → grapeVarieties" -ForegroundColor White
Write-Host "  producers → famousWineries" -ForegroundColor White
Write-Host "  soil → soilStructure" -ForegroundColor White
