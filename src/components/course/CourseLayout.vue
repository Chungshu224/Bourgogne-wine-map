<template>
  <div class="course-layout">
    <!-- 測試模式浮動標籤 -->
    <div class="test-mode-badge">
      🧪 測試
    </div>

    <!-- 頂部導航欄 -->
    <header class="course-header">
      <!-- 左側：返回按鈕和 Logo -->
      <div class="header-left">
        <button class="back-btn" @click="backToLevelSelector">
          <span class="back-icon">←</span>
        </button>
        <div class="logo">🍷</div>
      </div>
      
      <!-- 中間：Level 切換標籤 -->
      <div class="header-center">
        <div class="level-tabs">
          <button 
            v-for="level in [1, 2, 3, 4]" 
            :key="level"
            class="level-tab"
            :class="{ active: currentLevel.id === level }"
            @click="handleLevelChange(level)"
          >
            L{{ level }}
          </button>
        </div>
      </div>

      <!-- 右側：進度環 -->
      <div class="header-right">
        <button class="progress-btn" title="查看詳細進度">
          <svg class="progress-ring" width="36" height="36">
            <circle
              class="progress-ring-bg"
              cx="18" cy="18" r="15"
              fill="none"
              stroke="rgba(255,255,255,0.2)"
              stroke-width="3"
            />
            <circle
              class="progress-ring-fill"
              cx="18" cy="18" r="15"
              fill="none"
              stroke="white"
              stroke-width="3"
              :stroke-dasharray="`${overallProgress * 0.942} 94.2`"
              transform="rotate(-90 18 18)"
            />
          </svg>
          <span class="progress-text">{{ overallProgress }}%</span>
        </button>
      </div>
    </header>

    <!-- 主內容區 -->
    <div class="main-content">
      <!-- Level 標題卡片 -->
      <div class="level-header-card">
        <div class="level-header-top">
          <div class="level-badge">Level {{ currentLevel.id }}</div>
          <h2 class="level-name">{{ currentLevel.name }}</h2>
        </div>
        <p class="level-desc">{{ currentLevel.description }}</p>
        
        <div class="progress-section">
          <div class="progress-bar-wrapper">
            <div class="progress-bar-fill" :style="{ width: overallProgress + '%' }"></div>
          </div>
        </div>

        <!-- 激勵文字 -->
        <div v-if="overallProgress < 100 && overallProgress > 0" class="motivation-text">
          🎯 再完成 {{ modules.length - completedModules }} 個課程即可完成此階段！
        </div>
      </div>

      <!-- 課程內容標題 -->
      <h3 class="content-section-title">課程內容</h3>

      <!-- 課程卡片網格 -->
      <div class="modules-grid">
        <!-- 載入狀態 - 骨架屏 -->
        <template v-if="loading">
          <div 
            v-for="n in 6" 
            :key="'skeleton-' + n"
            class="skeleton-card"
          >
            <div class="skeleton-icon"></div>
            <div class="skeleton-content">
              <div class="skeleton-title"></div>
              <div class="skeleton-text"></div>
            </div>
          </div>
        </template>

        <!-- 實際模組卡片 -->
        <template v-else>
          <div 
            v-for="module in modules" 
            :key="module.id"
            class="module-card-wrapper"
          >
            <!-- 模組卡片主體 -->
          <div 
            class="module-card"
            :class="{ 
              completed: module.completed, 
              locked: module.locked,
              expanded: expandedModules[module.id]
            }"
            @click="toggleModuleExpand(module)"
          >
            <div class="card-icon">
              <div v-if="module.completed" class="check-icon">✓</div>
              <div v-else-if="module.locked" class="lock-icon">🔒</div>
            </div>
            <div class="card-content">
              <h4 class="card-title">{{ module.title }}</h4>
              <p class="card-meta">{{ module.duration }} · {{ module.lessons }} 課程</p>
            </div>
            <div class="expand-icon" v-if="!module.locked">
              {{ expandedModules[module.id] ? '▼' : '▶' }}
            </div>
          </div>

          <!-- 展開的課程列表 -->
          <transition name="expand">
            <div 
              v-if="expandedModules[module.id] && moduleDataCache[module.id]"
              class="lessons-list"
              @click.stop
            >
              <div 
                v-for="(lesson, index) in moduleDataCache[module.id].lessons" 
                :key="lesson.id"
                class="lesson-item"
                @click="handleLessonClick(module, index)"
              >
                <div class="lesson-number">{{ index + 1 }}</div>
                <div class="lesson-info">
                  <h5 class="lesson-title">{{ lesson.title }}</h5>
                  <div class="lesson-meta">
                    <span>{{ lesson.duration || '10 分鐘' }}</span>
                  </div>
                </div>
                <div class="lesson-status">
                  <span v-if="isLessonCompleted(module.id, lesson.id)" class="completed-badge">✓</span>
                  <span v-else class="start-badge">開始 ▶</span>
                </div>
              </div>
            </div>
          </transition>
        </div>
        </template>
      </div>

      <!-- Slot for additional content -->
      <slot></slot>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'

const props = defineProps({
  currentLevel: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['backToLevelSelector', 'selectModule', 'changeLevel', 'startLesson'])

const modules = ref([])
const currentModule = ref(null)
const totalTrophies = ref(9)
const expandedModules = ref({}) // 追踪展開的模組
const moduleDataCache = ref({}) // 快取載入的模組數據
const loading = ref(false) // 載入狀態

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

// 監聽 currentLevel 變化，重新載入模組
watch(() => props.currentLevel, async (newLevel, oldLevel) => {
  if (newLevel && newLevel.id !== oldLevel?.id) {
    console.log('🔄 Level 已改變，重新載入模組:', newLevel.name)
    await loadModules()
  }
}, { deep: true })

const loadModules = async () => {
  loading.value = true // 開始載入
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
  } finally {
    loading.value = false // 結束載入
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

const handleLevelChange = (levelId) => {
  console.log('🔄 切換到 Level:', levelId)
  emit('changeLevel', levelId)
}

// 切換模組展開/收合
const toggleModuleExpand = async (module) => {
  if (module.locked) {
    console.log('🔒 模組已鎖定，無法開啟')
    return
  }
  
  const moduleId = module.id
  const isExpanded = expandedModules.value[moduleId]
  
  // 收合
  if (isExpanded) {
    expandedModules.value[moduleId] = false
    console.log('📤 收合模組:', module.title)
  } 
  // 展開
  else {
    // 如果還沒有載入數據，先載入
    if (!moduleDataCache.value[moduleId]) {
      console.log('📥 載入模組數據:', module.title)
      await loadModuleData(moduleId)
    }
    expandedModules.value[moduleId] = true
    console.log('📥 展開模組:', module.title)
  }
}

// 載入模組數據
const loadModuleData = async (moduleId) => {
  try {
    const url = `/data/courses/level${props.currentLevel.id}/${moduleId}.json`
    console.log('📡 載入模組數據 URL:', url)
    const response = await fetch(url)
    const data = await response.json()
    moduleDataCache.value[moduleId] = data
    console.log('✅ 模組數據載入成功:', data.title)
  } catch (error) {
    console.error('❌ 載入模組數據失敗:', error)
  }
}

// 點擊課程項目
const handleLessonClick = (module, lessonIndex) => {
  console.log('🎓 點擊課程:', module.title, '- Lesson', lessonIndex + 1)
  emit('startLesson', {
    module: module,
    lessonIndex: lessonIndex,
    moduleData: moduleDataCache.value[module.id]
  })
}

// 檢查課程是否完成
const isLessonCompleted = (moduleId, lessonId) => {
  const saved = localStorage.getItem(`burgundy-level${props.currentLevel.id}-progress`)
  if (!saved) return false
  
  try {
    const progress = JSON.parse(saved)
    return progress[moduleId]?.completedLessons?.includes(lessonId) || false
  } catch {
    return false
  }
}
</script>

<style scoped>
.course-layout {
  min-height: 100vh;
  background: #f5f5f5;
  font-family: 'Segoe UI', 'Microsoft YaHei', Arial, sans-serif;
}

/* 測試模式浮動標籤 */
.test-mode-badge {
  position: fixed;
  bottom: 20px;
  right: 20px;
  background: rgba(0, 0, 0, 0.75);
  color: white;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  z-index: 9999;
  backdrop-filter: blur(10px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 0.8; }
  50% { opacity: 1; }
}

/* 頂部導航欄 */
.course-header {
  background: var(--color-primary-gradient);
  padding: 12px 32px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  color: white;
  box-shadow: var(--shadow-md);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.back-btn {
  padding: var(--spacing-sm) 12px;
  background: rgba(255, 255, 255, 0.15);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: var(--radius-sm);
  color: white;
  cursor: pointer;
  font-size: var(--text-base);
  font-weight: 600;
  transition: var(--transition-base);
  display: flex;
  align-items: center;
}

.back-btn:hover {
  background: rgba(255, 255, 255, 0.25);
  transform: translateX(-2px);
}

.back-icon {
  font-size: 18px;
}

.logo {
  font-size: 28px;
}

.header-center {
  flex: 1;
  display: flex;
  justify-content: center;
}

.level-tabs {
  display: flex;
  gap: 6px;
  background: rgba(255, 255, 255, 0.1);
  padding: 4px;
  border-radius: var(--radius-md);
}

.level-tab {
  padding: 8px 20px;
  background: transparent;
  border: none;
  border-radius: var(--radius-sm);
  color: rgba(255, 255, 255, 0.7);
  cursor: pointer;
  font-size: var(--text-sm);
  font-weight: 700;
  transition: var(--transition-base);
  min-width: 50px;
}

.level-tab:hover {
  color: white;
  background: rgba(255, 255, 255, 0.1);
}

.level-tab.active {
  background: white;
  color: var(--color-primary-start);
  box-shadow: var(--shadow-sm);
}

.header-right {
  display: flex;
  align-items: center;
}

.progress-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 12px;
  background: rgba(255, 255, 255, 0.15);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: var(--radius-full);
  color: white;
  cursor: pointer;
  transition: var(--transition-base);
}

.progress-btn:hover {
  background: rgba(255, 255, 255, 0.25);
  transform: scale(1.05);
}

.progress-ring {
  display: block;
}

.progress-ring-fill {
  transition: stroke-dasharray 0.5s ease;
}

.progress-text {
  font-size: var(--text-sm);
  font-weight: 700;
}

/* 主內容區 */
.main-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px 40px;
}

/* Level 標題卡片 */
.level-header-card {
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  border: 2px solid var(--border-light);
  border-radius: var(--radius-lg);
  padding: 24px 32px;
  margin-bottom: 24px;
  box-shadow: var(--shadow-sm);
  transition: var(--transition-base);
}

.level-header-card:hover {
  box-shadow: var(--shadow-md);
}

.level-header-top {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 12px;
}

.level-badge {
  display: inline-flex;
  align-items: center;
  padding: 6px 16px;
  background: var(--color-primary-gradient);
  color: white;
  border-radius: var(--radius-full);
  font-size: var(--text-sm);
  font-weight: 700;
  letter-spacing: 0.5px;
  flex-shrink: 0;
}

.level-name {
  font-size: var(--text-xl);
  font-weight: 700;
  color: var(--text-primary);
  margin: 0;
  flex: 1;
}

.level-desc {
  font-size: var(--text-base);
  color: var(--text-secondary);
  margin: 0 0 20px 0;
  line-height: 1.6;
}

/* 進度條區域 */
.progress-section {
  margin-top: 20px;
}

.progress-bar-wrapper {
  width: 100%;
  height: 8px;
  background: var(--bg-tertiary);
  border-radius: var(--radius-full);
  overflow: hidden;
  margin-bottom: 12px;
  position: relative;
}

.progress-bar-fill {
  height: 100%;
  background: var(--color-primary-gradient);
  border-radius: var(--radius-full);
  transition: width 0.6s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.progress-bar-fill::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(
    90deg,
    transparent,
    rgba(255, 255, 255, 0.3),
    transparent
  );
  animation: shimmer-progress 2s infinite;
}

@keyframes shimmer-progress {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

/* 激勵文字 */
.motivation-text {
  margin-top: 16px;
  padding: 12px 20px;
  background: linear-gradient(135deg, #fff7ed 0%, #ffedd5 100%);
  border-left: 4px solid var(--color-warning);
  border-radius: var(--radius-md);
  font-size: var(--text-sm);
  font-weight: 600;
  color: #ea580c;
  text-align: center;
}

.content-section-title {
  font-size: var(--text-xl);
  font-weight: 700;
  color: var(--text-primary);
  margin: 0 0 20px 0;
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

.card-meta {
  font-size: 13px;
  color: #7f8c8d;
  margin: 4px 0 0 0;
}

/* 模組卡片包裝器 */
.module-card-wrapper {
  display: flex;
  flex-direction: column;
}

/* 展開圖標 */
.expand-icon {
  font-size: 14px;
  color: #667eea;
  font-weight: 700;
  transition: transform 0.3s ease;
}

.module-card.expanded .expand-icon {
  transform: rotate(90deg);
}

/* 課程列表 */
.lessons-list {
  background: #f8f9fa;
  border: 2px solid #e9ecef;
  border-top: none;
  border-radius: 0 0 16px 16px;
  padding: 16px;
  margin-top: -12px;
  overflow: hidden;
}

.lesson-item {
  background: white;
  border: 1px solid #e9ecef;
  border-radius: 10px;
  padding: 12px 16px;
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  margin-bottom: 8px;
}

.lesson-item:last-child {
  margin-bottom: 0;
}

.lesson-item:hover {
  background: #667eea;
  border-color: #667eea;
  transform: translateX(4px);
}

.lesson-item:hover .lesson-title,
.lesson-item:hover .lesson-meta {
  color: white;
}

.lesson-item:hover .lesson-number {
  background: white;
  color: #667eea;
}

.lesson-item:hover .start-badge {
  background: white;
  color: #667eea;
}

.lesson-number {
  width: 32px;
  height: 32px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 700;
  flex-shrink: 0;
}

.lesson-info {
  flex: 1;
}

.lesson-title {
  font-size: 14px;
  font-weight: 600;
  color: #2c3e50;
  margin: 0 0 4px 0;
  transition: color 0.2s ease;
}

.lesson-meta {
  font-size: 12px;
  color: #7f8c8d;
  transition: color 0.2s ease;
}

.lesson-status {
  flex-shrink: 0;
}

.completed-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  background: #10b981;
  color: white;
  border-radius: 50%;
  font-size: 14px;
  font-weight: 700;
}

.start-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 6px 12px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  transition: all 0.2s ease;
}

/* 展開/收合動畫 */
.expand-enter-active,
.expand-leave-active {
  transition: all 0.3s ease;
  max-height: 500px;
}

.expand-enter-from,
.expand-leave-to {
  max-height: 0;
  opacity: 0;
  padding-top: 0;
  padding-bottom: 0;
}

/* 骨架屏載入動畫 */
@keyframes shimmer {
  0% { background-position: -1000px 0; }
  100% { background-position: 1000px 0; }
}

.skeleton-card {
  background: white;
  border: 2px solid var(--border-light);
  border-radius: var(--radius-lg);
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 16px;
}

.skeleton-icon {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: linear-gradient(
    90deg,
    #f0f0f0 0%,
    #e0e0e0 50%,
    #f0f0f0 100%
  );
  background-size: 1000px 100%;
  animation: shimmer 2s infinite linear;
  flex-shrink: 0;
}

.skeleton-content {
  flex: 1;
}

.skeleton-title {
  width: 70%;
  height: 20px;
  background: linear-gradient(
    90deg,
    #f0f0f0 0%,
    #e0e0e0 50%,
    #f0f0f0 100%
  );
  background-size: 1000px 100%;
  animation: shimmer 2s infinite linear;
  border-radius: 4px;
  margin-bottom: 8px;
}

.skeleton-text {
  width: 40%;
  height: 14px;
  background: linear-gradient(
    90deg,
    #f0f0f0 0%,
    #e0e0e0 50%,
    #f0f0f0 100%
  );
  background-size: 1000px 100%;
  animation: shimmer 2s infinite linear;
  border-radius: 4px;
}

@media (max-width: 1024px) {
  .modules-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .main-content {
    padding: 16px 20px;
  }

  .level-header-card {
    padding: 20px 24px;
    margin-bottom: 16px;
  }

  .level-header-top {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }

  .level-badge {
    font-size: 11px;
    padding: 5px 12px;
  }

  .level-name {
    font-size: var(--text-lg);
  }

  .level-desc {
    font-size: var(--text-sm);
    margin-bottom: 16px;
  }

  .motivation-text {
    font-size: 12px;
    padding: 10px 16px;
  }

  .content-section-title {
    font-size: var(--text-lg);
    margin-bottom: 16px;
  }

  .modules-grid {
    grid-template-columns: 1fr;
  }
  
  .header-center {
    display: none;
  }
}
</style>
