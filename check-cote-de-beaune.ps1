# 檢查 Côte-de-Beaune 區域的 GeoJSON 和 data 匹配情況

$geojsonBase = "c:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\Cote-de-Beaune"
$dataBase = "c:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\data\Cote-de-Beaune"

$villages = @(
    "01Pernand-Vergelesses",
    "02Ladoix",
    "03Aloxe-Corton",
    "04Savigny-lès-Beaune",
    "05Chorey-lès-Beaune",
    "06Beaune",
    "07Pommard",
    "08Volnay",
    "09Monthélie",
    "10Saint-Romain",
    "11Auxey-Duresses",
    "12Meursault",
    "13Blagny",
    "14Puligny-Montrachet",
    "15Chassagne-Montrachet",
    "16Saint-Aubin",
    "17Santenay",
    "18Maranges"
)

$report = @()

foreach ($village in $villages) {
    Write-Host "`n處理村莊: $village" -ForegroundColor Cyan
    
    # 列出所有 GeoJSON 文件
    $geojsonPath = Join-Path $geojsonBase $village
    if (Test-Path $geojsonPath) {
        $geojsonFiles = Get-ChildItem -Path $geojsonPath -Recurse -Filter "*.geojson"
        
        # 讀取對應的 data 文件
        $dataFile = Join-Path $dataBase "$village.json"
        if (Test-Path $dataFile) {
            $dataContent = Get-Content $dataFile -Raw | ConvertFrom-Json
            
            $missingData = @()
            
            foreach ($geojson in $geojsonFiles) {
                $fileName = $geojson.Name -replace '\.geojson$', ''
                $relativePath = $geojson.FullName.Replace($geojsonPath + "\", "")
                
                # 檢查 data 中是否有對應的數據
                $found = $false
                
                # 檢查各種可能的 key 結構
                $keysToCheck = @("Grand Crus", "grand_crus", "grandCrus", "1er Crus", "premier_crus", "premierCrus", "village", "villages", "lieux_dits", "lieuxDits")
                
                foreach ($key in $keysToCheck) {
                    if ($dataContent.PSObject.Properties.Name -contains $key) {
                        $items = $dataContent.$key
                        if ($items) {
                            foreach ($item in $items) {
                                if ($item.name -eq $fileName -or $item.aoc -eq $fileName -or $item.title -eq $fileName) {
                                    $found = $true
                                    break
                                }
                            }
                        }
                    }
                    if ($found) { break }
                }
                
                if (-not $found) {
                    $missingData += $relativePath
                }
            }
            
            $report += [PSCustomObject]@{
                Village = $village
                TotalGeoJSON = $geojsonFiles.Count
                WithData = $geojsonFiles.Count - $missingData.Count
                MissingData = $missingData
            }
        } else {
            Write-Host "  警告: 找不到 data 文件 $dataFile" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  警告: 找不到 GeoJSON 目錄 $geojsonPath" -ForegroundColor Yellow
    }
}

# 輸出報告
Write-Host "`n====== 檢查報告 ======" -ForegroundColor Green
foreach ($item in $report) {
    Write-Host "`n村莊名稱: $($item.Village)" -ForegroundColor Yellow
    Write-Host "  - GeoJSON 總數: $($item.TotalGeoJSON)"
    Write-Host "  - 有資料: $($item.WithData)"
    Write-Host "  - 缺少資料: $($item.MissingData.Count)"
    if ($item.MissingData.Count -gt 0) {
        Write-Host "  - 缺少資料的 GeoJSON 文件:" -ForegroundColor Red
        foreach ($missing in $item.MissingData) {
            Write-Host "    * $missing"
        }
    }
}
