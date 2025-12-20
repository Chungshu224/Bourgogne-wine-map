# 布根地產區整合專案 - 實作指南

## ✅ 已完成的工作

### 1. 建立區域選擇器組件 ✓
- 檔案: `src/components/RegionSelector.vue`
- 功能: 美觀的六大區域選擇介面
- 包含麵包屑導航

### 2. 建立多區域索引配置 ✓
- 檔案: `public/geojson/regions-index.json`
- 包含所有六個區域的配置（地圖中心點、縮放層級、配色方案）

### 3. 更新主應用程式 ✓
- 檔案: `src/App.vue`
- 實作區域切換邏輯
- 添加返回按鈕

### 4. 更新地圖組件 ✓
- 檔案: `src/components/ChablisGrandAuxerroisMap.vue`
- 支援 regionConfig props
- 動態配色方案

### 5. 更新 MapSection ✓
- 檔案: `src/components/MapSection.vue`
- 支援動態區域視角
- 動態標題顯示

### 6. 擴展數據服務 ✓
- 檔案: `src/dataService.js`
- 多區域數據載入
- 快取機制

## 📋 下一步驟：整合其他區域數據

### 步驟 1: 複製 GeoJSON 檔案

在 `public/geojson/` 目錄下建立以下資料夾結構：

```
public/geojson/
├── regions-index.json (已建立)
├── index.json (原 Chablis 索引，保留)
├── Chablis/ (目前的檔案，需要整理)
├── Cote-de-Nuits/ (新建)
│   ├── index.json
│   ├── 01Marsannay/
│   ├── 02Fixin/
│   ├── 04Gevrey Chambertin/
│   └── ...
├── Cote-de-Beaune/ (新建)
│   ├── index.json
│   └── ...
├── Cote-Chalonnaise/ (新建)
│   ├── index.json
│   └── ...
├── Maconnais/ (新建)
│   ├── index.json
│   └── ...
└── Beaujolais/ (新建)
    ├── index.json
    └── ...
```

### 步驟 2: 執行檔案複製命令

#### 複製 Côte de Nuits
```powershell
# 建立資料夾
New-Item -ItemType Directory -Path "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\Cote-de-Nuits" -Force

# 複製所有檔案
Copy-Item "C:\Users\Chungshu\Desktop\Bourgogne\Cote de Nuits-map\public\geojson\*" `
  -Destination "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\Cote-de-Nuits\" `
  -Recurse -Force
```

#### 複製 Côte de Beaune
```powershell
New-Item -ItemType Directory -Path "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\Cote-de-Beaune" -Force

Copy-Item "C:\Users\Chungshu\Desktop\Bourgogne\00Cote de Beaune-map\public\geojson\*" `
  -Destination "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\Cote-de-Beaune\" `
  -Recurse -Force
```

#### 複製 Côte Chalonnaise
```powershell
New-Item -ItemType Directory -Path "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\Cote-Chalonnaise" -Force

Copy-Item "C:\Users\Chungshu\Desktop\Bourgogne\Côte Chalonnaise-map\public\geojson\*" `
  -Destination "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\Cote-Chalonnaise\" `
  -Recurse -Force
```

#### 複製 Mâconnais
```powershell
New-Item -ItemType Directory -Path "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\Maconnais" -Force

Copy-Item "C:\Users\Chungshu\Desktop\Bourgogne\Maconnais-map\public\geojson\*" `
  -Destination "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\Maconnais\" `
  -Recurse -Force
```

#### 複製 Beaujolais
```powershell
New-Item -ItemType Directory -Path "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\Beaujolais" -Force

Copy-Item "C:\Users\Chungshu\Desktop\Bourgogne\06beaujolais-map\public\geojson\*" `
  -Destination "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\Beaujolais\" `
  -Recurse -Force
```

### 步驟 3: 整理 Chablis 資料夾

```powershell
# 建立 Chablis 子資料夾
New-Item -ItemType Directory -Path "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\Chablis-Region" -Force

# 移動現有檔案（保持原有結構）
Move-Item "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\Chablis" `
  -Destination "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\Chablis-Region\Chablis"

Move-Item "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\AOC Bourgogne" `
  -Destination "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\Chablis-Region\AOC Bourgogne"

Move-Item "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\Grand Auxerrois" `
  -Destination "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\geojson\Chablis-Region\Grand Auxerrois"
```

### 步驟 4: 複製 data 資料夾

```powershell
# 建立區域 data 資料夾
New-Item -ItemType Directory -Path "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\data\regions" -Force

# 複製各區域的 JSON 資料
Copy-Item "C:\Users\Chungshu\Desktop\Bourgogne\Cote de Nuits-map\public\data\*.json" `
  -Destination "C:\Users\Chungshu\Desktop\Bourgogne\Chablisienne-map\public\data\regions\" -Force
```

### 步驟 5: 建立多區域地圖組件

為其他區域建立對應的地圖組件（可以複製 ChablisGrandAuxerroisMap.vue 並調整）：

```vue
<!-- src/components/CoteDeNuitsMap.vue -->
<script setup>
import { ref } from 'vue'
import AOCList from './AOCList.vue'
import MapSection from './MapSection.vue'

const props = defineProps({
  regionConfig: Object
})

// ... 其他邏輯與 ChablisGrandAuxerroisMap.vue 類似
</script>
```

### 步驟 6: 更新 App.vue 以支援所有區域

在 `src/App.vue` 的 template 中加入其他區域的組件：

```vue
<CoteDeNuitsMap 
  v-if="currentRegion?.id === 'cote-de-nuits'"
  :region-config="currentRegion"
/>

<CoteDeBeauneMap 
  v-if="currentRegion?.id === 'cote-de-beaune'"
  :region-config="currentRegion"
/>

<!-- 其他區域... -->
```

## ⚠️ 可能遇到的問題與解決方案

### 問題 1: 檔案路徑不一致
**解決**: 檢查 `regions-index.json` 中的 `basePath` 是否正確

### 問題 2: GeoJSON 載入失敗
**解決**: 
- 確認檔案名稱沒有特殊字元
- 檢查 `index.json` 結構是否正確
- 使用瀏覽器開發者工具查看網路請求

### 問題 3: 地圖視角不正確
**解決**: 調整 `regions-index.json` 中各區域的 `center` 和 `zoom` 值

### 問題 4: 效能問題
**解決**: 
- 確保快取機制正常運作
- 考慮實作虛擬滾動
- 延遲載入非必要資料

## 🧪 測試檢查清單

- [ ] 區域選擇器正常顯示
- [ ] 可以切換到 Chablis 區域並顯示地圖
- [ ] 返回按鈕正常運作
- [ ] 複製其他區域檔案後可以正常顯示
- [ ] 地圖中心點和縮放正確
- [ ] 配色方案符合預期
- [ ] 快取機制運作正常
- [ ] 行動裝置響應式設計正常

## 🎯 優化建議（後續）

1. **效能優化**
   - 實作 Service Worker 快取
   - 使用 Mapbox Vector Tiles
   - 圖片延遲載入

2. **功能增強**
   - 全文搜尋功能（跨區域）
   - 比較模式（同時顯示多個區域）
   - 收藏功能
   - 分享連結

3. **使用者體驗**
   - 加入載入動畫
   - 錯誤處理提示
   - 離線模式支援
   - 多語言支援

## 📝 更新專案名稱

別忘了更新 `package.json`:

```json
{
  "name": "bourgogne-complete-map",
  "description": "布根地完整產區互動地圖"
}
```

## 🚀 部署

準備部署時：

1. 執行 `npm run build`
2. 測試 `dist/` 資料夾
3. 上傳到 GitHub Pages 或其他託管服務

---

**建立日期**: 2025-12-15
**版本**: 1.0.0
**狀態**: 基礎框架完成，等待數據整合
