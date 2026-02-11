# 更詳細的 AOC JSON 檔案分析

$results = @()

# 定義需要檢查的頂層屬性
$topLevelProps = @(
    'name', 'description', 'area', 'altitude', 'exposition', 
    'grapeVarieties', 'wineTypes', 'climate', 'soilStructure', 
    'wineStyle', 'tastingNotes', 'agingPotential', 'famousWineries',
    'grandCrus', 'premierCrus', 'history'
)

# 獲取所有需要檢查的 JSON 檔案
$folders = @(
    'Beaujolais',
    'Chablis',
    'Cote-Chalonnaise',
    'Cote-de-Beaune',
    'Cote-de-Nuits',
    'Maconnais'
)

# 檢查 AOC Bourgogne.json
$file = "public\data\AOC Bourgogne.json"
if (Test-Path $file) {
    $content = Get-Content $file -Raw | ConvertFrom-Json
    
    $hasTopLevel = $false
    foreach ($prop in $topLevelProps) {
        if ($content.PSObject.Properties.Name -contains $prop) {
            $hasTopLevel = $true
            break
        }
    }
    
    $hasGeojson = $content.PSObject.Properties.Name -contains 'geojson'
    
    # 檢查鍵名
    $keyNames = @()
    if ($content.PSObject.Properties.Name -contains "1er Crus") { $keyNames += "1er Crus" }
    if ($content.PSObject.Properties.Name -contains "premier_crus") { $keyNames += "premier_crus" }
    if ($content.PSObject.Properties.Name -contains "Grand Crus") { $keyNames += "Grand Crus" }
    if ($content.PSObject.Properties.Name -contains "grand_crus") { $keyNames += "grand_crus" }
    
    # 檢查是否為陣列格式
    $isArray = $false
    if ($content.PSObject.Properties.Name -contains "1er Crus" -and $content."1er Crus" -is [Array]) { $isArray = $true }
    if ($content.PSObject.Properties.Name -contains "premier_crus" -and $content.premier_crus -is [Array]) { $isArray = $true }
    if ($content.PSObject.Properties.Name -contains "Grand Crus" -and $content."Grand Crus" -is [Array]) { $isArray = $true }
    if ($content.PSObject.Properties.Name -contains "grand_crus" -and $content.grand_crus -is [Array]) { $isArray = $true }
    
    # 判斷修正類型
    $fixType = @()
    if (-not $hasTopLevel) { $fixType += "Type A" }
    if ($keyNames -contains "1er Crus" -or $keyNames -contains "Grand Crus") { $fixType += "Type B" }
    if ($isArray) { $fixType += "Type C" }
    if ($fixType.Count -eq 0) { $fixType += "Type D" }
    
    $results += [PSCustomObject]@{
        Region = "Root"
        FileName = "AOC Bourgogne.json"
        HasTopLevel = $hasTopLevel
        HasGeojson = $hasGeojson
        KeyNames = ($keyNames -join ", ")
        IsArray = $isArray
        FixType = ($fixType -join ", ")
    }
}

# 檢查各產區資料夾
foreach ($folder in $folders) {
    $path = "public\data\$folder"
    if (Test-Path $path) {
        $files = Get-ChildItem $path -Filter "*.json"
        
        foreach ($file in $files) {
            $content = Get-Content $file.FullName -Raw | ConvertFrom-Json
            
            $hasTopLevel = $false
            foreach ($prop in $topLevelProps) {
                if ($content.PSObject.Properties.Name -contains $prop) {
                    $hasTopLevel = $true
                    break
                }
            }
            
            $hasGeojson = $content.PSObject.Properties.Name -contains 'geojson'
            
            # 檢查鍵名
            $keyNames = @()
            if ($content.PSObject.Properties.Name -contains "1er Crus") { $keyNames += "1er Crus" }
            if ($content.PSObject.Properties.Name -contains "premier_crus") { $keyNames += "premier_crus" }
            if ($content.PSObject.Properties.Name -contains "Grand Crus") { $keyNames += "Grand Crus" }
            if ($content.PSObject.Properties.Name -contains "grand_crus") { $keyNames += "grand_crus" }
            
            # 檢查是否為陣列格式
            $isArray = $false
            if ($content.PSObject.Properties.Name -contains "1er Crus" -and $content."1er Crus" -is [Array]) { $isArray = $true }
            if ($content.PSObject.Properties.Name -contains "premier_crus" -and $content.premier_crus -is [Array]) { $isArray = $true }
            if ($content.PSObject.Properties.Name -contains "Grand Crus" -and $content."Grand Crus" -is [Array]) { $isArray = $true }
            if ($content.PSObject.Properties.Name -contains "grand_crus" -and $content.grand_crus -is [Array]) { $isArray = $true }
            
            # 判斷修正類型
            $fixType = @()
            if (-not $hasTopLevel) { $fixType += "Type A" }
            if ($keyNames -contains "1er Crus" -or $keyNames -contains "Grand Crus") { $fixType += "Type B" }
            if ($isArray) { $fixType += "Type C" }
            if ($fixType.Count -eq 0) { $fixType += "Type D" }
            
            $results += [PSCustomObject]@{
                Region = $folder
                FileName = $file.Name
                HasTopLevel = $hasTopLevel
                HasGeojson = $hasGeojson
                KeyNames = ($keyNames -join ", ")
                IsArray = $isArray
                FixType = ($fixType -join ", ")
            }
        }
    }
}

# 輸出為 Markdown 表格
$sb = New-Object System.Text.StringBuilder

[void]$sb.AppendLine("# AOC JSON 檔案結構分析報告")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## 修正類型說明")
[void]$sb.AppendLine("- **Type A**: 缺少頂層產區資訊")
[void]$sb.AppendLine("- **Type B**: 使用舊的鍵名稱（需要改為 premier_crus, grand_crus）")
[void]$sb.AppendLine("- **Type C**: 使用陣列格式（需要重構為對象格式）")
[void]$sb.AppendLine("- **Type D**: 格式正確，無需修正")
[void]$sb.AppendLine("")

# 按產區分組
$grouped = $results | Group-Object -Property Region | Sort-Object Name

foreach ($group in $grouped) {
    [void]$sb.AppendLine("## $($group.Name)")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("| 檔案名稱 | 頂層資訊 | GeoJSON | 鍵名稱 | 陣列格式 | 修正類型 |")
    [void]$sb.AppendLine("|---------|---------|---------|--------|---------|---------|")
    
    foreach ($item in $group.Group | Sort-Object FileName) {
        $topLevel = if ($item.HasTopLevel) { "✓" } else { "✗" }
        $geojson = if ($item.HasGeojson) { "✓" } else { "✗" }
        $array = if ($item.IsArray) { "是" } else { "否" }
        $keys = if ($item.KeyNames) { $item.KeyNames } else { "-" }
        
        [void]$sb.AppendLine("| $($item.FileName) | $topLevel | $geojson | $keys | $array | $($item.FixType) |")
    }
    
    [void]$sb.AppendLine("")
}

# 統計摘要
[void]$sb.AppendLine("## 統計摘要")
[void]$sb.AppendLine("")
$total = $results.Count
$needTypeA = ($results | Where-Object { $_.FixType -like "*Type A*" }).Count
$needTypeB = ($results | Where-Object { $_.FixType -like "*Type B*" }).Count
$needTypeC = ($results | Where-Object { $_.FixType -like "*Type C*" }).Count
$typeD = ($results | Where-Object { $_.FixType -eq "Type D" }).Count

[void]$sb.AppendLine("| 項目 | 數量 |")
[void]$sb.AppendLine("|------|------|")
[void]$sb.AppendLine("| 總檔案數 | $total |")
[void]$sb.AppendLine("| 需要 Type A 修正 | $needTypeA |")
[void]$sb.AppendLine("| 需要 Type B 修正 | $needTypeB |")
[void]$sb.AppendLine("| 需要 Type C 修正 | $needTypeC |")
[void]$sb.AppendLine("| Type D (無需修正) | $typeD |")

# 輸出到檔案
$output = $sb.ToString()
$output | Out-File -FilePath "AOC_ANALYSIS_REPORT.md" -Encoding utf8

Write-Host $output
Write-Host "`n報告已儲存至: AOC_ANALYSIS_REPORT.md"
