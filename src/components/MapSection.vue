<template>
  <section class="map-section">
    <div class="map-header">
      <h1>{{ props.regionConfig?.name || 'Bourgogne wine map' }} 葡萄酒產區地圖</h1>
    </div>
    <div class="map-info-bar" v-if="activeAOC.aoc" :class="{ collapsed: isInfoCollapsed }">
      <div class="info-header-bar">
        <div class="aoc-info-title">
          <span class="aoc-dot" :style="{background: aocColor(activeAOC.group)}"></span>
          <span class="aoc-name">{{ activeDomaine ? activeDomaine.replace('.geojson', '') : activeAOC.aoc.replace('.geojson','').replace(/_/g,' ') }}</span>
        </div>
        
        <div class="map-buttons-right">
          <div class="map-action-buttons">
            <button class="map-action-btn btn-collapse" @click="toggleInfoBar" :title="isInfoCollapsed ? '展開資訊' : '收合資訊'" :aria-label="isInfoCollapsed ? '展開資訊' : '收合資訊'">
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" :style="{ transform: isInfoCollapsed ? 'rotate(0deg)' : 'rotate(180deg)', transition: 'transform 0.3s ease' }">
                <polyline points="18 15 12 9 6 15"></polyline>
              </svg>
            </button>

            <button class="map-action-btn btn-audio-compact" @click="playPronunciation" :disabled="!audioPath || isPlayingAudio" :title="audioPath ? '聽發音' : '無發音檔'" :aria-label="audioPath ? '聽發音' : '無發音檔'">
              <svg v-if="!audioPath" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round">
                <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"></polygon>
                <line x1="23" y1="9" x2="17" y2="15"></line>
                <line x1="17" y1="9" x2="23" y2="15"></line>
              </svg>
              <svg v-else-if="!isPlayingAudio" xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round">
                <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"></polygon>
                <path d="M15.54 8.46a5 5 0 0 1 0 7.07"></path>
                <path d="M19.07 4.93a10 10 0 0 1 0 14.14"></path>
              </svg>
              <svg v-else xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round">
                <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"></polygon>
                <path d="M15.54 8.46a5 5 0 0 1 0 7.07"></path>
              </svg>
            </button>

            <button class="map-action-btn btn-reset" @click="resetMap" title="重置地圖" aria-label="重置地圖">
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round">
                <path d="M3 2v6h6"></path>
                <path d="M3.05 13A9 9 0 1 0 6 5.3L3 8"></path>
              </svg>
            </button>
          </div>
          
          <!-- 桌面版的其餘按鈕保留但不顯示於手機 -->
          <div class="desktop-only-buttons">
            <button v-if="showDomaineButton" class="btn-show-domaines" @click="toggleDomainesMode">
              {{ domainesMode ? '回上一層' : '顯示酒莊' }}
            </button>
          </div>
        </div>
      </div>
      
      <transition name="info-expand">
        <div v-show="!isInfoCollapsed" class="info-content-wrapper">
      <div v-if="domainesMode" class="domaines-list-container">
        <div v-if="currentDomaineImage" class="domaine-image-container" style="margin-bottom: 12px; text-align: center;">
          <img :src="currentDomaineImage" alt="Domaine Image" @error="onDomaineImageError" style="max-width: 100%; height: auto; border-radius: 4px; max-height: 150px; object-fit: cover;">
        </div>
        <ul class="domaines-list">
          <li v-for="domaine in domaines" :key="domaine" @click="loadDomaineLayer(domaine)" :class="{ active: activeDomaine === domaine }">
            {{ domaine.replace('.geojson', '').replace(/^\d+\s*/, '') }}
          </li>
        </ul>
        
        <!-- 酒莊詳細資訊 -->
        <div v-if="activeDomaine && selectedDomaineInfo && selectedDomaineInfo[activeDomaine]" class="domaine-info">
          <div class="domaine-info-header">
            <h4>{{ selectedDomaineInfo[activeDomaine].name }}</h4>
          </div>
          <div class="domaine-details">
            <div class="domaine-detail-item">
              <span class="detail-label">成立時間:</span>
              <span class="detail-value">{{ selectedDomaineInfo[activeDomaine].founded }}</span>
            </div>
            <div class="domaine-detail-item">
              <span class="detail-label">面積:</span>
              <span class="detail-value">{{ selectedDomaineInfo[activeDomaine].area }}</span>
            </div>
            <div class="domaine-detail-item">
              <span class="detail-label">釀造風格:</span>
              <span class="detail-value">{{ selectedDomaineInfo[activeDomaine].style }}</span>
            </div>
            <div class="domaine-detail-item full-width">
              <span class="detail-label">特色:</span>
              <span class="detail-value">{{ selectedDomaineInfo[activeDomaine].characteristics }}</span>
            </div>
            <div v-if="selectedDomaineInfo[activeDomaine].specialties" class="domaine-detail-item full-width">
              <span class="detail-label">專長技術:</span>
              <span class="detail-value">{{ selectedDomaineInfo[activeDomaine].specialties.join('、') }}</span>
            </div>
            <div class="domaine-detail-item full-width">
              <span class="detail-label">介紹:</span>
              <span class="detail-value domaine-description">{{ selectedDomaineInfo[activeDomaine].description }}</span>
            </div>
          </div>
        </div>
      </div>
      <div v-else-if="regionInfo" ref="regionInfoContent" class="region-info-content">
        <div style="flex: 1; min-width: 0;">
          <div class="info-header">
            <div>
              <b>{{ regionInfo.name }}</b> 
              <span class="region-type" v-if="regionInfo.classification">({{ regionInfo.classification }})</span>
            </div>
          </div>

          <div class="details-grid">
            <div v-if="regionInfo.area" class="detail-item">
              <span class="detail-label">面積:</span>
              <span class="detail-value">{{ regionInfo.area }}</span>
            </div>
            <div v-if="regionInfo.altitude" class="detail-item">
              <span class="detail-label">海拔:</span>
              <span class="detail-value">{{ regionInfo.altitude }}</span>
            </div>
            <div v-if="regionInfo.exposition" class="detail-item">
              <span class="detail-label">坡向:</span>
              <span class="detail-value">{{ regionInfo.exposition }}</span>
            </div>
            <div v-if="regionInfo.soilStructure" class="detail-item full-width">
              <span class="detail-label">土壤:</span>
              <span class="detail-value">{{ regionInfo.soilStructure }}</span>
            </div>
            <div v-if="regionInfo.climate" class="detail-item full-width">
              <span class="detail-label">氣候:</span>
              <span class="detail-value">{{ regionInfo.climate }}</span>
            </div>
            <div v-if="regionInfo.wineStyle" class="detail-item full-width">
              <span class="detail-label">葡萄酒風格:</span>
              <span class="detail-value">{{ regionInfo.wineStyle }}</span>
            </div>
            <div v-if="regionInfo.tastingNotes" class="detail-item full-width">
              <span class="detail-label">品酒筆記:</span>
              <span class="detail-value">{{ regionInfo.tastingNotes }}</span>
            </div>
            <div v-if="regionInfo.agingPotential" class="detail-item full-width">
              <span class="detail-label">陳年潛力:</span>
              <span class="detail-value">{{ regionInfo.agingPotential }}</span>
            </div>
            <div v-if="regionInfo.history" class="detail-item full-width">
              <span class="detail-label">歷史:</span>
              <span class="detail-value">{{ regionInfo.history }}</span>
            </div>
          </div>

          <div v-if="regionInfo.wineTypes && regionInfo.wineTypes.length" class="wine-types-section">
            <div class="wine-types-title">酒款類型:</div>
            <div class="wine-types-list">
              <span v-for="wineType in regionInfo.wineTypes" :key="wineType" class="wine-type-tag">
                {{ wineType }}
              </span>
            </div>
          </div>

          <div v-if="regionInfo.grapeVarieties && regionInfo.grapeVarieties.length" class="grape-section">
            <div class="grape-title">主要葡萄品種:</div>
            <div class="grape-badges">
              <div v-for="grape in regionInfo.grapeVarieties" :key="grape" class="grape-badge" :style="grapeBadgeStyle(grape)">
                {{ grape }}
              </div>
            </div>
          </div>

          <div v-if="regionInfo.famousWineries && regionInfo.famousWineries.length" class="producers-section">
            <div class="producers-title">知名酒莊:</div>
            <div class="producers-list">
              <span v-for="producer in regionInfo.famousWineries" :key="producer" class="producer-tag">
                {{ producer }}
              </span>
            </div>
          </div>
        </div>
      </div>
      <div v-else class="no-info">無詳細產區資料</div>
        </div>
      </transition>

    </div>

    <!-- 手機版底部 4宮格 按鈕 -->
    <div class="mobile-grid-buttons" v-if="isMobileView" :class="{ 'merged-with-info': activeAOC.aoc }">
      <button class="m-grid-btn" :class="{ active: mobileAOCListOpen }" @click="handleMobileAction('aoc')">
        <span class="m-grid-icon">產</span>
        <span class="m-grid-text">產區</span>
      </button>
      <button class="m-grid-btn" :class="{ active: showLayerPanel }" @click="handleMobileAction('layer')">
        <span class="m-grid-icon">層</span>
        <span class="m-grid-text">圖層</span>
      </button>
      <button class="m-grid-btn" :class="{ active: is3D }" @click="handleMobileAction('3d')">
        <span class="m-grid-icon">3D</span>
        <span class="m-grid-text">3D</span>
      </button>
      <button class="m-grid-btn" :class="{ active: activeAOC.aoc && !isInfoCollapsed }" @click="handleMobileAction('info')">
        <span class="m-grid-icon">資</span>
        <span class="m-grid-text">資訊</span>
      </button>
    </div>
    
    <!-- 圖層選擇面板 (在手機版由 圖層 按鈕呼叫) -->
    <div v-if="isMobileView && showLayerPanel" class="mobile-layer-panel">
      <div class="layer-panel-header">
        <h4>圖層設定</h4>
      </div>
      <div class="layer-panel-content">
        <button class="layer-toggle-btn" :class="{ active: showContours }" @click="toggleContours">
          {{ showContours ? '隱藏等高線' : '顯示等高線' }}
        </button>
      </div>
    </div>
    <div ref="mapContainer" class="map"></div>
    <!-- 返回學習模式按鈕 (手機版顯示為圓形圖示) -->
    <button class="btn-learning-mode" @click="$emit('request-learning-mode')" title="返回學習模式">
      <svg class="learning-icon" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M22 10v6M2 10l10-5 10 5-10 5z"/>
        <path d="M6 12v5c3 3 9 3 12 0v-5"/>
      </svg>
      <span class="learning-text">返回學習模式</span>
    </button>
    <button :class="['btn-3d', { 'controls-wide': geologyVisible }]" @click="toggle3D">
      {{ is3D ? '2D' : '3D' }}
    </button>
    <button :class="['btn-contours', { 'controls-wide': geologyVisible }]" @click="toggleContours">
      {{ showContours ? '隱藏等高線' : '顯示等高線' }}
    </button>
    <div :class="['geology-panel', { 'controls-wide': geologyVisible }]" v-if="!isMobileView && geologyIndex && currentGeologyProvinceCodes.length > 0">
      <button class="geology-visibility-btn" :class="{ active: geologyVisible }" type="button" @click="geologyVisible = !geologyVisible">
        {{ geologyVisible ? '隱藏地質' : '顯示地質' }}
      </button>
      <div class="geology-materials" v-if="geologyVisible">
        <div v-for="material in geologyIndex.materials" :key="material.id" class="geology-material-row">
          <button
            type="button"
            class="geology-material-toggle"
            :class="{ active: geologyActiveMaterials.includes(material.id) }"
            @click="toggleGeologyMaterial(material.id)"
          >
            <span class="material-dot" :style="{ backgroundColor: material.fillColor }"></span>
            <span>{{ material.name }}</span>
          </button>
          <label class="geology-slider-wrap">
            <input
              type="range"
              min="0.1"
              max="0.85"
              step="0.05"
              v-model.number="geologyMaterialOpacity[material.id]"
            />
            <span>{{ Math.round((geologyMaterialOpacity[material.id] || 0) * 100) }}%</span>
          </label>
        </div>
      </div>
    </div>
    <div v-if="mapError" class="map-error">
      {{ mapError }}
    </div>
    <div v-if="isLoading" class="loading-overlay">
      <div class="loading-spinner"></div>
    </div>
  </section>
</template>

<script setup>
import dataService from '../dataService.js';
// 葡萄品種分類顏色
const grapeTypeColors = {
  red: '#8B0000',
  white: '#F0E68C',
  aromatic: '#87CEEB',
  other: '#bbb'
}

const redGrapes = [
  'Pinot Noir', 'Gamey', 
]
const whiteGrapes = [
  'Chardonnay', 'Aligoté', 'Sauvignon Blanc', 'Riesling', 'Gewürztraminer', 'Viognier'
]
const aromaticGrapes = []

function grapeBadgeStyle(grape) {
  if (redGrapes.includes(grape)) {
    return { backgroundColor: grapeTypeColors.red, color: '#fff', fontWeight: 'bold' }
  } else if (whiteGrapes.includes(grape)) {
    return { backgroundColor: grapeTypeColors.white, color: '#333', fontWeight: 'bold' }
  } else if (aromaticGrapes.includes(grape)) {
    return { backgroundColor: grapeTypeColors.aromatic, color: '#333', fontWeight: 'bold' }
  } else {
    return { backgroundColor: grapeTypeColors.other, color: '#333' }
  }
}
import { ref, onMounted, onUnmounted, nextTick, watch, computed } from 'vue'
import mapboxgl from 'mapbox-gl'
import 'mapbox-gl/dist/mapbox-gl.css'
import * as turf from '@turf/turf'

const props = defineProps({
  activeAOC: Object,
  regionInfo: Object,
  styleColors: Object,
  mobileAOCListOpen: {
    type: Boolean,
    default: false
  },
  regionConfig: {
    type: Object,
    default: () => ({
      id: 'chablis',
      name: 'Bourgogne wine map',
      center: [3.8, 47.8],
      zoom: 10
    })
  }
})

const emit = defineEmits(['resetMap', 'clear-region-info', 'reselect-aoc', 'request-aoc-list', 'request-learning-mode'])

const TOUCH_LAYOUT_MAX_WIDTH = 4096
const useTouchCompactLayout = () => {
  return typeof window !== 'undefined' && window.innerWidth <= TOUCH_LAYOUT_MAX_WIDTH
}

const isMobileView = ref(useTouchCompactLayout())
const showLayerPanel = ref(false)

const checkMobile = () => {
  isMobileView.value = useTouchCompactLayout()
}

// 根據區域 ID 獲取基礎路徑
const geojsonBasePath = computed(() => {
  const pathMap = {
    'chablis': '/geojson',
    'cote-de-nuits': '/geojson/Cote-de-Nuits',
    'cote-de-beaune': '/geojson/Cote-de-Beaune',
    'cote-chalonnaise': '/geojson/Cote-Chalonnaise',
    'maconnais': '/geojson/Maconnais',
    'beaujolais': '/geojson/Beaujolais'
  }
  return pathMap[props.regionConfig?.id] || '/geojson'
})

// 根據區域 ID 獲取 index.json 路徑
const indexJsonPath = computed(() => {
  return `${geojsonBasePath.value}/index.json`
})

const isLoading = ref(false)
const mapError = ref(null)
const mapContainer = ref(null)
let map = null
const is3D = ref(false)
const showContours = ref(false)
const isInfoCollapsed = ref(false)
const geojsonCache = new Map()
let resetBounds = null // stored bbox [minX,minY,maxX,maxY] for reset
const geologyIndex = ref(null)
const geologyVisible = ref(false)
const geologyActiveMaterials = ref([])
const geologyMaterialOpacity = ref({})
const currentGeojsonBounds = ref(null)
const currentGeojsonClipFeatures = ref([])
const domaines = ref([])
const activeDomaine = ref(null)
const domainesMode = ref(false)
const selectedDomaineInfo = ref(null)
const loadedInitialFiles = ref([]) // 追蹤已載入的初始村莊檔案
// 圖片候補索引（用於 jpg/png fallback）
const imageIndex = ref(0)

// 音頻播放器
const audioPlayer = ref(null)
const isPlayingAudio = ref(false)

const REGION_PROVINCES = {
  chablis: ['089'],
  'cote-de-nuits': ['021'],
  'cote-de-beaune': ['021'],
  'cote-chalonnaise': ['071'],
  maconnais: ['071'],
  beaujolais: ['071', '069']
}

const normalizeGeojsonToFeatures = (geojson) => {
  if (!geojson || typeof geojson !== 'object') return []

  if (geojson.type === 'FeatureCollection') {
    return (geojson.features || []).filter((feature) => feature?.geometry)
  }

  if (geojson.type === 'Feature') {
    return geojson.geometry ? [geojson] : []
  }

  return geojson.type ? [{ type: 'Feature', properties: {}, geometry: geojson }] : []
}

const currentGeologyProvinceCodes = computed(() => {
  return REGION_PROVINCES[props.regionConfig?.id] || []
})

// 根據 activeAOC 構建音頻路徑
const audioPath = computed(() => {
  if (!props.activeAOC?.aoc || !props.activeAOC?.group) return null
  
  // 移除 .geojson 副檔名
  const aocName = props.activeAOC.aoc.replace('.geojson', '')
  
  // 從 group 中提取主資料夾路徑（例如 "Chablis" 或 "Chablis/Chablis Grand Cru"）
  // 對於 Chablis 區域，group 可能是 "Chablis", "Grand Auxerrois", "Chablis/Chablis 1er cru" 等
  let subPath = ''
  
  if (props.regionConfig?.id === 'chablis') {
    // Chablis 區域特殊處理：使用 group 的第一個部分
    const groupParts = props.activeAOC.group.split('/')
    if (groupParts[0] === 'Chablis' || groupParts[0] === 'Grand Auxerrois') {
      // 使用完整的 group 路徑
      subPath = props.activeAOC.group
    } else {
      subPath = groupParts[0]
    }
  } else {
    // 其他區域（Cote-de-Nuits, Cote-de-Beaune 等）：
    const regionName = geojsonBasePath.value.replace('/geojson/', '').replace('/geojson', '')
    const groupName = props.activeAOC.group
    
    // 特殊處理：Regional、Beaujolais、Beaujolais Crus 等虛擬分組
    // 這些不是實際的資料夾，檔案直接在區域根目錄下
    const isVirtualGroup = ['Regional', 'Beaujolais', 'Beaujolais Crus', 'AOC Bourgogne'].includes(groupName)
    
    if (isVirtualGroup) {
      // 檔案直接在區域根目錄
      subPath = regionName
    } else {
      // 使用 區域名稱/村莊資料夾 的完整路徑
      subPath = regionName ? `${regionName}/${groupName}` : groupName
    }
  }
  
  // 構建音頻路徑：/sounds/{子路徑}/{AOC名稱}.mp3
  const soundPath = subPath ? `/sounds/${subPath}/${aocName}.mp3` : `/sounds/${aocName}.mp3`
  
  console.log('[AudioPath] Constructed:', { 
    regionId: props.regionConfig?.id,
    group: props.activeAOC.group, 
    aocName, 
    subPath, 
    soundPath 
  })
  
  return soundPath
})

// 播放發音
const playPronunciation = () => {
  if (!audioPath.value) return
  
  if (audioPlayer.value) {
    audioPlayer.value.pause()
    audioPlayer.value.currentTime = 0
  }
  
  audioPlayer.value = new Audio(audioPath.value)
  isPlayingAudio.value = true
  
  audioPlayer.value.play().catch(error => {
    console.error('播放音頻失敗:', error)
    isPlayingAudio.value = false
  })
  
  audioPlayer.value.onended = () => {
    isPlayingAudio.value = false
  }
  
  audioPlayer.value.onerror = () => {
    console.error('音頻載入失敗:', audioPath.value)
    isPlayingAudio.value = false
  }
}

// 為各產區建立可能的圖片路徑候補清單（依 activeDomaine 推斷）
const domaineImageCandidates = computed(() => {
  const candidates = []
  if (!activeDomaine.value || !props.activeAOC?.aoc) return candidates

  // 取得酒莊檔名中的數字：優先取開頭的數字，否則抓取檔名中第一個 1-2 位數字
  let number = null
  const startMatch = activeDomaine.value.match(/^(\d{1,2})/)
  if (startMatch) {
    number = startMatch[1].padStart(2, '0')
  } else {
    const anyMatch = activeDomaine.value.match(/\b(\d{1,2})\b/)
    number = anyMatch ? anyMatch[1].padStart(2, '0') : null
  }
  const fileBaseName = activeDomaine.value.replace(/\.geojson$/i, '')

  // Helper: 先嘗試完整檔名（包含空格/重音符號），再嘗試編號檔名；輸出時使用 encodeURI
  const pushCandidates = (...bases) => {
    for (const base of bases) {
      // 1) 完整檔名優先
      candidates.push(encodeURI(`${base}${fileBaseName}.jpg`));
      candidates.push(encodeURI(`${base}${fileBaseName}.png`));

      // 2) 若有編號，再嘗試 01/02.jpg
      if (number) {
        candidates.push(encodeURI(`${base}${number}.jpg`));
        candidates.push(encodeURI(`${base}${number}.png`));
      }
    }
  }

  if (props.activeAOC.aoc === PREUSES_GRAND_CRU) {
    pushCandidates('/images/Chablis Grand Cru Preuses/')
  }
  return candidates
})

const currentDomaineImage = computed(() => domaineImageCandidates.value[imageIndex.value] || null)

function onDomaineImageError() {
  // 嘗試下一個候補，若已無候補則隱藏圖片
  if (imageIndex.value + 1 < domaineImageCandidates.value.length) {
    imageIndex.value += 1
  } else {
    imageIndex.value = domaineImageCandidates.value.length // 使 currentDomaineImage 為 null
  }
}

const PREUSES_GRAND_CRU = 'AOC Chablis Grand Cru Preuses.geojson';

// ... existing code ...

// 切換 AOC 或酒莊時，重置圖片候補索引
watch([() => props.activeAOC?.aoc, activeDomaine], () => {
  imageIndex.value = 0
})

const showDomaineButton = computed(() => {
  return props.activeAOC?.aoc === PREUSES_GRAND_CRU;
});

const toggleDomainesMode = async () => {
  domainesMode.value = !domainesMode.value;
  if (domainesMode.value) {
    emit('clear-region-info');
    try {
      const res = await fetch('/data/preuses-domaines.json');
      if (!res.ok) throw new Error('Failed to load domaines list');
      domaines.value = await res.json();
      
      // 同時載入酒莊詳細資訊
      const infoRes = await fetch('/data/preuses-domaines-info.json');
      if (infoRes.ok) {
        const domainesInfo = await infoRes.json();
        selectedDomaineInfo.value = domainesInfo;
      }
    } catch (err) {
      console.error('Error loading domaines:', err);
      domaines.value = [];
      mapError.value = '無法載入酒莊列表';
    }
  } else {
    domaines.value = [];
    activeDomaine.value = null;
    selectedDomaineInfo.value = null;
    if (map.getLayer('domaine-fill')) map.removeLayer('domaine-fill');
    if (map.getLayer('domaine-outline')) map.removeLayer('domaine-outline');
    if (map.getSource('domaine')) map.removeSource('domaine');
    emit('reselect-aoc', props.activeAOC);
  }
};

const loadDomaineLayer = async (domaineFile) => {
  if (!map) return;
  activeDomaine.value = domaineFile;

  // 滾動到酒莊列表容器的最上方
  await nextTick();
  const container = document.querySelector('.domaines-list-container');
  if (container) {
    container.scrollTop = 0;
  }

  let geojsonPath = '';
  if (props.activeAOC.aoc === PREUSES_GRAND_CRU) {
    geojsonPath = `${geojsonBasePath.value}/Chablis/Chablis Grand Cru/AOC Chablis Grand Cru Preuses/${encodeURIComponent(domaineFile)}`;
  }

  if (!geojsonPath) return;

  isLoading.value = true;
  try {
    let geojson;
    if (geojsonCache.has(geojsonPath)) {
      geojson = geojsonCache.get(geojsonPath);
    } else {
      const res = await fetch(geojsonPath);
      if (!res.ok) throw new Error(`無法載入 geojson (${res.status})`);
      geojson = await res.json();
      geojsonCache.set(geojsonPath, geojson);
    }

    if (map.getLayer('domaine-fill')) map.removeLayer('domaine-fill');
    if (map.getLayer('domaine-outline')) map.removeLayer('domaine-outline');
    if (map.getSource('domaine')) map.removeSource('domaine');

    map.addSource('domaine', { type: 'geojson', data: geojson });
    map.addLayer({
      id: 'domaine-fill',
      type: 'fill',
      source: 'domaine',
      paint: {
        'fill-color': '#FFD700', // Gold color for domaine
        'fill-opacity': 0.2
      }
    });
    map.addLayer({
      id: 'domaine-outline',
      type: 'line',
      source: 'domaine',
      paint: {
        'line-color': '#fff',
        'line-width': 2.5
      }
    });
    map.moveLayer('domaine-fill');
    map.moveLayer('domaine-outline');
    
  } catch (err) {
    console.error('載入 domaine geojson 失敗:', err);
    mapError.value = `載入 domaine geojson 失敗: ${err.message}`;
  } finally {
    isLoading.value = false;
  }
};

// default view - 使用 regionConfig 或預設為 Chablis
const DEFAULT_VIEW = computed(() => ({
  center: props.regionConfig?.center || [3.7984, 47.8139],
  zoom: props.regionConfig?.zoom || 11
}))

// list of village-level geojson files to load on startup (per region)
// 對於 Chablis 使用預定義列表，其他區域將自動從 index.json 載入所有村莊級檔案
const initialVillageFiles = computed(() => {
  const filesMap = {
    'chablis': [
      "AOC Chablis.geojson",
      "AOC Petit Chablis.geojson",
      "AOC Chablis Grand Cru.geojson"
    ],
    'cote-de-nuits': 'auto',  // 自動載入所有村莊級檔案
    'cote-de-beaune': 'auto',
    'cote-chalonnaise': 'auto',
    'maconnais': 'auto',
    'beaujolais': [
      "AOC Beaujolais.geojson"
    ]
  }
  return filesMap[props.regionConfig?.id] || []
})

// recursively search index.json structure to find the path for a filename
function findGeojsonPathInIndex(indexObj, filename) {
  const basePath = geojsonBasePath.value
  const regionId = props.regionConfig?.id
  
  console.log('[findGeojsonPathInIndex] 搜尋文件:', filename)
  console.log('[findGeojsonPathInIndex] basePath:', basePath)
  console.log('[findGeojsonPathInIndex] regionId:', regionId)
  
  for (const regionKey of Object.keys(indexObj)) {
    const region = indexObj[regionKey]
    if (region.files && region.files.includes(filename)) {
      // 檔案在村莊資料夾的頂層 files 中
      // 特殊處理：
      // 1. Beaujolais 和 Mâconnais：文件直接在 basePath 下
      // 2. Regional 分組：文件直接在 basePath 下（不在 Regional 子文件夾中）
      if (regionId === 'beaujolais' || regionId === 'maconnais' || regionKey === 'Regional') {
        const path = `${basePath}/${encodeURIComponent(filename)}`
        console.log('[findGeojsonPathInIndex] 特殊路徑 (basePath直接):', path)
        return path
      }
      // 路徑格式: basePath/regionKey/filename
      const path = `${basePath}/${encodeURIComponent(regionKey)}/${encodeURIComponent(filename)}`
      console.log('[findGeojsonPathInIndex] 一般路徑:', path)
      return path
    }
    if (region.subfolders) {
      for (const subKey of Object.keys(region.subfolders)) {
        const sub = region.subfolders[subKey]
        if (sub.files && sub.files.includes(filename)) {
          return `${basePath}/${encodeURIComponent(regionKey)}/${encodeURIComponent(subKey)}/${encodeURIComponent(filename)}`
        }
        // nested subfolders (two levels) - iterate deeper if present
        if (sub.subfolders) {
          for (const nestedKey of Object.keys(sub.subfolders)) {
            const nested = sub.subfolders[nestedKey]
            if (nested.files && nested.files.includes(filename)) {
              return `${basePath}/${encodeURIComponent(regionKey)}/${encodeURIComponent(subKey)}/${encodeURIComponent(nestedKey)}/${encodeURIComponent(filename)}`
            }
          }
        }
      }
    }
  }
  return null
}

async function loadInitialVillageGeojsons() {
  if (!map) return null
  try {
    const idxRes = await fetch(indexJsonPath.value)
    if (!idxRes.ok) throw new Error('無法讀取 geojson index')
    const indexJson = await idxRes.json()

    // 如果是 'auto' 模式，自動收集所有村莊級別的檔案
    let filesToLoad = initialVillageFiles.value
    if (filesToLoad === 'auto') {
      filesToLoad = []
      // 遍歷 index.json 中所有村莊資料夾，收集頂層的 files（不包括 subfolders）
      for (const villageKey of Object.keys(indexJson)) {
        const village = indexJson[villageKey]
        if (village.files && Array.isArray(village.files)) {
          village.files.forEach(f => {
            // 過濾掉會造成重疊的 Brochon.geojson 與 Flagey-Echézeaux.geojson 避免初始顏色加倍
            if (f === 'Brochon.geojson' || f === 'Flagey-Echézeaux.geojson') return;
            filesToLoad.push(f)
          })
        }
        
        // 針對 Flagey-Echézeaux：將其預設為開啟兩個 Grand Cru
        if (villageKey === '07Flagey-Echézeaux') {
          filesToLoad.push('AOC Echezeaux Grand Cru.geojson')
          filesToLoad.push('AOC Grands-Echezeaux Grand Cru.geojson')
        }
      }
      console.log(`自動載入 ${filesToLoad.length} 個村莊級 GeoJSON 檔案`)
    }

    // 保存已載入的檔案列表
    loadedInitialFiles.value = filesToLoad

    const allFeatures = []
    for (const file of filesToLoad) {
      const path = findGeojsonPathInIndex(indexJson, file)
      if (!path) {
        console.warn('index.json 中未找到檔案:', file)
        continue
      }

      try {
        let geojson
        if (geojsonCache.has(path)) {
          geojson = geojsonCache.get(path)
        } else {
          const res = await fetch(path)
          if (!res.ok) {
            // 如果路徑失敗，可能是因為檔案直接在根目錄（如 Mâconnais）
            // 嘗試替代路徑：不帶 regionKey 的路徑
            const alternatePath = `${geojsonBasePath.value}/${encodeURIComponent(file)}`
            console.warn(`Failed to load ${path}, trying alternate: ${alternatePath}`)
            const altRes = await fetch(alternatePath)
            if (!altRes.ok) {
              throw new Error(`載入 ${file} 失敗 (${res.status})`)
            }
            geojson = await altRes.json()
            geojsonCache.set(alternatePath, geojson)
          } else {
            geojson = await res.json()
            geojsonCache.set(path, geojson)
          }
        }

        // add source & layer with unique ids
        const idBase = file.replace(/[^a-z0-9]/gi, '_')
        const srcId = `init_${idBase}`
        const fillId = `init_fill_${idBase}`
        const outlineId = `init_outline_${idBase}`

        if (map.getLayer(fillId)) map.removeLayer(fillId)
        if (map.getLayer(outlineId)) map.removeLayer(outlineId)
        if (map.getSource(srcId)) map.removeSource(srcId)

        map.addSource(srcId, { type: 'geojson', data: geojson })
        map.addLayer({
          id: fillId,
          type: 'fill',
          source: srcId,
          paint: {
            'fill-color': '#ffffff',
            'fill-opacity': geologyVisible.value ? 0 : 0.2
          }
        })
        map.addLayer({
          id: outlineId,
          type: 'line',
          source: srcId,
          paint: { 'line-color': 'white', 'line-width': 1 }
        })

        // collect features for bbox
        if (geojson.type === 'FeatureCollection') {
          allFeatures.push(...geojson.features)
        } else if (geojson.type === 'Feature') {
          allFeatures.push(geojson)
        } else {
          // maybe a geometry
          allFeatures.push({ type: 'Feature', geometry: geojson })
        }

      } catch (err) {
        console.warn('載入初始村莊 geojson 失敗', file, err)
      }
    }

    if (allFeatures.length) {
      const fc = turf.featureCollection(allFeatures)
      const bbox = turf.bbox(fc) // [minX, minY, maxX, maxY]
      resetBounds = bbox
      currentGeojsonBounds.value = bbox
      currentGeojsonClipFeatures.value = allFeatures.filter((feature) => feature?.geometry)
      // fit to combined bbox
      map.fitBounds([[bbox[0], bbox[1]], [bbox[2], bbox[3]]], { padding: 60, duration: 1200 })
      return bbox
    }
  } catch (err) {
    console.error('載入初始村莊列表失敗', err)
  }
  return null
}

function aocColor(groupName) {
  return '#006400' // DarkGreen for Veneto
}

const styleColors = {
  '紅酒': '#8B0000',
  '白酒': '#F0E68C',
  '甜酒': '#FFD700',
  '氣泡酒': '#87CEEB',
  '粉紅酒': '#FFB6C1'
}

const regionInfoContent = ref(null);

watch(
  () => props.regionInfo,
  (newInfo) => {
    if (newInfo && regionInfoContent.value) {
      nextTick(() => {
        regionInfoContent.value.scrollTop = 0;
      });
    }
  },
  { deep: true }
);

const showAOCGeojson = async (groupName, aocFile) => {
  console.log('[showAOCGeojson] 開始載入', { groupName, aocFile })
  if (!map) return
  domaines.value = [];
  activeDomaine.value = null;
  if (map.getLayer('domaine-fill')) map.removeLayer('domaine-fill');
  if (map.getLayer('domaine-outline')) map.removeLayer('domaine-outline');
  if (map.getSource('domaine')) map.removeSource('domaine');

  isLoading.value = true
  mapError.value = null

  try {
    // 先載入 index.json 以正確查找檔案路徑
    const idxRes = await fetch(indexJsonPath.value)
    if (!idxRes.ok) throw new Error('無法讀取 geojson index')
    const indexJson = await idxRes.json()

    // 使用 findGeojsonPathInIndex 函數查找正確的檔案路徑
    const geojsonPath = findGeojsonPathInIndex(indexJson, aocFile)
    
    if (!geojsonPath) {
      throw new Error(`在 index.json 中找不到檔案: ${aocFile}`)
    }

    // Debug log：方便在 console 檢查實際請求的路徑
    console.debug('[showAOCGeojson] 載入 geojson 路徑:', geojsonPath)

    let geojson
    if (geojsonCache.has(geojsonPath)) {
      geojson = geojsonCache.get(geojsonPath)
      console.debug('[showAOCGeojson] 使用緩存的 geojson')
    } else {
      console.debug('[showAOCGeojson] Fetching:', geojsonPath)
      const res = await fetch(geojsonPath)
      if (!res.ok) throw new Error(`無法載入 geojson (${res.status})`)
      geojson = await res.json()
      console.debug('[showAOCGeojson] GeoJSON 已解析:', geojson.type, '特徵數:', geojson.features?.length)
      geojsonCache.set(geojsonPath, geojson)
    }

    // 移除初始村莊圖層（使用已載入的檔案列表）
    if (Array.isArray(loadedInitialFiles.value)) {
      for (const file of loadedInitialFiles.value) {
        const idBase = file.replace(/[^a-z0-9]/gi, '_')
        const fillId = `init_fill_${idBase}`
        const outlineId = `init_outline_${idBase}`
        const srcId = `init_${idBase}`
        if (map.getLayer(fillId)) map.removeLayer(fillId)
        if (map.getLayer(outlineId)) map.removeLayer(outlineId)
        if (map.getSource(srcId)) map.removeSource(srcId)
      }
    }

    if (map.getLayer('aoc-fill')) map.removeLayer('aoc-fill')
    if (map.getLayer('aoc-outline')) map.removeLayer('aoc-outline')
    if (map.getSource('aoc')) map.removeSource('aoc')

    map.addSource('aoc', { type: 'geojson', data: geojson })
    
    // 隨機顏色（不透明），透明度由 fill-opacity 控制
    function getRandomColor() {
      const r = Math.floor(Math.random() * 200);
      const g = Math.floor(Math.random() * 200);
      const b = Math.floor(Math.random() * 200);
      return `rgb(${r},${g},${b})`;
    }
    map.addLayer({
      id: 'aoc-fill',
      type: 'fill',
      source: 'aoc',
      paint: {
        'fill-color': getRandomColor(),
        'fill-opacity': geologyVisible.value ? 0 : 0.2
      }
    })
    map.addLayer({
      id: 'aoc-outline',
      type: 'line',
      source: 'aoc',
      paint: {
        'line-color': '#fff',
        'line-width': 2
      }
    })

    const bbox = turf.bbox(geojson)
    currentGeojsonBounds.value = bbox
    currentGeojsonClipFeatures.value = normalizeGeojsonToFeatures(geojson)
    map.fitBounds(bbox, { padding: 40, duration: 800 })

  } catch (err) {
    console.error('載入 geojson 失敗:', err)
    mapError.value = `載入 geojson 失敗: ${err.message}`
  } finally {
    isLoading.value = false
  }
}

const resetMap = async () => {
  domainesMode.value = false;
  domaines.value = [];
  activeDomaine.value = null;
  if (map.getLayer('domaine-fill')) map.removeLayer('domaine-fill');
  if (map.getLayer('domaine-outline')) map.removeLayer('domaine-outline');
  if (map.getSource('domaine')) map.removeSource('domaine');

  // 移除當前選中的 AOC 圖層
  if (map.getLayer('aoc-fill')) map.removeLayer('aoc-fill')
  if (map.getLayer('aoc-outline')) map.removeLayer('aoc-outline')
  if (map.getSource('aoc')) map.removeSource('aoc')
  currentGeojsonBounds.value = resetBounds

  // 重新載入並顯示初始村莊圖層
  await loadInitialVillageGeojsons()

  // prefer using stored combined bounds from initial village load
  if (map && resetBounds && Array.isArray(resetBounds) && resetBounds.length === 4) {
    try {
      map.fitBounds([[resetBounds[0], resetBounds[1]], [resetBounds[2], resetBounds[3]]], { padding: 60, duration: 800 })
    } catch (err) {
      console.warn('fitBounds 失敗，將回到預設視角', err)
      map.easeTo({ center: DEFAULT_VIEW.value.center, zoom: DEFAULT_VIEW.value.zoom, duration: 800 })
    }
  } else if (map) {
    // fallback: center on typical Cote de Beaune area
    map.easeTo({ center: DEFAULT_VIEW.value.center, zoom: DEFAULT_VIEW.value.zoom, duration: 800 })
  }
  // still emit event for parent components in case they react
  emit('resetMap')
}

const toggle3D = () => {
  is3D.value = !is3D.value
  if (map) {
    if (is3D.value) {
      // 啟用 3D 模式：傾斜視角 + 地形
      map.easeTo({ pitch: 45, duration: 800 })
      
      // 啟用地形（如果 source 已存在）
      if (map.getSource('mapbox-dem')) {
        map.setTerrain({ 
          source: 'mapbox-dem', 
          exaggeration: 1.5  // 地形高度誇張倍數
        })
        
        // 添加天空層
        if (!map.getLayer('sky')) {
          map.addLayer({
            id: 'sky',
            type: 'sky',
            paint: {
              'sky-type': 'atmosphere',
              'sky-atmosphere-sun': [0.0, 90.0],
              'sky-atmosphere-sun-intensity': 15
            }
          })
        }
      }
    } else {
      // 關閉 3D 模式：平面視角 + 移除地形
      map.easeTo({ pitch: 0, duration: 800 })
      
      // 移除地形效果
      map.setTerrain(null)
      
      // 移除天空層
      if (map.getLayer('sky')) {
        map.removeLayer('sky')
      }
    }
  }
}

const toggleContours = () => {
  showContours.value = !showContours.value
  if (map) {
    const visibility = showContours.value ? 'visible' : 'none'
    
    // 切換所有等高線相關圖層的可見性
    if (map.getLayer('contour-lines')) {
      map.setLayoutProperty('contour-lines', 'visibility', visibility)
    }
    if (map.getLayer('contour-lines-bold')) {
      map.setLayoutProperty('contour-lines-bold', 'visibility', visibility)
    }
    if (map.getLayer('contour-labels')) {
      map.setLayoutProperty('contour-labels', 'visibility', visibility)
    }
  }
}

const toggleInfoBar = () => {
  isInfoCollapsed.value = !isInfoCollapsed.value
}

const setMobileAOCListOpen = (visible) => {
  emit('request-aoc-list', visible)
}

const collapseOtherMobileActions = (exceptAction) => {
  if (exceptAction !== 'aoc' && props.mobileAOCListOpen) {
    setMobileAOCListOpen(false)
  }
  if (exceptAction !== 'layer' && showLayerPanel.value) {
    showLayerPanel.value = false
  }
  if (exceptAction !== '3d' && is3D.value) {
    toggle3D()
  }
  if (exceptAction !== 'info' && !isInfoCollapsed.value) {
    toggleInfoBar()
  }
}

const handleMobileAction = (action) => {
  if (!isMobileView.value) return

  if (action === 'aoc') {
    if (props.mobileAOCListOpen) {
      setMobileAOCListOpen(false)
      return
    }
    collapseOtherMobileActions('aoc')
    setMobileAOCListOpen(true)
    return
  }

  if (action === 'layer') {
    if (showLayerPanel.value) {
      showLayerPanel.value = false
      return
    }
    collapseOtherMobileActions('layer')
    showLayerPanel.value = true
    return
  }

  if (action === '3d') {
    if (is3D.value) {
      toggle3D()
      return
    }
    collapseOtherMobileActions('3d')
    toggle3D()
    return
  }

  if (action === 'info') {
    if (!props.activeAOC?.aoc) return
    if (!isInfoCollapsed.value) {
      toggleInfoBar()
      return
    }
    collapseOtherMobileActions('info')
    toggleInfoBar()
  }
}

const geologySourceId = (materialId) => `geology-src-${materialId}`
const geologyFillId = (materialId) => `geology-fill-${materialId}`
const geologyLineId = (materialId) => `geology-line-${materialId}`
const EMPTY_FEATURE_COLLECTION = { type: 'FeatureCollection', features: [] }

const clearGeologyLayers = () => {
  if (!map) return
  for (const materialId of ['clay', 'sand', 'limestone', 'gravel', 'mixed']) {
    const fillId = geologyFillId(materialId)
    const lineId = geologyLineId(materialId)
    const sourceId = geologySourceId(materialId)

    if (map.getLayer(fillId)) map.removeLayer(fillId)
    if (map.getLayer(lineId)) map.removeLayer(lineId)
    if (map.getSource(sourceId)) map.removeSource(sourceId)
  }
}

const loadGeologyIndex = async () => {
  try {
    const res = await fetch('/geojson/geology/index.json')
    if (!res.ok) {
      console.warn('無法載入 geology index，將略過地質面板')
      return
    }

    const data = await res.json()
    geologyIndex.value = data

    if (Array.isArray(data.materials) && data.materials.length > 0 && geologyActiveMaterials.value.length === 0) {
      geologyActiveMaterials.value = ['limestone', 'clay']
    }

    if (Array.isArray(data.materials) && Object.keys(geologyMaterialOpacity.value).length === 0) {
      const opacityMap = {}
      for (const material of data.materials) {
        opacityMap[material.id] = 0.1
      }
      geologyMaterialOpacity.value = opacityMap
    }
  } catch (error) {
    console.warn('讀取 geology index 失敗:', error)
  }
}

const toggleGeologyMaterial = (materialId) => {
  const current = [...geologyActiveMaterials.value]
  const idx = current.indexOf(materialId)
  if (idx >= 0) {
    current.splice(idx, 1)
  } else {
    current.push(materialId)
  }
  geologyActiveMaterials.value = current
}

const bboxIntersects = (a, b) => {
  return !(a[2] < b[0] || a[0] > b[2] || a[3] < b[1] || a[1] > b[3])
}

const getGeojsonBboxFilteredFeatureCollection = (collections) => {
  const clipBbox = currentGeojsonBounds.value
  const clipFeatures = currentGeojsonClipFeatures.value || []
  const features = []

  // 預先計算 clipFeature 的 bbox，大幅加速檢查
  const clipFeatureBboxes = clipFeatures.map(f => {
    try { return turf.bbox(f) } catch (e) { return null }
  })

  for (const collection of collections) {
    const rawFeatures = collection?.features || []
    for (const feature of rawFeatures) {
      try {
        if (!feature?.geometry) continue

        const featureBbox = turf.bbox(feature)

        // 1. 整體邊界框快速過濾
        if (clipBbox && !bboxIntersects(featureBbox, clipBbox)) {
          continue
        }

        // 2. 個別特徵邊界框與幾何精確過濾
        if (clipFeatures.length > 0) {
          const intersectsOpenedGeojson = clipFeatures.some((clipFeature, index) => {
            const cBbox = clipFeatureBboxes[index]
            if (!cBbox || !bboxIntersects(featureBbox, cBbox)) return false
            try {
              // 效能優化：如果是點或線且邊界重疊，作精確檢查
              // 但 booleanIntersects 非常耗能，為避免卡頓故障（五土按鈕無法操作的主因），僅依賴個別特徵 BBox 已足夠精確。
              return true 
            } catch (error) {
              return false
            }
          })

          if (intersectsOpenedGeojson) {
            features.push(feature)
          }
          continue
        }

        features.push(feature)
      } catch (error) {
        // Ignore malformed geometry and continue rendering the rest.
      }
    }
  }

  return {
    type: 'FeatureCollection',
    features
  }
}

const syncGeojsonFillVisibilityWithGeology = () => {
  if (!map) return

  const fillOpacity = geologyVisible.value ? 0 : 0.2

  if (map.getLayer('aoc-fill')) {
    map.setPaintProperty('aoc-fill', 'fill-opacity', fillOpacity)
  }

  if (Array.isArray(loadedInitialFiles.value)) {
    for (const file of loadedInitialFiles.value) {
      const idBase = file.replace(/[^a-z0-9]/gi, '_')
      const fillId = `init_fill_${idBase}`
      if (map.getLayer(fillId)) {
        map.setPaintProperty(fillId, 'fill-opacity', fillOpacity)
      }
    }
  }
}

const refreshGeologyLayers = async () => {
  if (!map || !geologyIndex.value) return

  const selectedProvinceCodes = currentGeologyProvinceCodes.value
  const selectedIds = new Set(geologyActiveMaterials.value)

  for (const material of geologyIndex.value.materials || []) {
    const materialId = material.id
    const sourceId = geologySourceId(materialId)
    const fillId = geologyFillId(materialId)
    const lineId = geologyLineId(materialId)
    const isActive = geologyVisible.value && selectedIds.has(materialId) && selectedProvinceCodes.length > 0

    if (!isActive) {
      if (map.getLayer(fillId)) map.setLayoutProperty(fillId, 'visibility', 'none')
      if (map.getLayer(lineId)) map.setLayoutProperty(lineId, 'visibility', 'none')
      if (map.getSource(sourceId)) {
        map.getSource(sourceId).setData(EMPTY_FEATURE_COLLECTION)
      }
      continue
    }

    const collections = []
    for (const provinceCode of selectedProvinceCodes) {
      const province = geologyIndex.value.provinces?.[provinceCode]
      const layerMeta = province?.layers?.find((layer) => layer.materialId === materialId)
      if (!layerMeta) continue

      try {
        let geojson
        if (geojsonCache.has(layerMeta.url)) {
          geojson = geojsonCache.get(layerMeta.url)
        } else {
          const res = await fetch(layerMeta.url)
          if (!res.ok) {
            console.warn(`載入地質圖層失敗: ${layerMeta.url}`)
            continue
          }
          geojson = await res.json()
          geojsonCache.set(layerMeta.url, geojson)
        }
        collections.push(geojson)
      } catch (error) {
        console.warn('地質圖層渲染失敗:', materialId, provinceCode, error)
      }
    }

    const viewportData = getGeojsonBboxFilteredFeatureCollection(collections)
    const opacity = geologyMaterialOpacity.value[materialId] ?? 0.1

    try {
      if (map.getSource(sourceId)) {
        map.getSource(sourceId).setData(viewportData)
        if (map.getLayer(fillId)) {
          map.setLayoutProperty(fillId, 'visibility', 'visible')
          map.setPaintProperty(fillId, 'fill-opacity', opacity)
        }
        if (map.getLayer(lineId)) {
          map.setLayoutProperty(lineId, 'visibility', 'visible')
          map.setPaintProperty(lineId, 'line-opacity', Math.min(opacity + 0.15, 0.9))
        }
      } else {
        map.addSource(sourceId, { type: 'geojson', data: viewportData })
        map.addLayer({
          id: fillId,
          type: 'fill',
          source: sourceId,
          paint: {
            'fill-color': material.fillColor || '#999999',
            'fill-opacity': opacity
          }
        })
        map.addLayer({
          id: lineId,
          type: 'line',
          source: sourceId,
          paint: {
            'line-color': material.lineColor || '#666666',
            'line-width': 0.4,
            'line-opacity': Math.min(opacity + 0.15, 0.9)
          }
        })
      }
    } catch (error) {
      console.warn('地質圖層更新失敗:', materialId, error)
    }
  }
}

const initMap = async (retry = 0) => {
  try {
    if (!mapContainer.value) {
      if (retry < 5) {
        setTimeout(() => initMap(retry + 1), 200)
      } else {
        mapError.value = '無法獲取地圖容器'
      }
      return
    }
    
    mapboxgl.accessToken = import.meta.env.VITE_MAPBOX_TOKEN
    
    map = new mapboxgl.Map({
      container: mapContainer.value,
      style: 'mapbox://styles/mapbox/satellite-streets-v12',
      // 使用 regionConfig 的預設視角
      center: DEFAULT_VIEW.value.center,
      zoom: DEFAULT_VIEW.value.zoom,
      pitch: is3D.value ? 45 : 0,
      bearing: 0
    })
    
    map.on('load', async () => {
      map.addControl(new mapboxgl.NavigationControl(), 'top-right')
      map.addControl(new mapboxgl.FullscreenControl(), 'top-right')
      
      // 添加 3D 地形 source (Mapbox Terrain DEM v1)
      map.addSource('mapbox-dem', {
        type: 'raster-dem',
        url: 'mapbox://mapbox.mapbox-terrain-dem-v1',
        tileSize: 512,
        maxzoom: 14
      })
      
      // 添加等高線 source (Mapbox Terrain Vector v2)
      map.addSource('contours', {
        type: 'vector',
        url: 'mapbox://mapbox.mapbox-terrain-v2'
      })
      
      // 添加等高線圖層（初始隱藏）
      map.addLayer({
        id: 'contour-lines',
        type: 'line',
        source: 'contours',
        'source-layer': 'contour',
        layout: {
          'line-join': 'round',
          'line-cap': 'round',
          'visibility': 'none'  // 初始隱藏
        },
        paint: {
          'line-color': '#ff6b35',
          'line-width': [
            'interpolate',
            ['linear'],
            ['zoom'],
            10, 0.5,
            14, 1.5
          ],
          'line-opacity': 0.8
        },
        filter: ['==', ['get', 'index'], 1]  // 每10米一條等高線
      })
      
      // 添加粗等高線（每100米）
      map.addLayer({
        id: 'contour-lines-bold',
        type: 'line',
        source: 'contours',
        'source-layer': 'contour',
        layout: {
          'line-join': 'round',
          'line-cap': 'round',
          'visibility': 'none'  // 初始隱藏
        },
        paint: {
          'line-color': '#d62828',
          'line-width': [
            'interpolate',
            ['linear'],
            ['zoom'],
            10, 1,
            14, 2.5
          ],
          'line-opacity': 0.9
        },
        filter: ['==', ['get', 'index'], 5]  // 每50米一條粗等高線
      })
      
      // 添加等高線標籤
      map.addLayer({
        id: 'contour-labels',
        type: 'symbol',
        source: 'contours',
        'source-layer': 'contour',
        layout: {
          'symbol-placement': 'line',
          'text-field': ['concat', ['get', 'ele'], 'm'],
          'text-font': ['DIN Pro Medium', 'Arial Unicode MS Regular'],
          'text-size': 10,
          'text-pitch-alignment': 'viewport',
          'symbol-spacing': 250,  // 增加標籤間距避免過於密集
          'visibility': 'none'  // 初始隱藏
        },
        paint: {
          'text-color': '#d62828',
          'text-halo-color': '#fff',
          'text-halo-width': 1.5
        },
        filter: ['==', ['get', 'index'], 1]  // 每10米顯示標籤
      })
      
      // 如果已經是 3D 模式，立即啟用地形
      if (is3D.value) {
        map.setTerrain({ 
          source: 'mapbox-dem', 
          exaggeration: 1.5  // 地形高度誇張倍數（1.5x）
        })
        
        // 添加天空層增強 3D 效果
        map.addLayer({
          id: 'sky',
          type: 'sky',
          paint: {
            'sky-type': 'atmosphere',
            'sky-atmosphere-sun': [0.0, 90.0],
            'sky-atmosphere-sun-intensity': 15
          }
        })
      }
      
      // load initial village-level geojsons and set reset bounds
      await loadInitialVillageGeojsons()

      // initialize stage-1 geology overlays
      await loadGeologyIndex()
    })
    
    map.on('error', (err) => {
      console.error('地圖錯誤:', err)
      mapError.value = `地圖錯誤: ${err.error?.message || '未知錯誤'}`
    })
    
    mapError.value = null
  } catch (err) {
    console.error('地圖初始化錯誤:', err)
    mapError.value = `初始化錯誤: ${err.message}`
  }
}

watch(() => props.activeAOC, (newAOC, oldAOC) => {
  domainesMode.value = false;
  if (newAOC && newAOC.aoc) {
    if (newAOC.aoc !== oldAOC?.aoc) {
      showAOCGeojson(newAOC.group, newAOC.aoc)
      // regionInfo 由父組件 RegionMap 處理，不在此重複載入
    }
    } else if (map && map.getLayer('aoc-fill')) {
    map.removeLayer('aoc-fill')
    map.removeLayer('aoc-outline')
    map.removeSource('aoc')
    currentGeojsonBounds.value = resetBounds
    // Fly back to default view
    map.flyTo({ center: DEFAULT_VIEW.value.center, zoom: DEFAULT_VIEW.value.zoom })
  }
}, { deep: true })

watch([geologyVisible, currentGeologyProvinceCodes], async () => {
  syncGeojsonFillVisibilityWithGeology()
  await refreshGeologyLayers()
})

watch(currentGeojsonBounds, async () => {
  await refreshGeologyLayers()
})

watch(() => geologyActiveMaterials.value, async () => {
  await refreshGeologyLayers()
}, { deep: true })

watch(() => geologyMaterialOpacity.value, async () => {
  await refreshGeologyLayers()
}, { deep: true })

onMounted(async () => {
  window.addEventListener('resize', checkMobile)
  await nextTick()
  setTimeout(async () => {
    await initMap()
  }, 100)
})

onUnmounted(() => {
  window.removeEventListener('resize', checkMobile)
  clearGeologyLayers()
  if (map) {
    map.remove()
    map = null
  }
})
</script>

<style scoped>
.map-section {
  flex: 1;
  position: relative;
  height: 100%;
  overflow: hidden;
}

.map {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.map-header {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  background: rgba(255, 255, 255, 0.85);
  padding: 16px 20px 12px;
  z-index: 10;
  text-align: center;
  box-shadow: 0 2px 5px rgba(0,0,0,0.1);
  backdrop-filter: blur(8px);
}

.map-header h1 {
  margin: 0;
  font-size: 1.5rem;
  color: #006400; /* DarkGreen for Veneto */
  line-height: 1.4;
}

.map-info-bar {
  position: absolute;
  bottom: 20px;
  left: 20px;
  background: linear-gradient(to bottom, white, #fafafa);
  padding: 0;
  border-radius: 12px;
  max-width: 450px;
  max-height: 60vh;
  box-shadow: 
    0 8px 24px rgba(0, 0, 0, 0.15),
    0 2px 8px rgba(0, 0, 0, 0.1);
  z-index: 10;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  border: 1px solid rgba(0, 0, 0, 0.08);
}

.info-header-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-shrink: 0;
  background: linear-gradient(135deg, #8B0000 0%, #660000 100%);
  color: white;
  padding: 12px 16px;
  border-bottom: 2px solid rgba(255, 255, 255, 0.1);
}

.aoc-info-title {
  display: flex;
  align-items: center;
  font-size: 1.15rem;
  font-weight: 700;
  color: white;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
  min-width: 0;
  flex: 1;
}

.aoc-name {
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  line-height: 1.25;
  max-height: calc(1.25em * 2);
}

.aoc-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  margin-right: 8px;
  flex-shrink: 0;
  border: 2px solid white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.map-buttons {
  display: flex;
  gap: 8px;
}

.map-buttons-right {
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 0;
}

.map-action-buttons {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
}

.map-action-btn {
  width: 40px;
  height: 40px;
  padding: 0;
  border: none;
  border-radius: 12px;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 6px 14px rgba(0, 0, 0, 0.18);
  transition: transform 0.2s ease, box-shadow 0.2s ease, opacity 0.2s ease, background 0.2s ease;
}

.map-action-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 10px 18px rgba(0, 0, 0, 0.22);
}

.map-action-btn:active {
  transform: translateY(0);
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.18);
}

.map-action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  box-shadow: none;
}

.map-action-btn:disabled:hover {
  transform: none;
}

.btn-collapse {
  background: linear-gradient(145deg, #222, #0f0f0f);
}

.btn-audio-compact {
  background: linear-gradient(145deg, #8a63cf, #6b46c1);
}

.btn-reset {
  background: linear-gradient(145deg, #f25f57, #dd3f37);
}

.region-info-content {
  margin-top: 0;
  padding: 0;
  font-size: 0.95rem;
  line-height: 1.6;
  text-align: left;
  background: white;
}

.info-header {
  margin-bottom: 10px;
}

.region-type, .region-hectare {
  font-size: 0.9rem;
  color: #666;
}

.style-badges {
  display: flex;
  gap: 5px;
  flex-wrap: wrap;
  margin-top: 8px;
}

.style-badge {
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: bold;
  display: inline-block;
  text-align: center;
  box-shadow: 0 1px 3px rgba(0,0,0,0.2);
}

.description {
  margin-top: 10px;
  font-size: 0.9rem;
  text-align: left;
}

.details-section {
  margin-top: 15px;
  border-top: 2px solid #f0f0f0;
  padding-top: 15px;
  background: #fafafa;
  padding: 15px;
  border-radius: 8px;
  margin: 15px -16px -16px;
}

.details-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 10px 14px;
  margin-top: 10px;
  font-size: 0.9rem;
}

.detail-item {
  display: contents;
}

.detail-item .detail-label {
  font-weight: 700;
  color: #8B0000;
  grid-column: 1 / 2;
  font-size: 0.88rem;
}

.detail-item .detail-value {
  grid-column: 2 / 3;
  color: #333;
  font-weight: 500;
}

.detail-item.full-width {
  display: block;
  grid-column: 1 / -1;
  margin-top: 8px;
  padding: 10px;
  background: white;
  border-radius: 6px;
  border-left: 3px solid #8B0000;
}

.detail-item .detail-value {
  grid-column: 2 / 3;
}

.detail-item.full-width .detail-label {
  grid-column: 1 / 3;
  margin-bottom: 2px;
}

.detail-item.full-width .detail-value {
  grid-column: 1 / 3;
  padding-left: 8px;
}

.producers-section {
  margin-top: 15px;
  padding-top: 10px;
  background: #fafafa;
  padding: 15px;
  border-radius: 8px;
  margin: 15px -16px 0;
  border-left: 3px solid #8B0000;
}

.wine-types-section {
  margin: 15px -16px 0;
  padding: 15px;
  background: #fafafa;
  border-radius: 8px;
  border-left: 3px solid #8B0000;
}

.wine-types-title {
  font-weight: 700;
  font-size: 1rem;
  color: #8B0000;
  margin-bottom: 10px;
}

.wine-types-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.wine-type-tag {
  background: linear-gradient(145deg, #8B0000, #660000);
  color: #fff;
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 600;
  box-shadow: 
    0 2px 4px rgba(139, 0, 0, 0.3),
    inset 0 1px 0 rgba(255, 255, 255, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.1);
  transition: all 0.2s ease;
}

.wine-type-tag:hover {
  background: linear-gradient(145deg, #a00000, #800000);
  transform: translateY(-1px);
  box-shadow: 0 3px 6px rgba(139, 0, 0, 0.4);
}

.producers-title {
  font-weight: 700;
  font-size: 1rem;
  color: #8B0000;
  margin-bottom: 10px;
}

.producers-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.producer-tag {
  background: linear-gradient(145deg, #ffffff, #f5f5f5);
  color: #333;
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 600;
  box-shadow: 
    0 2px 4px rgba(0, 0, 0, 0.08),
    inset 0 -1px 2px rgba(0, 0, 0, 0.05);
  border: 1px solid #e0e0e0;
  transition: all 0.2s ease;
}

.producer-tag:hover {
  background: linear-gradient(145deg, #f5f5f5, #eeeeee);
  transform: translateY(-1px);
  box-shadow: 0 3px 6px rgba(0, 0, 0, 0.12);
}

.grape-section {
  margin: 15px -16px 0;
  padding: 15px;
  background: #fafafa;
  border-radius: 8px;
  border-left: 3px solid #8B0000;
}

.grape-title {
  font-weight: 700;
  font-size: 1rem;
  color: #8B0000;
  margin-bottom: 12px;
}

.grape-badges {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.grape-badge {
  padding: 6px 14px;
  border-radius: 16px;
  font-size: 0.85rem;
  white-space: nowrap;
  font-weight: 700;
  box-shadow: 
    0 2px 6px rgba(0, 0, 0, 0.12),
    inset 0 1px 0 rgba(255, 255, 255, 0.5);
  border: 2px solid rgba(255, 255, 255, 0.8);
  transition: all 0.2s ease;
}

.grape-badge:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.18);
}

.no-info {
  margin-top: 10px;
  color: #888;
  font-size: 0.9rem;
  font-style: italic;
}

.btn-learning-mode {
  position: absolute;
  top: 80px;
  left: 20px;
  width: 200px;
  height: 48px;
  padding: 0 12px;
  background: linear-gradient(180deg, #4784b4, #33669d);
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  z-index: 100;
  font-weight: 800;
  font-size: 1.15rem;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.25);
  transition: transform 0.18s ease, filter 0.18s ease;
}

.btn-learning-mode:hover {
  filter: brightness(1.05);
  transform: translateY(-1px);
}

.btn-learning-mode:active {
  transform: translateY(0px);
}


.btn-learning-mode .learning-icon {
  display: none;
}

.btn-learning-mode .learning-text {
  display: inline;
}


.btn-learning-mode .learning-icon {
  display: none;
}

.btn-learning-mode .learning-text {
  display: inline;
}

.btn-3d {


  position: absolute;
  top: 136px;
  left: 20px;
  width: 200px;
  height: 48px;
  padding: 0 12px;
  background: linear-gradient(180deg, #5ebc5e, #47b457);
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  z-index: 100;
  font-weight: 800;
  font-size: 1.15rem;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.25);
  transition: transform 0.18s ease, filter 0.18s ease;
}

.btn-3d:hover {
  filter: brightness(1.05);
  transform: translateY(-1px);
}

.btn-3d:active {
  transform: translateY(0px);
}

.btn-contours {
  position: absolute;
  top: 192px;
  left: 20px;
  width: 200px;
  height: 48px;
  padding: 0 12px;
  background: linear-gradient(180deg, #9d33b5, #88279d);
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  z-index: 100;
  font-weight: 800;
  font-size: 1.15rem;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.25);
  transition: transform 0.18s ease, filter 0.18s ease;
}

.btn-contours:hover {
  filter: brightness(1.05);
  transform: translateY(-1px);
}

.btn-contours:active {
  transform: translateY(0px);
}

.geology-panel {
  position: absolute;
  top: 248px;
  left: 20px;
  width: 200px;
  background: transparent;
  border-radius: 0;
  box-shadow: none;
  z-index: 100;
  padding: 0;
  backdrop-filter: none;
  border: none;
}

.geology-visibility-btn {
  width: 100%;
  border: none;
  border-radius: 6px;
  background: linear-gradient(180deg, #8a6754, #755544);
  color: #fff;
  height: 48px;
  padding: 0 10px;
  font-size: 1.15rem;
  font-weight: 800;
  margin-bottom: 8px;
  cursor: pointer;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.25);
  transition: transform 0.18s ease, filter 0.18s ease;
}

.geology-visibility-btn:hover {
  filter: brightness(1.05);
  transform: translateY(-1px);
}

.geology-visibility-btn:active {
  transform: translateY(0px);
}

.geology-visibility-btn.active {
  background: linear-gradient(180deg, #8a6754, #755544);
  /* border-color removed since we match the image */
}

.controls-wide {
  width: 248px;
}

.geology-materials {
  display: flex;
  flex-direction: column;
  gap: 8px;
  max-height: none;
  overflow-y: visible;
}

.geology-material-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

.geology-material-toggle {
  flex: 0 0 108px;
  display: flex;
  align-items: center;
  gap: 6px;
  border: 1px solid rgba(31, 60, 95, 0.2);
  border-radius: 6px;
  background: rgba(255, 255, 255, 0.94);
  color: #1c2430;
  font-size: 0.9rem;
  font-weight: 700;
  padding: 10px 12px;
  cursor: pointer;
  white-space: nowrap;
}

.geology-material-toggle.active {
  box-shadow: inset 0 0 0 2px rgba(28, 138, 255, 0.95);
}

.geology-slider-wrap {
  flex: 1;
  min-width: 0;
  display: flex;
  align-items: center;
  gap: 10px;
  background: rgba(255, 255, 255, 0.14);
  border-radius: 6px;
  padding: 10px 12px;
  color: #fff;
  font-size: 0.9rem;
  font-weight: 700;
}

.geology-slider-wrap input[type='range'] {
  flex: 1;
  min-width: 0;
}

.material-dot {
  width: 9px;
  height: 9px;
  border-radius: 50%;
  border: 1px solid rgba(0, 0, 0, 0.22);
}

.loading-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 20;
}

.loading-spinner {
  width: 50px;
  height: 50px;
  border: 5px solid #f3f3f3;
  border-top: 5px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.map-error {
  position: absolute;
  top: 70px;
  left: 50%;
  transform: translateX(-50%);
  background: #f44336;
  color: white;
  padding: 10px 20px;
  border-radius: 4px;
  z-index: 30;
  max-width: 80%;
  text-align: center;
}

.btn-show-domaines {
  padding: 6px 12px;
  background: #4CAF50;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.8rem;
}

.btn-show-domaines:hover {
  background: #388E3C;
}

.domaines-list-container {
  margin-top: 0;
  padding-right: 0;
}

.domaines-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.domaines-list li {
  padding: 8px;
  cursor: pointer;
  border-bottom: 1px solid #eee;
  font-size: 0.9rem;
}

.domaines-list li:hover {
  background-color: #f0f0f0;
}

.domaines-list li.active {
  background-color: #d0e0d0;
  font-weight: bold;
}

.domaine-info {
  margin-top: 15px;
  padding: 12px;
  background-color: #f8f9fa;
  border-radius: 6px;
  border: 1px solid #e9ecef;
}

.domaine-info-header h4 {
  margin: 0 0 10px 0;
  color: #2c5530;
  font-size: 1rem;
  font-weight: bold;
}

.domaine-details {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 8px 12px;
  font-size: 0.85rem;
}

.domaine-detail-item {
  display: contents;
}

.domaine-detail-item .detail-label {
  font-weight: bold;
  color: #555;
  grid-column: 1 / 2;
}

.domaine-detail-item .detail-value {
  grid-column: 2 / 3;
  color: #333;
}

.domaine-detail-item.full-width .detail-label {
  grid-column: 1 / 3;
  margin-bottom: 4px;
}

.domaine-detail-item.full-width .detail-value {
  grid-column: 1 / 3;
  padding-left: 8px;
}

.domaine-description {
  line-height: 1.4;
  font-style: italic;
}

.pronunciation-section {
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 2px solid #e9ecef;
}

.btn-pronunciation {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 20px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 500;
  transition: all 0.3s ease;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.btn-pronunciation:hover:not(:disabled) {
  background: linear-gradient(135deg, #5568d3 0%, #6a3f8f 100%);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
  transform: translateY(-1px);
}

.btn-pronunciation:active:not(:disabled) {
  transform: translateY(0);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.btn-pronunciation:disabled {
  opacity: 0.7;
  cursor: not-allowed;
}

.btn-pronunciation svg {
  flex-shrink: 0;
}

@media (max-width: 4096px) {
  .map-header {
    position: fixed;
    background: none;
    border: none;
    pointer-events: none;
    padding-top: 25px;
    z-index: 1000;
  }
  .map-header h1 {
    font-size: 1.16rem;
    color: #5b1d1d;
    text-shadow: 0 1px 4px rgba(255,255,255, 0.9), 0 0 10px rgba(255,255,255, 0.9), 0 0 15px rgba(255,255,255, 0.9);
    pointer-events: auto;
  }

  .btn-learning-mode {
    position: fixed !important;
    top: 45%;
    left: 10px;
    width: 56px;
    height: 56px;
    border-radius: 50%;
    padding: 0;
    background: #4CAF50; /* Green */
    color: #111;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 4px 12px rgba(0,0,0,0.3);
  }
  .btn-learning-mode .learning-icon {
    display: block;
    color: #111;
  }
  .btn-learning-mode .learning-text {
    display: none;
  }

  .btn-3d, .btn-contours {
    display: none; /* Map tools moved to panels */
  }

  .desktop-only-buttons {
    display: none !important;
  }

  .info-header-bar {
    background: white;
    color: #333;
    padding: 9px 10px;
    border-bottom: none;
    border-radius: 20px 20px 0 0;
  }

  .aoc-info-title {
    color: #333;
    font-weight: 600;
    min-width: 0;
    margin-right: 8px;
  }

  .aoc-name {
    font-size: 0.92rem;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    text-overflow: ellipsis;
    white-space: normal;
    line-height: 1.2;
    max-height: calc(1.2em * 2);
  }

  .map-buttons-right {
    gap: 6px;
  }

  .map-action-buttons {
    gap: 5px;
  }

  .map-action-btn {
    width: 36px;
    height: 36px;
    border-radius: 11px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.14);
  }

  .btn-collapse {
    background: #111 !important;
    color: white !important;
    width: 36px;
    height: 36px;
  }

  .btn-audio-compact {
    background: #764ba2 !important;
    color: white !important;
    width: 36px;
    height: 36px;
    min-height: 36px;
  }

  .map-info-bar {
    position: fixed !important;
    bottom: 96px !important;
    left: 5px !important;
    right: auto !important;
    width: calc(100vw - 10px) !important;
    max-width: calc(100vw - 10px) !important;
    transform: none !important;
    margin: 0;
    border-radius: 20px 20px 0 0 !important;
    box-shadow: 0 -4px 15px rgba(0,0,0,0.1) !important;
    border-bottom: 1px solid #f0f0f0;
    z-index: 1001;
  }

  .mobile-grid-buttons {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 6px;
    align-items: center;
    position: fixed;
    bottom: 12px;
    left: 5px;
    right: 5px;
    background: white;
    padding: 9px 8px;
    border-radius: 16px;
    box-shadow: 0 4px 15px rgba(0,0,0,0.15);
    z-index: 1000;
  }
  .mobile-grid-buttons.merged-with-info {
    bottom: 12px;
    border-top-left-radius: 0;
    border-top-right-radius: 0;
    box-shadow: 0 8px 15px rgba(0,0,0,0.15);
    padding-top: 4px; /* Move slightly closer to the top piece */
  }

  .m-grid-btn {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    background: #FAEFEC;
    border-radius: 12px;
    border: none;
    padding: 8px 0;
    gap: 4px;
    color: #6D4C41;
    transition: all 0.2s;
  }
  .m-grid-btn.active {
    background: white;
    color: #8B0000;
    box-shadow: inset 0 0 0 1px #8B0000;
  }
  .m-grid-icon {
    font-size: 1rem;
    font-weight: bold;
    display: flex;
    align-items: center;
    justify-content: center;
    background: none !important;
  }
  .m-grid-btn.active .m-grid-icon {
    background: none !important;
    color: #8B0000;
  }
  .m-grid-text {
    font-size: 0.7rem;
    font-weight: bold;
  }

  .mobile-layer-panel {
    position: fixed;
    bottom: 142px;
    left: 5px;
    background: white;
    padding: 14px;
    border-radius: 14px;
    box-shadow: 0 4px 16px rgba(0,0,0,0.2);
    z-index: 1003;
    width: calc(100vw - 10px);
    max-width: calc(100vw - 10px);
    transform: none;
    overflow: visible;
  }

  .layer-panel-header {
    display: flex;
    justify-content: flex-start;
    align-items: center;
    margin-bottom: 12px;
  }
  .layer-panel-header h4 {
    margin: 0;
    font-size: 0.92rem;
    color: #333;
  }
  .layer-toggle-btn {
    width: 100%;
    padding: 9px;
    margin-bottom: 8px;
    border-radius: 6px;
    border: 1px solid #ddd;
    background: #f8f8f8;
    color: #333;
    font-weight: 700;
    font-size: 0.9rem;
    cursor: pointer;
  }
  .layer-toggle-btn.active {
    background: #800020;
    color: white;
    border-color: #800020;
  }

  .btn-reset {
    background: rgba(244, 67, 54, 0.9);
    color: white;
    height: 34px;
    width: 34px;
    min-width: 34px;
    border-radius: 9px;
  }
  .btn-reset:hover {
    background: rgba(229, 57, 53, 0.95);
    transform: scale(1.05);
  }

}

@media (min-width: 1024px) {
  .mobile-grid-buttons,
  .mobile-layer-panel,
  .map-info-bar {
    width: min(52vw, 760px) !important;
    max-width: min(52vw, 760px) !important;
    left: 50% !important;
    right: auto !important;
    transform: translateX(-50%) !important;
  }
}

@media (min-width: 769px) and (max-width: 1366px) and (pointer: fine) {
  /* 平板僅隱藏次要桌機按鈕，其餘地圖控制保留顯示 */
  .desktop-only-buttons {
    display: none !important;
  }

  .map-info-bar {
    left: 50% !important;
    right: auto !important;
    bottom: 24px;
    width: min(52vw, 760px) !important;
    max-width: min(52vw, 760px) !important;
    transform: translateX(-50%) !important;
  }

  .info-header-bar {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    padding: 10px 14px;
  }

  .aoc-info-title {
    display: flex;
    align-items: flex-start;
    min-width: 0;
    flex: 1;
    margin-right: 10px;
  }

  .aoc-name {
    font-size: 1rem;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    text-overflow: ellipsis;
    white-space: normal;
    line-height: 1.25;
    max-height: calc(1.25em * 2);
  }

  .map-buttons-right {
    display: flex;
    align-items: center;
    flex-shrink: 0;
    gap: 8px;
  }

  .map-action-buttons {
    display: flex;
    flex-direction: row;
    align-items: center;
    flex-shrink: 0;
    gap: 8px;
  }

  .map-action-btn {
    width: 38px;
    height: 38px;
  }
}

/* 收合狀態樣式 */
.map-info-bar.collapsed {
  max-height: 78px;
}

.map-info-bar.collapsed .info-header-bar {
  border-bottom: none;
}

.map-info-bar.collapsed .aoc-info-title {
  padding-right: 4px;
}

@media (max-width: 4096px) {
  .map-info-bar.collapsed {
    bottom: 104px !important;
    z-index: 1002;
  }
}

/* 資訊內容包裹器 */
.info-content-wrapper {
  overflow-y: auto;
  overflow-x: hidden;
  flex: 1;
  padding: 16px;
}

/* 展開收合動畫 */
.info-expand-enter-active {
  animation: expand 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.info-expand-leave-active {
  animation: collapse 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes expand {
  from {
    max-height: 0;
    opacity: 0;
  }
  to {
    max-height: 60vh;
    opacity: 1;
  }
}

@keyframes collapse {
  from {
    max-height: 60vh;
    opacity: 1;
  }
  to {
    max-height: 0;
    opacity: 0;
  }
}
</style>