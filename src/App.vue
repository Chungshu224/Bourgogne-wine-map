<script setup>
import { ref, provide } from 'vue'
import RegionSelector from './components/RegionSelector.vue'
import RegionMap from './components/RegionMap.vue'
import CourseManager from './components/course/CourseManager.vue'

const currentRegion = ref(null)
const showRegionSelector = ref(true)
const currentMode = ref('course') // 'course' 為主要模式，'map' 為輔助
const showBackMenu = ref(false) // 控制下拉菜單

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
  showBackMenu.value = false
}

const switchMode = (mode) => {
  currentMode.value = mode
  showBackMenu.value = false
  if (mode === 'map') {
    showRegionSelector.value = true
    currentRegion.value = null
  }
}

// 計算當前位置文字
const getCurrentLocation = () => {
  if (showRegionSelector.value) {
    return '產區選擇'
  }
  if (currentRegion.value) {
    return currentRegion.value.name || '產區詳情'
  }
  return '地圖'
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
        <!-- 智慧返回菜單 -->
        <div class="back-menu-container">
          <button 
            class="back-menu-btn"
            @click="showBackMenu = !showBackMenu"
            :title="getCurrentLocation()"
          >
            ▼ 返回 {{ getCurrentLocation() }}
          </button>
          
          <!-- 下拉菜單 -->
          <div v-if="showBackMenu" class="back-menu-dropdown">
            <button class="menu-item" @click="switchMode('course')">
              ← 返回課程學習
            </button>
            <button 
              v-if="!showRegionSelector"
              class="menu-item"
              @click="backToRegionSelector"
            >
              ← 返回產區選擇
            </button>
          </div>
        </div>
      </div>
      
      <!-- 區域選擇器 -->
      <RegionSelector 
        v-if="showRegionSelector"
        @region-selected="handleRegionSelected"
      />
      
      <!-- 地圖視圖 -->
      <div v-else class="map-view">
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
  display: flex;
  gap: 12px;
  align-items: center;
}

/* 返回菜單容器 */
.back-menu-container {
  position: relative;
}

.back-menu-btn {
  padding: 10px 16px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  font-size: 0.95rem;
  font-weight: 600;
  transition: all 0.2s ease;
  white-space: nowrap;
}

.back-menu-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 14px rgba(102, 126, 234, 0.3);
}

/* 下拉菜單 */
.back-menu-dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 10px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  overflow: hidden;
  z-index: 1002;
  margin-top: 8px;
  min-width: 200px;
}

.menu-item {
  display: block;
  width: 100%;
  padding: 12px 16px;
  background: none;
  border: none;
  text-align: left;
  cursor: pointer;
  font-size: 0.95rem;
  font-weight: 500;
  color: #333;
  transition: all 0.2s ease;
}

.menu-item:hover {
  background: #f5f5f5;
  color: #667eea;
  padding-left: 20px;
}

.menu-item:not(:last-child) {
  border-bottom: 1px solid #f0f0f0;
}

/* 響應式調整 */
@media (max-width: 768px) {
  .map-mode-header {
    padding: 10px 12px;
    gap: 8px;
  }

  .back-menu-btn {
    padding: 8px 12px;
    font-size: 0.9rem;
  }

  .back-menu-dropdown {
    min-width: 160px;
    margin-top: 6px;
  }

  .menu-item {
    padding: 10px 12px;
    font-size: 0.9rem;
  }

  .menu-item:hover {
    padding-left: 16px;
  }

  .map-view {
    padding-top: calc(var(--header-height));
  }
}

@media (max-width: 480px) {
  .map-mode-header {
    padding: 8px 10px;
    gap: 6px;
  }

  .back-menu-btn {
    padding: 6px 10px;
    font-size: 0.8rem;
  }

  .back-menu-dropdown {
    min-width: 140px;
    margin-top: 4px;
  }

  .menu-item {
    padding: 8px 10px;
    font-size: 0.8rem;
  }

  .menu-item:hover {
    padding-left: 14px;
  }
}

</style>
