<template>
  <div class="lesson-intro">
    <!-- 課程標題區 -->
    <div class="intro-header">
      <div class="lesson-icon">📚</div>
      <h1 class="lesson-title">{{ lesson.title }}</h1>
      <div class="lesson-meta">
        <span class="meta-item">
          <span class="icon">⏱️</span>
          {{ lesson.duration }}
        </span>
        <span class="meta-item">
          <span class="icon">📊</span>
          {{ slideCount }} 張投影片
        </span>
      </div>
    </div>

    <!-- 課程介紹 -->
    <div class="intro-content">
      <section class="intro-section">
        <h2>📖 課程介紹</h2>
        <p class="intro-text">{{ getCourseIntroduction }}</p>
      </section>

      <!-- 學習目標 -->
      <section class="intro-section" v-if="learningObjectives.length > 0">
        <h2>🎯 學習目標</h2>
        <ul class="objectives-list">
          <li v-for="(objective, index) in learningObjectives" :key="index">
            {{ objective }}
          </li>
        </ul>
      </section>

      <!-- 課程大綱預覽 -->
      <section class="intro-section">
        <h2>📑 課程大綱</h2>
        <div class="outline-preview">
          <div 
            v-for="(slide, index) in outlineSlides" 
            :key="index"
            class="outline-item"
          >
            <span class="outline-number">{{ index + 1 }}</span>
            <span class="outline-title">{{ slide.title || '投影片 ' + (index + 1) }}</span>
          </div>
        </div>
      </section>
    </div>

    <!-- 開始學習按鈕 -->
    <div class="intro-actions">
      <button class="back-btn" @click="$emit('back')">
        ← 返回課程列表
      </button>
      <button class="start-btn" @click="$emit('startLesson')">
        <span class="play-icon">▶</span>
        開始學習
      </button>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  lesson: {
    type: Object,
    required: true
  },
  slideCount: {
    type: Number,
    default: 0
  }
})

const emit = defineEmits(['startLesson', 'back'])

// 獲取課程介紹文字
const getCourseIntroduction = computed(() => {
  // 從第一張投影片獲取描述
  if (props.lesson.slides && props.lesson.slides[0]) {
    return props.lesson.slides[0].description || props.lesson.slides[0].content || '深入了解布根地葡萄酒的精髓。'
  }
  
  // 或從課程內容中獲取
  if (props.lesson.content?.introduction) {
    return props.lesson.content.introduction
  }
  
  return '本課程將帶您探索布根地葡萄酒的獨特魅力，建立扎實的知識基礎。'
})

// 學習目標列表
const learningObjectives = computed(() => {
  const objectives = []
  
  // 從課程內容中提取學習目標
  if (props.lesson.content?.objectives && Array.isArray(props.lesson.content.objectives)) {
    return props.lesson.content.objectives
  }
  
  // 根據課程類型生成預設目標
  if (props.lesson.slides && props.lesson.slides.length > 0) {
    const slideTypes = new Set(props.lesson.slides.map(s => s.type))
    
    if (slideTypes.has('map')) {
      objectives.push('認識產區地理位置與分布')
    }
    if (slideTypes.has('timeline')) {
      objectives.push('了解歷史發展脈絡')
    }
    if (slideTypes.has('comparison')) {
      objectives.push('掌握品種與風格差異')
    }
    if (slideTypes.has('chart')) {
      objectives.push('分析數據與趨勢')
    }
    
    // 通用目標
    if (props.lesson.title.includes('產區') || props.lesson.title.includes('村莊')) {
      objectives.push('理解風土條件的重要性')
    }
    if (props.lesson.title.includes('品種')) {
      objectives.push('識別葡萄品種特徵')
    }
    if (props.lesson.title.includes('酒標') || props.lesson.title.includes('分級')) {
      objectives.push('學會閱讀與辨別酒標資訊')
    }
  }
  
  // 如果沒有特定目標，返回通用目標
  if (objectives.length === 0) {
    objectives.push('建立系統化的知識架構')
    objectives.push('培養品鑑與分析能力')
    objectives.push('深化對布根地葡萄酒的理解')
  }
  
  return objectives
})

// 課程大綱（前8張投影片）
const outlineSlides = computed(() => {
  if (!props.lesson.slides) return []
  return props.lesson.slides.slice(0, 8)
})
</script>

<style scoped>
.lesson-intro {
  min-height: 100vh;
  background: linear-gradient(135deg, #f8f5ff 0%, #f3f8ff 100%);
  padding: 60px 40px 40px;
  font-family: 'Segoe UI', 'Microsoft YaHei', Arial, sans-serif;
}

/* 課程標題區 */
.intro-header {
  text-align: center;
  margin-bottom: 50px;
  padding: 40px;
  background: white;
  border-radius: 24px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.lesson-icon {
  font-size: 64px;
  margin-bottom: 20px;
}

.lesson-title {
  font-size: 2.5rem;
  font-weight: 700;
  color: #2c3e50;
  margin-bottom: 20px;
  line-height: 1.3;
}

.lesson-meta {
  display: flex;
  justify-content: center;
  gap: 30px;
  margin-top: 20px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 1.1rem;
  color: #666;
  font-weight: 500;
}

.meta-item .icon {
  font-size: 1.3rem;
}

/* 課程內容區 */
.intro-content {
  max-width: 900px;
  margin: 0 auto;
}

.intro-section {
  background: white;
  border-radius: 20px;
  padding: 35px 40px;
  margin-bottom: 25px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
}

.intro-section h2 {
  font-size: 1.5rem;
  color: #2c3e50;
  margin-bottom: 20px;
  font-weight: 700;
  display: flex;
  align-items: center;
  gap: 10px;
}

.intro-text {
  font-size: 1.1rem;
  line-height: 1.8;
  color: #555;
  margin: 0;
}

/* 學習目標列表 */
.objectives-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.objectives-list li {
  font-size: 1.1rem;
  line-height: 1.8;
  color: #555;
  padding: 12px 0;
  padding-left: 35px;
  position: relative;
}

.objectives-list li::before {
  content: '✓';
  position: absolute;
  left: 0;
  color: #667eea;
  font-weight: 700;
  font-size: 1.3rem;
}

/* 課程大綱預覽 */
.outline-preview {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 12px;
}

.outline-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background: #f8f9fa;
  border-radius: 10px;
  transition: all 0.2s ease;
  cursor: default;
}

.outline-item:hover {
  background: #e9ecef;
  transform: translateX(3px);
}

.outline-number {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  border-radius: 50%;
  font-size: 0.85rem;
  font-weight: 700;
  flex-shrink: 0;
}

.outline-title {
  font-size: 0.95rem;
  color: #2c3e50;
  font-weight: 500;
  line-height: 1.4;
}

/* 操作按鈕 */
.intro-actions {
  max-width: 900px;
  margin: 40px auto 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
}

.back-btn,
.start-btn {
  padding: 16px 32px;
  border: none;
  border-radius: 12px;
  font-size: 1.05rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 10px;
}

.back-btn {
  background: white;
  color: #666;
  border: 2px solid #e0e0e0;
}

.back-btn:hover {
  background: #f5f5f5;
  border-color: #ccc;
  transform: translateX(-3px);
}

.start-btn {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
  flex: 1;
  justify-content: center;
  max-width: 300px;
  margin-left: auto;
}

.start-btn:hover {
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
  transform: translateY(-2px);
}

.play-icon {
  font-size: 1.1rem;
}

/* 響應式設計 */
@media (max-width: 768px) {
  .lesson-intro {
    padding: 40px 20px 20px;
  }

  .intro-header {
    padding: 30px 20px;
  }

  .lesson-title {
    font-size: 1.8rem;
  }

  .lesson-meta {
    flex-direction: column;
    gap: 15px;
  }

  .intro-section {
    padding: 25px 20px;
  }

  .intro-section h2 {
    font-size: 1.3rem;
  }

  .outline-preview {
    grid-template-columns: 1fr;
  }

  .intro-actions {
    flex-direction: column;
  }

  .start-btn {
    max-width: 100%;
    width: 100%;
  }
}
</style>
