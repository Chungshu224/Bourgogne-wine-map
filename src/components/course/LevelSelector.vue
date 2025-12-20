<template>
  <div class="level-selector">
    <div class="page-header">
      <div class="hero-grid">
        <div class="hero-text">
          <div class="logo-section">
            <div class="logo-icon">🍷</div>
            <div class="title-group">
              <h1 class="main-title">Burgundy Wine Academy</h1>
              <p class="sub-title">布根地葡萄酒學院</p>
            </div>
          </div>
          <p class="hero-tagline">追隨布根地的香氣足跡，從入門到大師的完整學習旅程。</p>
          <div class="hero-actions">
            <button class="hero-btn primary" @click="startJourney">
              <span class="btn-icon">▶</span>
              {{ heroButtonText }}
            </button>
            <button class="hero-btn secondary" @click="emit('openMap')">
              <span class="btn-icon">🗺️</span>
              探索地圖
            </button>
          </div>
        </div>
        <div class="hero-stats">
          <div class="stats-card">
            <div class="stat-item">
              <span class="stat-label">總體進度</span>
              <span class="stat-value">{{ totalProgress }}%</span>
            </div>
            <div class="stat-divider"></div>
            <div class="stat-item">
              <span class="stat-label">完成模組</span>
              <span class="stat-value">{{ completedLevels }}</span>
            </div>
            <div class="stat-divider"></div>
            <div class="stat-item">
              <span class="stat-label">累積時數</span>
              <span class="stat-value">{{ studyTime }} 小時</span>
            </div>
            <div class="stat-divider"></div>
            <div class="stat-item">
              <span class="stat-label">獲得證書</span>
              <span class="stat-value">{{ earnedCertificates }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="levels-section">
      <div class="section-header">
        <div class="section-title-group">
          <h2>選擇課程階段</h2>
          <p>依照學習路徑循序漸進掌握布根地的風土、產區與品種，完成挑戰即可解鎖下一階段。</p>
        </div>
        <div class="section-actions">
          <button class="section-btn" @click="startJourney">
            立即開始
          </button>
        </div>
      </div>

      <div class="levels-grid">
        <div
          v-for="level in levels"
          :key="level.id"
          class="level-card"
          :class="{
            locked: !level.unlocked,
            'level-1': level.id === 1,
            'level-2': level.id === 2,
            'level-3': level.id === 3,
            'level-4': level.id === 4
          }"
        >
          <div class="level-number">{{ level.id }}</div>
          <div class="card-title">
            <h2>{{ level.name }}</h2>
            <p class="level-label">Level {{ level.id }}</p>
          </div>
          <p class="card-description">{{ level.description }}</p>
          <div class="features-list">
            <div
              v-for="(feature, index) in level.features"
              :key="index"
              class="feature-item"
            >
              <span class="feature-icon">{{ feature.icon }}</span>
              <span class="feature-text">{{ feature.text }}</span>
            </div>
          </div>
          <div class="stats-row">
            <div class="stat-box">
              <div class="stat-value">{{ level.modules }}</div>
              <div class="stat-label">個模組</div>
            </div>
            <div class="stat-box">
              <div class="stat-value">{{ level.hours }}</div>
              <div class="stat-label">小時</div>
            </div>
            <div class="stat-box">
              <div class="stat-value">{{ Math.round(getProgress(level.id)) }}%</div>
              <div class="stat-label">完成度</div>
            </div>
          </div>
          <button
            v-if="level.unlocked"
            class="action-btn"
            @click="startLevel(level)"
          >
            {{ isInProgress(level.id) ? '繼續學習' : '開始學習' }} →
          </button>
          <button v-else class="action-btn locked-btn" disabled>
            開始學習 →
          </button>
          <div v-if="!level.unlocked" class="lock-overlay">
            <div class="lock-icon">🔒</div>
          </div>
        </div>
      </div>
    </div>

    <div class="bottom-actions">
      <button class="action-button explore-map" @click="emit('openMap')">
        <span class="btn-icon">🗺️</span>
        探索地圖
      </button>
      <button class="action-button achievements">
        <span class="btn-icon">🏆</span>
        成就系統
      </button>
      <button class="action-button learning-progress">
        <span class="btn-icon">📊</span>
        學習進度
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const levels = ref([])
const userProgress = ref({
  1: { completed: false, progress: 0, score: 0 },
  2: { completed: false, progress: 0, score: 0 },
  3: { completed: false, progress: 0, score: 0 },
  4: { completed: false, progress: 0, score: 0 }
})

const emit = defineEmits(['startLevel', 'openMap'])

onMounted(async () => {
  const response = await fetch('/data/courses/levels.json')
  const data = await response.json()
  levels.value = data.levels
  loadUserProgress()
  updateLevelLocks()
})

const loadUserProgress = () => {
  const saved = localStorage.getItem('burgundy-course-progress')
  if (saved) {
    userProgress.value = JSON.parse(saved)
  }
}

const updateLevelLocks = () => {
  const TEST_MODE = true
  if (TEST_MODE) {
    levels.value.forEach(level => {
      level.unlocked = true
    })
  } else {
    levels.value[0].unlocked = true
    if (userProgress.value[1].progress >= 100) {
      levels.value[1].unlocked = true
    }
    if (userProgress.value[2].progress >= 85) {
      levels.value[2].unlocked = true
    }
    if (userProgress.value[3].progress >= 85) {
      levels.value[3].unlocked = true
    }
  }
}

const isInProgress = (levelId) => {
  const progress = userProgress.value[levelId]?.progress || 0
  return progress > 0 && progress < 100
}

const getProgress = (levelId) => {
  return userProgress.value[levelId]?.progress || 0
}

const completedLevels = computed(() => {
  return Object.values(userProgress.value).filter(p => p.completed).length
})

const totalProgress = computed(() => {
  const total = Object.values(userProgress.value).reduce((sum, p) => sum + p.progress, 0)
  return Math.round(total / 4)
})

const studyTime = computed(() => {
  return Math.round(totalProgress.value * 0.5)
})

const earnedCertificates = computed(() => {
  return completedLevels.value
})

const startLevel = (level) => {
  emit('startLevel', level)
}

const nextAvailableLevel = computed(() => {
  return levels.value.find(level => level.unlocked)
})

const heroButtonText = computed(() => {
  if (!nextAvailableLevel.value) {
    return '查看課程'
  }
  const target = nextAvailableLevel.value
  return isInProgress(target.id) ? `繼續 Level ${target.id}` : `開始 Level ${target.id}`
})

const startJourney = () => {
  if (nextAvailableLevel.value) {
    emit('startLevel', nextAvailableLevel.value)
  }
}
</script>

<style scoped>
.level-selector {
  min-height: 100vh;
  background: linear-gradient(135deg, #f8f5ff 0%, #f3f8ff 100%);
  padding: 40px 48px;
  font-family: 'Segoe UI', 'Microsoft YaHei', Arial, sans-serif;
  display: flex;
  flex-direction: column;
  align-items: stretch;
  box-sizing: border-box;
  width: 100vw;
  overflow-y: auto;
}

.page-header {
  width: 100%;
  margin: 0 0 24px;
  background: white;
  border-radius: 24px;
  padding: 32px 48px;
  box-shadow: 0 24px 60px rgba(102, 126, 234, 0.18);
  position: relative;
  overflow: hidden;
}

.page-header::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.08), rgba(118, 75, 162, 0.12));
  pointer-events: none;
}

.hero-grid {
  position: relative;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 48px;
  align-items: center;
  z-index: 1;
}

.hero-text {
  display: flex;
  flex-direction: column;
  gap: 20px;
  align-items: flex-start;
  text-align: left;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 20px;
}

.logo-icon {
  font-size: 3rem;
  background: linear-gradient(135deg, #667eea, #764ba2);
  border-radius: 16px;
  width: 80px;
  height: 80px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.3);
}

.title-group {
  flex: 1;
}

.main-title {
  font-size: 2.5rem;
  font-weight: 700;
  background: linear-gradient(135deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 0 0 6px 0;
  letter-spacing: -0.3px;
  line-height: 1.2;
}

.sub-title {
  font-size: 1.125rem;
  color: #6b7280;
  margin: 0;
  font-weight: 500;
}

.hero-tagline {
  font-size: 1rem;
  color: #4b5563;
  line-height: 1.7;
  max-width: 520px;
  margin: 0;
}

.hero-actions {
  display: flex;
  gap: 16px;
  align-items: center;
  flex-wrap: wrap;
}

.hero-btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 14px 24px;
  border-radius: 12px;
  font-size: 0.95rem;
  font-weight: 600;
  border: none;
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  z-index: 1;
}

.hero-btn .btn-icon {
  font-size: 1.125rem;
}

.hero-btn.primary {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  box-shadow: 0 16px 40px rgba(102, 126, 234, 0.35);
}

.hero-btn.primary:hover {
  transform: translateY(-3px);
  box-shadow: 0 22px 50px rgba(102, 126, 234, 0.45);
}

.hero-btn.secondary {
  background: white;
  color: #4b5563;
  border: 1px solid rgba(102, 126, 234, 0.35);
}

.hero-btn.secondary:hover {
  border-color: rgba(102, 126, 234, 0.6);
  box-shadow: 0 16px 32px rgba(102, 126, 234, 0.15);
}

.hero-stats {
  display: flex;
  justify-content: flex-end;
  width: 100%;
}

.stats-card {
  background: linear-gradient(135deg, #667eea, #764ba2);
  padding: 32px;
  border-radius: 24px;
  color: white;
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px;
  align-items: center;
  box-shadow: 0 20px 50px rgba(102, 126, 234, 0.45);
  width: 100%;
}

.stat-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 120px;
}

.stat-label {
  font-size: 0.875rem;
  opacity: 0.85;
  font-weight: 500;
}

.stat-value {
  font-size: 2rem;
  font-weight: 700;
  line-height: 1.2;
}

.stat-divider {
  width: 1px;
  height: 48px;
  background: rgba(255, 255, 255, 0.3);
}

.levels-section {
  width: 100%;
  margin: 24px 0 0;
  background: white;
  border-radius: 24px;
  padding: 40px 48px 44px;
  box-shadow: 0 24px 60px rgba(79, 70, 229, 0.12);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 32px;
  margin-bottom: 32px;
}

.section-title-group h2 {
  font-size: 1.875rem;
  color: #1f2937;
  margin: 0 0 10px 0;
  font-weight: 600;
}

.section-title-group p {
  font-size: 0.95rem;
  color: #6b7280;
  margin: 0;
  max-width: 520px;
  line-height: 1.65;
}

.section-actions {
  flex-shrink: 0;
}

.section-btn {
  padding: 14px 28px;
  border-radius: 12px;
  border: none;
  background: #1f2937;
  color: white;
  font-size: 15px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s ease;
}

.section-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 18px 30px rgba(17, 24, 39, 0.2);
}

.levels-grid {
  width: 100%;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 24px;
}

.level-card {
  background: white;
  border-radius: 20px;
  padding: 28px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
  width: 100%;
  border: 1px solid #e5e7eb;
}

.level-card:hover:not(.locked) {
  transform: translateY(-8px);
  box-shadow: 0 16px 48px rgba(0, 0, 0, 0.2);
}

.level-number {
  width: 52px;
  height: 52px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  font-weight: 700;
  color: white;
  margin-bottom: 18px;
}

.level-1 .level-number {
  background: linear-gradient(135deg, #667eea, #764ba2);
}

.level-2 .level-number {
  background: linear-gradient(135deg, #f093fb, #f5576c);
}

.level-3 .level-number {
  background: linear-gradient(135deg, #4facfe, #00f2fe);
}

.level-4 .level-number {
  background: linear-gradient(135deg, #fa709a, #fee140);
}

.card-title h2 {
  font-size: 1.375rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 4px 0;
  line-height: 1.3;
}

.level-label {
  font-size: 0.8125rem;
  color: #9ca3af;
  margin: 0 0 14px 0;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.card-description {
  font-size: 0.875rem;
  line-height: 1.65;
  color: #4b5563;
  margin-bottom: 20px;
  min-height: 60px;
}

.features-list {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  margin-bottom: 24px;
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.8125rem;
  color: #374151;
}

.feature-icon {
  font-size: 1rem;
  flex-shrink: 0;
}

.feature-text {
  font-weight: 500;
  line-height: 1.4;
}

.stats-row {
  display: flex;
  justify-content: space-around;
  padding: 18px 0;
  margin-bottom: 18px;
  border-top: 1px solid #e5e7eb;
  border-bottom: 1px solid #e5e7eb;
}

.stat-box {
  text-align: center;
}

.stat-box .stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: #1f2937;
  line-height: 1.2;
}

.stat-box .stat-label {
  font-size: 0.6875rem;
  color: #94a3b8;
  text-transform: uppercase;
  letter-spacing: 0.8px;
  margin-top: 4px;
  display: block;
}

.action-btn {
  width: 100%;
  padding: 14px 0;
  border: none;
  border-radius: 10px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  font-size: 0.95rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.3);
}

.action-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(102, 126, 234, 0.35);
}

.locked-btn {
  background: #e5e7eb;
  color: #9ca3af;
  box-shadow: none;
}

.locked-btn:hover {
  transform: none;
  box-shadow: none;
}

.lock-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.92);
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10;
  backdrop-filter: blur(4px);
}

.lock-icon {
  font-size: 56px;
  opacity: 0.6;
}

.bottom-actions {
  width: 100%;
  margin: 32px 0 0;
  background: white;
  border-radius: 20px;
  padding: 20px 32px;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  flex-wrap: wrap;
}

.action-button {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 32px;
  border: none;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.explore-map {
  background: linear-gradient(135deg, #06b6d4, #0891b2);
  color: white;
}

.achievements {
  background: linear-gradient(135deg, #fbbf24, #f59e0b);
  color: white;
}

.learning-progress {
  background: linear-gradient(135deg, #8b5cf6, #7c3aed);
  color: white;
}

.action-button:hover {
  transform: translateY(-3px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);
}

.btn-icon {
  font-size: 24px;
}

@media (max-width: 1200px) {
  .levels-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 1024px) {
  .level-selector {
    padding: 32px 24px;
  }

  .hero-grid {
    grid-template-columns: 1fr;
    gap: 32px;
  }

  .hero-text {
    align-items: center;
    text-align: center;
  }

  .hero-stats {
    justify-content: center;
  }

  .levels-section {
    padding: 32px 24px;
  }
}

@media (max-width: 768px) {
  .level-selector {
    padding: 24px 16px;
  }

  .hero-actions {
    flex-direction: column;
    width: 100%;
  }

  .levels-grid {
    grid-template-columns: 1fr;
  }

  .levels-section {
    padding: 24px 16px;
  }

  .bottom-actions {
    flex-direction: column;
    padding: 16px;
  }
}
</style>
