<template>
  <div class="map-slide">
    <!-- 標題 -->
    <div class="slide-header">
      <h2 class="slide-title">{{ slide.title }}</h2>
    </div>

    <!-- 左側按鈕面板（如果是交互式地圖） -->
    <div v-if="slide.interactive && slide.buttonPosition === 'left'" class="layer-buttons left">
      <button
        v-for="layer in interactiveLayers"
        :key="layer.id"
        :class="['layer-btn', { active: activeLayerId === layer.id }]"
        @click="toggleLayer(layer)"
      >
        {{ layer.name }}
      </button>
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
const activeLayerId = ref(null)
let mapManager = null

// 交互式圖層列表
const interactiveLayers = computed(() => {
  if (!props.slide.interactive || !props.slide.geojsonFiles) return []
  
  return props.slide.geojsonFiles
    .filter(file => !file.isBase)
    .map(file => ({
      id: file.id,
      name: file.name || file.displayName,
      url: file.url,
      fillColor: file.fillColor,
      fillOpacity: file.fillOpacity,
      lineColor: file.lineColor,
      lineWidth: file.lineWidth,
      defaultVisible: file.defaultVisible
    }))
})

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
  if (!mapContainer.value) {
    console.error('❌ mapContainer 不存在')
    return
  }

  console.log('🗺️ 開始初始化地圖')
  console.log('📋 地圖配置:', props.slide)
  console.log('📍 GeoJSON 文件列表:', props.slide.geojsonFiles)

  // 創建新的地圖管理器實例
  mapManager = new MapSlideManager(mapContainer.value, props.slide)
  
  try {
    await mapManager.initialize()
    console.log('✅ 地圖初始化成功')
    
    // 如果是交互式地圖，等待用戶點擊按鈕
    if (!props.slide.interactive) {
      // 自動顯示所有產區（非交互式）
      if (mapManager) {
        await mapManager.showAllRegions()
        console.log('✅ 所有產區已顯示')
      }
    }
  } catch (error) {
    console.error('❌ 地圖初始化失敗:', error)
  }
}

// 切換圖層顯示
const toggleLayer = async (layer) => {
  if (!mapManager || !mapManager.map) return
  
  try {
    // 如果點擊已激活的圖層，隱藏它
    if (activeLayerId.value === layer.id) {
      mapManager.map.setLayoutProperty(`${layer.id}-fill`, 'visibility', 'none')
      mapManager.map.setLayoutProperty(`${layer.id}-line`, 'visibility', 'none')
      activeLayerId.value = null
    } else {
      // 隱藏所有其他圖層
      interactiveLayers.value.forEach(l => {
        if (mapManager.map.getLayer(`${l.id}-fill`)) {
          mapManager.map.setLayoutProperty(`${l.id}-fill`, 'visibility', 'none')
        }
        if (mapManager.map.getLayer(`${l.id}-line`)) {
          mapManager.map.setLayoutProperty(`${l.id}-line`, 'visibility', 'none')
        }
      })
      
      // 顯示選中的圖層
      if (mapManager.map.getLayer(`${layer.id}-fill`)) {
        mapManager.map.setLayoutProperty(`${layer.id}-fill`, 'visibility', 'visible')
        mapManager.map.setLayoutProperty(`${layer.id}-line`, 'visibility', 'visible')
        activeLayerId.value = layer.id
      }
    }
  } catch (error) {
    console.error('切換圖層失敗:', error)
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

/* 左側圖層按鈕 */
.layer-buttons.left {
  position: absolute;
  left: 1rem;
  top: 50%;
  transform: translateY(-50%);
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  z-index: 10;
  background: rgba(255, 255, 255, 0.95);
  padding: 1rem;
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
}

.layer-btn {
  padding: 0.65rem 1.2rem;
  background: white;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-size: 0.9rem;
  font-weight: 600;
  color: #4a5568;
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
  text-align: center;
  white-space: nowrap;
  min-width: 160px;
}

.layer-btn:hover {
  transform: translateX(4px);
  box-shadow: 0 4px 12px rgba(184, 134, 11, 0.3);
  border-color: #B8860B;
  color: #B8860B;
}

.layer-btn.active {
  background: linear-gradient(135deg, #B8860B 0%, #DAA520 100%);
  color: white;
  border-color: transparent;
  box-shadow: 0 4px 16px rgba(184, 134, 11, 0.4);
  transform: translateX(4px);
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
