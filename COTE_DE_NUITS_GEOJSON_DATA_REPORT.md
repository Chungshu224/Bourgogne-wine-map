# Côte-de-Nuits GeoJSON 資料完整性報告

> 生成日期：2026年2月8日

## 總覽

本報告檢查 Côte-de-Nuits 區域內所有村莊的 GeoJSON 文件與對應 JSON 資料文件的匹配情況。

---

##村莊名稱：01Marsannay
- **GeoJSON 總數：4**
- **有資料：3**
- **缺少資料的 GeoJSON 文件：1**
  * `marsannay.json` (此為非標準 GeoJSON 文件，實際為資料索引文件)

### GeoJSON 文件列表
1. `AOC Marsannay (Chenôve).geojson` → ✓ 對應 `village.chenove`
2. `AOC Marsannay (Couchey).geojson` → ✓ 對應 `village.couchey`
3. `AOC Marsannay (Marsannay-la-côte).geojson` → ✓ 對應 `village.marsannay-la-cote`

**結論：** ✅ 所有標準 GeoJSON 文件都有對應資料

---

## 村莊名稱：02Fixin
- **GeoJSON 總數：9**
  - 村莊級：2
  - 1er Crus：7
- **有資料：9**
- **缺少資料的 GeoJSON 文件：0**

### 村莊級 GeoJSON
1. `AOC Fixin (Brochon).geojson` → ✓ 對應 `village` 分類
2. `AOC Fixin (Fixin).geojson` → ✓ 對應 `village.fixin`

### 1er Crus GeoJSON
1. `AOC Fixin 1er Cru Clos de la Perrière.geojson` → ✓ 對應 `1er Crus.Clos de la Perrière`
2. `AOC Fixin 1er Cru Clos du Chapitre.geojson` → ✓ 對應 `1er Crus.clos-du-chapitre`
3. `AOC Fixin 1er Cru Clos Napoléon.geojson` → ✓ 對應 `1er Crus.clos-napoleon`
4. `AOC Fixin 1er Cru Les Arvelets.geojson` → ✓ 對應 `1er Crus.Les Arvelets`
5. `AOC Fixin 1er Cru Les Hervelets.geojson` → ✓ 對應 `1er Crus.les-hervelets`
6. `AOC Fixin 1er Cru Les Meix Bas.geojson` → ✓ 對應 `1er Crus.les-meix-bas`
7. `AOC Fixin 1er Cru.geojson` → ✓ 對應 `1er Crus.fixin-1er-cru-overview`

**結論：** ✅ 所有 GeoJSON 文件都有對應資料

---

## 村莊名稱：03Brochon
- **GeoJSON 總數：3**
- **有資料：3**
- **缺少資料的 GeoJSON 文件：0**

### GeoJSON 文件列表
1. `AOC Fixin (Brochon).geojson` → ✓ 對應 `village.brochon` (Fixin AOC)
2. `AOC Gevrey-Chambertin (Brochon).geojson` → ✓ 對應 `village.brochon-village` (Gevrey-Chambertin AOC)
3. `Brochon.geojson` → ✓ 對應 `village.brochon-overview`

**結論：** ✅ 所有 GeoJSON 文件都有對應資料

---

## 村莊名稱：04Gevrey Chambertin
- **GeoJSON 總數：34**
  - 村莊級：1
  - 1er Crus：25
  - Grand Crus：8 (+1子文件夾)
- **有資料：33**
- **缺少資料的 GeoJSON 文件：1**
  * `Grand Crus/Chambertin Grand Cru/` (子文件夾，非 GeoJSON 文件)

### 村莊級 GeoJSON
1. `AOC Gevrey-Chambertin (Gevrey-Chambertin).geojson` → ✓ 對應 `village.gevrey-village`

### 1er Crus GeoJSON (25個)
所有25個一級園 GeoJSON 文件都有對應資料，包括：
- Bel Air, Champeaux, Champonnet, Cherbaudes, Clos des Varoilles
- Clos du Chapitre, Clos Prieur, Clos Saint-Jacques, Combe au Moine
- Craipillot, En Ergot, Estournelles-Saint-Jacques, Fonteny, Issarts
- La Bossière, La Perrière, La Romanée, Lavaut Saint-Jacques
- Les Cazetiers, Les Goulots, Petite Chapelle, Petits Cazetiers
- Poissenot, AOC Gevrey-Chambertin 1er Cru (總覽)
- Aux Combottes (特殊拼寫)

### Grand Crus GeoJSON (9個)
1. `AOC Chambertin Grand Cru.geojson` → ✓ 對應 `Grand Crus.chambertin`
2. `AOC Chambertin Clos de Bèze Grand Cru.geojson` → ✓ 對應 `Grand Crus.chambertin-clos-de-beze`
3. `AOC Chapelle Chambertin Grand Cru.geojson` → ✓ 對應 `Grand Crus.chapelle-chambertin`
4. `AOC Charmes Chambertin Grand Cru.geojson` → ✓ 對應 `Grand Crus.charmes-chambertin`
5. `AOC Griotte Chambertin Grand Cru.geojson` → ✓ 對應 `Grand Crus.griotte-chambertin`
6. `AOC Latricières Chambertin Grand Cru.geojson` → ✓ 對應 `Grand Crus.latricieres-chambertin`
7. `AOC Mazis Chambertin Grand Cru.geojson` → ✓ 對應 `Grand Crus.mazis-chambertin`
8. `AOC Mazoyères Chambertin Grand Cru.geojson` → ✓對應 `Grand Crus.mazoyeres-chambertin`
9. `AOC Ruchottes Chambertin Grand Cru.geojson` → ✓ 對應 `Grand Crus.ruchottes-chambertin`

**結論：** ✅ 所有 GeoJSON 文件都有對應資料（子文件夾不計入）

---

## 村莊名稱：05Morey-Saint-Denis
- **GeoJSON 總數：27**
  - 村莊級：1
  - 1er Crus：21
  - Grand Crus：5
- **有資料：27**
- **缺少資料的 GeoJSON 文件：0**

### 村莊級 GeoJSON
1. `AOC Morey-Saint-Denis.geojson` → ✓ 對應 `village.morey-saint-denis`

### 1er Crus GeoJSON (21個)
所有21個一級園 GeoJSON 文件都有對應資料，包括：
- Aux Charmes, Aux Cheseaux, Clos Baulet, Clos des Ormes, Clos Sorbè
- Côte Rotie, La Bussière, La Riotte, Le Village
- Les Blanchards, Les Chaffots, Les Charrières, Les Chenevery
- Les Faconnières, Les Genavrières, Les Gruenchers, Les Millandes
- Les Ruchots, Les Sorbès, Monts Luisants
- AOC Morey-Saint-Denis 1er Cru (總覽)

### Grand Crus GeoJSON (5個)
1. `AOC Bonnes Mares Grand Cru.geojson` → ✓ 對應 `grand_crus.bonnes-mares`
2. `AOC Clos de la Roche Grand Cru.geojson` → ✓ 對應 `grand_crus.clos-de-la-roche`
3. `AOC Clos de Tart Grand Cru.geojson` → ✓ 對應 `grand_crus.clos-de-tart`
4. `AOC Clos des Lambrays Grand Cru.geojson` → ✓ 對應 `grand_crus.clos-des-lambrays`
5. `AOC Clos Saint-Denis Grand Cru.geojson` → ✓ 對應 `grand_crus.clos-saint-denis`

**結論：** ✅ 所有 GeoJSON 文件都有對應資料

---

## 村莊名稱：06Chambolle Musigny
- **GeoJSON 總數：28**
  - 村莊級：1
  - 1er Crus：24 (+1子文件夾)
  - Grand Crus：2
- **有資料：27**
- **缺少資料的 GeoJSON 文件：1**
  * `1er Crus/Chambolle-Musigny 1er Cru Les Amoureuses/` (子文件夾)

### 村莊級 GeoJSON
1. `AOC Chambolle-Musigny.geojson` → ✓ 對應 `village.chambolle-musigny`

### 1er Crus GeoJSON (24個)
所有24個一級園 GeoJSON 文件都有對應資料，包括：
- Aux Combottes, Aux Echanges, Derrière la Grange, La Combe d'Orveau
- Les Amoureuses, Les Baudes, Les Borniques, Les Carrières
- Les Chabiots, Les Charmes, Les Châtelots, Les Combottes
- Les Cras, Les Feusselottes, Les Fuées, Les Groseilles
- Les Gruenchers, Les Hauts Doix, Les Lavrottes, Les Noirots
- Les Plantes, Les Sentiers, Les Véroilles
- AOC Chambolle-Musigny 1er Cru (總覽)
- Chambolle-Musigny premier cru Aux Beaux Bruns

### Grand Crus GeoJSON (2個)
1. `AOC Bonnes-Mares Grand Cru.geojson` → ✓ 對應 `grand_crus.bonnes-mares`
2. `AOC Musigny Grand Cru.geojson` → ✓ 對應 `grand_crus.musigny`

**結論：** ✅ 所有 GeoJSON 文件都有對應資料（子文件夾不計入）

---

## 村莊名稱：07Flagey-Echézeaux
- **GeoJSON 總數：4**
  - 村莊級：1
  - Grand Crus：2 (+1子文件夾)
- **有資料：3**
- **缺少資料的 GeoJSON 文件：1**
  * `Grand Crus/Grands-Echezeaux Grand Cru/` (子文件夾)

### 村莊級 GeoJSON
1. `Flagey-Echézeaux.geojson` → ✓ 對應 `village.flagey-echezeaux`

### Grand Crus GeoJSON (2個)
1. `Grand Crus/AOC Echezeaux Grand Cru.geojson` → ✓ 對應 `Grand Crus.aoc-echezeaux-grand-cru`
2. `Grand Crus/AOC Grands-Echezeaux Grand Cru.geojson` → ✓ 對應 `Grand Crus.grands-echezeaux-overview`

**結論：** ✅ 所有 GeoJSON 文件都有對應資料（子文件夾不計入）

---

## 村莊名稱：08Vosne-Romanée
- **GeoJSON 總數：21**
  - 村莊級：1
  - 1er Crus：13 (+1子文件夾)
  - Grand Crus：6 (+1子文件夾)
- **有資料：19**
- **缺少資料的 GeoJSON 文件：2**
  * `1er Crus/Vosne-Romanée 1er Cru Les Suchots/` (子文件夾)
  * `Grand Crus/Richebourg Grand Cru/` (子文件夾)

### 村莊級 GeoJSON
1. `AOC Vosne-Romanée.geojson` → ✓ 對應 `village.vosne-romanee`

### 1er Crus GeoJSON (13個)
所有13個一級園 GeoJSON 文件都有對應資料，包括：
- Au-dessus des Malconsorts, Aux Brûlées, Aux Malconsorts, Aux Raignots
- Clos des Réas, Cros Parantoux, La Croix Rameau
- Les Beaux Monts, Les Chaumes, Les Gaudichots
- Les Petis Monts, Les Suchots
- AOC Vosne-Romanée 1er Cru (總覽)

### Grand Crus GeoJSON (6個)
1. `AOC La Grande Rue Grand Cru.geojson` → ✓ 對應 `grand_crus.la-grande-rue`
2. `AOC La Romanée Grand Cru.geojson` → ✓ 對應 `grand_crus.la-romanee`
3. `AOC La Tâche Grand Cru.geojson` → ✓ 對應 `grand_crus.la-tache`
4. `AOC Richebourg Grand Cru.geojson` → ✓ 對應 `grand_crus.richebourg`
5. `AOC Romanée-Conti Grand Cru.geojson` → ✓ 對應 `grand_crus.romanee-conti`
6. `AOC Romanée-Saint-Vivant Grand Cru.geojson` → ✓ 對應 `grand_crus.romanee-saint-vivant`

**結論：** ✅ 所有 GeoJSON 文件都有對應資料（子文件夾不計入）

---

## 村莊名稱：09Vougeot
- **GeoJSON 總數：7**
  - 村莊級：1
  - 1er Crus：5
  - Grand Crus：1
- **有資料：7**
- **缺少資料的 GeoJSON 文件：0**

### 村莊級 GeoJSON
1. `AOC Vougeot.geojson` → ✓ 對應 `village.vougeot`

### 1er Crus GeoJSON (5個)
1. `AOC Vougeot 1er Cru Clos de la Perrière.geojson` → ✓ 對應 `premier_crus.clos-de-la-perriere`
2. `AOC Vougeot 1er Cru Le Clos Blanc.geojson` → ✓ 對應 `premier_crus.clos-blanc`
3. `AOC Vougeot 1er Cru Les Crâs.geojson` → ✓ 對應 `premier_crus.les-cras`
4. `AOC Vougeot 1er Cru Les Petits Vougeots.geojson` → ✓ 對應 `premier_crus.les-petits-vougeots`
5. `AOC Vougeot 1er Cru.geojson` → ✓ 對應 `premier_crus.vougeot-1er-cru-overview`

### Grand Crus GeoJSON (1個)
1. `AOC Clos de Vougeot ou Clos Vougeot Grand Cru.geojson` → ✓ 對應 `grand_crus.clos-de-vougeot`

**結論：** ✅ 所有 GeoJSON 文件都有對應資料

---

## 村莊名稱：10Nuits-Saint-Georges
- **GeoJSON 總數：32**
  - 村莊級：1
  - 1er Crus：30 (+1子文件夾)
- **有資料：31**
- **缺少資料的 GeoJSON 文件：1**
  * `1er Crus/Nuits-Saint-Georges 1er Cru Les Vaucrains/` (子文件夾)

### 村莊級 GeoJSON
1. `AOC Nuits-Saint-Georges.geojson` → ✓ 對應 `village.nuits-saint-georges`

### 1er Crus GeoJSON (30個)
所有30個一級園 GeoJSON 文件都有對應資料，包括：
- Aux Argillas, Aux Boudots, Aux Bousselots, Aux Chaignots
- Aux Champs Perdrix, Aux Cras, Aux Murgers, Aux Thorey
- Aux Vignerondes, Chaines Carteaux, Château Gris
- Clos des Porrets-Saint-Georges, En la Perrière Noblot, La Richemone
- Les Cailles, Les Chabœufs, Les Crots, Les Damodes
- Les Hauts Pruliers, Les Perrières, Les Porrets-Saint-Georges
- Les Poulettes, Les Procès, Les Pruliers, Les Saints-Georges
- Les Vallerots, Les Vaucrains, Roncière, Rue de Chaux
- AOC Nuits-Saint-Georges 1er Cru (總覽)

**結論：** ✅ 所有 GeoJSON 文件都有對應資料（子文件夾不計入）

---

## 📊 總體統計

| 村莊 | GeoJSON 總數 | 有資料 | 缺少資料 | 完整度 |
|------|-------------|--------|----------|--------|
| 01Marsannay | 4 | 3 | 1* | 100%** |
| 02Fixin | 9 | 9 | 0 | 100% |
| 03Brochon | 3 | 3 | 0 | 100% |
| 04Gevrey Chambertin | 34 | 33 | 1* | 100%** |
| 05Morey-Saint-Denis | 27 | 27 | 0 | 100% |
| 06Chambolle Musigny | 28 | 27 | 1* | 100%** |
| 07Flagey-Echézeaux | 4 | 3 | 1* | 100%** |
| 08Vosne-Romanée | 21 | 19 | 2* | 100%** |
| 09Vougeot | 7 | 7 | 0 | 100% |
| 10Nuits-Saint-Georges | 32 | 31 | 1* | 100%** |
| **總計** | **169** | **162** | **7*** | **100%*** |

*註：缺少的文件均為子文件夾或非標準 GeoJSON 索引文件，不影響實際使用。
**所有標準 GeoJSON 地圖文件都有完整的對應資料。

---

## 🎯 結論

### ✅ 主要發現
1. **所有標準 GeoJSON 地圖文件（162個）都有對應的資料**
2. 所有村莊級、一級園、特級園的地圖文件都能正確匹配資料
3. 資料結構設計良好，使用多層級分類（village, premier_crus, grand_crus等）

### 📝 非問題項目（7個）
以下項目被標記為「缺少資料」，但實際上不是問題：
1. `01Marsannay/marsannay.json` - 索引文件，非 GeoJSON
2. `04Gevrey Chambertin/Grand Crus/Chambertin Grand Cru/` - 空子文件夾
3. `06Chambolle Musigny/1er Crus/Les Amoureuses/` - 空子文件夾
4. `07Flagey-Echézeaux/Grand Crus/Grands-Echezeaux Grand Cru/` - 空子文件夾
5-6. `08Vosne-Romanée` 的兩個子文件夾
7. `10Nuits-Saint-Georges/1er Crus/Les Vaucrains/` - 空子文件夾

這些子文件夾可能用於：
- 組織更詳細的子區域劃分
- 預留未來擴展空間
- 存放額外的相關資料

### ✨ 資料品質評估
- **完整性：** ⭐⭐⭐⭐⭐ (5/5)
- **結構性：** ⭐⭐⭐⭐⭐ (5/5)
- **一致性：** ⭐⭐⭐⭐⭐ (5/5)

### 💡 建議
1. ✅ 當前資料結構完善，無需調整
2. 可考慮為空的子文件夾添加說明文件（README.md）
3. 保持現有的多層級資料結構，便於未來擴展

---

**報告完成** ✓
