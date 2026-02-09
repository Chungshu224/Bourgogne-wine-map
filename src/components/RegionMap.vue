<script setup>
import { ref, computed, watch } from 'vue'
import AOCList from './AOCList.vue'
import MapSection from './MapSection.vue'

// 接收區域配置
const props = defineProps({
  regionConfig: {
    type: Object,
    required: true
  }
})

const search = ref('')
const activeAOC = ref({ group: '', aoc: '' })
const regionInfo = ref(null)
const dataCache = new Map()

// 根據區域動態調整顏色配置
const styleColors = computed(() => {
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
  
  return colorSchemes[props.regionConfig?.id] || colorSchemes['chablis']
})

// 根據區域 ID 獲取 index.json 路徑
const indexPath = computed(() => {
  const pathMap = {
    'chablis': '/geojson/index.json',
    'cote-de-nuits': '/geojson/Cote-de-Nuits/index.json',
    'cote-de-beaune': '/geojson/Cote-de-Beaune/index.json',
    'cote-chalonnaise': '/geojson/Cote-Chalonnaise/index.json',
    'maconnais': '/geojson/Maconnais/index.json',
    'beaujolais': '/geojson/Beaujolais/index.json'
  }
  
  return pathMap[props.regionConfig?.id] || '/geojson/index.json'
})

// 根據區域 ID 獲取數據路徑前綴
const dataPathPrefix = computed(() => {
  const prefixMap = {
    'chablis': 'Chablis/',
    'cote-de-nuits': 'Cote-de-Nuits/',
    'cote-de-beaune': 'Cote-de-Beaune/',
    'cote-chalonnaise': 'Cote-Chalonnaise/',
    'maconnais': 'Maconnais/',
    'beaujolais': 'Beaujolais/'
  }
  
  return prefixMap[props.regionConfig?.id] || ''
})

const showAOCGeojson = async (group, aoc) => {
  activeAOC.value = { group, aoc };

  // 根據區域動態構建數據路徑
  const mainFolder = group.split('/')[0];
  let dataPath = ''
  
  // 所有區域統一使用資料夾結構
  if (group === 'Regional' || group === 'Beaujolais' || group === 'Beaujolais Crus') {
    // Regional 分組使用 Regional.json (包括 Beaujolais 和 Beaujolais Crus)
    dataPath = `/data/${dataPathPrefix.value}Regional.json`;
  } else if (group === 'AOC Bourgogne') {
    // AOC Bourgogne 使用根目錄的 AOC Bourgogne.json
    dataPath = `/data/AOC Bourgogne.json`;
  } else if (props.regionConfig?.id === 'chablis') {
    // Chablis 使用 mainFolder.json (如 Chablis.json, Grand Auxerrois.json)
    dataPath = `/data/${dataPathPrefix.value}${mainFolder}.json`;
  } else {
    // 其他區域使用村莊編號和名稱匹配（如 01Marsannay, 04Gevrey Chambertin 等）
    // 使用 mainFolder 保留原始空格，因為實際文件名包含空格
    dataPath = `/data/${dataPathPrefix.value}${mainFolder}.json`;
  }

  console.log('[RegionMap] Loading data:', { group, aoc, dataPath });

  try {
    let aocData;
    if (dataCache.has(dataPath)) {
      aocData = dataCache.get(dataPath);
      console.log('[RegionMap] Data loaded from cache:', dataPath);
    } else {
      const res = await fetch(dataPath);
      if (!res.ok) {
        console.error(`[RegionMap] Failed to load data file: ${dataPath} (Status: ${res.status})`);
        regionInfo.value = null;
        return;
      }
      aocData = await res.json();
      dataCache.set(dataPath, aocData);
      console.log('[RegionMap] Data loaded successfully:', dataPath);
    }

    // 處理不同的 JSON 結構
    if (Array.isArray(aocData)) {
      // Chablis 格式: 陣列 [{id, name, ...}]
      const foundInfo = aocData.find(info => info.id === aoc);
      regionInfo.value = foundInfo || null;
    } else if (aocData.geojson?.regional) {
      // Regional.json 格式: {geojson: {regional: {key: {...}}}}
      const aocKey = aoc.replace('.geojson', '').toLowerCase().replace(/\s+/g, '-').replace(/[àâä]/g, 'a').replace(/[éèêë]/g, 'e').replace(/[ôö]/g, 'o').replace(/ç/g, 'c');
      const foundInfo = aocData.geojson.regional[aocKey];
      if (foundInfo) {
        regionInfo.value = { ...foundInfo, name: foundInfo.fullName || foundInfo.name };
      } else {
        console.warn(`No info found for key: "${aocKey}" in Regional.json`);
        regionInfo.value = null;
      }
    } else if (aocData.village || aocData['1er Crus'] || aocData.premier_crus || aocData['Grand Crus'] || aocData.grand_crus || 
               aocData.geojson?.village || aocData.geojson?.['1er Crus'] || aocData.geojson?.premier_crus || aocData.geojson?.['Grand Crus'] || aocData.geojson?.grand_crus) {
      // Côte de Nuits/Beaune 格式: {village: {...}, "1er Crus": {...}, "Grand Crus": {...}}
      // 或 {village: {...}, premier_crus: {...}, grand_crus: {...}}
      // 或 {geojson: {village: {...}, premier_crus: {...}, grand_crus: {...}}}
      
      // 如果資料在 geojson 屬性內，先提取出來
      const dataSource = aocData.geojson || aocData;
      // 從 AOC 檔名分析等級和名稱
      let searchKey = aoc.replace('.geojson', '');
      let targetCategory = null;
      
      // 判斷是否為 Grand Cru
      if (searchKey.includes('Grand Cru')) {
        targetCategory = dataSource['Grand Crus'] || dataSource.grand_crus;
        // 提取 Grand Cru 名稱，例如 "AOC Chambertin Grand Cru" -> "chambertin"
        searchKey = searchKey.replace(/AOC\s+/i, '').replace(/\s+Grand Cru.*$/i, '').trim();
      }
      // 判斷是否為 1er Cru / Premier Cru
      else if (searchKey.match(/1er\s+Cru|Premier\s+Cru/i)) {
        targetCategory = dataSource['1er Crus'] || dataSource.premier_crus;
        // 提取 1er Cru 名稱，例如 "AOC Fixin 1er Cru Clos du Chapitre" -> "Clos du Chapitre"
        searchKey = searchKey.replace(/AOC\s+/i, '').replace(/.*?1er\s+Cru\s+/i, '').replace(/.*?Premier\s+Cru\s+/i, '').trim();
      }
      // 否則為村莊級
      else {
        targetCategory = dataSource.village;
        // 從 AOC 檔名提取關鍵字，例如 "AOC Marsannay (Couchey).geojson" -> "couchey"
        const match = searchKey.match(/\(([^)]+)\)/);
        searchKey = match ? match[1] : searchKey.replace(/^AOC /, '');
      }
      
      // 標準化搜尋鍵
      searchKey = searchKey.toLowerCase()
        .replace(/\s+/g, '-')
        .replace(/[àâä]/g, 'a')
        .replace(/[éèêë]/g, 'e')
        .replace(/[ôö]/g, 'o')
        .replace(/[ùûü]/g, 'u')
        .replace(/ç/g, 'c')
        .replace(/[îï]/g, 'i');
      
      let foundInfo = null;
      
      if (targetCategory) {
        // 嘗試直接匹配
        foundInfo = targetCategory[searchKey];
        
        // 如果沒找到，嘗試其他可能的變體
        if (!foundInfo) {
          // 嘗試不帶連字符的版本
          const noHyphens = searchKey.replace(/-/g, '');
          foundInfo = targetCategory[noHyphens];
        }
        
        if (!foundInfo) {
          // 嘗試首字母大寫的版本 (例如 "Clos de la Perrière" 可能用原始大小寫作為 key)
          for (const key of Object.keys(targetCategory)) {
            if (key.toLowerCase().replace(/\s+/g, '-') === searchKey) {
              foundInfo = targetCategory[key];
              break;
            }
          }
        }
      }
      
      if (foundInfo) {
        regionInfo.value = foundInfo;
        console.log('[RegionMap] Region info found:', foundInfo.name);
      } else {
        // 如果找不到，嘗試使用第一個資訊（預設）
        if (targetCategory && Object.keys(targetCategory).length > 0) {
          const firstKey = Object.keys(targetCategory)[0];
          regionInfo.value = targetCategory[firstKey];
          console.warn(`[RegionMap] Using first entry for: "${aoc}", searched for: "${searchKey}"`);
        } else {
          regionInfo.value = null;
          console.error(`[RegionMap] No info found for: "${aoc}", searched for: "${searchKey}" in category:`, targetCategory ? Object.keys(targetCategory) : 'undefined');
        }
      }
    } else {
      // 其他格式: 直接使用整個物件 {name, description, ...}
      regionInfo.value = aocData;
      console.log('[RegionMap] Using direct data format');
    }
  } catch (error) {
    console.error("[RegionMap] Error loading region info:", error);
    console.error("[RegionMap] Failed for:", { group, aoc, dataPath });
    regionInfo.value = null;
  }
};

const reselectAOC = (aoc) => {
  showAOCGeojson(aoc.group, aoc.aoc);
}

const resetMap = () => {
  activeAOC.value = { group: '', aoc: '' }
  regionInfo.value = null;
}

const clearRegionInfo = () => {
  regionInfo.value = null;
}

// 當區域切換時，重置狀態
watch(() => props.regionConfig?.id, () => {
  resetMap()
  dataCache.clear()
})
</script>

<template>
  <div class="main-layout">
    <AOCList
      v-model:search="search"
      :activeAOC="activeAOC"
      :aocColor="(group) => '#800020'"
      :indexPath="indexPath"
      :regionName="regionConfig?.name || 'Chablis'"
      @selectAOC="showAOCGeojson"
    />
    
    <MapSection
      :activeAOC="activeAOC"
      :regionInfo="regionInfo"
      :regionConfig="regionConfig"
      :styleColors="styleColors"
      @resetMap="resetMap"
      @clear-region-info="clearRegionInfo"
      @reselect-aoc="reselectAOC"
    />
  </div>
</template>

<style scoped>
.main-layout {
  display: flex;
  width: 100vw;
  height: 100vh;
  overflow: hidden;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
}

@media (max-width: 768px) {
  .main-layout {
    flex-direction: column;
    height: 100%;
    width: 100%;
  }
  
  :deep(.aoc-list) {
    height: 30%;
    width: 100%;
    overflow-y: auto;
    flex-shrink: 0;
  }
}
</style>
