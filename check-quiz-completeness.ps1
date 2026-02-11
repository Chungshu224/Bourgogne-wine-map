# 課程測驗完整性檢查腳本
# 生成時間: 2026-02-11

Write-Host "`n" "="*60 -ForegroundColor Cyan
Write-Host "  布根地課程系統 - 測驗完整性檢查報告" -ForegroundColor Cyan
Write-Host "  生成時間: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "="*60 "`n" -ForegroundColor Cyan

$totalModules = 0
$totalWithQuiz = 0
$totalQuestions = 0
$allIssues = @()

for ($levelId = 1; $levelId -le 4; $levelId++) {
    Write-Host "【Level $levelId 檢查】" -ForegroundColor Yellow
    
    $levelPath = "public/data/courses/level$levelId"
    $allFiles = Get-ChildItem -Path $levelPath -File -Filter "*.json"
    $moduleFiles = $allFiles | Where-Object { $_.Name -ne "modules.json" }
    
    $levelModuleCount = $moduleFiles.Count
    $withQuiz = 0
    $withoutQuiz = @()
    $incompleteQuiz = @()
    $levelQuestions = 0
    
    foreach ($file in $moduleFiles) {
        try {
            $content = Get-Content $file.FullName -Raw | ConvertFrom-Json
            
            if ($content.quiz) {
                $withQuiz++
                $qCount = $content.quiz.questions.Count
                $levelQuestions += $qCount
                
                # 檢查題目數量
                if ($qCount -lt 5) {
                    $incompleteQuiz += "$($file.BaseName) (僅 $qCount 題，建議至少 5 題)"
                }
                
                # 檢查是否有 explanation
                $noExplanation = 0
                foreach ($q in $content.quiz.questions) {
                    if (-not $q.explanation -or $q.explanation.Trim() -eq "") {
                        $noExplanation++
                    }
                }
                
                if ($noExplanation -gt 0) {
                    $incompleteQuiz += "$($file.BaseName) ($noExplanation 題缺少解釋)"
                }
                
                # 檢查是否有 passingScore
                if (-not $content.quiz.passingScore) {
                    $incompleteQuiz += "$($file.BaseName) (缺少 passingScore)"
                }
                
            } else {
                $withoutQuiz += $file.BaseName
            }
        } catch {
            Write-Host "  ✗ 解析錯誤: $($file.BaseName) - $_" -ForegroundColor Red
            $allIssues += "Level $levelId - $($file.BaseName) - JSON 解析錯誤"
        }
    }
    
    $totalModules += $levelModuleCount
    $totalWithQuiz += $withQuiz
    $totalQuestions += $levelQuestions
    
    Write-Host "  總模組文件: $levelModuleCount"
    Write-Host "  有測驗: $withQuiz" -ForegroundColor Green
    Write-Host "  無測驗: $($withoutQuiz.Count)" -ForegroundColor $(if ($withoutQuiz.Count -eq 0) { "Green" } else { "Red" })
    Write-Host "  測驗總題數: $levelQuestions"
    
    if ($withQuiz -gt 0) {
        $avg = [math]::Round($levelQuestions / $withQuiz, 1)
        Write-Host "  平均每模組: $avg 題" -ForegroundColor Cyan
    }
    
    if ($withoutQuiz.Count -gt 0) {
        Write-Host "`n  ⚠ 缺少測驗的模組:" -ForegroundColor Yellow
        foreach ($mod in $withoutQuiz) {
            Write-Host "    - $mod" -ForegroundColor Yellow
            $allIssues += "Level $levelId - $mod - 缺少測驗"
        }
    }
    
    if ($incompleteQuiz.Count -gt 0) {
        Write-Host "`n  ⚠ 測驗不完整或有問題:" -ForegroundColor Yellow
        foreach ($issue in $incompleteQuiz) {
            Write-Host "    - $issue" -ForegroundColor Yellow
            $allIssues += "Level $levelId - $issue"
        }
    }
    
    if ($withoutQuiz.Count -eq 0 -and $incompleteQuiz.Count -eq 0) {
        Write-Host "  ✓ 所有測驗完整" -ForegroundColor Green
    }
    
    Write-Host ""
}

Write-Host "="*60 -ForegroundColor Cyan
Write-Host "  總體統計" -ForegroundColor Cyan
Write-Host "="*60 -ForegroundColor Cyan
Write-Host "  總模組數: $totalModules"
Write-Host "  有測驗模組: $totalWithQuiz" -ForegroundColor $(if ($totalWithQuiz -eq $totalModules) { "Green" } else { "Yellow" })
Write-Host "  測驗覆蓋率: $([math]::Round($totalWithQuiz / $totalModules * 100, 1))%"
Write-Host "  總題目數: $totalQuestions"
Write-Host "  平均每模組: $([math]::Round($totalQuestions / $totalWithQuiz, 1)) 題`n"

if ($allIssues.Count -gt 0) {
    Write-Host "="*60 -ForegroundColor Yellow
    Write-Host "  發現 $($allIssues.Count) 個問題需要修復" -ForegroundColor Yellow
    Write-Host "="*60 -ForegroundColor Yellow
    
    # 保存問題清單到文件
    $issuesFile = "quiz-issues-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
    $allIssues | Out-File $issuesFile -Encoding UTF8
    Write-Host "  問題清單已保存至: $issuesFile`n" -ForegroundColor Gray
} else {
    Write-Host "="*60 -ForegroundColor Green
    Write-Host "  ✓ 所有測驗檢查通過！" -ForegroundColor Green
    Write-Host "="*60 -ForegroundColor Green
}

Write-Host ""
