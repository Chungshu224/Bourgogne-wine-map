# Data 資料夾 JSON 格式一致性報告

生成時間: 2026年2月9日

## 📊 統計摘要

### ✅ 已使用標準欄位的區域 (正確)
- **Côte de Nuits**: 11個文件 - 全部使用 `grapeVarieties`, `famousWineries`, `soilStructure`
- **AOC Bourgogne**: 1個文件 - 使用標準欄位
- **Chablis**: 2個文件 - 使用標準欄位

**小計: 14個文件 ✅**

---

### ❌ 仍使用舊欄位的區域 (需要修正)

#### 1. **Côte de Beaune** (18個文件)
使用舊欄位: `grapes`, `producers`, `soil`

文件列表:
- 01Pernand-Vergelesses.json
- 02Ladoix.json
- 03Aloxe-Corton.json
- 04Savigny-lès-Beaune.json
- 05Chorey-lès-Beaune.json
- 06Beaune.json
- 07Pommard.json
- 08Volnay.json
- 09Monthélie.json
- 10Saint-Romain.json
- 11Auxey-Duresses.json
- 12Meursault.json
- 13Blagny.json
- 14Puligny-Montrachet.json
- 15Chassagne-Montrachet.json
- 16Saint-Aubin.json
- 17Santenay.json
- 18Maranges.json

#### 2. **Côte Chalonnaise** (6個文件)
使用舊欄位: `grapes`, `producers`, `soil`

文件列表:
- 01Bouzeron.json
- 02 Rully.json
- 03Mercurey.json
- 04Givry.json
- 05Montagny.json
- Regional.json

#### 3. **Mâconnais** (1個文件)
使用舊欄位: `grapes`, `producers`, `soil`

文件列表:
- Regional.json

#### 4. **Beaujolais** (1個文件)
使用舊欄位: `grapes`, `producers`, `soil`

文件列表:
- Regional.json

**小計: 26個文件 ❌**

---

## 🎯 標準欄位對照表

| 舊欄位名稱 | 新欄位名稱 | 說明 |
|---------|----------|------|
| `grapes` | `grapeVarieties` | 葡萄品種 |
| `producers` | `famousWineries` | 知名酒莊 |
| `soil` | `soilStructure` | 土壤結構 |

---

## 📝 建議修正方案

### 方案 1: 批量修正 (推薦)
一次性修正所有 26 個文件，確保整個系統使用統一的欄位名稱。

**優點:**
- 完全統一，避免混淆
- 一次性完成，節省時間
- 確保 UI 顯示正確

**缺點:**
- 需要處理較多文件

### 方案 2: 分區域逐步修正
按區域順序修正：
1. Côte de Beaune (18個)
2. Côte Chalonnaise (6個)
3. Mâconnais (1個)
4. Beaujolais (1個)

---

## 🔍 欄位使用現況

### 正確格式範例 (Côte de Nuits)
```json
{
  "name": "Marsannay",
  "grapeVarieties": ["Pinot Noir", "Chardonnay"],
  "soilStructure": "石灰岩和泥灰岩",
  "famousWineries": ["Domaine Bruno Clair", "Domaine Sylvain Pataille"]
}
```

### 需修正格式範例 (Côte de Beaune)
```json
{
  "name": "Pernand-Vergelesses",
  "grapes": ["Chardonnay", "Pinot Noir"],
  "soil": "石灰岩和泥灰岩",
  "producers": ["Domaine Rollin Père et Fils"]
}
```

---

## ⚠️ UI 顯示影響

目前 MapSection.vue 已更新為使用新欄位名稱:
- ✅ `regionInfo.grapeVarieties` 
- ✅ `regionInfo.famousWineries`
- ✅ `regionInfo.soilStructure`

**影響:** 使用舊欄位的 26 個文件中，這些資訊將無法正確顯示！

---

## 🚀 建議行動

**立即修正所有 26 個文件**，確保：
1. 葡萄品種正確顯示
2. 知名酒莊正確顯示
3. 土壤結構正確顯示
4. 氣候資訊正確顯示
5. 整體系統格式統一
