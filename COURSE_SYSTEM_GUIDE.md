# 布根地葡萄酒課程系統

## 系統架構

### 核心組件

#### 1. CourseManager.vue（課程管理器）
- **功能**：統籌整個課程系統的運作
- **職責**：
  - 管理視圖狀態切換（階段選擇 → 課程學習 → 證書展示）
  - 控制學習進度追蹤
  - 整合所有子組件
  - 處理 localStorage 資料存取

#### 2. LevelSelector.vue（階段選擇器）
- **功能**：四階段課程選擇介面
- **特色**：
  - 精美卡片式設計
  - 圓環進度顯示
  - 鎖定/解鎖機制
  - 統計資料儀表板
- **資料來源**：`/data/courses/levels.json`

#### 3. CourseLayout.vue（課程布局）
- **功能**：學習頁面框架
- **包含**：
  - 頂部導航列（返回、進度顯示）
  - 左側模組列表（帶圓環進度）
  - 右側內容區（插槽設計）
  - 順序解鎖邏輯

#### 4. LessonViewer.vue（課程檢視器）
- **功能**：顯示課程內容
- **支援內容類型**：
  - 📖 簡介與章節文字
  - 📅 歷史時間軸
  - 🍇 葡萄品種對比
  - 🏷️ 酒標元素解析
  - 🗺️ 地圖互動提示
  - 💡 實用提示
- **導航**：上一課 / 完成並繼續

#### 5. QuizEngine.vue（測驗引擎）
- **功能**：互動式測驗系統
- **包含三個階段**：
  1. **準備畫面**：題數、及格分數、時間預估
  2. **測驗中**：進度條、計時器、選項選擇、解釋說明
  3. **結果畫面**：圓環分數、詳細統計、重試/複習/繼續
- **題型支援**：單選題、是非題
- **自動儲存**：所有作答記錄存入 localStorage

#### 6. CertificateGenerator.vue（證書生成器）
- **功能**：精美證書設計與下載
- **設計元素**：
  - 金色邊框與印章
  - 漸層階段徽章
  - 完成統計網格
  - 簽名區與證書編號
- **操作**：
  - 📥 下載 PDF（需安裝 html2canvas + jsPDF）
  - 📤 分享到社群媒體
  - 🖨️ 列印證書

---

## 資料結構

### 階段定義 (`levels.json`)
```json
{
  "levels": [
    {
      "id": 1,
      "name": "初階課程",
      "icon": "🍇",
      "primaryColor": "#667eea",
      "duration": "4-6小時",
      "moduleCount": 5,
      "passingScore": 60,
      "unlockRequirement": 100,
      "objectives": [...]
    }
  ]
}
```

### 模組結構 (`level1/modules.json`)
```json
{
  "modules": [
    {
      "id": "module1",
      "order": 1,
      "title": "認識布根地",
      "icon": "🌍",
      "description": "...",
      "duration": "60分鐘",
      "lessonCount": 4,
      "locked": false,
      "progress": 0,
      "completed": false
    }
  ]
}
```

### 課程內容 (`level1/module1.json`)
```json
{
  "moduleId": "module1",
  "lessons": [
    {
      "id": "lesson1",
      "title": "布根地的地理與氣候",
      "duration": "15分鐘",
      "type": "video-text",
      "content": {
        "introduction": "...",
        "sections": [...],
        "timeline": [...],
        "grapes": [...],
        "labelElements": [...],
        "mapInteraction": {...}
      }
    }
  ],
  "quiz": {
    "passingScore": 60,
    "questions": [
      {
        "id": "q1",
        "question": "...",
        "type": "single-choice",
        "options": ["A", "B", "C", "D"],
        "correctAnswer": 0,
        "explanation": "..."
      }
    ]
  }
}
```

---

## 進度追蹤機制

### LocalStorage 鍵值

| 鍵值 | 用途 | 範例資料 |
|------|------|----------|
| `burgundy-level{levelId}-progress` | 階段整體進度 | `{"module1": {completed: true, progress: 100, quizScore: 85}}` |
| `completed-lessons-{moduleId}` | 模組已完成課程 | `["lesson1", "lesson2", "lesson3"]` |
| `quizHistory` | 測驗歷史記錄 | `[{moduleId, score, passed, completedAt, ...}]` |
| `certificates` | 已獲得證書 | `[{userName, level, averageScore, certificateId, ...}]` |
| `userName` | 學習者名稱 | `"張三"` |

### 解鎖邏輯

```javascript
// 模組解鎖
modules[0].locked = false  // 第一個永遠解鎖
modules[i].locked = !modules[i-1].completed  // 需完成前一個

// 階段解鎖
level2.locked = level1.overallProgress < 100 || level1.averageScore < 85
level3.locked = level2.overallProgress < 100 || level2.averageScore < 85
level4.locked = level3.overallProgress < 100 || level3.averageScore < 85
```

---

## 使用流程

### 學習者旅程

```
1. App.vue 地圖模式
   ↓ 點擊「進入課程模式」
   
2. CourseManager → LevelSelector
   → 選擇階段（初階🍇 / 中階🍷 / 高階🏆 / 大師👨‍🏫）
   
3. CourseManager → CourseLayout
   → 左側：模組列表（順序解鎖）
   → 右側：模組總覽（課程大綱）
   
4. 點擊「開始學習」
   → LessonViewer（課程 1/4）
   → 閱讀內容、觀看時間軸、比較品種、學習酒標
   → 點擊「完成並繼續」
   
5. 循環步驟 4 直到所有課程完成
   
6. 自動跳轉 QuizEngine
   → 準備畫面：查看題數、及格分數
   → 測驗中：作答、查看解釋
   → 結果畫面：查看分數
   
7a. 及格（≥60%）
    → 模組解鎖下一個
    → 繼續學習或返回
    
7b. 不及格
    → 複習課程或重新測驗
    
8. 完成所有 5 個模組
   → 自動生成證書
   → CertificateGenerator 展示
   → 下載/分享/列印
```

---

## 整合到主應用

### App.vue 修改

```vue
<script setup>
import CourseManager from './components/course/CourseManager.vue'

const currentMode = ref('map') // 'map' or 'course'

const switchMode = (mode) => {
  currentMode.value = mode
}
</script>

<template>
  <!-- 地圖模式 -->
  <div v-if="currentMode === 'map'">
    <button @click="switchMode('course')">📚 進入課程模式</button>
    <RegionSelector ... />
  </div>
  
  <!-- 課程模式 -->
  <div v-else-if="currentMode === 'course'">
    <button @click="switchMode('map')">← 返回地圖模式</button>
    <CourseManager />
  </div>
</template>
```

---

## 依賴套件（選用）

### PDF 下載功能
```bash
npm install html2canvas jspdf
```

如未安裝，`CertificateGenerator.vue` 會提示使用列印功能替代。

---

## 已完成內容

### ✅ 完整組件
- [x] LevelSelector.vue（647行）
- [x] CourseLayout.vue（423行）
- [x] LessonViewer.vue（500+行）
- [x] QuizEngine.vue（650+行）
- [x] CertificateGenerator.vue（550+行）
- [x] CourseManager.vue（450+行）

### ✅ 資料檔案
- [x] `/data/courses/levels.json`（4階段定義）
- [x] `/data/courses/level1/modules.json`（5模組）
- [x] `/data/courses/level1/module1.json`（4課程+10題測驗）

### 🔄 待完成
- [ ] Level 1 Module 2-5 資料檔案
- [ ] Level 2-4 所有模組資料
- [ ] 地圖互動功能整合
- [ ] 測驗題庫擴充

---

## 未來擴充方向

1. **影片整合**：嵌入 YouTube/Vimeo 影片
2. **互動地圖**：點擊課程內容跳轉到產區地圖
3. **社群功能**：學習者討論區、筆記分享
4. **成就系統**：徽章、排行榜、連續學習天數
5. **行動版優化**：響應式設計、觸控手勢
6. **多語言支援**：英文、法文介面
7. **AI 助教**：即時問答、個人化學習建議

---

## 開發者筆記

### 樣式變數
```css
主色調：#667eea（紫色）
次色調：#764ba2（深紫）
成功色：#4CAF50
警告色：#FF9800
錯誤色：#f44336
```

### 命名規範
- 組件：PascalCase（LevelSelector）
- 方法：camelCase（handleQuizComplete）
- 常數：UPPER_SNAKE_CASE（PASSING_SCORE）
- CSS：kebab-case（.level-selector）

### Git 提交建議
```bash
feat: 新增課程系統核心組件
feat: 實作測驗引擎與進度追蹤
feat: 新增證書生成功能
docs: 更新課程系統文檔
```

---

**最後更新**：2024-12-18  
**作者**：GitHub Copilot  
**版本**：1.0.0
