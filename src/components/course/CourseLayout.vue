<template>
  <div class="course-layout">
    <!-- 測試模式橫幅 -->
    <div class="test-mode-banner">
      <span class="banner-icon">🧪</span>
      測試模式已啟用 - 所有功能已解鎖
      <div class="banner-actions">
        <button class="banner-btn">電腦測試模式</button>
        <button class="banner-btn primary">退出測試模式</button>
      </div>
    </div>

    <!-- 頂部導航欄 -->
    <header class="course-header">
      <div class="header-left">
        <div class="logo">🍷</div>
        <h1 class="academy-title">布根地葡萄酒學院</h1>
        <button class="back-btn" @click="backToLevelSelector">← 返回 Level 選擇</button>
      </div>
      
      <div class="header-center">
        <button 
          v-for="level in [1, 2, 3, 4]" 
          :key="level"
          class="level-tab"
          :class="{ active: currentLevel.id === level }"
        >
          Level {{ level }}
        </button>
      </div>

      <div class="header-right">
        <div class="progress-badge">{{ overallProgress }}%</div>
        <div class="trophy-badge">🏆 {{ totalTrophies }}</div>
      </div>
    </header>

    <!-- 主內容區 -->
    <div class="main-content">
      <!-- 課程標題區 -->
      <div class="level-intro">
        <h2 class="level-title">Level {{ currentLevel.id }} - {{ currentLevel.name }}</h2>
        <p class="level-description">{{ currentLevel.description }}</p>
        
        <button class="continue-btn">
          <span class="play-icon">▶</span>
          繼續學習
        </button>
        
        <p class="completion-status">已完成 {{ completedModules }}/{{ modules.length }} 課程</p>
      </div>

      <!-- 課程內容標題 -->
      <h3 class="content-section-title">課程內容</h3>

      <!-- 課程卡片網格 -->
      <div class="modules-grid">
        <div 
          v-for="module in modules" 
          :key="module.id"
          class="module-card"
          :class="{ completed: module.completed, locked: module.locked }"
          @click="handleModuleClick(module)"
        >
          <div class="card-icon">
            <div v-if="module.completed" class="check-icon">✓</div>
            <div v-else-if="module.locked" class="lock-icon">🔒</div>
          </div>
          <div class="card-content">
            <h4 class="card-title">{{ module.title }}</h4>
            <p class="card-duration">{{ module.duration }}</p>
          </div>
        </div>
      </div>

      <!-- Slot for additional content -->
      <slot></slot>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const props = defineProps({
  currentLevel: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['backToLevelSelector', 'selectModule'])

const modules = ref([])
const currentModule = ref(null)
const totalTrophies = ref(9)

const overallProgress = computed(() => {
  if (!modules.value.length) return 0
  const total = modules.value.reduce((sum, m) => sum + m.progress, 0)
  return Math.round(total / modules.value.length)
})

const completedModules = computed(() => {
  return modules.value.filter(m => m.completed).length
})

onMounted(async () => {
  console.log('CourseLayout mounted, currentLevel:', props.currentLevel)
  await loadModules()
})

const loadModules = async () => {
  try {
    console.log('🔍 開始載入模組列表...')
    const url = `/data/courses/level${props.currentLevel.id}/modules.json`
    console.log('📡 Fetch URL:', url)
    const response = await fetch(url, {
      headers: {
        'Content-Type': 'application/json'
      }
    })
    console.log('✅ Response status:', response.status)
    const data = await response.json()
    console.log('📦 模組列表載入成功:', data)
    modules.value = data.modules
    
    console.log('📋 模組數量:', modules.value.length)
    modules.value.forEach((m, i) => {
      console.log(`  ${i + 1}. ${m.title} - locked: ${m.locked}`)
    })
    
    // 載入用戶進度
    const saved = localStorage.getItem(`burgundy-level${props.currentLevel.id}-progress`)
    if (saved) {
      const progress = JSON.parse(saved)
      modules.value.forEach(module => {
        if (progress[module.id]) {
          module.progress = progress[module.id].progress
          module.completed = progress[module.id].completed
        }
      })
    }
    
    // 🔧 測試模式：解鎖所有模組
    const TEST_MODE = true
    if (TEST_MODE) {
      modules.value.forEach(m => m.locked = false)
      console.log('🧪 測試模式：所有模組已解鎖')
      modules.value.forEach((m, i) => {
        console.log(`  ${i + 1}. ${m.title} - locked: ${m.locked}`)
      })
    } else {
      updateModuleLocks()
    }
  } catch (error) {
    console.error('❌ 載入模組失敗:', error)
  }
}

const updateModuleLocks = () => {
  if (modules.value.length > 0) {
    modules.value[0].locked = false
  }
  
  for (let i = 1; i < modules.value.length; i++) {
    modules.value[i].locked = !modules.value[i - 1].completed
  }
}

const handleModuleClick = (module) => {
  console.log('🎯 模組卡片被點擊:', module.title, 'locked:', module.locked)
  if (!module.locked) {
    console.log('✅ 模組未鎖定，觸發 selectModule')
    selectModule(module)
  } else {
    console.log('🔒 模組已鎖定，無法開啟')
  }
}

const selectModule = (module) => {
  console.log('📢 發送 selectModule 事件:', module)
  if (!module.locked) {
    currentModule.value = module
    emit('selectModule', module)
  }
}

const backToLevelSelector = () => {
  emit('backToLevelSelector')
}
</script>

<style scoped>
.course-layout {
  min-height: 100vh;
  background: #f5f5f5;
  font-family: 'Segoe UI', 'Microsoft YaHei', Arial, sans-serif;
}

/* 測試模式橫幅 */
.test-mode-banner {
  background: linear-gradient(135deg, #ff6b6b, #ee5a6f);
  color: white;
  padding: 12px 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 20px;
  font-size: 14px;
  font-weight: 600;
}

.banner-icon {
  font-size: 18px;
}

.banner-actions {
  display: flex;
  gap: 12px;
  margin-left: auto;
}

.banner-btn {
  padding: 6px 16px;
  border: 1px solid rgba(255, 255, 255, 0.5);
  background: transparent;
  color: white;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
  font-weight: 600;
  transition: all 0.3s ease;
}

.banner-btn.primary {
  background: white;
  color: #ff6b6b;
  border: none;
}

/* 頂部導航欄 */
.course-header {
  background: linear-gradient(135deg, #667eea, #764ba2);
  padding: 16px 40px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  color: white;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.logo {
  font-size: 32px;
}

.academy-title {
  font-size: 18px;
  font-weight: 700;
  margin: 0;
}

.back-btn {
  padding: 8px 16px;
  background: rgba(255, 255, 255, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 6px;
  color: white;
  cursor: pointer;
  font-size: 13px;
  font-weight: 600;
}

.header-center {
  display: flex;
  gap: 8px;
}

.level-tab {
  padding: 10px 24px;
  background: rgba(255, 255, 255, 0.15);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  color: rgba(255, 255, 255, 0.7);
  cursor: pointer;
  font-size: 14px;
  font-weight: 600;
}

.level-tab.active {
  background: white;
  color: #667eea;
}

.header-right {
  display: flex;
  gap: 12px;
}

.progress-badge,
.trophy-badge {
  padding: 8px 16px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 20px;
  font-size: 14px;
  font-weight: 700;
}

/* 主內容區 */
.main-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 60px 40px;
}

.level-intro {
  text-align: center;
  margin-bottom: 60px;
}

.level-title {
  font-size: 36px;
  font-weight: 700;
  color: #2c3e50;
  margin: 0 0 16px 0;
}

.level-description {
  font-size: 16px;
  color: #7f8c8d;
  margin: 0 0 32px 0;
}

.continue-btn {
  padding: 16px 48px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  border: none;
  border-radius: 50px;
  color: white;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 12px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.4);
  margin-bottom: 16px;
}

.play-icon {
  font-size: 14px;
}

.completion-status {
  font-size: 14px;
  color: #95a5a6;
}

.content-section-title {
  font-size: 24px;
  font-weight: 700;
  color: #2c3e50;
  margin: 0 0 32px 0;
}

.modules-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}

.module-card {
  background: white;
  border: 2px solid #d1fae5;
  border-radius: 16px;
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 16px;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  z-index: 1;
  user-select: none;
}

.module-card.locked {
  opacity: 0.6;
  cursor: not-allowed;
  pointer-events: auto;
}

.module-card:not(.locked) {
  pointer-events: auto;
}

.module-card.completed {
  background: #d1fae5;
  border-color: #10b981;
}

.module-card:hover:not(.locked) {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
}

.card-icon {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: #10b981;
  display: flex;
  align-items: center;
  justify-content: center;
  pointer-events: none;
  flex-shrink: 0;
}

.check-icon {
  color: white;
  font-size: 24px;
  font-weight: 700;
  pointer-events: none;
}

.lock-icon {
  font-size: 24px;
  pointer-events: none;
}

.card-content {
  flex: 1;
  pointer-events: none;
}

.card-title {
  font-size: 16px;
  font-weight: 700;
  color: #2c3e50;
  margin: 0 0 4px 0;
}

.card-duration {
  font-size: 13px;
  color: #7f8c8d;
  margin: 0;
}

@media (max-width: 1024px) {
  .modules-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .modules-grid {
    grid-template-columns: 1fr;
  }
  
  .header-center {
    display: none;
  }
}
</style>
