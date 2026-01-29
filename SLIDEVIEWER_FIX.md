# SlideViewer 顯示衝突診斷報告

## 🔴 發現的問題

### 問題 1：同一個 section 可能產生多張投影片
在目前的邏輯中：
- 如果 `section` 同時有 `text` 和 `comparisonTable`，會創建 2 張投影片
- 如果 `section` 同時有 `keyPoints` 和 `comparisonTable`，也會創建 2 張

**範例（來自 beginner-m3.json lesson4-c）：**
```json
{
  "heading": "👀 觀色：讀懂酒的年齡",
  "text": "薄酒萊的顏色能透露村莊風格和陳年狀態",  // ← 創建 content slide
  "comparisonTable": { ... }                    // ← 又創建 comparison slide
}
```

### 問題 2：villageProfiles 處理邏輯不一致
- 某些版本會為每個村莊創建獨立投影片
- 某些版本會合併所有村莊到一張投影片
- 導致相同的 JSON 在不同時間顯示結果不同

### 問題 3：pairingRules 資料結構不匹配
- SlideViewer 期待簡單字串陣列
- 但 JSON 提供的是物件陣列 `{ rule, description, avoid, examples }`
- 兩種格式都需要支援

### 問題 4：缺少錯誤處理
- 沒有 null/undefined 檢查
- 陣列可能不是陣列
- 物件屬性可能不存在
- 一個 section 失敗會導致整個課程無法顯示

## 📋 建議的修復方案

### 修復原則
1. **互斥處理**：每個 section 只能創建一種類型的投影片
2. **優先級明確**：複雜結構 > 簡單列表 > 純文字 > 對比表
3. **防禦性編程**：所有陣列/物件都要檢查
4. **錯誤隔離**：單一 section 失敗不影響其他

### 優先級順序
1. `categories` - 分類列表（多張投影片）
2. `villageProfiles` - 村莊檔案（多張投影片）
3. `tastingSteps` - 品鑑步驟（多張投影片）
4. `pairingRules` - 配對規則（單張投影片）
5. `cuisineTypes` - 烹飪類型（多張投影片）
6. `subRegions` - 子產區（多張投影片）
7. `temperatures` - 溫度列表（單張）
8. `keyPoints` - 重點列表（單張）
9. `tips` - 技巧列表（單張）
10. `pairings` - 配對列表（單張）
11. `villages` - 村莊列表（單張）
12. `grandCrus` - 特級園列表（單張）
13. `comparisonTable` - 對比表（單張）
14. `text` - 純文字（單張）

### 核心邏輯變更
```javascript
if (section.heading) {
  let slideCreated = false
  
  try {
    // 按優先級處理，一旦 slideCreated = true 就跳出
    
    if (!slideCreated && section.categories && Array.isArray(section.categories)) {
      // 處理...
      slideCreated = true
    }
    
    if (!slideCreated && section.villageProfiles && Array.isArray(section.villageProfiles)) {
      // 處理...
      slideCreated = true
    }
    
    // ... 其他處理
    
    // 最後的備案
    if (!slideCreated) {
      console.warn('⚠️ Section 未能創建投影片:', section.heading)
    }
    
  } catch (error) {
    console.error('❌ 處理 section 錯誤:', section.heading, error)
  }
}
```

## 🛠️ 需要修改的文件
- `src/components/course/SlideViewer.vue` (lines 150-450)

## 🧪 測試重點
1. 測試包含 `text` + `comparisonTable` 的 section
2. 測試包含 `keyPoints` + `comparisonTable` 的 section
3. 測試空陣列、null 值、undefined 的情況
4. 測試錯誤的資料類型（物件當成陣列、字串當成物件）
