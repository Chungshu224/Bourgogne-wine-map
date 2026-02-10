<template>
  <div class="course-manager">
    <!-- 階段選擇器 -->
    <LevelSelector 
      v-if="currentView === 'levelSelector'" 
      @startLevel="handleSelectLevel"
      @openMap="handleOpenMap"
    />

    <!-- 課程學習介面 -->
    <div v-else-if="currentView === 'courseContent'" class="course-container">
      <CourseLayout 
        :currentLevel="selectedLevel"
        @backToLevelSelector="backToLevelSelector"
        @selectModule="handleSelectModule"
      >
        <!-- 模組總覽 -->
        <div v-if="viewMode === 'overview' && selectedModule && moduleData" class="module-overview">
          <div class="module-header">
            <div class="module-icon">{{ selectedModule.icon }}</div>
            <h1>{{ selectedModule.title }}</h1>
            <p class="module-description">{{ selectedModule.description }}</p>
          </div>

          <div class="module-meta">
            <div class="meta-item">
              <span class="meta-icon">⏱️</span>
              <span>{{ selectedModule.duration }}</span>
            </div>
            <div class="meta-item">
              <span class="meta-icon">📚</span>
              <span>{{ moduleData.lessons?.length || selectedModule.lessons }} 課程</span>
            </div>
            <div class="meta-item">
              <span class="meta-icon">📝</span>
              <span>完成測驗可獲得進度</span>
            </div>
          </div>

          <div class="lessons-list">
            <h2>課程大綱</h2>
            <div
              v-for="(lesson, index) in moduleData.lessons"
              :key="lesson.id"
              class="lesson-item"
              @click="startLesson(index)"
            >
              <div class="lesson-number">{{ index + 1 }}</div>
              <div class="lesson-info">
                <h3>{{ lesson.title }}</h3>
                <div class="lesson-meta">
                  <span>{{ lesson.duration }}</span>
                  <span>•</span>
                  <span>{{ getLessonTypeName(lesson.type) }}</span>
                </div>
              </div>
              <div class="lesson-status">
                <span v-if="isLessonCompleted(lesson.id)" class="completed-icon">✓</span>
              </div>
            </div>
          </div>

          <div class="module-actions">
            <button class="start-module-btn" @click="startLesson(0)">
              {{ hasModuleProgress ? '繼續學習' : '開始學習' }}
            </button>
            <button class="quiz-btn" @click="startQuiz" v-if="moduleData.quiz">
              {{ allLessonsCompleted ? '📝 開始測驗' : '📝 挑戰測驗' }}
            </button>
          </div>
        </div>

        <!-- 課程內容 - 使用簡報模式 -->
        <SlideViewer
          v-if="viewMode === 'lesson' && currentLesson"
          :lesson="currentLesson"
          :lessonNumber="currentLessonIndex + 1"
          :totalLessons="moduleData.lessons.length"
          @close="backToOverview"
          @complete="completeLesson"
        />

        <!-- 測驗 -->
        <QuizEngine
          v-else-if="viewMode === 'quiz'"
          :quiz="moduleData.quiz"
          :moduleId="selectedModule.id"
          @quizComplete="handleQuizComplete"
          @reviewLessons="reviewLessons"
          @continueNext="continueToNextModule"
        />
      </CourseLayout>
    </div>

    <!-- 證書展示 -->
    <div v-else-if="currentView === 'certificate'" class="certificate-container">
      <CertificateGenerator 
        :certificateData="certificateData"
      />
      <div class="certificate-actions-bottom">
        <button class="back-to-courses-btn" @click="backToLevelSelector">
          返回課程選擇
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, defineEmits } from 'vue'
import { useProgress } from '../../composables/useProgress.js'
import LevelSelector from './LevelSelector.vue'
import CourseLayout from './CourseLayout.vue'
import LessonViewer from './LessonViewer.vue'
import SlideViewer from './SlideViewer.vue'
import QuizEngine from './QuizEngine.vue'
import CertificateGenerator from './CertificateGenerator.vue'

const emit = defineEmits(['openMap'])
const progressStore = useProgress()

// 當前視圖狀態
const currentView = ref('levelSelector') // levelSelector, courseContent, certificate
const viewMode = ref('overview') // overview, lesson, quiz

// 選擇的階段和模組
const selectedLevel = ref(null)
const selectedModule = ref(null)
const moduleData = ref(null)

// 當前課程狀態
const currentLessonIndex = ref(0)
const completedLessons = ref([])
const lessonStartTime = ref(0)

// 證書資料
const certificateData = ref(null)

// 計算屬性
const currentLesson = computed(() => {
  if (!moduleData.value || !moduleData.value.lessons) return null
  return moduleData.value.lessons[currentLessonIndex.value]
})

const hasModuleProgress = computed(() => {
  return completedLessons.value.length > 0
})

const allLessonsCompleted = computed(() => {
  if (!moduleData.value || !moduleData.value.lessons) return false
  return completedLessons.value.length === moduleData.value.lessons.length
})

// 處理選擇階段
const handleSelectLevel = async (level) => {
  console.log('🎓 選擇 Level:', level.id, level.name)
  selectedLevel.value = level
  currentView.value = 'courseContent'
  console.log('✅ currentView 已設為 courseContent，CourseLayout 應該渲染')
}

// 處理選擇模組
const handleSelectModule = async (module) => {
  try {
    console.log('🎯 handleSelectModule 被調用:', module.title)
    selectedModule.value = module
    viewMode.value = 'overview'
    console.log('📌 viewMode 設為:', viewMode.value)
    console.log('📌 selectedModule:', selectedModule.value?.title)
    
    // 載入模組資料
    await loadModuleData(selectedLevel.value.id, module.id)
    console.log('✅ 模組資料載入完成')
    console.log('📊 檢查顯示條件:')
    console.log('  - viewMode === "overview":', viewMode.value === 'overview')
    console.log('  - selectedModule 存在:', !!selectedModule.value)
    console.log('  - moduleData 存在:', !!moduleData.value)
    console.log('  - 應該顯示 module-overview:', viewMode.value === 'overview' && !!selectedModule.value && !!moduleData.value)
    
    // 載入已完成課程
    loadCompletedLessons(module.id)
  } catch (error) {
    console.error('載入模組失敗:', error)
    alert(`無法載入模組「${module.title}」，請檢查網路連線或稍後再試。\n錯誤詳情：${error.message}`)
    // 重置狀態
    selectedModule.value = null
    moduleData.value = null
    viewMode.value = 'list'
  }
}

// 載入階段所有模組
const loadLevelModules = async (levelId) => {
  try {
    const response = await fetch(`/data/courses/level${levelId}/modules.json`)
    const data = await response.json()
    
    console.log('📋 Level 模組已載入，不自動選擇模組')
    // 移除自動選擇 - 讓用戶點擊卡片來選擇模組
  } catch (error) {
    console.error('載入模組列表失敗:', error)
  }
}

// 載入模組詳細資料
const loadModuleData = async (levelId, moduleId) => {
  try {
    // 根據 levelId 確定正確的路徑
    let levelFolder = 'level1'
    if (levelId === 1) levelFolder = 'level1'
    else if (levelId === 2) levelFolder = 'level2'
    else if (levelId === 3) levelFolder = 'level3'
    else if (levelId === 4) levelFolder = 'level4'
    
    const url = `/data/courses/${levelFolder}/${moduleId}.json`
    console.log('🔍 載入模組資料 URL:', url)
    const response = await fetch(url)
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }
    
    moduleData.value = await response.json()
    console.log('✅ 模組資料載入成功:', moduleData.value.title)
  } catch (error) {
    console.error('載入模組資料失敗:', error)
    moduleData.value = null
    throw new Error(`無法載入模組資料 (${moduleId}): ${error.message}`)
  }
}

// 載入已完成課程
const loadCompletedLessons = (moduleId) => {
  completedLessons.value = progressStore.getCompletedLessons(moduleId)
}

// 開始課程
const startLesson = (lessonIndex) => {
  // 範圍驗證
  if (!moduleData.value || lessonIndex < 0 || lessonIndex >= moduleData.value.lessons.length) {
    console.error(`Invalid lesson index: ${lessonIndex}`)
    return
  }
  
  // 記錄開始時間
  lessonStartTime.value = Date.now()
  currentLessonIndex.value = lessonIndex
  viewMode.value = 'lesson'
}

// 開始測驗
const startQuiz = () => {
  viewMode.value = 'quiz'
}

// 完成課程
const completeLesson = (lessonId) => {
  if (!completedLessons.value.includes(lessonId)) {
    completedLessons.value.push(lessonId)
    saveCompletedLessons()
  }
  
  // 計算並累計學習時間
  if (lessonStartTime.value > 0) {
    const endTime = Date.now()
    const durationMinutes = Math.round((endTime - lessonStartTime.value) / 1000 / 60)
    
    // 使用 progressStore 累計時間
    const moduleId = selectedModule.value.id
    progressStore.addLearningTime(moduleId, durationMinutes)
    
    lessonStartTime.value = 0
  }
  
  // 如果還有下一課，繼續
  if (currentLessonIndex.value < moduleData.value.lessons.length - 1) {
    currentLessonIndex.value++
  } else {
    // 所有課程完成，進入測驗
    viewMode.value = 'quiz'
  }
}

// 上一課
const previousLesson = () => {
  if (currentLessonIndex.value > 0) {
    currentLessonIndex.value--
  }
}

// 儲存已完成課程
const saveCompletedLessons = () => {
  const moduleId = selectedModule.value.id
  progressStore.saveCompletedLessons(moduleId, completedLessons.value)
}

// 處理測驗完成
const handleQuizComplete = async (result) => {
  if (result.passed) {
    // 標記模組為完成
    markModuleComplete(selectedModule.value.id, result)
    
    // 檢查是否完成整個階段
    const levelComplete = await checkLevelComplete(selectedLevel.value.id)
    if (levelComplete) {
      // 生成證書
      await generateCertificate(selectedLevel.value, result)
    } else {
      // 繼續下一模組
      continueToNextModule()
    }
  }
}

// 標記模組完成
const markModuleComplete = (moduleId, quizResult) => {
  const levelId = selectedLevel.value.id
  progressStore.saveModuleProgress(levelId, moduleId, {
    completed: true,
    progress: 100,
    quizScore: quizResult.score,
    completedAt: new Date().toISOString()
  })
}

// 檢查階段是否完成
const checkLevelComplete = async (levelId) => {
  // 動態讀取模組總數
  try {
    const modulesRes = await fetch(`/data/courses/level${levelId}/modules.json`)
    if (!modulesRes.ok) {
      console.error(`Failed to load modules.json for level ${levelId}`)
      return false
    }
    const modulesData = await modulesRes.json()
    const totalModules = modulesData.modules.length
    
    return progressStore.isLevelComplete(levelId, totalModules)
  } catch (error) {
    console.error('Error checking level completion:', error)
    return false
  }
}

// 生成證書
const generateCertificate = async (level, lastQuizResult) => {
  const levelId = level.id
  const progress = progressStore.getLevelProgress(levelId)
  
  const completedModules = Object.keys(progress).filter(key => progress[key].completed).length
  const scores = Object.values(progress).map(p => p.quizScore || 0)
  const averageScore = Math.round(scores.reduce((sum, s) => sum + s, 0) / scores.length)
  
  // 動態讀取模組總數
  let totalModules = completedModules
  try {
    const modulesRes = await fetch(`/data/courses/level${levelId}/modules.json`)
    if (modulesRes.ok) {
      const modulesData = await modulesRes.json()
      totalModules = modulesData.modules.length
    }
  } catch (error) {
    console.error('Error loading modules count:', error)
  }
  
  // 計算總學習時間
  let totalTimeHours = 0
  try {
    const modulesRes = await fetch(`/data/courses/level${levelId}/modules.json`)
    if (modulesRes.ok) {
      const modulesData = await modulesRes.json()
      let totalMinutes = 0
      
      modulesData.modules.forEach(mod => {
        totalMinutes += progressStore.getLearningTime(mod.id)
      })
      
      totalTimeHours = Math.round(totalMinutes / 60 * 10) / 10 // 小時，保留一位小數
    }
  } catch (error) {
    console.error('Error calculating total time:', error)
  }
  
  // 生成證書ID
  const certificateId = `BW-L${levelId}-${Date.now()}-${Math.random().toString(36).substr(2, 9).toUpperCase()}`
  
  certificateData.value = {
    userName: progressStore.getUserName(),
    level: levelId,
    completedModules: completedModules,
    totalModules: totalModules,
    averageScore: averageScore,
    totalTime: totalTimeHours,
    completedAt: new Date(),
    certificateId: certificateId
  }
  
  // 儲存證書資料
  progressStore.saveCertificate(certificateData.value)
  
  // 顯示證書
  currentView.value = 'certificate'
}

// 繼續下一模組
const continueToNextModule = () => {
  viewMode.value = 'overview'
  // 這裡應該載入下一個模組，暫時回到總覽
}

// 複習課程
const reviewLessons = () => {
  currentLessonIndex.value = 0
  viewMode.value = 'lesson'
}

// 返回階段選擇
const backToLevelSelector = () => {
  currentView.value = 'levelSelector'
  selectedLevel.value = null
  selectedModule.value = null
  moduleData.value = null
  viewMode.value = 'overview'
}

// 檢查課程是否完成
const isLessonCompleted = (lessonId) => {
  return completedLessons.value.includes(lessonId)
}

// 返回課程總覽
const backToOverview = () => {
  viewMode.value = 'overview'
}

// 獲取課程類型名稱
const getLessonTypeName = (type) => {
  const types = {
    'video-text': '影片+文字',
    'text-images': '圖文教學',
    'comparison': '對比學習',
    'interactive': '互動練習',
    'presentation': '簡報式課程'
  }
  return types[type] || '一般課程'
}

// 打開地圖互動
const openMapInteraction = (mapData) => {
  console.log('Opening map interaction:', mapData)
  // 觸發事件通知父組件切換到地圖模式
  emit('openMap', mapData)
}

const handleOpenMap = () => {
  emit('openMap')
}
</script>

<style scoped>
.course-manager {
  height: 100vh;
  overflow-y: auto;
  background: #f5f7fa;
}

.course-container,
.certificate-container {
  min-height: 100vh;
}

/* 模組總覽 */
.module-overview {
  max-width: 900px;
  margin: 0 auto;
  padding: 40px 20px;
}

.module-header {
  text-align: center;
  margin-bottom: 32px;
  padding: 36px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.module-icon {
  font-size: 4rem;
  margin-bottom: 18px;
}

.module-header h1 {
  font-size: 2rem;
  color: #2c3e50;
  margin-bottom: 14px;
  font-weight: 700;
  line-height: 1.3;
}

.module-description {
  font-size: 1rem;
  color: #7f8c8d;
  line-height: 1.65;
  max-width: 600px;
  margin: 0 auto;
}

.module-meta {
  display: flex;
  justify-content: center;
  gap: 36px;
  margin-bottom: 32px;
  padding: 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.9375rem;
  color: #2c3e50;
  font-weight: 600;
}

.meta-icon {
  font-size: 1.25rem;
}

.lessons-list {
  background: white;
  border-radius: 16px;
  padding: 28px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  margin-bottom: 28px;
}

.lessons-list h2 {
  font-size: 1.5rem;
  color: #2c3e50;
  margin-bottom: 20px;
  font-weight: 600;
  line-height: 1.3;
}

.lesson-item {
  display: flex;
  align-items: center;
  gap: 18px;
  padding: 18px;
  background: #f8f9fa;
  border-radius: 10px;
  margin-bottom: 10px;
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

.lesson-item:hover {
  background: #e8f4f8;
  transform: translateX(4px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.lesson-number {
  width: 38px;
  height: 38px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 1rem;
  flex-shrink: 0;
}

.lesson-info {
  flex: 1;
}

.lesson-info h3 {
  font-size: 1.0625rem;
  color: #2c3e50;
  margin-bottom: 4px;
  font-weight: 600;
  line-height: 1.4;
}

.lesson-meta {
  font-size: 0.8125rem;
  color: #95a5a6;
  display: flex;
  gap: 8px;
}

.lesson-status {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.completed-icon {
  color: #4CAF50;
  font-size: 1.5rem;
  font-weight: 700;
}

.module-actions {
  display: flex;
  gap: 12px;
  margin-top: 24px;
}

.start-module-btn {
  flex: 1;
  padding: 16px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 1.0625rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

.start-module-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.35);
}

.quiz-btn {
  flex: 1;
  padding: 16px;
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 1.0625rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

.quiz-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(245, 87, 108, 0.35);
}

.certificate-actions-bottom {
  text-align: center;
  padding: 28px;
}

.back-to-courses-btn {
  padding: 13px 30px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 0.9375rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

.back-to-courses-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.35);
}
</style>
