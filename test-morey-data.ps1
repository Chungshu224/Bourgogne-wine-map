# 測試 Morey-Saint-Denis 資料載入
$jsonPath = "public\data\Cote-de-Nuits\05Morey-Saint-Denis.json"

Write-Host "讀取 JSON 文件..." -ForegroundColor Cyan
$content = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json

Write-Host "`n頂層欄位:" -ForegroundColor Yellow
Write-Host "- name: $($content.name)"
Write-Host "- description: $($content.description.Substring(0, [Math]::Min(50, $content.description.Length)))..."
Write-Host "- grapeVarieties: $($content.grapeVarieties -join ', ')"
Write-Host "- famousWineries: $($content.famousWineries -join ', ')"

Write-Host "`n檢查 geojson 結構:" -ForegroundColor Yellow
if ($content.geojson) {
    Write-Host "✓ geojson 屬性存在" -ForegroundColor Green
    
    if ($content.geojson.premier_crus) {
        Write-Host "✓ premier_crus 屬性存在" -ForegroundColor Green
        Write-Host "  一級園數量: $($content.geojson.premier_crus.PSObject.Properties.Count)"
        
        Write-Host "`n一級園列表:" -ForegroundColor Cyan
        $content.geojson.premier_crus.PSObject.Properties | ForEach-Object {
            Write-Host "  - $($_.Name): $($_.Value.name)"
        }
        
        Write-Host "`n檢查 'clos-baulet':" -ForegroundColor Yellow
        if ($content.geojson.premier_crus.'clos-baulet') {
            Write-Host "✓ 'clos-baulet' 找到!" -ForegroundColor Green
            $closBaulet = $content.geojson.premier_crus.'clos-baulet'
            Write-Host "  name: $($closBaulet.name)"
            Write-Host "  fullName: $($closBaulet.fullName)"
            Write-Host "  classification: $($closBaulet.classification)"
            Write-Host "  area: $($closBaulet.area)"
            Write-Host "  altitude: $($closBaulet.altitude)"
            Write-Host "  soilStructure: $($closBaulet.soilStructure)"
            Write-Host "  grapeVarieties: $($closBaulet.grapeVarieties -join ', ')"
            Write-Host "  famousWineries: $($closBaulet.famousWineries -join ', ')"
        } else {
            Write-Host "✗ 'clos-baulet' 未找到!" -ForegroundColor Red
        }
    } else {
        Write-Host "✗ premier_crus 屬性不存在" -ForegroundColor Red
    }
    
    if ($content.geojson.grand_crus) {
        Write-Host "`n特級園數量: $($content.geojson.grand_crus.PSObject.Properties.Count)" -ForegroundColor Cyan
    }
} else {
    Write-Host "✗ geojson 屬性不存在" -ForegroundColor Red
}

Write-Host "`n測試檔名處理邏輯:" -ForegroundColor Yellow
$testFileName = "AOC Morey-Saint-Denis 1er Cru Clos Baulet.geojson"
Write-Host "原始檔名: $testFileName"

$searchKey = $testFileName -replace '\.geojson$', ''
Write-Host "去除 .geojson: $searchKey"

$searchKey = $searchKey -replace '(?i)AOC\s+',''
Write-Host "去除 'AOC ': $searchKey"

$searchKey = $searchKey -replace '(?i).*?1er\s+Cru\s+',''  
Write-Host "提取 1er Cru 後的名稱: $searchKey"

$searchKey = $searchKey.Trim().ToLower() -replace '\s+','-'
Write-Host "標準化: $searchKey"

if ($searchKey -eq 'clos-baulet') {
    Write-Host "✓ 標準化後的 key 匹配!" -ForegroundColor Green
} else {
    Write-Host "✗ Key 不匹配! 期望: 'clos-baulet', 實際: '$searchKey'" -ForegroundColor Red
}
