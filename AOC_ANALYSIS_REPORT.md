# AOC JSON 檔案結構分析報告

## 修正類型說明
- **Type A**: 缺少頂層產區資訊
- **Type B**: 使用舊的鍵名稱（需要改為 premier_crus, grand_crus）
- **Type C**: 使用陣列格式（需要重構為對象格式）
- **Type D**: 格式正確，無需修正

## Beaujolais

| 檔案名稱 | 頂層資訊 | GeoJSON | 鍵名稱 | 陣列格式 | 修正類型 |
|---------|---------|---------|--------|---------|---------|
| Regional.json | ✓ | ✓ | - | 否 | Type D |

## Chablis

| 檔案名稱 | 頂層資訊 | GeoJSON | 鍵名稱 | 陣列格式 | 修正類型 |
|---------|---------|---------|--------|---------|---------|
| Chablis.json | ✗ | ✗ | - | 否 | Type A |
| Grand Auxerrois.json | ✗ | ✗ | - | 否 | Type A |

## Cote-Chalonnaise

| 檔案名稱 | 頂層資訊 | GeoJSON | 鍵名稱 | 陣列格式 | 修正類型 |
|---------|---------|---------|--------|---------|---------|
| 01Bouzeron.json | ✓ | ✓ | - | 否 | Type D |
| 02 Rully.json | ✓ | ✓ | - | 否 | Type D |
| 03Mercurey.json | ✓ | ✓ | - | 否 | Type D |
| 04Givry.json | ✓ | ✓ | - | 否 | Type D |
| 05Montagny.json | ✓ | ✓ | - | 否 | Type D |
| Regional.json | ✓ | ✓ | - | 否 | Type D |

## Cote-de-Beaune

| 檔案名稱 | 頂層資訊 | GeoJSON | 鍵名稱 | 陣列格式 | 修正類型 |
|---------|---------|---------|--------|---------|---------|
| 01Pernand-Vergelesses.json | ✓ | ✓ | - | 否 | Type D |
| 02Ladoix.json | ✓ | ✓ | - | 否 | Type D |
| 03Aloxe-Corton.json | ✓ | ✓ | - | 否 | Type D |
| 04Savigny-lès-Beaune.json | ✓ | ✓ | - | 否 | Type D |
| 05Chorey-lès-Beaune.json | ✓ | ✓ | - | 否 | Type D |
| 06Beaune.json | ✓ | ✓ | - | 否 | Type D |
| 07Pommard.json | ✓ | ✓ | - | 否 | Type D |
| 08Volnay.json | ✓ | ✓ | - | 否 | Type D |
| 09Monthélie.json | ✓ | ✓ | - | 否 | Type D |
| 10Saint-Romain.json | ✓ | ✓ | - | 否 | Type D |
| 11Auxey-Duresses.json | ✓ | ✓ | - | 否 | Type D |
| 12Meursault.json | ✓ | ✓ | - | 否 | Type D |
| 13Blagny.json | ✓ | ✓ | - | 否 | Type D |
| 14Puligny-Montrachet.json | ✓ | ✓ | - | 否 | Type D |
| 15Chassagne-Montrachet.json | ✓ | ✓ | - | 否 | Type D |
| 16Saint-Aubin.json | ✓ | ✓ | - | 否 | Type D |
| 17Santenay.json | ✓ | ✓ | - | 否 | Type D |
| 18Maranges.json | ✓ | ✓ | - | 否 | Type D |

## Cote-de-Nuits

| 檔案名稱 | 頂層資訊 | GeoJSON | 鍵名稱 | 陣列格式 | 修正類型 |
|---------|---------|---------|--------|---------|---------|
| 00Villages-introduction.json | ✗ | ✗ | - | 否 | Type A |
| 01Marsannay.json | ✓ | ✓ | - | 否 | Type D |
| 02Fixin.json | ✓ | ✓ | - | 否 | Type D |
| 03Brochon.json | ✓ | ✓ | - | 否 | Type D |
| 04Gevrey Chambertin.json | ✗ | ✗ | 1er Crus, premier_crus, Grand Crus | 否 | Type A, Type B |
| 05Morey-Saint-Denis.json | ✗ | ✗ | premier_crus, grand_crus | 否 | Type A |
| 06Chambolle Musigny.json | ✗ | ✗ | premier_crus, grand_crus | 否 | Type A |
| 07Flagey-Echézeaux.json | ✗ | ✗ | Grand Crus | 否 | Type A, Type B |
| 08Vosne-Romanée.json | ✗ | ✗ | premier_crus, grand_crus | 否 | Type A |
| 09Vougeot.json | ✗ | ✗ | premier_crus, grand_crus | 否 | Type A |
| 10Nuits-Saint-Georges.json | ✗ | ✗ | premier_crus | 否 | Type A |

## Maconnais

| 檔案名稱 | 頂層資訊 | GeoJSON | 鍵名稱 | 陣列格式 | 修正類型 |
|---------|---------|---------|--------|---------|---------|
| Regional.json | ✓ | ✓ | - | 否 | Type D |

## Root

| 檔案名稱 | 頂層資訊 | GeoJSON | 鍵名稱 | 陣列格式 | 修正類型 |
|---------|---------|---------|--------|---------|---------|
| AOC Bourgogne.json | ✗ | ✗ | - | 否 | Type A |

## 統計摘要

| 項目 | 數量 |
|------|------|
| 總檔案數 | 40 |
| 需要 Type A 修正 | 11 |
| 需要 Type B 修正 | 2 |
| 需要 Type C 修正 | 0 |
| Type D (無需修正) | 29 |

