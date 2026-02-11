# 最終修正版腳本

$geojsonBase = "c:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\Cote-de-Beaune"
$dataBase = "c:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\data\Cote-de-Beaune"

$villages = @(
    "01Pernand-Vergelesses", "02Ladoix", "03Aloxe-Corton", "04Savigny-lès-Beaune",
    "05Chorey-lès-Beaune", "06Beaune", "07Pommard", "08Volnay", "09Monthélie",
    "10Saint-Romain", "11Auxey-Duresses", "12Meursault", "13Blagny", 
    "14Puligny-Montrachet", "15Chassagne-Montrachet", "16Saint-Aubin",
    "17Santenay", "18Maranges"
)

$totalReport = @()

foreach ($village in $villages) {
    $geojsonPath = Join-Path $geojsonBase $village
    $dataFile = Join-Path $dataBase "$village.json"
    
    if (-not (Test-Path $geojsonPath)) { continue }
    if (-not (Test-Path $dataFile)) { continue }
    
    $geojsonFiles = Get-ChildItem -Path $geojsonPath -Recurse -Filter "*.geojson"
    $geojsonCount = $geojsonFiles.Count
    
    $dataContent = Get-Content $dataFile -Raw | ConvertFrom-Json
    
    $definedFiles = @()
    
    function Get-GeojsonFiles($obj) {
        if ($obj -is [PSCustomObject]) {
            foreach ($prop in $obj.PSObject.Properties) {
                if ($prop.Name -eq "file" -and $prop.Value) {
                    $script:definedFiles += $prop.Value
                } elseif ($prop.Value -is [PSCustomObject] -or $prop.Value -is [Array]) {
                    Get-GeojsonFiles $prop.Value
                }
            }
        } elseif ($obj -is [Array]) {
            foreach ($item in $obj) {
                Get-GeojsonFiles $item
            }
        }
    }
    
    if ($dataContent.geojson) {
        Get-GeojsonFiles $dataContent.geojson
    }
    
    $missingFiles = @()
    
    foreach ($geoFile in $geojsonFiles) {
        # 正確計算相對路徑 - 使用 Substring
        $fullPath = $geoFile.FullName
        $basePath = $geojsonPath + "\"
        $relativePath = $fullPath.Substring($basePath.Length).Replace("\", "/")
        
        # 檢查是否在 definedFiles 中
        if ($definedFiles -notcontains $relativePath) {
            $missingFiles += $relativePath
        }
    }
    
    $withData = $geojsonCount - $missingFiles.Count
    
    $totalReport += [PSCustomObject]@{
        Village = $village
        Total = $geojsonCount
        WithData = $withData
        Missing = $missingFiles.Count
        MissingFiles = $missingFiles
    }
}

# 輸出報告
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Côte-de-Beaune 區域 GeoJSON 檢查報告" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$grandTotal = 0
$grandWithData = 0
$grandMissing = 0

foreach ($item in $totalReport) {
    $grandTotal += $item.Total
    $grandWithData += $item.WithData
    $grandMissing += $item.Missing
    
    Write-Host "$($item.Village):" -ForegroundColor Yellow
    Write-Host "  - GeoJSON 總數: $($item.Total)"
    Write-Host "  - 有資料: $($item.WithData)" -ForegroundColor Green
    Write-Host "  - 缺少資料: $($item.Missing)" -ForegroundColor $(if ($item.Missing -gt 0) {"Red"} else {"Green"})
    
    if ($item.Missing -gt 0 -and $item.MissingFiles.Count -le 10) {
        Write-Host "  - 缺少資料的 GeoJSON 文件:"
        foreach ($file in $item.MissingFiles) {
            Write-Host "    * $file" -ForegroundColor Red
        }
    } elseif ($item.Missing -gt 10) {
        Write-Host "  - 缺少資料的 GeoJSON 文件: (僅顯示前10個)"
        for ($i = 0; $i -lt 10; $i++) {
            Write-Host "    * $($item.MissingFiles[$i])" -ForegroundColor Red
        }
        Write-Host "    ... 還有 $($item.Missing - 10) 個文件" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "總計:" -ForegroundColor Cyan
Write-Host "  - GeoJSON 總數: $grandTotal"
Write-Host "  - 有資料: $grandWithData" -ForegroundColor Green
Write-Host "  - 缺少資料: $grandMissing" -ForegroundColor Red
if ($grandTotal -gt 0) {
    $percentage = [math]::Round(($grandWithData / $grandTotal) * 100, 2)
    Write-Host "  - 完成度: $percentage%" -ForegroundColor $(if ($percentage -ge 80) {"Green"} elseif ($percentage -ge 50) {"Yellow"} else {"Red"})
}
Write-Host "========================================" -ForegroundColor Cyan
