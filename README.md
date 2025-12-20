# Bourgogne wine map
這是一個互動式 Bourgogne wine map（布根地葡萄酒產區）教學地圖，使用 Vue 3 + Vite + Mapbox GL JS 開發，提供各 AOC 產區的地理位置及詳細資訊展示。

## 功能特色
- **互動式地圖**：顯示 Bourgogne 各 AOC 產區的精確地理邊界
- **產區分類**：依村莊級、特級園等類別進行分組
- **詳細資訊**：包含產區介紹、葡萄品種、酒類型等資料
- **3D 視角**：支援 2D/3D 視圖切換，更直觀感受地形特色
- **搜尋功能**：快速尋找特定產區
- **響應式設計**：支援桌面與行動裝置瀏覽

## 技術架構
- **前端框架**：Vue 3 (使用 Composition API)
- **建置工具**：Vite
- **地圖引擎**：Mapbox GL JS
- **地理資料**：GeoJSON 格式
- **資料處理**：@turf/turf

## 圖片命名規範（新增圖片請參考）

1. 命名規則（兩種方式皆可）
	- 編號命名（推薦，用於快速對應）：
	  - 檔名使用兩位數字（`01.jpg`, `02.png` 等）放在對應的酒莊資料夾下。
	  - 範例：`public/images/Gevrey Chambertin/Chambertin Grand Cru/01.jpg`
	- 完整檔名（用於特定酒莊專用圖片）：
	  - 使用與 geojson 檔名對應的完整名稱（保留空白和特殊字元），但副檔名只接受 `jpg` 或 `png`。
	  - 範例：`public/images/Gevrey Chambertin/Chambertin Grand Cru/Chambertin 01 Domaine Armand Rousseau.jpg`

2. 匹配邏輯（應用程式端）
	- 預設會先嘗試以「編號」對應（若檔名中有 1-2 位數字），依序嘗試 `jpg` → `png`。
	- 若編號對應不存在，會再嘗試完整檔名（`<完整檔名>.jpg` → `.png`）。
	- 程式會同時支援兩種路徑：`/images/...` 與不含 `/images/` 的基底，增加資料夾結構彈性。

3. 放置位置建議
	- 建議將圖片放在 `public/images/<村莊或AOC資料夾>/<climat 資料夾>/` 之下。例如：
	  - `public/images/Gevrey Chambertin/Chambertin Grand Cru/01.jpg`
	  - 或 `public/images/chambolle musigny/Chambolle-Musigny 1er Cru Les Amoureuses/01.jpg`

4. 注意
	- 僅支援 `jpg` 或 `png`。
	- 若圖片無法載入，系統會依序嘗試下一個候選圖片。

如果你要我把這段加入專案的其他文件或進一步自動化（如在開發時掃描圖片並生成 index），我可以幫你做。
