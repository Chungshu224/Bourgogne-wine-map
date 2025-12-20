<template>
  <div class="slide-viewer">
    <!-- 簡報主區域 -->
    <div class="slide-container">
      <!-- 當前投影片 -->
      <div class="slide" :key="currentSlide">
        <component :is="getCurrentSlideComponent" :slide="slides[currentSlide]" />
      </div>

      <!-- 導航按鈕 -->
      <button 
        v-if="currentSlide > 0"
        class="nav-btn prev-btn" 
        @click="prevSlide"
      >
        <span class="arrow">‹</span>
      </button>
      
      <button 
        v-if="currentSlide < slides.length - 1"
        class="nav-btn next-btn" 
        @click="nextSlide"
      >
        <span class="arrow">›</span>
      </button>

      <!-- 進度指示器 -->
      <div class="progress-indicator">
        <div 
          v-for="(slide, index) in slides" 
          :key="index"
          class="dot"
          :class="{ active: index === currentSlide }"
          @click="goToSlide(index)"
        ></div>
      </div>

      <!-- 投影片編號 -->
      <div class="slide-number">
        {{ currentSlide + 1 }} / {{ slides.length }}
      </div>
    </div>

    <!-- 底部控制欄 -->
    <div class="controls">
      <button class="control-btn" @click="$emit('close')">
        ← 返回課程列表
      </button>
      <div class="slide-title">{{ lesson.title }}</div>
      <button 
        v-if="currentSlide === slides.length - 1"
        class="control-btn complete-btn" 
        @click="completeLesson"
      >
        完成課程 ✓
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import TitleSlide from './slides/TitleSlide.vue'
import ContentSlide from './slides/ContentSlide.vue'
import ImageSlide from './slides/ImageSlide.vue'
import ListSlide from './slides/ListSlide.vue'
import ComparisonSlide from './slides/ComparisonSlide.vue'
import TimelineSlide from './slides/TimelineSlide.vue'

const props = defineProps({
  lesson: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['complete', 'close'])

const currentSlide = ref(0)

// 將課程內容轉換為投影片
const slides = computed(() => {
  // 如果課程已經包含 slides 陣列，直接使用
  if (props.lesson.slides && Array.isArray(props.lesson.slides)) {
    return props.lesson.slides
  }
  
  // 否則，將舊格式轉換為投影片格式
  const slideArray = []
  
  // 1. 標題投影片
  slideArray.push({
    type: 'title',
    title: props.lesson.title,
    subtitle: props.lesson.duration,
    description: props.lesson.content?.introduction || ''
  })

  // 2. 內容投影片
  if (props.lesson.content?.sections) {
    props.lesson.content.sections.forEach(section => {
      if (section.heading) {
        // 如果有重點列表，使用 list 類型
        if (section.keyPoints && section.keyPoints.length > 0) {
          slideArray.push({
            type: 'list',
            title: section.heading,
            content: section.text,
            points: section.keyPoints
          })
        } 
        // 如果有村莊列表，使用 list 類型
        else if (section.villages && section.villages.length > 0) {
          slideArray.push({
            type: 'list',
            title: section.heading,
            content: section.text,
            points: section.villages.map(v => typeof v === 'string' ? v : v.name || v.village)
          })
        }
        // 如果有特級村列表，使用 list 類型
        else if (section.crus && section.crus.length > 0) {
          slideArray.push({
            type: 'list',
            title: section.heading,
            content: section.text,
            points: section.crus.map(c => typeof c === 'string' ? c : `${c.name} - ${c.character}`)
          })
        }
        // 否則使用 content 類型
        else {
          slideArray.push({
            type: 'content',
            title: section.heading,
            content: section.text
          })
        }
      }
    })
  }

  // 3. 金字塔投影片（分級制度）
  if (props.lesson.content?.pyramid) {
    slideArray.push({
      type: 'comparison',
      title: props.lesson.content.pyramid.title || '分級金字塔',
      pyramid: props.lesson.content.pyramid
    })
  }

  // 4. 對比表投影片
  if (props.lesson.content?.comparison) {
    slideArray.push({
      type: 'comparison',
      title: '詳細對比',
      comparison: props.lesson.content.comparison
    })
  }

  // 5. 時間軸投影片
  if (props.lesson.content?.timeline) {
    slideArray.push({
      type: 'timeline',
      title: '歷史時間軸',
      timeline: props.lesson.content.timeline
    })
  }

  // 6. 品種對比投影片
  if (props.lesson.content?.grapes) {
    slideArray.push({
      type: 'comparison',
      title: '葡萄品種對比',
      grapes: props.lesson.content.grapes
    })
  }

  // 7. 提示與技巧投影片
  if (props.lesson.content?.tips && props.lesson.content.tips.length > 0) {
    slideArray.push({
      type: 'list',
      title: '💡 實用技巧',
      points: props.lesson.content.tips
    })
  }

  // 8. 總結投影片
  if (props.lesson.content?.summary) {
    slideArray.push({
      type: 'content',
      title: '📝 課程總結',
      content: props.lesson.content.summary
    })
  }

  return slideArray
})

const getCurrentSlideComponent = computed(() => {
  const slideType = slides.value[currentSlide.value]?.type
  
  switch(slideType) {
    case 'title': return TitleSlide
    case 'list': return ListSlide
    case 'timeline': return TimelineSlide
    case 'comparison': return ComparisonSlide
    case 'image': return ImageSlide
    default: return ContentSlide
  }
})

const nextSlide = () => {
  if (currentSlide.value < slides.value.length - 1) {
    currentSlide.value++
  }
}

const prevSlide = () => {
  if (currentSlide.value > 0) {
    currentSlide.value--
  }
}

const goToSlide = (index) => {
  currentSlide.value = index
}

const completeLesson = () => {
  emit('complete', props.lesson.id)
}

// 鍵盤導航
const handleKeydown = (e) => {
  if (e.key === 'ArrowRight') nextSlide()
  if (e.key === 'ArrowLeft') prevSlide()
  if (e.key === 'Escape') emit('close')
}

onMounted(() => {
  window.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown)
})
</script>

<style scoped>
.slide-viewer {
  width: 100%;
  height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  flex-direction: column;
}

.slide-container {
  flex: 1;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px;
}

.slide {
  width: 100%;
  max-width: 1000px;
  height: 100%;
  max-height: 600px;
  background: white;
  border-radius: 24px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: slideIn 0.4s ease-out;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateX(50px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

/* 導航按鈕 */
.nav-btn {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 56px;
  height: 56px;
  background: rgba(255, 255, 255, 0.95);
  border: none;
  border-radius: 50%;
  cursor: pointer;
  font-size: 2rem;
  color: #667eea;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
  z-index: 10;
}

.nav-btn:hover {
  background: white;
  transform: translateY(-50%) scale(1.08);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.2);
}

.prev-btn {
  left: 32px;
}

.next-btn {
  right: 32px;
}

.arrow {
  line-height: 1;
}

/* 進度指示器 */
.progress-indicator {
  position: absolute;
  bottom: 24px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 8px;
  z-index: 10;
}

.dot {
  width: 10px;
  height: 10px;
  background: rgba(255, 255, 255, 0.4);
  border-radius: 50%;
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

.dot:hover {
  background: rgba(255, 255, 255, 0.7);
  transform: scale(1.15);
}

.dot.active {
  background: white;
  width: 28px;
  border-radius: 5px;
}

/* 投影片編號 */
.slide-number {
  position: absolute;
  top: 24px;
  right: 32px;
  background: rgba(255, 255, 255, 0.95);
  padding: 8px 14px;
  border-radius: 16px;
  font-size: 0.875rem;
  font-weight: 600;
  color: #667eea;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

/* 底部控制欄 */
.controls {
  background: rgba(0, 0, 0, 0.15);
  backdrop-filter: blur(12px);
  padding: 18px 36px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.control-btn {
  background: rgba(255, 255, 255, 0.95);
  border: none;
  padding: 11px 22px;
  border-radius: 10px;
  font-size: 0.9375rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  color: #667eea;
}

.control-btn:hover {
  background: white;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.complete-btn {
  background: linear-gradient(135deg, #4CAF50, #45a049);
  color: white;
}

.complete-btn:hover {
  background: linear-gradient(135deg, #45a049, #3d8b40);
}

.slide-title {
  color: white;
  font-size: 1.0625rem;
  font-weight: 600;
}

/* 響應式設計 */
@media (max-width: 768px) {
  .slide-container {
    padding: 20px;
  }

  .slide {
    max-height: none;
    height: auto;
  }

  .nav-btn {
    width: 50px;
    height: 50px;
    font-size: 28px;
  }

  .prev-btn {
    left: 10px;
  }

  .next-btn {
    right: 10px;
  }

  .slide-number {
    top: 10px;
    right: 10px;
  }

  .controls {
    padding: 16px 20px;
    flex-wrap: wrap;
    gap: 10px;
  }

  .slide-title {
    width: 100%;
    text-align: center;
    font-size: 16px;
  }
}
</style>
