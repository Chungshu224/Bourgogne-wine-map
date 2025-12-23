# MapSlide 配置指南

## 概述

MapSlide 組件現在使用獨立的 `MapSlideManager` 來管理每個地圖實例。每個地圖幻燈片都可以有自己的配置、顯示效果和互動邏輯。

## 基本配置結構

```json
{
  "type": "map",
  "title": "地圖標題",
  "content": "<p>可選的HTML內容說明</p>",
  "mapConfig": {
    "center": [經度, 緯度],
    "zoom": 8,
    "pitch": 0,
    "bearing": 0
  },
  "geojsonFiles": [...],
  "bounds": [[西南經度, 西南緯度], [東北經度, 東北緯度]],
  "markers": [...]
}
```

## 配置選項詳解

### 1. 基本屬性

- **type**: `"map"` - 必填，指定為地圖類型幻燈片
- **title**: 地圖標題，顯示在頂部
- **content**: 可選的 HTML 內容，顯示在左側覆蓋層

### 2. mapConfig（地圖配置）

控制地圖的初始視圖：

```json
"mapConfig": {
  "center": [4.5, 47.0],      // 中心點經緯度
  "zoom": 8.5,                 // 縮放級別 (0-22)
  "pitch": 0,                  // 傾斜角度 (0-60)
  "bearing": 0                 // 旋轉角度 (0-360)
}
```

### 3. geojsonFiles（圖層配置）

定義要載入的 GeoJSON 圖層：

```json
"geojsonFiles": [
  {
    "id": "bourgogne-map",           // 圖層ID
    "url": "/geojson/AOC Bourgogne map.geojson",
    "isBase": true,                  // 標記為基礎圖層（自動載入）
    "fillColor": "#8B4789",          // 填充顏色
    "fillOpacity": 0.3,              // 填充透明度
    "lineColor": "#5C2E5C",          // 邊框顏色
    "lineWidth": 2,                  // 邊框寬度
    "showLabels": true               // 是否顯示標籤
  },
  {
    "id": "cote-de-nuits",
    "url": "/geojson/Cote-de-Nuits/...",
    "displayName": "夜丘",           // 按鈕顯示名稱
    "fillColor": "#DC143C",
    "fillOpacity": 0.5,
    "lineColor": "#B22222",
    "lineWidth": 2
  }
]
```

**重要屬性：**
- `isBase: true` - 該圖層會在地圖載入時自動顯示
- `id === 'bourgogne-map'` - 也會被視為基礎圖層
- 沒有 `isBase` 的圖層需要透過按鈕點擊才會載入

### 4. bounds（視圖範圍）

設定地圖的初始邊界：

```json
"bounds": [
  [3.8, 45.8],   // 西南角 [經度, 緯度]
  [5.2, 48.0]    // 東北角 [經度, 緯度]
]
```

### 5. markers（標記點）

添加城市或地點標記：

```json
"markers": [
  {
    "name": "Dijon",
    "coordinates": [5.0415, 47.3220]
  },
  {
    "name": "Beaune",
    "coordinates": [4.8378, 47.0247]
  }
]
```

## 實際範例

### 範例 1: 布根地整體概覽

```json
{
  "type": "map",
  "title": "布根地葡萄酒產區概覽",
  "content": "<p>布根地位於法國東部，南北延伸約 230 公里。</p><p><strong>六大產區</strong>各有獨特風格。</p>",
  "mapConfig": {
    "center": [2.5, 46.5],
    "zoom": 6,
    "pitch": 0,
    "bearing": 0
  },
  "geojsonFiles": [
    {
      "id": "bourgogne-map",
      "url": "/geojson/AOC Bourgogne map.geojson",
      "isBase": true,
      "fillColor": "#8B4789",
      "fillOpacity": 0.3,
      "lineColor": "#5C2E5C",
      "lineWidth": 2,
      "showLabels": true
    }
  ],
  "bounds": [[3.5, 46.8], [5.5, 48.0]],
  "markers": [
    {
      "name": "Dijon",
      "coordinates": [5.0415, 47.3220]
    },
    {
      "name": "Beaune",
      "coordinates": [4.8378, 47.0247]
    }
  ]
}
```

### 範例 2: 六大產區互動地圖

```json
{
  "type": "map",
  "title": "探索布根地六大產區",
  "content": "<p>點擊下方按鈕，探索各個產區的獨特魅力。</p>",
  "mapConfig": {
    "center": [4.5, 47.0],
    "zoom": 8.5,
    "pitch": 0,
    "bearing": 0
  },
  "geojsonFiles": [
    {
      "id": "bourgogne-map",
      "url": "/geojson/AOC Bourgogne map.geojson",
      "isBase": true,
      "fillColor": "#8B4789",
      "fillOpacity": 0.25,
      "lineColor": "#5C2E5C",
      "lineWidth": 1.5,
      "showLabels": false
    },
    {
      "id": "chablis",
      "url": "/geojson/Chablis/AOC Chablis.geojson",
      "displayName": "夏布利與大歐塞瓦",
      "fillColor": "#F0E68C",
      "fillOpacity": 0.6,
      "lineColor": "#DAA520",
      "lineWidth": 2,
      "showLabels": true
    },
    {
      "id": "cote-de-nuits",
      "url": "/geojson/Cote-de-Nuits/AOC Côte de Nuits-Villages.geojson",
      "displayName": "夜丘",
      "fillColor": "#DC143C",
      "fillOpacity": 0.5,
      "lineColor": "#B22222",
      "lineWidth": 2,
      "showLabels": true
    },
    {
      "id": "cote-de-beaune",
      "url": "/geojson/Cote-de-Beaune/AOC Côte de Beaune.geojson",
      "displayName": "伯恩丘",
      "fillColor": "#FF6B6B",
      "fillOpacity": 0.5,
      "lineColor": "#FF4500",
      "lineWidth": 2,
      "showLabels": true
    },
    {
      "id": "cote-chalonnaise",
      "url": "/geojson/Cote-Chalonnaise/AOC Bourgogne Côte Chalonnaise.geojson",
      "displayName": "夏隆丘",
      "fillColor": "#FF6B6B",
      "fillOpacity": 0.5,
      "lineColor": "#FF4500",
      "lineWidth": 2,
      "showLabels": true
    },
    {
      "id": "maconnais",
      "url": "/geojson/Maconnais/AOC Mâcon.geojson",
      "displayName": "馬貢內",
      "fillColor": "#98D8C8",
      "fillOpacity": 0.5,
      "lineColor": "#45B7AF",
      "lineWidth": 2,
      "showLabels": true
    },
    {
      "id": "beaujolais",
      "url": "/geojson/Beaujolais/AOC Beaujolais Villages.geojson",
      "displayName": "薄酒萊",
      "fillColor": "#DC143C",
      "fillOpacity": 0.5,
      "lineColor": "#B22222",
      "lineWidth": 2,
      "showLabels": true
    }
  ],
  "bounds": [[3.8, 45.8], [5.2, 48.0]]
}
```

### 範例 3: 特定產區深入探索

```json
{
  "type": "map",
  "title": "夜丘產區村莊分布",
  "content": "<p><strong>夜丘</strong>是布根地最負盛名的產區。</p><p>包含眾多世界頂級特級園。</p>",
  "mapConfig": {
    "center": [4.95, 47.15],
    "zoom": 11,
    "pitch": 30,
    "bearing": 0
  },
  "geojsonFiles": [
    {
      "id": "cote-de-nuits-base",
      "url": "/geojson/Cote-de-Nuits/AOC Côte de Nuits-Villages.geojson",
      "isBase": true,
      "fillColor": "#DC143C",
      "fillOpacity": 0.3,
      "lineColor": "#B22222",
      "lineWidth": 2,
      "showLabels": false
    },
    {
      "id": "gevrey-chambertin",
      "url": "/geojson/Cote-de-Nuits/AOC Gevrey-Chambertin.geojson",
      "displayName": "Gevrey-Chambertin",
      "fillColor": "#8B0000",
      "fillOpacity": 0.6,
      "lineColor": "#4A0000",
      "lineWidth": 2.5,
      "showLabels": true
    },
    {
      "id": "vosne-romanee",
      "url": "/geojson/Cote-de-Nuits/AOC Vosne-Romanée.geojson",
      "displayName": "Vosne-Romanée",
      "fillColor": "#800020",
      "fillOpacity": 0.6,
      "lineColor": "#4A0012",
      "lineWidth": 2.5,
      "showLabels": true
    }
  ],
  "bounds": [[4.85, 47.05], [5.05, 47.25]],
  "markers": [
    {
      "name": "Gevrey-Chambertin",
      "coordinates": [4.9647, 47.2270]
    },
    {
      "name": "Vosne-Romanée",
      "coordinates": [4.9598, 47.1612]
    }
  ]
}
```

## MapSlideManager API

如果需要更進階的控制，可以直接使用 MapSlideManager 的方法：

### 主要方法

```javascript
// 初始化地圖
await mapManager.initialize()

// 聚焦到指定產區
await mapManager.focusRegion(region)

// 飛到指定位置
mapManager.flyTo({
  center: [4.5, 47.0],
  zoom: 10,
  pitch: 30,
  bearing: 45,
  duration: 2000
})

// 設置視圖範圍
mapManager.fitBounds([[3.8, 45.8], [5.2, 48.0]], {
  padding: 80,
  duration: 1500
})

// 切換圖層可見性
mapManager.toggleLayer('layerId', true/false)

// 更新圖層樣式
mapManager.updateLayerStyle('layerId', {
  fillColor: '#FF0000',
  fillOpacity: 0.5
})

// 獲取當前狀態
const activeRegion = mapManager.getActiveRegion()
const loadedLayers = mapManager.getLoadedLayers()

// 重置到初始狀態
mapManager.reset()

// 銷毀地圖
mapManager.destroy()
```

## 最佳實踐

1. **基礎圖層**：總是設置一個底圖作為基礎（使用 `isBase: true`）
2. **顏色選擇**：使用對比色來區分不同產區
3. **透明度**：基礎圖層使用較低透明度（0.2-0.3），互動圖層使用較高透明度（0.5-0.6）
4. **邊界設定**：合理設置 bounds 確保重要區域都在視野內
5. **內容說明**：使用 content 屬性提供簡潔的說明文字
6. **按鈕命名**：使用清晰的 displayName 讓用戶理解產區名稱

## 創建新的地圖幻燈片

1. 在簡報 JSON 文件中添加新的 map 類型幻燈片
2. 配置 mapConfig、geojsonFiles、bounds 和 markers
3. 每個地圖會自動擁有獨立的實例和狀態
4. 無需修改組件代碼，只需調整 JSON 配置
