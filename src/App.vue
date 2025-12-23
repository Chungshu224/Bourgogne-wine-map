<script setup>
import { ref, provide } from 'vue'
import RegionSelector from './components/RegionSelector.vue'
import RegionMap from './components/RegionMap.vue'
import CourseManager from './components/course/CourseManager.vue'

const currentRegion = ref(null)
const showRegionSelector = ref(true)
const currentMode = ref('course') // 'course' 為主要模式，'map' 為輔助

// 提供全域狀態給子組件
provide('currentRegion', currentRegion)

const handleRegionSelected = (region) => {
  if (region) {
    currentRegion.value = region
    showRegionSelector.value = false
  } else {
    // 返回區域選擇頁面
    currentRegion.value = null
    showRegionSelector.value = true
  }
}

const backToRegionSelector = () => {
  currentRegion.value = null
  showRegionSelector.value = true
}

const switchMode = (mode) => {
  currentMode.value = mode
  if (mode === 'map') {
    showRegionSelector.value = true
    currentRegion.value = null
  }
}
</script>

<template>
  <div class="app-container">
    <!-- 課程模式（主要） -->
    <div v-if="currentMode === 'course'">
      <CourseManager @openMap="switchMode('map')" />
    </div>

    <!-- 地圖模式（輔助） -->
    <div v-else-if="currentMode === 'map'">
      <div class="map-mode-header">
        <button class="back-to-course-btn" @click="switchMode('course')">
          ← 返回課程學習
        </button>
      </div>
      
      <!-- 區域選擇器 -->
      <RegionSelector 
        v-if="showRegionSelector"
        @region-selected="handleRegionSelected"
      />
      
      <!-- 地圖視圖 -->
      <div v-else class="map-view">
        <!-- 返回按鈕 -->
        <button class="back-button" @click="backToRegionSelector">
          ← 返回產區選擇
        </button>
        
        <!-- 使用通用 RegionMap 組件顯示所有區域 -->
        <RegionMap 
          v-if="currentRegion"
          :region-config="currentRegion"
        />
      </div>
    </div>
  </div>
</template>
<style>
:root {
  --header-height: 56px;
}

#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  width: 100%;
  min-height: 100vh;
  margin: 0;
  padding: 0;
  overflow: auto;
}

.app-container {
  width: 100%;
  min-height: 100vh;
  position: relative;
}

.map-view {
  width: 100%;
  min-height: calc(100vh - var(--header-height));
  position: relative;
  padding-top: var(--header-height);
}

.back-button {
  position: absolute;
  top: calc(var(--header-height) + 12px);
  left: 16px;
  z-index: 1000;
  padding: 10px 18px;
  background: white;
  border: 2px solid #667eea;
  border-radius: 10px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 600;
  color: #667eea;
  transition: all 0.2s ease;
  box-shadow: 0 2px 8px rgba(0,0,0,0.12);
  min-height: 44px;
}

.back-button:hover {
  background: #667eea;
  color: white;
  transform: scale(1.03);
  box-shadow: 0 6px 14px rgba(102, 126, 234, 0.25);
}

/* 模式切換按鈕 */
.mode-switcher {
  position: absolute;
  top: 12px;
  right: 12px;
  z-index: 1000;
}

.course-mode-btn {
  padding: 12px 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  font-size: 1.05rem;
  font-weight: 700;
  transition: all 0.2s ease;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.22);
}

.course-mode-btn:hover {
  transform: translateY(-2px);
}

.course-mode-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1001;
  padding: 12px 16px;
  background: white;
  box-shadow: 0 1px 6px rgba(0, 0, 0, 0.06);
}

.exit-course-btn {
  padding: 10px 16px;
  background: white;
  border: 2px solid #667eea;
  border-radius: 10px;
  cursor: pointer;
  font-size: 0.95rem;
  font-weight: 600;
  color: #667eea;
  transition: all 0.2s ease;
}

.exit-course-btn:hover {
  background: #f5f5f5;
}

.map-mode-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1001;
  padding: 12px 16px;
  background: rgba(255, 255, 255, 0.96);
  backdrop-filter: blur(6px);
  box-shadow: 0 1px 6px rgba(0, 0, 0, 0.06);
}

.back-to-course-btn {
  padding: 10px 16px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: 600;
  transition: all 0.2s ease;
}

.back-to-course-btn:hover {
  transform: translateX(-2px);
  box-shadow: 0 6px 14px rgba(102, 126, 234, 0.2);
}

/* 響應式調整 */
@media (max-width: 768px) {
  .back-button {
    left: 12px;
    top: calc(var(--header-height) + 10px);
    font-size: 0.98rem;
    padding: 10px 14px;
  }

  .course-mode-btn, .back-to-course-btn {
    padding: 10px 14px;
    font-size: 0.95rem;
  }

  .map-view {
    padding-top: calc(var(--header-height));
  }
}

</style>
