<template>
  <div class="map-slide">
    <!-- 標題 -->
    <div class="slide-header">
      <h2 class="slide-title">{{ slide.title }}</h2>
    </div>

    <!-- 全屏地圖 -->
    <div ref="mapContainer" class="map-container"></div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import 'mapbox-gl/dist/mapbox-gl.css'
import { MapSlideManager } from './MapSlideManager.js'

const props = defineProps({
  slide: {
    type: Object,
    required: true
  }
})

const mapContainer = ref(null)
const activeRegion = ref(null)
let mapManager = null

// 從 slide 配置中提取產區列表
const regions = computed(() => {
  if (!props.slide.geojsonFiles) return []
  
  return props.slide.geojsonFiles
    .filter(file => !file.isBase && file.id !== 'bourgogne-map') // 排除底圖
    .map(file => ({
      id: file.id,
      name: file.displayName || getRegionDisplayName(file.id),
      nameFr: file.displayNameFr || '',
      url: file.url,
      fillColor: file.fillColor,
      fillOpacity: file.fillOpacity,
      lineColor: file.lineColor,
      lineWidth: file.lineWidth
    }))
})

// 根據 ID 取得顯示名稱
function getRegionDisplayName(id) {
  const nameMap = {
    'chablis': '夏布利與大歐塞瓦',
    'cote-de-nuits': '夜丘',
    'cote-de-beaune': '伯恩丘',
    'cote-chalonnaise': '夏隆丘',
    'maconnais': '馬貢內',
    'beaujolais': '薄酒萊'
  }
  return nameMap[id] || id
}

// 初始化地圖
const initMap = async () => {
  if (!mapContainer.value) return

  // 創建新的地圖管理器實例
  mapManager = new MapSlideManager(mapContainer.value, props.slide)
  
  try {
    await mapManager.initialize()
    console.log('地圖初始化成功')
    
    // 自動顯示所有產區
    if (mapManager) {
      await mapManager.showAllRegions()
    }
  } catch (error) {
    console.error('地圖初始化失敗:', error)
  }
}

// 處理產區按鈕點擊
const handleRegionClick = async (region) => {
  if (!mapManager) return
  
  try {
    const regionId = await mapManager.focusRegion(region)
    activeRegion.value = regionId
  } catch (error) {
    console.error('聚焦產區失敗:', error)
  }
}

onMounted(() => {
  initMap()
})

onUnmounted(() => {
  if (mapManager) {
    mapManager.destroy()
    mapManager = null
  }
})

// 監聽投影片變化，重新初始化地圖
watch(() => props.slide, () => {
  if (mapManager) {
    mapManager.destroy()
    mapManager = null
  }
  activeRegion.value = null
  
  setTimeout(() => {
    initMap()
  }, 100)
}, { deep: true })
</script>

<style scoped>
.map-slide {
  width: 100%;
  height: 100%;
  position: relative;
  background: white;
  overflow: hidden;
}

/* 標題區域 */
.slide-header {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  z-index: 10;
  padding: 1.5rem 3rem;
  background: linear-gradient(180deg, rgba(255,255,255,0.95) 0%, rgba(255,255,255,0.85) 70%, rgba(255,255,255,0) 100%);
  pointer-events: none;
}

.slide-title {
  font-size: 2rem;
  font-weight: 700;
  color: #2c3e50;
  margin: 0;
  text-shadow: 0 2px 4px rgba(255,255,255,0.8);
}

/* 全屏地圖 */
.map-container {
  width: 100%;
  height: 100%;
  position: absolute;
  top: 0;
  left: 0;
}

/* 產區按鈕覆蓋層 */
.region-buttons-overlay {
  position: absolute;
  top: 5rem;
  left: 1.5rem;
  z-index: 10;
  pointer-events: none;
  max-width: 240px;
  max-height: calc(100% - 6rem);
}

.region-buttons {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  pointer-events: auto;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  padding: 0.7rem;
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
  max-height: calc(100vh - 8rem);
  overflow-y: auto;
}

.region-btn {
  padding: 0.5rem 0.8rem;
  background: white;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 600;
  color: #4a5568;
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
  text-align: left;
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
  width: 100%;
  white-space: nowrap;
}

.region-name-zh {
  font-size: 0.9rem;
  font-weight: 700;
  line-height: 1.2;
}

.region-name-fr {
  font-size: 0.72rem;
  font-weight: 500;
  color: #718096;
  font-style: italic;
  line-height: 1.2;
}

.region-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.2);
  border-color: #667eea;
  color: #667eea;
}

.region-btn.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: transparent;
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

/* 城市標記樣式 */
.city-marker {
  cursor: pointer;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.marker-pin {
  width: 12px;
  height: 12px;
  background: #DC143C;
  border: 2px solid white;
  border-radius: 50%;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.3);
}

.marker-label {
  background: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 13px;
  font-weight: 600;
  color: #2c3e50;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  margin-top: 4px;
  white-space: nowrap;
  border: 1px solid #ddd;
}

/* 響應式設計 */
@media (max-width: 768px) {
  .slide-header {
    padding: 1rem 1.5rem;
  }

  .slide-title {
    font-size: 1.4rem;
  }

  .region-buttons-overlay {
    bottom: 1rem;
    left: 1rem;
    right: 1rem;
    transform: none;
  }

  .region-buttons {
    padding: 1rem;
    gap: 0.6rem;
  }

  .region-btn {
    padding: 0.6rem 1rem;
    font-size: 0.9rem;
    min-width: 100px;
  }
}

@media (max-width: 480px) {
  .content-section {
    padding: 1.5rem 1rem;
  }

  .slide-title {
    font-size: 1.25rem;
  }

  .slide-content {
    font-size: 0.95rem;
  }
}
</style>
