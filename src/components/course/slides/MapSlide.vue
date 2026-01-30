<template>
  <div class="map-slide">
    <!-- 標題 -->
    <div class="slide-header">
      <h2 class="slide-title">{{ slide.title }}</h2>
    </div>

    <!-- 左側產區按鈕（如果配置了regions） -->
    <div v-if="slide.regions && slide.regions.length > 0" class="region-buttons-container">
      <!-- 左側按鈕組 -->
      <div class="region-buttons-panel left">
        <button
          v-for="region in leftRegions"
          :key="region.id"
          :class="['region-btn', { active: activeLayerId === region.id }]"
          @click="toggleRegion(region)"
        >
          <div class="region-name-zh">{{ region.name }}</div>
          <div class="region-name-fr">{{ region.nameFr }}</div>
        </button>
      </div>
      
      <!-- 右側按鈕組 -->
      <div class="region-buttons-panel right">
        <button
          v-for="region in rightRegions"
          :key="region.id"
          :class="['region-btn', { active: activeLayerId === region.id }]"
          @click="toggleRegion(region)"
        >
          <div class="region-name-zh">{{ region.name }}</div>
          <div class="region-name-fr">{{ region.nameFr }}</div>
        </button>
      </div>
    </div>

    <!-- 左側圖層按鈕（舊版互動式地圖） -->
    <div v-else-if="slide.interactive && slide.buttonPosition === 'left'" class="layer-buttons left">
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
import * as turf from '@turf/turf'

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

// 將產區按鈕分成左右兩組
const leftRegions = computed(() => {
  if (!props.slide.regions) return []
  const mid = Math.ceil(props.slide.regions.length / 2)
  return props.slide.regions.slice(0, mid)
})

const rightRegions = computed(() => {
  if (!props.slide.regions) return []
  const mid = Math.ceil(props.slide.regions.length / 2)
  return props.slide.regions.slice(mid)
})

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

// 切換產區顯示
const toggleRegion = async (region) => {
  if (!mapManager || !mapManager.map) return
  
  try {
    const map = mapManager.map
    
    // 如果點擊已激活的產區，隱藏它並恢復全景
    if (activeLayerId.value === region.id) {
      // 隱藏該產區的所有圖層
      props.slide.geojsonFiles.forEach(file => {
        // 跳過底圖
        if (file.id === 'bourgogne-base' || file.id === 'bourgogne-map') return
        
        // 隱藏與該產區相關的所有圖層
        if (file.id === region.id || file.id.includes(region.id.split('-')[0])) {
          const fillLayerId = `${file.id}-fill`
          const lineLayerId = `${file.id}-line`
          if (map.getLayer(fillLayerId)) {
            map.setLayoutProperty(fillLayerId, 'visibility', 'none')
          }
          if (map.getLayer(lineLayerId)) {
            map.setLayoutProperty(lineLayerId, 'visibility', 'none')
          }
        }
      })
      activeLayerId.value = null
      
      // 恢復到初始視圖
      const initialConfig = props.slide.mapConfig || { center: [4.5, 47.0], zoom: 8.2 }
      map.flyTo({
        center: initialConfig.center,
        zoom: initialConfig.zoom,
        pitch: initialConfig.pitch || 0,
        bearing: initialConfig.bearing || 0,
        duration: 1500
      })
    } else {
      // 先隱藏所有產區圖層（除了底圖）
      props.slide.geojsonFiles.forEach(file => {
        if (file.id !== 'bourgogne-base' && file.id !== 'bourgogne-map') {
          const fillLayerId = `${file.id}-fill`
          const lineLayerId = `${file.id}-line`
          if (map.getLayer(fillLayerId)) {
            map.setLayoutProperty(fillLayerId, 'visibility', 'none')
          }
          if (map.getLayer(lineLayerId)) {
            map.setLayoutProperty(lineLayerId, 'visibility', 'none')
          }
        }
      })
      
      // 收集選中產區的所有相關圖層並顯示
      const regionFeatures = []
      props.slide.geojsonFiles.forEach(file => {
        // 跳過底圖
        if (file.id === 'bourgogne-base' || file.id === 'bourgogne-map') return
        
        // 檢查是否匹配主產區或相關子區域
        const isMatch = file.id === region.id || 
                       file.displayName === region.name ||
                       (region.id === 'cote-de-nuits' && file.fillColor === '#8B0000') ||
                       (region.id === 'cote-de-beaune' && file.fillColor === '#FF6347') ||
                       (region.id === 'marsannay' && file.fillColor === '#8B4789') ||
                       (region.id === 'fixin' && file.fillColor === '#CD5C5C') ||
                       (region.id === 'gevrey-chambertin' && (file.fillColor === '#DC143C' || file.id === 'brochon')) ||
                       (region.id === 'morey-saint-denis' && file.fillColor === '#C71585') ||
                       (region.id === 'chambolle-musigny' && file.fillColor === '#DB7093') ||
                       (region.id === 'vougeot' && file.fillColor === '#B22222') ||
                       (region.id === 'vosne-romanee' && file.fillColor === '#8B0000') ||
                       (region.id === 'flagey-echezeaux' && file.fillColor === '#CD5C5C') ||
                       (region.id === 'nuits-saint-georges' && file.fillColor === '#DC143C') ||
                       (region.id === 'meursault' && file.fillColor === '#FFD700') ||
                       (region.id === 'puligny-montrachet' && file.fillColor === '#FFFF00') ||
                       (region.id === 'chassagne-montrachet' && file.fillColor === '#F5DEB3') ||
                       (region.id === 'pommard' && file.fillColor === '#8B0000') ||
                       (region.id === 'volnay' && file.fillColor === '#DC143C') ||
                       (region.id === 'petit-chablis' && file.fillColor === '#E8D5A8') ||
                       (region.id === 'chablis' && file.fillColor === '#DBC68F') ||
                       (region.id === 'premier-cru' && file.fillColor === '#CEB776') ||
                       (region.id === 'grand-cru' && file.fillColor === '#B8860B') ||
                       (region.id === 'bougros' && file.fillColor === '#8B4513') ||
                       (region.id === 'preuses' && file.fillColor === '#B8860B') ||
                       (region.id === 'vaudesir' && file.fillColor === '#DAA520') ||
                       (region.id === 'grenouilles' && file.fillColor === '#FFD700') ||
                       (region.id === 'valmur' && file.fillColor === '#F0E68C') ||
                       (region.id === 'les-clos' && file.fillColor === '#CD853F') ||
                       (region.id === 'blanchot' && file.fillColor === '#DEB887') ||
                       (region.id === 'saint-amour' && file.fillColor === '#FFB6C1') ||
                       (region.id === 'julienas' && file.fillColor === '#FF69B4') ||
                       (region.id === 'chenas' && file.fillColor === '#C71585') ||
                       (region.id === 'moulin-a-vent' && file.fillColor === '#8B008B') ||
                       (region.id === 'fleurie' && file.fillColor === '#DDA0DD') ||
                       (region.id === 'chiroubles' && file.fillColor === '#EE82EE') ||
                       (region.id === 'morgon' && file.fillColor === '#BA55D3') ||
                       (region.id === 'regnie' && file.fillColor === '#DA70D6') ||
                       (region.id === 'brouilly' && file.fillColor === '#9370DB') ||
                       (region.id === 'cote-de-brouilly' && file.fillColor === '#8A2BE2') ||
                       (region.id === 'bouzeron' && file.fillColor === '#98D8C8') ||
                       (region.id === 'rully' && file.fillColor === '#6EC1E4') ||
                       (region.id === 'mercurey' && file.fillColor === '#5DADE2') ||
                       (region.id === 'givry' && file.fillColor === '#3498DB') ||
                       (region.id === 'montagny' && file.fillColor === '#2E86C1') ||
                       (region.id === 'macon-villages' && file.fillColor === '#B8E6B8') ||
                       (region.id === 'vire-clesse' && file.fillColor === '#90D090') ||
                       (region.id === 'saint-veran' && file.fillColor === '#6BBF6B') ||
                       (region.id === 'pouilly-vinzelles' && file.fillColor === '#4CAF50') ||
                       (region.id === 'pouilly-loche' && file.fillColor === '#45A049') ||
                       (region.id === 'pouilly-fuisse' && file.fillColor === '#2E7D32')
        
        if (isMatch) {
          const fillLayerId = `${file.id}-fill`
          const lineLayerId = `${file.id}-line`
          if (map.getLayer(fillLayerId)) {
            map.setLayoutProperty(fillLayerId, 'visibility', 'visible')
          }
          if (map.getLayer(lineLayerId)) {
            map.setLayoutProperty(lineLayerId, 'visibility', 'visible')
          }
          
          // 收集該圖層的 GeoJSON 數據用於計算邊界
          const geojsonData = mapManager.loadedLayers.get(file.id)
          if (geojsonData && geojsonData.features) {
            regionFeatures.push(...geojsonData.features)
          }
        }
      })
      
      activeLayerId.value = region.id
      
      // 計算邊界並縮放到該產區
      if (regionFeatures.length > 0) {
        try {
          const combinedGeoJSON = {
            type: 'FeatureCollection',
            features: regionFeatures
          }
          const bbox = turf.bbox(combinedGeoJSON)
          
          // 根據產區大小調整 padding 和 maxZoom
          let padding = 80
          let maxZoom = 12
          
          // 為較小的產區（如夏布利、薄酒萊）使用更大的縮放
          if (region.id === 'chablis') {
            padding = 60
            maxZoom = 11.5
          } else if (region.id === 'beaujolais') {
            padding = 70
            maxZoom = 10.5
          } else if (region.id === 'cote-de-nuits' || region.id === 'cote-de-beaune') {
            padding = 50
            maxZoom = 11
          } else if (region.id === 'maconnais') {
            padding = 70
            maxZoom = 10.5
          } else if (region.id === 'cote-chalonnaise') {
            padding = 60
            maxZoom = 11
          } else if (region.id === 'marsannay') {
            padding = 40
            maxZoom = 13
          } else if (region.id === 'fixin') {
            padding = 30
            maxZoom = 13.5
          } else if (region.id === 'gevrey-chambertin') {
            padding = 50
            maxZoom = 12.5
          } else if (region.id === 'morey-saint-denis') {
            padding = 40
            maxZoom = 13
          } else if (region.id === 'chambolle-musigny') {
            padding = 35
            maxZoom = 13
          } else if (region.id === 'vougeot') {
            padding = 35
            maxZoom = 13
          } else if (region.id === 'vosne-romanee') {
            padding = 40
            maxZoom = 13
          } else if (region.id === 'flagey-echezeaux') {
            padding = 35
            maxZoom = 13.5
          } else if (region.id === 'nuits-saint-georges') {
            padding = 50
            maxZoom = 12
          } else if (region.id === 'meursault') {
            padding = 40
            maxZoom = 13
          } else if (region.id === 'puligny-montrachet') {
            padding = 35
            maxZoom = 13.5
          } else if (region.id === 'chassagne-montrachet') {
            padding = 35
            maxZoom = 13
          } else if (region.id === 'pommard') {
            padding = 35
            maxZoom = 13.5
          } else if (region.id === 'volnay') {
            padding = 30
            maxZoom = 14
          } else if (region.id === 'petit-chablis') {
            padding = 60
            maxZoom = 11.5
          } else if (region.id === 'premier-cru') {
            padding = 50
            maxZoom = 12.5
          } else if (region.id === 'grand-cru') {
            padding = 40
            maxZoom = 13.5
          } else if (region.id === 'bougros') {
            padding = 25
            maxZoom = 15
          } else if (region.id === 'preuses') {
            padding = 25
            maxZoom = 15
          } else if (region.id === 'vaudesir') {
            padding = 25
            maxZoom = 14.5
          } else if (region.id === 'grenouilles') {
            padding = 20
            maxZoom = 15.5
          } else if (region.id === 'valmur') {
            padding = 25
            maxZoom = 14.5
          } else if (region.id === 'les-clos') {
            padding = 30
            maxZoom = 14.5
          } else if (region.id === 'blanchot') {
            padding = 25
            maxZoom = 15
          } else if (region.id === 'saint-amour') {
            padding = 30
            maxZoom = 13.5
          } else if (region.id === 'julienas') {
            padding = 35
            maxZoom = 13
          } else if (region.id === 'chenas') {
            padding = 28
            maxZoom = 14
          } else if (region.id === 'moulin-a-vent') {
            padding = 35
            maxZoom = 13
          } else if (region.id === 'fleurie') {
            padding = 40
            maxZoom = 12.5
          } else if (region.id === 'chiroubles') {
            padding = 32
            maxZoom = 13.5
          } else if (region.id === 'morgon') {
            padding = 55
            maxZoom = 11.5
          } else if (region.id === 'regnie') {
            padding = 35
            maxZoom = 13
          } else if (region.id === 'brouilly') {
            padding = 60
            maxZoom = 11.5
          } else if (region.id === 'cote-de-brouilly') {
            padding = 32
            maxZoom = 13.5
          } else if (region.id === 'bouzeron') {
            padding = 30
            maxZoom = 14
          } else if (region.id === 'rully') {
            padding = 35
            maxZoom = 13
          } else if (region.id === 'mercurey') {
            padding = 50
            maxZoom = 12
          } else if (region.id === 'givry') {
            padding = 35
            maxZoom = 13
          } else if (region.id === 'montagny') {
            padding = 40
            maxZoom = 12.5
          } else if (region.id === 'macon-villages') {
            padding = 70
            maxZoom = 10
          } else if (region.id === 'vire-clesse') {
            padding = 35
            maxZoom = 13
          } else if (region.id === 'saint-veran') {
            padding = 45
            maxZoom = 12
          } else if (region.id === 'pouilly-vinzelles') {
            padding = 30
            maxZoom = 13.5
          } else if (region.id === 'pouilly-loche') {
            padding = 28
            maxZoom = 14
          } else if (region.id === 'pouilly-fuisse') {
            padding = 40
            maxZoom = 12.5
          }
          
          map.fitBounds(bbox, {
            padding: padding,
            duration: 1500,
            maxZoom: maxZoom
          })
        } catch (error) {
          console.error('計算產區邊界失敗:', error)
        }
      }
    }
  } catch (error) {
    console.error('切換產區失敗:', error)
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

/* 產區按鈕容器 */
.region-buttons-container {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  left: 0;
  right: 0;
  pointer-events: none;
  z-index: 10;
  display: flex;
  justify-content: space-between;
  padding: 0 2rem;
}

/* 產區按鈕面板 */
.region-buttons-panel {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  padding: 1.2rem;
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
  max-width: 220px;
  pointer-events: auto;
  max-height: calc(100vh - 12rem);
  overflow-y: auto;
}

.region-buttons-panel.left {
  align-self: flex-start;
}

.region-buttons-panel.right {
  align-self: flex-start;
}

.region-btn {
  padding: 0.75rem 1rem;
  background: white;
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  text-align: left;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  position: relative;
  overflow: hidden;
}

.region-btn::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 4px;
  background: linear-gradient(180deg, #667eea 0%, #764ba2 100%);
  transform: scaleY(0);
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.region-btn:hover::before {
  transform: scaleY(1);
}

.region-name-zh {
  font-size: 1rem;
  font-weight: 700;
  color: #2d3748;
  line-height: 1.3;
  transition: color 0.3s ease;
}

.region-name-fr {
  font-size: 0.75rem;
  font-weight: 500;
  color: #718096;
  font-style: italic;
  line-height: 1.2;
  transition: color 0.3s ease;
}

.region-btn:hover {
  transform: translateX(4px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.25);
  border-color: #667eea;
}

.region-btn:hover .region-name-zh {
  color: #667eea;
}

.region-btn:hover .region-name-fr {
  color: #667eea;
}

.region-btn.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-color: transparent;
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.4);
  transform: translateX(6px);
}

.region-btn.active .region-name-zh,
.region-btn.active .region-name-fr {
  color: white;
}

.region-btn.active::before {
  background: rgba(255, 255, 255, 0.3);
  transform: scaleY(1);
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
