# 🚀 快速參考指南

## 一鍵命令

### 開發環境
```powershell
# 啟動開發伺服器
npm run dev

# 建立生產版本
npm run build

# 預覽生產版本
npm run preview
```

### 整合其他區域
```powershell
# 執行自動化複製腳本
.\copy-regions.ps1
```

---

## 📁 重要檔案快速索引

| 檔案 | 用途 | 優先級 |
|------|------|--------|
| [SUMMARY.md](SUMMARY.md) | 📋 專案摘要與完成狀態 | ⭐⭐⭐ |
| [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) | 📖 詳細整合步驟 | ⭐⭐⭐ |
| [ARCHITECTURE.md](ARCHITECTURE.md) | 🏗️ 系統架構圖解 | ⭐⭐ |
| [copy-regions.ps1](copy-regions.ps1) | 🔧 自動化工具 | ⭐⭐⭐ |

---

## 🔧 核心組件

### RegionSelector.vue
**位置**: `src/components/RegionSelector.vue`  
**功能**: 六大區域選擇介面  
**事件**: `@region-selected`

```vue
<!-- 使用範例 -->
<RegionSelector @region-selected="handleRegionSelected" />
```

### App.vue
**位置**: `src/App.vue`  
**功能**: 主應用邏輯、區域切換  
**狀態**: 
- `currentRegion`: 當前選擇的區域
- `showRegionSelector`: 是否顯示選擇器

### dataService.js
**位置**: `src/dataService.js`  
**主要方法**:
```javascript
// 載入區域索引
await dataService.getRegionsIndex()

// 取得特定區域配置
await dataService.getRegionConfig('chablis')

// 載入 GeoJSON
await dataService.getGeoJSON('chablis', 'Chablis/AOC Chablis.geojson')

// 清除快取
dataService.clearCache('all')
```

---

## 📊 區域配置

### regions-index.json 結構
```json
{
  "regions": {
    "regionId": {
      "name": "中文名稱",
      "nameFr": "法文名稱",
      "basePath": "/geojson/路徑",
      "mapConfig": {
        "center": [經度, 緯度],
        "zoom": 縮放層級
      },
      "colorScheme": {
        "default": "預設顏色",
        "1er Cru": "一級園顏色"
      }
    }
  }
}
```

### 六大區域 ID

| ID | 中文名稱 | 法文名稱 | 中心座標 |
|----|----------|----------|----------|
| `chablis` | 夏布利與大歐塞瓦 | Chablis & Grand Auxerrois | [3.8, 47.8] |
| `cote-de-nuits` | 夜丘 | Côte de Nuits | [4.95, 47.15] |
| `cote-de-beaune` | 伯恩丘 | Côte de Beaune | [4.85, 47.0] |
| `cote-chalonnaise` | 夏隆內丘 | Côte Chalonnaise | [4.75, 46.80] |
| `maconnais` | 馬貢內 | Mâconnais | [4.80, 46.35] |
| `beaujolais` | 薄酒萊 | Beaujolais | [4.65, 46.15] |

---

## 🎨 配色方案

```javascript
const colorSchemes = {
  'chablis': {
    '紅酒': '#8B0000',
    '白酒': '#F0E68C',
  },
  'cote-de-nuits': {
    '紅酒': '#8B0000',
    '白酒': '#F5DEB3',
  },
  'cote-de-beaune': {
    '紅酒': '#CD5C5C',
    '白酒': '#F5DEB3',
  },
  'cote-chalonnaise': {
    '紅酒': '#BC8F8F',
    '白酒': '#F5DEB3',
  },
  'maconnais': {
    '紅酒': '#D2691E',
    '白酒': '#F5DEB3',
  },
  'beaujolais': {
    '紅酒': '#E0115F',
    '白酒': '#FFE4C4',
  }
}
```

---

## 🐛 常見問題速查

### 問題: 區域選擇器不顯示
```javascript
// 檢查 App.vue
showRegionSelector.value = true
currentRegion.value = null
```

### 問題: 地圖載入失敗
```javascript
// 檢查 Mapbox token
// 位置: src/components/MapSection.vue
mapboxgl.accessToken = 'YOUR_TOKEN'
```

### 問題: GeoJSON 載入 404
```bash
# 檢查檔案路徑
ls public/geojson/Chablis/

# 檢查 regions-index.json 中的 basePath
```

### 問題: 快取問題
```javascript
// 清除快取
import dataService from './dataService.js'
dataService.clearCache('all')

// 或重新整理頁面
location.reload()
```

---

## 📦 專案結構速查

```
src/
├── main.js                    # 入口
├── App.vue                    # 主應用 ✨
├── dataService.js             # 資料服務 ✨
├── style.css                  # 全域樣式
└── components/
    ├── RegionSelector.vue     # 區域選擇器 ✨
    ├── ChablisGrandAuxerroisMap.vue  # 地圖容器 ✨
    ├── MapSection.vue         # 地圖核心 ✨
    └── AOCList.vue            # AOC 列表

public/
├── geojson/
│   ├── regions-index.json    # 區域配置 ✨
│   ├── Chablis/              # 現有資料
│   ├── Cote-de-Nuits/        # 待整合
│   └── ...
└── data/
    ├── Chablis.json          # AOC 資訊
    └── regions/              # 待整合

✨ = 已更新/新建檔案
```

---

## 🔄 工作流程

### 新增區域的步驟
1. 複製 GeoJSON 到 `public/geojson/[RegionName]/`
2. 複製 data JSON 到 `public/data/regions/`
3. 確認 `regions-index.json` 已包含該區域配置
4. 測試

### 修改配色
1. 編輯 `src/components/ChablisGrandAuxerroisMap.vue`
2. 找到 `styleColors` computed
3. 更新對應區域的顏色

### 調整地圖視角
1. 編輯 `public/geojson/regions-index.json`
2. 修改對應區域的 `mapConfig.center` 和 `zoom`
3. 重新整理頁面

---

## 💻 開發技巧

### 快速測試特定區域
```vue
<!-- 在 App.vue 中暫時設定 -->
<script setup>
const currentRegion = ref({
  id: 'chablis',
  name: '夏布利與大歐塞瓦',
  center: [3.8, 47.8],
  zoom: 10
})
const showRegionSelector = ref(false)  // 跳過選擇器
</script>
```

### 查看快取狀態
```javascript
// 在瀏覽器 Console 執行
console.log(dataService)
```

### 效能監控
```javascript
// 在 dataService.js 中加入計時
console.time('Loading GeoJSON')
const data = await fetch(...)
console.timeEnd('Loading GeoJSON')
```

---

## 📱 響應式斷點

```css
/* 手機 */
@media (max-width: 768px) {
  .region-grid {
    grid-template-columns: 1fr;
  }
}

/* 平板 */
@media (min-width: 769px) and (max-width: 1024px) {
  .region-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

/* 桌面 */
@media (min-width: 1025px) {
  .region-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}
```

---

## 🚨 緊急修復

### 專案無法啟動
```powershell
# 重新安裝依賴
Remove-Item node_modules -Recurse -Force
npm install
npm run dev
```

### 地圖不顯示
```javascript
// 檢查 Mapbox GL CSS 是否載入
// src/components/MapSection.vue
import 'mapbox-gl/dist/mapbox-gl.css'
```

### 回到初始狀態
```powershell
# 恢復到只有 Chablis 的版本
git checkout HEAD -- src/
```

---

## 📞 聯絡與支援

- 📖 完整文件: [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)
- 🏗️ 架構圖: [ARCHITECTURE.md](ARCHITECTURE.md)
- 📋 專案摘要: [SUMMARY.md](SUMMARY.md)

---

**最後更新**: 2025-12-15  
**版本**: 1.0.0
