/**
 * MapSlideManager.js
 * 獨立的地圖幻燈片管理器
 * 每個地圖幻燈片都有自己的管理器實例，擁有獨立的狀態和控制
 */

import mapboxgl from 'mapbox-gl'
import * as turf from '@turf/turf'

export class MapSlideManager {
  constructor(container, config) {
    this.container = container
    this.config = config
    this.map = null
    this.loadedLayers = new Map()
    this.markers = []
    this.activeRegion = null
    
    // Mapbox access token
    this.accessToken = 'pk.eyJ1IjoiY2h1bmdzaHVsZWUiLCJhIjoiY21kcTZqbHU1MDNnODJsczZ5NXBtNms2NCJ9.UThWFp3_47qETAMZWhdrTg'
  }

  /**
   * 初始化地圖
   */
  async initialize() {
    if (!this.container) {
      console.error('地圖容器不存在')
      return
    }

    mapboxgl.accessToken = this.accessToken

    // 使用配置或預設值
    const mapConfig = this.config.mapConfig || {
      center: [4.5, 47.2],
      zoom: 8,
      pitch: 0,
      bearing: 0
    }

    // 初始化地圖
    this.map = new mapboxgl.Map({
      container: this.container,
      style: 'mapbox://styles/mapbox/light-v11',
      center: mapConfig.center,
      zoom: mapConfig.zoom,
      pitch: mapConfig.pitch || 0,
      bearing: mapConfig.bearing || 0
    })

    // 添加導航控制
    this.map.addControl(new mapboxgl.NavigationControl(), 'top-right')

    // 等待地圖載入
    await new Promise((resolve) => {
      this.map.on('load', resolve)
    })

    // 載入基礎圖層
    await this.loadBaseLayers()

    // 載入所有產區圖層（初始可見）
    await this.loadAllRegionLayers()

    // 添加標記
    this.addMarkers()

    // 設置初始視圖（自動縮放到所有產區）
    this.fitToAllRegions()

    return this.map
  }

  /**
   * 載入基礎圖層（通常是布根地底圖）
   */
  async loadBaseLayers() {
    if (!this.config.geojsonFiles) return

    // 只載入基礎圖層（如 bourgogne-map）
    const baseLayers = this.config.geojsonFiles.filter(
      file => file.isBase || file.id === 'bourgogne-map'
    )

    for (const layer of baseLayers) {
      await this.loadGeoJSONLayer(layer)
    }
  }

  /**
   * 載入所有產區圖層（初始為可見狀態）
   */
  async loadAllRegionLayers() {
    if (!this.config.geojsonFiles) return

    // 載入所有非基礎圖層
    const regionLayers = this.config.geojsonFiles.filter(
      file => !file.isBase && file.id !== 'bourgogne-map'
    )

    console.log(`準備載入 ${regionLayers.length} 個產區圖層`)

    for (const layer of regionLayers) {
      await this.loadGeoJSONLayer(layer)
    }
    
    console.log('所有產區圖層載入完成')
  }

  /**
   * 載入 GeoJSON 圖層
   */
  async loadGeoJSONLayer(geojsonFile) {
    try {
      const response = await fetch(geojsonFile.url)
      const geojsonData = await response.json()

      const layerId = geojsonFile.id || `layer-${Math.random().toString(36).substr(2, 9)}`
      const sourceId = `source-${layerId}`

      // 添加數據源
      if (!this.map.getSource(sourceId)) {
        this.map.addSource(sourceId, {
          type: 'geojson',
          data: geojsonData
        })
      }

      // 添加填充圖層
      if (!this.map.getLayer(`${layerId}-fill`)) {
        // 對於基礎圖層使用極低透明度，對於產區圖層使用配置的透明度
        const fillOpacity = geojsonFile.isBase ? 0.05 : (geojsonFile.fillOpacity || 0.6)
        
        this.map.addLayer({
          id: `${layerId}-fill`,
          type: 'fill',
          source: sourceId,
          layout: {
            'visibility': 'visible'
          },
          paint: {
            'fill-color': geojsonFile.fillColor || '#667eea',
            'fill-opacity': fillOpacity
          }
        })
        
        console.log(`已載入填充圖層: ${layerId}, 顏色: ${geojsonFile.fillColor}, 透明度: ${fillOpacity}`)
      }

      // 添加邊框圖層
      if (!this.map.getLayer(`${layerId}-line`)) {
        this.map.addLayer({
          id: `${layerId}-line`,
          type: 'line',
          source: sourceId,
          layout: {
            'visibility': 'visible'
          },
          paint: {
            'line-color': geojsonFile.lineColor || '#4a5568',
            'line-width': geojsonFile.lineWidth || 2
          }
        })
      }

      // 添加標籤圖層
      if (geojsonFile.showLabels && geojsonData.features && geojsonData.features.length > 0) {
        const feature = geojsonData.features[0]
        if (feature.properties && feature.properties.name) {
          if (!this.map.getLayer(`${layerId}-label`)) {
            this.map.addLayer({
              id: `${layerId}-label`,
              type: 'symbol',
              source: sourceId,
              layout: {
                'text-field': ['get', 'name'],
                'text-size': 14,
                'text-anchor': 'center'
              },
              paint: {
                'text-color': '#333',
                'text-halo-color': '#fff',
                'text-halo-width': 2
              }
            })
          }
        }
      }

      // 儲存圖層資訊
      this.loadedLayers.set(layerId, geojsonData)

      return geojsonData
    } catch (error) {
      console.error(`載入 GeoJSON 失敗:`, error)
      return null
    }
  }

  /**
   * 添加城市/地點標記
   */
  addMarkers() {
    if (!this.config.markers || this.config.markers.length === 0) return

    this.config.markers.forEach(marker => {
      const markerElement = this.createMarkerElement(marker)
      
      const mapMarker = new mapboxgl.Marker(markerElement)
        .setLngLat(marker.coordinates)
        .addTo(this.map)

      this.markers.push(mapMarker)
    })
  }

  /**
   * 創建標記元素
   */
  createMarkerElement(marker) {
    const el = document.createElement('div')
    el.className = 'city-marker'
    el.innerHTML = `
      <div class="marker-pin"></div>
      <div class="marker-label">${marker.name}</div>
    `
    return el
  }

  /**
   * 設置初始視圖
   */
  setInitialView() {
    if (this.config.bounds) {
      this.map.fitBounds(this.config.bounds, {
        padding: 60,
        duration: 1500
      })
    }
  }

  /**
   * 自動縮放到所有產區的邊界
   */
  fitToAllRegions() {
    if (!this.config.geojsonFiles) return

    // 獲取所有非基礎圖層
    const regionLayers = this.config.geojsonFiles.filter(
      file => !file.isBase && file.id !== 'bourgogne-map'
    )

    if (regionLayers.length === 0) return

    // 收集所有產區的 GeoJSON 數據
    const allFeatures = []
    regionLayers.forEach(layer => {
      const geojsonData = this.loadedLayers.get(layer.id)
      if (geojsonData && geojsonData.features) {
        allFeatures.push(...geojsonData.features)
      }
    })

    if (allFeatures.length === 0) return

    // 創建包含所有要素的 FeatureCollection
    const combinedGeoJSON = {
      type: 'FeatureCollection',
      features: allFeatures
    }

    // 計算總邊界
    try {
      const bbox = turf.bbox(combinedGeoJSON)
      this.map.fitBounds(bbox, {
        padding: 80,
        duration: 1000,
        maxZoom: 12
      })
    } catch (error) {
      console.error('計算邊界失敗:', error)
      // 如果失敗，使用配置中的預設視圖
      this.setInitialView()
    }
  }

  /**
   * 聚焦到指定產區
   */
  async focusRegion(region) {
    if (!this.map) return

    this.activeRegion = region.id

    // 如果該產區尚未載入，先載入它
    if (!this.loadedLayers.has(region.id)) {
      await this.loadGeoJSONLayer(region)
    }

    // 隱藏所有非基礎圖層
    if (this.config.geojsonFiles) {
      this.config.geojsonFiles.forEach(file => {
        if (!file.isBase && file.id !== 'bourgogne-map' && file.id !== region.id) {
          this.toggleLayer(file.id, false)
        }
      })
    }

    // 顯示選中的產區
    this.toggleLayer(region.id, true)

    // 計算邊界並飛到該位置
    const geojsonData = this.loadedLayers.get(region.id)
    if (geojsonData && geojsonData.features && geojsonData.features.length > 0) {
      const bbox = turf.bbox(geojsonData)
      this.map.fitBounds(bbox, {
        padding: 80,
        duration: 1500,
        maxZoom: 13
      })
    }

    return region.id
  }

  /**
   * 顯示所有產區圖層
   */
  async showAllRegions() {
    if (!this.config.geojsonFiles) return

    // 顯示所有非基礎圖層
    const regionLayers = this.config.geojsonFiles.filter(
      file => !file.isBase && file.id !== 'bourgogne-map'
    )

    regionLayers.forEach(layer => {
      this.toggleLayer(layer.id, true)
    })
  }

  /**
   * 飛到指定位置
   */
  flyTo(options) {
    if (!this.map) return

    this.map.flyTo({
      center: options.center,
      zoom: options.zoom || this.map.getZoom(),
      pitch: options.pitch !== undefined ? options.pitch : this.map.getPitch(),
      bearing: options.bearing !== undefined ? options.bearing : this.map.getBearing(),
      duration: options.duration || 2000,
      essential: true
    })
  }

  /**
   * 設置地圖視圖範圍
   */
  fitBounds(bounds, options = {}) {
    if (!this.map) return

    this.map.fitBounds(bounds, {
      padding: options.padding || 60,
      duration: options.duration || 1500,
      maxZoom: options.maxZoom || 14
    })
  }

  /**
   * 切換圖層可見性
   */
  toggleLayer(layerId, visible) {
    if (!this.map) return

    const visibility = visible ? 'visible' : 'none'
    
    if (this.map.getLayer(`${layerId}-fill`)) {
      this.map.setLayoutProperty(`${layerId}-fill`, 'visibility', visibility)
    }
    if (this.map.getLayer(`${layerId}-line`)) {
      this.map.setLayoutProperty(`${layerId}-line`, 'visibility', visibility)
    }
    if (this.map.getLayer(`${layerId}-label`)) {
      this.map.setLayoutProperty(`${layerId}-label`, 'visibility', visibility)
    }
  }

  /**
   * 更新圖層樣式
   */
  updateLayerStyle(layerId, style) {
    if (!this.map) return

    if (style.fillColor && this.map.getLayer(`${layerId}-fill`)) {
      this.map.setPaintProperty(`${layerId}-fill`, 'fill-color', style.fillColor)
    }
    if (style.fillOpacity !== undefined && this.map.getLayer(`${layerId}-fill`)) {
      this.map.setPaintProperty(`${layerId}-fill`, 'fill-opacity', style.fillOpacity)
    }
    if (style.lineColor && this.map.getLayer(`${layerId}-line`)) {
      this.map.setPaintProperty(`${layerId}-line`, 'line-color', style.lineColor)
    }
    if (style.lineWidth !== undefined && this.map.getLayer(`${layerId}-line`)) {
      this.map.setPaintProperty(`${layerId}-line`, 'line-width', style.lineWidth)
    }
  }

  /**
   * 獲取當前活動的產區
   */
  getActiveRegion() {
    return this.activeRegion
  }

  /**
   * 獲取所有已載入的圖層
   */
  getLoadedLayers() {
    return Array.from(this.loadedLayers.keys())
  }

  /**
   * 清除所有標記
   */
  clearMarkers() {
    this.markers.forEach(marker => marker.remove())
    this.markers = []
  }

  /**
   * 銷毀地圖實例
   */
  destroy() {
    if (this.map) {
      this.clearMarkers()
      this.map.remove()
      this.map = null
    }
    this.loadedLayers.clear()
    this.activeRegion = null
  }

  /**
   * 重置到初始狀態
   */
  reset() {
    this.setInitialView()
    this.activeRegion = null
  }
}

export default MapSlideManager
