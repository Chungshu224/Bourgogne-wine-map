<template>
  <div class="intro-slide">
    <div class="intro-header">
      <h1 class="intro-title">課程導讀</h1>
    </div>

    <div class="intro-content">
      <!-- 課程描述 -->
      <div class="intro-description">
        <p>{{ description }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  slide: {
    type: Object,
    required: true
  }
})

// 課程描述
const description = computed(() => {
  return props.slide.description || props.slide.content || '本課程將帶您深入了解布根地葡萄酒的精髓。'
})
</script>

<style scoped>
.intro-slide {
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 60px 80px;
  background: white;
  overflow-y: auto;
}

.intro-header {
  text-align: center;
  margin-bottom: 50px;
}

.intro-title {
  font-size: 2.5rem;
  font-weight: 700;
  color: #2c3e50;
  margin: 0;
  letter-spacing: 2px;
}

.intro-content {
  max-width: 1000px;
  margin: 0 auto;
  width: 100%;
}

/* 課程描述 */
.intro-description {
  background: #f8f9fa;
  border-left: 4px solid #667eea;
  border-radius: 12px;
  padding: 35px 40px;
}

.intro-description p {
  font-size: 1.15rem;
  line-height: 2;
  color: #495057;
  margin: 0;
  text-align: justify;
}

/* 響應式設計 */
@media (max-width: 768px) {
  .intro-slide {
    padding: 40px 30px;
  }

  .intro-title {
    font-size: 2rem;
  }

  .intro-description {
    padding: 25px 30px;
  }

  .intro-description p {
    font-size: 1rem;
    line-height: 1.8;
  }
}
</style>
