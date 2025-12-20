<script setup>
import { ref, computed } from 'vue'
import AOCList from './AOCList.vue'
import MapSection from './MapSection.vue'

// 接收區域配置
const props = defineProps({
  regionConfig: {
    type: Object,
    default: () => ({
      id: 'chablis',
      name: '夏布利與大歐塞瓦',
      center: [3.8, 47.8],
      zoom: 10
    })
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

const showAOCGeojson = async (group, aoc) => {
  activeAOC.value = { group, aoc };

  const mainFolder = group.split('/')[0];
  const dataPath = `/data/${mainFolder}.json`;

  try {
    let aocData;
    if (dataCache.has(dataPath)) {
      aocData = dataCache.get(dataPath);
    } else {
      const res = await fetch(dataPath);
      if (!res.ok) throw new Error(`Cannot load data file: ${dataPath}`);
      aocData = await res.json();
      dataCache.set(dataPath, aocData);
    }

    const foundInfo = aocData.find(info => info.id === aoc);

    if (foundInfo) {
      regionInfo.value = foundInfo;
    } else {
      console.warn(`No info found for id: "${aoc}" in ${dataPath}`);
      regionInfo.value = null;
    }
  } catch (error) {
    console.error("Error loading region info:", error);
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
</script>

<template>
  <div class="main-layout">
    <AOCList
      v-model:search="search"
      :activeAOC="activeAOC"
      :aocColor="(group) => '#800020'"
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

<style>
html, body {
  margin: 0;
  padding: 0;
  height: 100%;
  width: 100%;
  overflow: hidden;
}

#app {
  height: 100%;
  width: 100%;
}
</style>

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