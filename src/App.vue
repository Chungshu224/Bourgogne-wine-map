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
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  width: 100vw;
  height: 100vh;
  margin: 0;
  padding: 0;
  overflow: hidden;
}

body {
  margin: 0;
}

.app-container {
  width: 100%;
  height: 100vh;
  position: relative;
}

.map-view {
  width: 100%;
  height: 100vh;
  position: relative;
}

.back-button {
  position: absolute;
  top:50px;
  left: 400px;
  z-index: 1000;
  padding: 10px 20px;
  background: white;
  border: 2px solid #667eea;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 600;
  color: #667eea;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(0,0,0,0.15);
}

.back-button:hover {
  background: #667eea;
  color: white;
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

/* 模式切換按鈕 */
.mode-switcher {
  position: absolute;
  top: 20px;
  right: 20px;
  z-index: 1000;
}

.course-mode-btn {
  padding: 12px 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 16px;
  font-weight: 700;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.course-mode-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.course-mode-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1001;
  padding: 15px 20px;
  background: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.exit-course-btn {
  padding: 10px 20px;
  background: white;
  border: 2px solid #667eea;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 600;
  color: #667eea;
  transition: all 0.3s ease;
}

.exit-course-btn:hover {
  background: #f5f5f5;
  transform: translateX(-2px);
}
</style>

.map-mode-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1001;
  padding: 15px 20px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.back-to-course-btn {
  padding: 10px 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 600;
  transition: all 0.3s ease;
}

.back-to-course-btn:hover {
  transform: translateX(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}
