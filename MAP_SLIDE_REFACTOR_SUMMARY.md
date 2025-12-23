# MapSlide 重構完成

## 已完成的改進

### 1. 創建獨立的地圖管理器
- **檔案**: [MapSlideManager.js](src/components/course/slides/MapSlideManager.js)
- 每個地圖幻燈片都有自己的管理器實例
- 獨立的狀態管理（圖層、標記、活動產區）
- 完整的生命週期管理（初始化、更新、銷毀）

### 2. 重構 MapSlide.vue
- **檔案**: [MapSlide.vue](src/components/course/slides/MapSlide.vue)
- 使用新的 MapSlideManager 類
- 簡化的組件邏輯
- 新增內容覆蓋層支持
- 改進的產區按鈕系統

### 3. 提供完整文檔
- **配置指南**: [MAP_SLIDE_CONFIG_GUIDE.md](MAP_SLIDE_CONFIG_GUIDE.md)
- **範例配置**: [map-example.json](public/data/courses/map-example.json)

## 主要功能

### 獨立地圖實例
每個地圖幻燈片現在完全獨立：
- ✅ 獨立的地圖配置（中心、縮放、傾斜、旋轉）
- ✅ 獨立的圖層管理
- ✅ 獨立的標記和互動
- ✅ 獨立的狀態追蹤

### 靈活的配置選項
```json
{
  "type": "map",
  "title": "地圖標題",
  "content": "HTML 內容說明",
  "mapConfig": {
    "center": [經度, 緯度],
    "zoom": 8,
    "pitch": 0,
    "bearing": 0
  },
  "geojsonFiles": [
    {
      "id": "layer-id",
      "url": "/path/to/geojson",
      "isBase": true,           // 基礎圖層會自動載入
      "displayName": "顯示名稱", // 按鈕上的文字
      "fillColor": "#色碼",
      "fillOpacity": 0.5,
      "lineColor": "#色碼",
      "lineWidth": 2,
      "showLabels": true
    }
  ],
  "bounds": [[西南], [東北]],
  "markers": [...]
}
```

### MapSlideManager API
提供豐富的控制方法：
- `initialize()` - 初始化地圖
- `focusRegion(region)` - 聚焦到產區
- `flyTo(options)` - 飛到指定位置
- `fitBounds(bounds)` - 設置視圖範圍
- `toggleLayer(id, visible)` - 切換圖層
- `updateLayerStyle(id, style)` - 更新樣式
- `reset()` - 重置到初始狀態
- `destroy()` - 銷毀實例

## 使用方式

### 1. 在簡報中添加地圖幻燈片
只需在 JSON 配置文件中添加 `type: "map"` 的幻燈片：

```json
{
  "type": "map",
  "title": "探索布根地",
  "mapConfig": { ... },
  "geojsonFiles": [ ... ]
}
```

### 2. 配置產區按鈕
任何沒有 `isBase: true` 的圖層都會自動生成互動按鈕：

```json
{
  "id": "chablis",
  "displayName": "夏布利",  // 按鈕顯示文字
  "url": "/geojson/Chablis/AOC Chablis.geojson",
  "fillColor": "#F0E68C",
  ...
}
```

### 3. 添加內容說明
使用 `content` 屬性添加 HTML 說明文字：

```json
{
  "type": "map",
  "title": "布根地概覽",
  "content": "<p><strong>布根地</strong>位於法國東部。</p><p>包含六大產區。</p>",
  ...
}
```

## 範例檔案

參考 [map-example.json](public/data/courses/map-example.json) 查看三種不同的地圖配置：
1. 簡單地圖 - 基礎展示
2. 互動式產區地圖 - 多產區切換
3. 3D 傾斜視角 - 立體效果

## 優勢

### ✅ 完全獨立
每個地圖都有自己的實例，互不干擾

### ✅ 易於擴展
新增地圖只需添加 JSON 配置，無需修改代碼

### ✅ 靈活配置
支持豐富的配置選項滿足不同需求

### ✅ 良好的性能
按需載入圖層，不浪費資源

### ✅ 可維護性
代碼結構清晰，易於理解和修改

## 下一步

如果需要添加更多功能，可以在 MapSlideManager.js 中擴展方法，例如：
- 添加動畫效果
- 支持圖層過濾
- 添加點擊事件處理
- 支持自定義控制項
- 添加測量工具
- 等等...

所有這些功能都可以在不影響現有地圖的情況下添加。
