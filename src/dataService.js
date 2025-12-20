// src/services/dataService.js

// 數據快取
const cache = {
  regionsIndex: null,
  regionData: new Map(),
  geojsonData: new Map()
};

export default {
  /**
   * 載入區域索引配置
   */
  async getRegionsIndex() {
    if (cache.regionsIndex) {
      return cache.regionsIndex;
    }
    
    try {
      const response = await fetch('/geojson/regions-index.json');
      if (!response.ok) throw new Error('Failed to load regions index');
      
      cache.regionsIndex = await response.json();
      return cache.regionsIndex;
    } catch (error) {
      console.error('Error loading regions index:', error);
      return null;
    }
  },

  /**
   * 取得特定區域的配置
   */
  async getRegionConfig(regionId) {
    const index = await this.getRegionsIndex();
    if (!index || !index.regions) return null;
    
    return index.regions[regionId] || null;
  },

  /**
   * 取得產區資訊
   */
  async getRegionInfo(dataPath) {
    if (!dataPath) return null;
    
    // 檢查快取
    if (cache.regionData.has(dataPath)) {
      return cache.regionData.get(dataPath);
    }
    
    try {
      const response = await fetch(dataPath);
      if (!response.ok) throw new Error('Failed to load region info');
      
      const regionData = await response.json();
      cache.regionData.set(dataPath, regionData);
      return regionData;
    } catch (error) {
      console.error('Error loading region info:', error);
      return null;
    }
  },

  /**
   * 載入 GeoJSON 資料
   */
  async getGeoJSON(regionId, path) {
    const cacheKey = `${regionId}:${path}`;
    
    // 檢查快取
    if (cache.geojsonData.has(cacheKey)) {
      return cache.geojsonData.get(cacheKey);
    }
    
    try {
      const config = await this.getRegionConfig(regionId);
      const basePath = config?.basePath || '/geojson';
      const fullPath = `${basePath}/${path}`;
      
      const response = await fetch(fullPath);
      if (!response.ok) throw new Error(`Failed to load GeoJSON: ${fullPath}`);
      
      const geojsonData = await response.json();
      cache.geojsonData.set(cacheKey, geojsonData);
      return geojsonData;
    } catch (error) {
      console.error('Error loading GeoJSON:', error);
      return null;
    }
  },

  /**
   * 清除快取
   */
  clearCache(type = 'all') {
    switch (type) {
      case 'regions':
        cache.regionsIndex = null;
        break;
      case 'data':
        cache.regionData.clear();
        break;
      case 'geojson':
        cache.geojsonData.clear();
        break;
      case 'all':
      default:
        cache.regionsIndex = null;
        cache.regionData.clear();
        cache.geojsonData.clear();
    }
  }
};
