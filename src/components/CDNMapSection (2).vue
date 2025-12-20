<template>
  <section class="map-section">
    <div class="map-header">
      <h1>Cote de Nuits 葡萄酒產區地圖</h1>
    </div>
    <div class="map-info-bar" v-if="activeAOC.aoc">
      <div class="info-header-bar">
        <span class="aoc-info-title">
          <span class="aoc-dot" :style="{background: aocColor(activeAOC.group)}"></span>
          {{ activeDomaine ? activeDomaine.replace('.geojson', '') : activeAOC.aoc.replace('.geojson','').replace(/_/g,' ') }}
        </span>
        <div class="map-buttons">
          <button v-if="showDomaineButton" class="btn-show-domaines" @click="toggleDomainesMode">
            {{ domainesMode ? '回上一層' : '顯示酒莊' }}
          </button>
          <button class="btn-reset" @click="resetMap">重置地圖</button>
        </div>
      </div>
      
      <div v-if="domainesMode" class="domaines-list-container">
        <div v-if="currentDomaineImage" class="domaine-image-container" style="margin-bottom: 12px; text-align: center;">
          <img :src="currentDomaineImage" alt="Domaine Image" @error="onDomaineImageError" style="max-width: 100%; height: auto; border-radius: 4px; max-height: 150px; object-fit: cover;">
        </div>
        <ul class="domaines-list">
          <li v-for="domaine in domaines" :key="domaine" @click="loadDomaineLayer(domaine)" :class="{ active: activeDomaine === domaine }">
            {{ domaine.replace('.geojson', '').replace(/^\d+\s*/, '') }}
          </li>
        </ul>
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
            <div v-if="regionInfo.soil" class="detail-item full-width">
              <span class="detail-label">土壤:</span>
              <span class="detail-value">{{ regionInfo.soil }}</span>
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

          <div v-if="regionInfo.grapes && regionInfo.grapes.length" class="grape-section">
            <div class="grape-title">主要葡萄品種:</div>
            <div class="grape-badges">
              <div v-for="grape in regionInfo.grapes" :key="grape" class="grape-badge" :style="grapeBadgeStyle(grape)">
                {{ grape }}
              </div>
            </div>
          </div>

          <div v-if="regionInfo.producers && regionInfo.producers.length" class="producers-section">
            <div class="producers-title">代表生產者:</div>
            <div class="producers-list">
              <span v-for="producer in regionInfo.producers" :key="producer" class="producer-tag">
                {{ producer }}
              </span>
            </div>
          </div>
        </div>
      </div>
      <div v-else class="no-info">無詳細產區資料</div>
    </div>
    <div ref="mapContainer" class="map"></div>
    <button class="btn-3d" @click="toggle3D">
      {{ is3D ? '2D' : '3D' }}
    </button>
    <div v-if="mapError" class="map-error">
      {{ mapError }}
    </div>
    <div v-if="isLoading" class="loading-overlay">
      <div class="loading-spinner"></div>
    </div>
  </section>
</template>

<script setup>
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
})

const emit = defineEmits(['resetMap', 'clear-region-info', 'reselect-aoc'])

const isLoading = ref(false)
const mapError = ref(null)
const mapContainer = ref(null)
let map = null
const is3D = ref(false)
const geojsonCache = new Map()
let resetBounds = null // stored bbox [minX,minY,maxX,maxY] for reset
const domaines = ref([])
const activeDomaine = ref(null)
const domainesMode = ref(false)
// 圖片候補索引（用於 jpg/png fallback）
const imageIndex = ref(0)

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

  // Helper: 編號優先，再完整檔名；支援多個 basePath 與 jpg/png
  const pushCandidates = (...bases) => {
    for (const base of bases) {
      if (number) {
        candidates.push(`${base}${number}.jpg`, `${base}${number}.png`)
      }
      candidates.push(`${base}${fileBaseName}.jpg`, `${base}${fileBaseName}.png`)
    }
  }

  if (props.activeAOC.aoc === chambertinGrandCruName) {
    pushCandidates('/images/04Gevrey Chambertin/Chambertin Grand Cru/', '/04Gevrey Chambertin/Chambertin Grand Cru/')
  } else if (props.activeAOC.aoc === lesAmoureusesName) {
    pushCandidates('/images/06Chambolle Musigny/Chambolle-Musigny 1er Cru Les Amoureuses/', '/06Chambolle Musigny/Chambolle-Musigny 1er Cru Les Amoureuses/')
  } else if (props.activeAOC.aoc === richebourgGrandCruName) {
    pushCandidates('/images/08Vosne-Romanée/Richebourg Grand Cru/', '/08Vosne-Romanée/Richebourg Grand Cru/')
  } else if (props.activeAOC.aoc === lesSuchotsName) {
    pushCandidates('/images/08Vosne-Romanée/Vosne-Romanée 1er Cru Les Suchots/', '/08Vosne-Romanée/Vosne-Romanée 1er Cru Les Suchots/')
  } else if (props.activeAOC.aoc === grandsEchezeauxName) {
    pushCandidates('/images/07Flagey-Echézeaux/Grands-Echezeaux Grand Cru/', '/07Flagey-Echézeaux/Grands-Echezeaux Grand Cru/')
  } else if (props.activeAOC.aoc === lesVaucrainsName) {
    pushCandidates('/images/10Nuits-Saint-Georges/Nuits-Saint-Georges 1er Cru Les Vaucrains/', '/10Nuits-Saint-Georges/Nuits-Saint-Georges 1er Cru Les Vaucrains/')
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

// 切換 AOC 或酒莊時，重置圖片候補索引
watch([() => props.activeAOC?.aoc, activeDomaine], () => {
  imageIndex.value = 0
})

const chambertinGrandCruName = 'AOC Chambertin Grand Cru.geojson';
const lesAmoureusesName = "AOC Chambolle-Musigny 1er Cru Les Amoureuses.geojson";
const richebourgGrandCruName = 'AOC Richebourg Grand Cru.geojson';
const lesSuchotsName = 'AOC Vosne-Romanée 1er Cru Les Suchots.geojson';
const lesVaucrainsName = 'AOC Nuits-Saint-Georges 1er Cru Les Vaucrains.geojson';
const grandsEchezeauxName = 'AOC Grands-Echezeaux Grand Cru.geojson';

const showDomaineButton = computed(() => {
  return [
    chambertinGrandCruName,
    lesAmoureusesName,
    richebourgGrandCruName,
    lesSuchotsName,
    lesVaucrainsName,
    grandsEchezeauxName
  ].includes(props.activeAOC.aoc);
});

const chambertinDomaines = [
  "01 Domaine Armand Rousseau.geojson",
  "02 Domaine Trapet.geojson",
  "03 Domaine Camus.geojson",
  "04 Domaine Rossignol-Trapet.geojson",
  "05 Domaine Jacques Prieur.geojson",
  "06 Maison Louis Latour.geojson",
  "07 Domaine Leroy.geojson",
  "08 Domaine Damoy.geojson",
  "09 Domaine Rebourseau.geojson",
  "10 Domaine Tortochot.geojson",
  "11 Maison Albert Bichot.geojson",
  "12 Domaine Feuillet-Duband.geojson",
  "13 Domaine Charlopin.geojson",
  "14 Domaine Bertagna.geojson",
  "15 Maison Bouchard Père et Fils.geojson",
  "16 Domaine Ponsot.geojson",
  "17 Domaine Denis Mortet.geojson",
  "18 Château de Marsannay.geojson",
  "19 Domaine Dugat-Py.geojson",
];

const lesAmoureusesDomaines = [
  "01Domaine Bertagna.geojson",
  "02Domaine de Vogué.geojson",
  "03Domaine Georges Roumier.geojson",
  "04Domaine Robert Groffier.geojson",
  "05Jacques-Frédéric Mugnier.geojson",
  "06Domaine Gérard Peiraizeau.geojson",
  "07Domaine de la Pousse d'Or.geojson",
  "08Domaine Amiot-Servelle.geojson",
  "09Domaine François Bertheau.geojson",
  "10Domaine Chazans.geojson",
  "11Domaine Louis Jadot.kmz.geojson",
  "12Joseph Drouhin.geojson",
  "13Domaine Michèle et Patrice Rion.geojson",
  "14Domaine Bernard Serveau.geojson"
];

const lesSuchotsDomaines = [
  "01Domaine Confuron-Cotetidot.geojson",
  "02Domaine Michel Noellat.geojson",
  "03Domaine Prieuré-Roch.geojson",
  "04Domaine René Cacheux et Fils.geojson",
  "05Domaine de l'Arlot.geojson",
  "06Domaine Arnoux-Lachaux.geojson",
  "07Domaine François Lamarche.geojson",
  "08Domaine Hudelot-Noellat.geojson",
  "09Domaine Chantal Lescure.geojson",
  "10Domaine Michel Joannet.geojson",
  "11Domaine Gérard Mugneret.geojson",
  "12Domaine Jérôme Chezeaux.geojson",
  "13Domaine Yves Chevallier.geojson",
  "14Domaine Jean-Marc Millot.geojson",
  "15Domaine du Clos des Poulettes.geojson",
  "16Domaine Mongeard-Mugneret.geojson",
  "17Comte Liger-Belair.geojson",
  "18Domaine Berthaut-Gerbet.geojson",
  "19Domaine de Bellene.geojson",
  "20Domaine Jean Grivot.geojson",
  "21Domaine Sylvain Cathiard et Fils..geojson",
  "22Domaine Richard Maniere.geojson",
  "23Domaine Boigey Frères.geojson",
];

const lesVaucrainsDomaines = [
  "01Domaine Alain Michelot.geojson",
  "02 Domaine Robert Chevillon.geojson",
  "03 Domaine Jean Chauvenet.geojson",
  "04 Domaine de la Poulette.geojson",
  "05 Domaine Christian Confuron.geojson",
  "06 Domaine Jérôme Chezeaux.geojson",
  "07 Domaine Chicotot.geojson",
  "08 Domaine Gouges.geojson",
  "09 Domaine Dupasquier.geojson",
  "10 Domaine Ambroise.geojson",
];

const grandsEchezeauxDomaines = [
  "01 Domaine de la Romanée Conti.geojson",
  "02 Domaine Mongeard-Mugneret.geojson",
  "03 Maison Joseph Drouhin.geojson",
  "04 Maison Henri de Villamont.geojson",
  "05 Domaine François Lamarche.geojson",
  "06 Maison Albert Bichot.geojson",
  "07 Domaine d'Eugénie.geojson",
  "08 Domaine Ghislain Kohut.geojson",
  "09 Domaine Desaunay.geojson",
  "10 Domaine Gros Frere et Sour.geojson",
  "11 Dom. Coquard-Loison-Fleurot.geojson",
  "12 Domaine Robert Sirugue.geojson",
  "13 Domaine Georges Noellat.geojson",
  "14 Domaine Jean-Marc Millot.geojson",
];

const richebourgDomaines = [
  "01 Domaine de la Romanée-Conti.geojson",
  "02 Domaine Leroy.geojson",
  "03 Domaine Gros Frères et soeur.geojson",
  "04Domaine A.-F. Gros.geojson",
  "05 Anne Gros .geojson",
  "06 Thibault Liger-Belair .geojson",
  "07Domaine Méo-Camuzet.geojson",
  "08 Domaine Jean Grivot.geojson",
  "09 Domaine Mongeard-Mugneret.geojson",
  "10 Domaine Hudelot-Noëllat.geojson",
  "11 Domaine du Clos Frantin.geojson"
];

const toggleDomainesMode = () => {
  domainesMode.value = !domainesMode.value;
  if (domainesMode.value) {
    emit('clear-region-info');
    if (props.activeAOC.aoc === chambertinGrandCruName) {
      domaines.value = chambertinDomaines;
    } else if (props.activeAOC.aoc === lesAmoureusesName) {
      domaines.value = lesAmoureusesDomaines;
    } else if (props.activeAOC.aoc === richebourgGrandCruName) {
      domaines.value = richebourgDomaines;
    } else if (props.activeAOC.aoc === lesSuchotsName) {
      domaines.value = lesSuchotsDomaines;
    } else if (props.activeAOC.aoc === lesVaucrainsName) {
      domaines.value = lesVaucrainsDomaines;
    } else if (props.activeAOC.aoc === grandsEchezeauxName) {
      domaines.value = grandsEchezeauxDomaines;
    }
  } else {
    domaines.value = [];
    activeDomaine.value = null;
    if (map.getLayer('domaine-fill')) map.removeLayer('domaine-fill');
    if (map.getLayer('domaine-outline')) map.removeLayer('domaine-outline');
    if (map.getSource('domaine')) map.removeSource('domaine');
    emit('reselect-aoc', props.activeAOC);
  }
};

const loadDomaineLayer = async (domaineFile) => {
  if (!map) return;
  activeDomaine.value = domaineFile;

  let geojsonPath;
  if (props.activeAOC.aoc === chambertinGrandCruName) {
    geojsonPath = `/geojson/04Gevrey Chambertin/Grand Crus/Chambertin Grand Cru/${encodeURIComponent(domaineFile)}`;
  } else if (props.activeAOC.aoc === lesAmoureusesName) {
    geojsonPath = `/geojson/06Chambolle Musigny/1er Crus/Chambolle-Musigny 1er Cru Les Amoureuses/${encodeURIComponent(domaineFile)}`;
  } else if (props.activeAOC.aoc === richebourgGrandCruName) {
    geojsonPath = `/geojson/08Vosne-Romanée/Grand Crus/Richebourg Grand Cru/${encodeURIComponent(domaineFile)}`;
  } else if (props.activeAOC.aoc === lesSuchotsName) {
    geojsonPath = `/geojson/08Vosne-Romanée/1er Crus/Vosne-Romanée 1er Cru Les Suchots/${encodeURIComponent(domaineFile)}`;
  } else if (props.activeAOC.aoc === lesVaucrainsName) {
    geojsonPath = `/geojson/10Nuits-Saint-Georges/1er Crus/Nuits-Saint-Georges 1er Cru Les Vaucrains/${encodeURIComponent(domaineFile)}`;
  } else if (props.activeAOC.aoc === grandsEchezeauxName) {
    geojsonPath = `/geojson/07Flagey-Echézeaux/Grand Crus/Grands-Echezeaux Grand Cru/${encodeURIComponent(domaineFile)}`;
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
        'fill-opacity': 0.5
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

// default view for Côte de Nuits (tweak these values to match screenshot)
const DEFAULT_VIEW = {
  // adjusted to better match provided screenshot (slightly more south and closer zoom)
  center: [4.95, 47.095],
  zoom: 12.2
}

// list of village-level geojson files to load on startup
const initialVillageFiles = [
  "AOC Marsannay (Chenôve).geojson",
  "AOC Marsannay (Couchey).geojson",
  "AOC Marsannay (Marsannay-la-côte).geojson",
  "Brochon.geojson",
  "AOC Fixin (Fixin).geojson",
  "AOC Gevrey-Chambertin (Gevrey-Chambertin).geojson",
  "AOC Chambolle-Musigny.geojson",
  "AOC Morey-Saint-Denis.geojson",
  "AOC Vosne-Romanée.geojson",
  "Flagey-Echézeaux.geojson",
  "AOC Vougeot.geojson",
  "AOC Nuits-Saint-Georges.geojson"
]

// recursively search index.json structure to find the path for a filename
function findGeojsonPathInIndex(indexObj, filename) {
  for (const regionKey of Object.keys(indexObj)) {
    const region = indexObj[regionKey]
    if (region.files && region.files.includes(filename)) {
      return `/geojson/${encodeURIComponent(regionKey)}/${encodeURIComponent(filename)}`
    }
    if (region.subfolders) {
      for (const subKey of Object.keys(region.subfolders)) {
        const sub = region.subfolders[subKey]
        if (sub.files && sub.files.includes(filename)) {
          return `/geojson/${encodeURIComponent(regionKey)}/${encodeURIComponent(subKey)}/${encodeURIComponent(filename)}`
        }
        // nested subfolders (two levels) - iterate deeper if present
        if (sub.subfolders) {
          for (const nestedKey of Object.keys(sub.subfolders)) {
            const nested = sub.subfolders[nestedKey]
            if (nested.files && nested.files.includes(filename)) {
              return `/geojson/${encodeURIComponent(regionKey)}/${encodeURIComponent(subKey)}/${encodeURIComponent(nestedKey)}/${encodeURIComponent(filename)}`
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
    const idxRes = await fetch('/geojson/index.json')
    if (!idxRes.ok) throw new Error('無法讀取 geojson index')
    const indexJson = await idxRes.json()

    const allFeatures = []
    for (const file of initialVillageFiles) {
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
          if (!res.ok) throw new Error(`載入 ${file} 失敗 (${res.status})`)
          geojson = await res.json()
          geojsonCache.set(path, geojson)
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
          paint: { 'fill-color': 'rgba(255, 255, 255, 0.2)' }
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
  if (!map) return
  domaines.value = [];
  activeDomaine.value = null;
  if (map.getLayer('domaine-fill')) map.removeLayer('domaine-fill');
  if (map.getLayer('domaine-outline')) map.removeLayer('domaine-outline');
  if (map.getSource('domaine')) map.removeSource('domaine');


  // 正確地對每個 path segment 編碼（避免把 '/' 編碼成 %2F）
  const encodedGroupPath = groupName
    .split('/')
    .map(segment => encodeURIComponent(segment))
    .join('/')

  const encodedAocFile = encodeURIComponent(aocFile)
  const geojsonPath = `/geojson/${encodedGroupPath}/${encodedAocFile}`

  // Debug log：方便在 console 檢查實際請求的路徑
  console.debug('載入 geojson 路徑:', geojsonPath)

  isLoading.value = true
  mapError.value = null

  try {
    let geojson
    if (geojsonCache.has(geojsonPath)) {
      geojson = geojsonCache.get(geojsonPath)
    } else {
      const res = await fetch(geojsonPath)
      if (!res.ok) throw new Error(`無法載入 geojson (${res.status})`)
      geojson = await res.json()
      geojsonCache.set(geojsonPath, geojson)
    }

    // 移除初始村莊圖層
    for (const file of initialVillageFiles) {
      const idBase = file.replace(/[^a-z0-9]/gi, '_')
      const fillId = `init_fill_${idBase}`
      const outlineId = `init_outline_${idBase}`
      const srcId = `init_${idBase}`
      if (map.getLayer(fillId)) map.removeLayer(fillId)
      if (map.getLayer(outlineId)) map.removeLayer(outlineId)
      if (map.getSource(srcId)) map.removeSource(srcId)
    }

    if (map.getLayer('aoc-fill')) map.removeLayer('aoc-fill')
    if (map.getLayer('aoc-outline')) map.removeLayer('aoc-outline')
    if (map.getSource('aoc')) map.removeSource('aoc')

    map.addSource('aoc', { type: 'geojson', data: geojson })
    
    // 隨機顏色 + 透明度 0.2
    function getRandomColor() {
      const r = Math.floor(Math.random() * 200);
      const g = Math.floor(Math.random() * 200);
      const b = Math.floor(Math.random() * 200);
      return `rgba(${r},${g},${b},0.2)`;
    }
    map.addLayer({
      id: 'aoc-fill',
      type: 'fill',
      source: 'aoc',
      paint: {
        'fill-color': getRandomColor(),
        'fill-opacity': 1
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

  // 重新載入並顯示初始村莊圖層
  await loadInitialVillageGeojsons()

  // prefer using stored combined bounds from initial village load
  if (map && resetBounds && Array.isArray(resetBounds) && resetBounds.length === 4) {
    try {
      map.fitBounds([[resetBounds[0], resetBounds[1]], [resetBounds[2], resetBounds[3]]], { padding: 60, duration: 800 })
    } catch (err) {
      console.warn('fitBounds 失敗，將回到預設視角', err)
      map.easeTo({ center: DEFAULT_VIEW.center, zoom: DEFAULT_VIEW.zoom, duration: 800 })
    }
  } else if (map) {
    // fallback: center on typical Cote de Nuits area
    map.easeTo({ center: DEFAULT_VIEW.center, zoom: DEFAULT_VIEW.zoom, duration: 800 })
  }
  // still emit event for parent components in case they react
  emit('resetMap')
}

const toggle3D = () => {
  is3D.value = !is3D.value
  if (map) {
    map.easeTo({ pitch: is3D.value ? 45 : 0, duration: 800 })
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
    
    mapboxgl.accessToken = 'pk.eyJ1IjoiY2h1bmdzaHVsZWUiLCJhIjoiY21kcTZqbHU1MDNnODJsczZ5NXBtNms2NCJ9.UThWFp3_47qETAMZWhdrTg'
    
    map = new mapboxgl.Map({
      container: mapContainer.value,
      style: 'mapbox://styles/mapbox/satellite-streets-v12',
      // Côte de Nuits default view (can be adjusted via DEFAULT_VIEW)
      center: DEFAULT_VIEW.center,
      zoom: DEFAULT_VIEW.zoom,
      pitch: is3D.value ? 45 : 0,
      bearing: 0
    })
    
    map.on('load', async () => {
      map.addControl(new mapboxgl.NavigationControl(), 'top-right')
      map.addControl(new mapboxgl.FullscreenControl(), 'top-right')
      // load initial village-level geojsons and set reset bounds
      await loadInitialVillageGeojsons()
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
    }
    } else if (map.getLayer('aoc-fill')) {
    map.removeLayer('aoc-fill')
    map.removeLayer('aoc-outline')
    map.removeSource('aoc')
    // Fly back to Côte de Nuits default view
    map.flyTo({ center: DEFAULT_VIEW.center, zoom: DEFAULT_VIEW.zoom })
  }
}, { deep: true })

onMounted(async () => {
  await nextTick()
  setTimeout(async () => {
    await initMap()
  }, 100)
})

onUnmounted(() => {
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
  padding: 8px 20px;
  z-index: 10;
  text-align: center;
  box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}

.map-header h1 {
  margin: 0;
  font-size: 1.5rem;
  color: #006400; /* DarkGreen for Veneto */
}

.map-info-bar {
  position: absolute;
  bottom: 20px;
  left: 20px;
  background: white;
  padding: 15px;
  border-radius: 8px;
  max-width: 450px;
  max-height: 25vh;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
  z-index: 10;
  display: flex;
  flex-direction: column;
}

.info-header-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-shrink: 0;
}

.aoc-info-title {
  display: flex;
  align-items: center;
  font-size: 1.1rem;
  font-weight: bold;
}

.aoc-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  margin-right: 8px;
  flex-shrink: 0;
}

.map-buttons {
  display: flex;
  gap: 8px;
}

.btn-reset {
  padding: 6px 12px;
  background: #f44336;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.8rem;
}

.btn-reset:hover {
  background: #d32f2f;
}

.region-info-content {
  margin-top: 12px;
  font-size: 0.95rem;
  line-height: 1.5;
  text-align: left;
  overflow-y: auto;
  padding-right: 10px;
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
  border-top: 1px solid #eee;
  padding-top: 15px;
}

.details-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 8px 12px;
  margin-top: 10px;
  font-size: 0.9rem;
}

.detail-item {
  display: contents; /* Allows grid layout to apply to children */
}

.detail-item .detail-label {
  font-weight: bold;
  color: #555;
  grid-column: 1 / 2;
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
  border-top: 1px solid #eee;
  padding-top: 10px;
}

.producers-title {
  font-weight: bold;
  font-size: 1rem;
  color: #333;
  margin-bottom: 8px;
}

.producers-list {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.producer-tag {
  background-color: #e0e0e0;
  color: #333;
  padding: 3px 8px;
  border-radius: 4px;
  font-size: 0.85rem;
}

.grape-section {
  margin: 15px 0;
  border-top: 1px solid #eee;
  padding-top: 15px;
}

.grape-title {
  font-weight: bold;
  font-size: 1rem;
  color: #333;
  margin-bottom: 10px;
}

.grape-badges {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.grape-badge {
  padding: 4px 10px;
  border-radius: 15px;
  font-size: 0.8rem;
  white-space: nowrap;
  font-weight: bold;
  box-shadow: 0 1px 2px rgba(0,0,0,0.08);
  border: 1px solid #ddd;
}

.no-info {
  margin-top: 10px;
  color: #888;
  font-size: 0.9rem;
  font-style: italic;
}

.btn-3d {
  position: absolute;
  top: 80px;
  right: 10px;
  padding: 8px 15px;
  background: #4CAF50;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  z-index: 10;
  font-weight: bold;
}

.btn-3d:hover {
  background: #388E3C;
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
  margin-top: 12px;
  overflow-y: auto;
  padding-right: 10px;
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

@media (max-width: 768px) {
  .map-info-bar {
    max-width: calc(100% - 40px);
    width: auto;
    bottom: 10px;
    left: 10px;
    max-height: 30vh;
  }
  
  .map-header h1 {
    font-size: 1.2rem;
  }
}
</style>