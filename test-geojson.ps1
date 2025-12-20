# 測試所有區域的 GeoJSON 檔案
# 此腳本會檢查各區域的 index.json 和示例檔案

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "布根地產區 GeoJSON 檔案檢查" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$baseDir = "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson"

$regions = @(
    @{ Id = "chablis"; Path = ""; Name = "Chablis" },
    @{ Id = "cote-de-nuits"; Path = "Cote-de-Nuits"; Name = "Côte de Nuits" },
    @{ Id = "cote-de-beaune"; Path = "Cote-de-Beaune"; Name = "Côte de Beaune" },
    @{ Id = "cote-chalonnaise"; Path = "Cote-Chalonnaise"; Name = "Côte Chalonnaise" },
    @{ Id = "maconnais"; Path = "Maconnais"; Name = "Mâconnais" },
    @{ Id = "beaujolais"; Path = "Beaujolais"; Name = "Beaujolais" }
)

foreach ($region in $regions) {
    Write-Host "檢查: $($region.Name)" -ForegroundColor Yellow
    
    if ($region.Path -eq "") {
        $regionPath = $baseDir
        $indexPath = "$baseDir\index.json"
    } else {
        $regionPath = "$baseDir\$($region.Path)"
        $indexPath = "$regionPath\index.json"
    }
    
    # 檢查 index.json
    if (Test-Path $indexPath) {
        Write-Host "  ✅ index.json 存在" -ForegroundColor Green
        
        # 讀取並驗證 JSON
        try {
            $indexContent = Get-Content $indexPath -Raw | ConvertFrom-Json
            $groupCount = ($indexContent.PSObject.Properties).Count
            Write-Host "  📁 包含 $groupCount 個分組" -ForegroundColor Gray
            
            # 檢查第一個分組的檔案
            $firstGroup = $indexContent.PSObject.Properties | Select-Object -First 1
            if ($firstGroup) {
                $groupName = $firstGroup.Name
                $files = $firstGroup.Value.files
                if ($files -and $files.Count -gt 0) {
                    $firstFile = $files[0]
                    
                    # 檢查檔案是否真的存在
                    if ($region.Path -eq "") {
                        # Chablis 有子資料夾結構
                        $searchPath = Get-ChildItem "$baseDir\*\$firstFile" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                    } else {
                        $searchPath = Get-ChildItem "$regionPath\*\$firstFile" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
                    }
                    
                    if ($searchPath) {
                        Write-Host "  ✅ 測試檔案可訪問: $firstFile" -ForegroundColor Green
                    } else {
                        Write-Host "  ⚠️  測試檔案未找到: $firstFile" -ForegroundColor Yellow
                    }
                }
            }
        } catch {
            Write-Host "  ❌ index.json 格式錯誤: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "  ❌ index.json 不存在: $indexPath" -ForegroundColor Red
    }
    
    # 統計 GeoJSON 檔案數
    if ($region.Path -eq "") {
        $geojsonCount = (Get-ChildItem "$baseDir" -Recurse -Filter "*.geojson").Count
    } else {
        $geojsonCount = (Get-ChildItem "$regionPath" -Recurse -Filter "*.geojson").Count
    }
    Write-Host "  📊 GeoJSON 檔案總數: $geojsonCount" -ForegroundColor Gray
    
    Write-Host ""
}

Write-Host "=====================================" -ForegroundColor Green
Write-Host "✅ 檢查完成！" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
Write-Host "現在可以開啟瀏覽器測試:" -ForegroundColor Yellow
Write-Host "http://localhost:5173" -ForegroundColor Cyan
