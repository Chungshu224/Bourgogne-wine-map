<template>
  <div class="lesson-viewer">
    <div class="lesson-header">
      <div class="breadcrumb">
        <span>模組 {{ moduleOrder }}</span>
        <span class="separator">›</span>
        <span>課程 {{ lessonNumber }}/{{ totalLessons }}</span>
      </div>
      <h1>{{ lesson.title }}</h1>
      <div class="lesson-meta">
        <span class="duration">⏱️ {{ lesson.duration }}</span>
        <span class="type">📖 {{ getLessonTypeName(lesson.type) }}</span>
      </div>
    </div>

    <div class="lesson-content">
      <!-- 簡介 -->
      <div v-if="lesson.content.introduction" class="introduction">
        <p>{{ lesson.content.introduction }}</p>
      </div>

      <!-- 章節內容 -->
      <div v-for="(section, index) in lesson.content.sections" :key="index" class="section">
        <h2 v-if="section.heading">{{ section.heading }}</h2>
        <p v-if="section.text" class="section-text">{{ section.text }}</p>

        <!-- 重點列表 -->
        <ul v-if="section.keyPoints" class="key-points">
          <li v-for="(point, i) in section.keyPoints" :key="i">{{ point }}</li>
        </ul>

        <!-- 產區列表 -->
        <div v-if="section.regions" class="regions-grid">
          <div v-for="(region, i) in section.regions" :key="i" class="region-card">
            <h3>{{ region.name }}</h3>
            <p class="region-fr">{{ region.nameFr }}</p>
            <p class="region-highlight">✨ {{ region.highlight }}</p>
          </div>
        </div>
      </div>

      <!-- 時間軸 -->
      <div v-if="lesson.content.timeline" class="timeline">
        <h2>📅 歷史時間軸</h2>
        <div class="timeline-items">
          <div v-for="(item, index) in lesson.content.timeline" :key="index" class="timeline-item">
            <div class="timeline-year">{{ item.year }}</div>
            <div class="timeline-event">{{ item.event }}</div>
          </div>
        </div>
      </div>

      <!-- 葡萄品種對比 -->
      <div v-if="lesson.content.grapes" class="grapes-comparison">
        <div v-for="grape in lesson.content.grapes" :key="grape.name" class="grape-section">
          <div class="grape-header">
            <span class="grape-emoji">{{ grape.emoji }}</span>
            <h2>{{ grape.name }}</h2>
          </div>

          <div class="characteristics">
            <div v-for="(value, key) in grape.characteristics" :key="key" class="char-item">
              <strong>{{ formatCharKey(key) }}：</strong>
              <span>{{ value }}</span>
            </div>
          </div>

          <div v-if="grape.regions" class="grape-regions">
            <h3>主要產區：</h3>
            <ul>
              <li v-for="(region, i) in grape.regions" :key="i">{{ region }}</li>
            </ul>
          </div>

          <div v-if="grape.tastingNotes" class="tasting-notes">
            <h3>🍷 品飲筆記：</h3>
            <ul>
              <li v-for="(note, i) in grape.tastingNotes" :key="i">{{ note }}</li>
            </ul>
          </div>

          <div v-if="grape.temperature" class="temperature">
            <span>🌡️ {{ grape.temperature }}</span>
          </div>
        </div>
      </div>

      <!-- 酒標元素 -->
      <div v-if="lesson.content.labelElements" class="label-elements">
        <h2>🏷️ 酒標組成元素</h2>
        <div v-for="(element, index) in lesson.content.labelElements" :key="index" class="label-element">
          <h3>{{ index + 1 }}. {{ element.element }}</h3>
          <p><strong>位置：</strong>{{ element.position }}</p>
          <p><strong>重要性：</strong>{{ element.importance }}</p>
          
          <ul v-if="element.examples">
            <li v-for="(example, i) in element.examples" :key="i">{{ example }}</li>
          </ul>

          <div v-if="element.hierarchy" class="hierarchy">
            <strong>分級層次：</strong>
            <ol>
              <li v-for="(level, i) in element.hierarchy" :key="i">{{ level }}</li>
            </ol>
          </div>
        </div>
      </div>

      <!-- 閱讀範例 -->
      <div v-if="lesson.content.readingExamples" class="reading-examples">
        <h2>📖 酒標閱讀範例</h2>
        <div v-for="(example, index) in lesson.content.readingExamples" :key="index" class="example-card">
          <div class="example-label">{{ example.label }}</div>
          <div class="example-interpretation">
            <strong>解讀：</strong>{{ example.interpretation }}
          </div>
          <div class="example-level">
            <span class="level-badge" :class="'level-' + example.level">{{ example.level }}</span>
          </div>
          <div class="example-notes">💡 {{ example.notes }}</div>
        </div>
      </div>

      <!-- 提示列表 -->
      <div v-if="lesson.content.tips" class="tips-section">
        <h2>💡 實用提示</h2>
        <div v-for="(tip, index) in lesson.content.tips" :key="index" class="tip-item">
          {{ tip }}
        </div>
      </div>

      <!-- 總結 -->
      <div v-if="lesson.content.summary" class="summary">
        <h3>📝 本課總結</h3>
        <p>{{ lesson.content.summary }}</p>
      </div>

      <!-- 地圖互動提示 -->
      <div v-if="lesson.content.mapInteraction" class="map-interaction">
        <div class="map-hint">
          🗺️ {{ lesson.content.mapInteraction.instructions }}
        </div>
        <button class="map-btn" @click="openMap">打開互動地圖</button>
      </div>
    </div>

    <!-- 課程導航 -->
    <div class="lesson-navigation">
      <button 
        v-if="lessonNumber > 1" 
        class="nav-btn prev-btn"
        @click="$emit('previousLesson')"
      >
        ← 上一課
      </button>
      <button 
        class="nav-btn complete-btn"
        @click="completeLesson"
      >
        {{ lessonNumber < totalLessons ? '完成並繼續 →' : '完成課程' }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { defineProps, defineEmits } from 'vue'

const props = defineProps({
  lesson: {
    type: Object,
    required: true
  },
  lessonNumber: {
    type: Number,
    required: true
  },
  totalLessons: {
    type: Number,
    required: true
  },
  moduleOrder: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['previousLesson', 'nextLesson', 'completeLesson', 'openMap'])

const getLessonTypeName = (type) => {
  const types = {
    'video-text': '影片+文字',
    'text-images': '圖文教學',
    'comparison': '對比學習',
    'interactive': '互動練習'
  }
  return types[type] || '一般課程'
}

const formatCharKey = (key) => {
  const keyNames = {
    origin: '起源',
    skinColor: '果皮特徵',
    aromatic: '香氣特徵',
    structure: '結構',
    ageingPotential: '陳年潛力',
    difficulty: '種植難度',
    versatility: '多樣性',
    winemaking: '釀造影響'
  }
  return keyNames[key] || key
}

const completeLesson = () => {
  emit('completeLesson', props.lesson.id)
}

const openMap = () => {
  emit('openMap', props.lesson.content.mapInteraction)
}
</script>

<style scoped>
.lesson-viewer {
  max-width: 900px;
  margin: 0 auto;
  background: white;
  border-radius: 12px;
  padding: 40px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.lesson-header {
  margin-bottom: 40px;
  border-bottom: 2px solid #f0f0f0;
  padding-bottom: 24px;
}

.breadcrumb {
  font-size: 13px;
  color: #95a5a6;
  margin-bottom: 12px;
}

.separator {
  margin: 0 8px;
}

.lesson-header h1 {
  font-size: 32px;
  color: #2c3e50;
  margin: 0 0 12px 0;
  font-weight: 700;
}

.lesson-meta {
  display: flex;
  gap: 20px;
  font-size: 14px;
  color: #7f8c8d;
}

.lesson-content {
  line-height: 1.8;
  color: #34495e;
}

.introduction {
  background: #e8f5e9;
  border-left: 4px solid #4CAF50;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 32px;
}

.introduction p {
  margin: 0;
  font-size: 16px;
  color: #2c3e50;
  font-weight: 500;
}

.section {
  margin-bottom: 40px;
}

.section h2 {
  font-size: 24px;
  color: #2c3e50;
  margin-bottom: 16px;
  font-weight: 600;
}

.section-text {
  margin-bottom: 16px;
  line-height: 1.8;
}

.key-points {
  background: #f8f9fa;
  padding: 20px 20px 20px 40px;
  border-radius: 8px;
  margin: 16px 0;
}

.key-points li {
  margin-bottom: 12px;
  color: #2c3e50;
}

.regions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 16px;
  margin-top: 20px;
}

.region-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 20px;
  border-radius: 12px;
  transition: transform 0.3s ease;
}

.region-card:hover {
  transform: translateY(-4px);
}

.region-card h3 {
  margin: 0 0 4px 0;
  font-size: 18px;
}

.region-fr {
  font-size: 13px;
  opacity: 0.9;
  font-style: italic;
  margin: 0 0 8px 0;
}

.region-highlight {
  margin: 0;
  font-size: 14px;
  font-weight: 600;
}

.timeline {
  margin: 40px 0;
  padding: 30px;
  background: #f8f9fa;
  border-radius: 12px;
}

.timeline h2 {
  text-align: center;
  margin-bottom: 30px;
}

.timeline-items {
  position: relative;
  padding-left: 40px;
}

.timeline-items::before {
  content: '';
  position: absolute;
  left: 10px;
  top: 0;
  bottom: 0;
  width: 2px;
  background: #ddd;
}

.timeline-item {
  position: relative;
  margin-bottom: 24px;
  padding-left: 40px;
}

.timeline-item::before {
  content: '';
  position: absolute;
  left: 4px;
  top: 6px;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: #667eea;
  border: 2px solid white;
  box-shadow: 0 0 0 2px #667eea;
}

.timeline-year {
  font-weight: 700;
  color: #667eea;
  margin-bottom: 4px;
}

.timeline-event {
  color: #555;
  line-height: 1.6;
}

.grapes-comparison {
  margin: 40px 0;
}

.grape-section {
  background: #fafafa;
  padding: 30px;
  border-radius: 12px;
  margin-bottom: 24px;
}

.grape-header {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 24px;
}

.grape-emoji {
  font-size: 48px;
}

.grape-header h2 {
  margin: 0;
  font-size: 28px;
}

.characteristics {
  margin-bottom: 24px;
}

.char-item {
  margin-bottom: 12px;
  padding-left: 20px;
  border-left: 3px solid #667eea;
}

.char-item strong {
  color: #2c3e50;
}

.grape-regions,
.tasting-notes {
  margin-top: 20px;
}

.grape-regions h3,
.tasting-notes h3 {
  font-size: 16px;
  margin-bottom: 12px;
  color: #2c3e50;
}

.temperature {
  margin-top: 16px;
  padding: 12px;
  background: white;
  border-radius: 8px;
  text-align: center;
  font-weight: 600;
}

.label-elements {
  margin: 40px 0;
}

.label-element {
  background: #f8f9fa;
  padding: 24px;
  border-radius: 12px;
  margin-bottom: 20px;
}

.label-element h3 {
  color: #2c3e50;
  margin-bottom: 12px;
}

.hierarchy {
  margin-top: 12px;
}

.hierarchy ol {
  margin-left: 20px;
}

.reading-examples {
  margin: 40px 0;
}

.example-card {
  background: white;
  border: 2px solid #e0e0e0;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 16px;
}

.example-label {
  font-size: 24px;
  font-weight: 700;
  color: #2c3e50;
  text-align: center;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
  margin-bottom: 16px;
}

.example-interpretation {
  margin-bottom: 12px;
}

.level-badge {
  display: inline-block;
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  color: white;
}

.level-Village {
  background: #4CAF50;
}

.level-1er.Cru,
.level-Premier.Cru {
  background: #FF9800;
}

.level-Grand.Cru {
  background: #9C27B0;
}

.example-notes {
  margin-top: 12px;
  color: #7f8c8d;
  font-size: 14px;
}

.tips-section {
  margin: 40px 0;
  background: #fff3cd;
  padding: 30px;
  border-radius: 12px;
  border-left: 4px solid #ffc107;
}

.tip-item {
  padding: 12px 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
}

.tip-item:last-child {
  border-bottom: none;
}

.summary {
  margin: 40px 0;
  background: #e3f2fd;
  border-left: 4px solid #2196F3;
  padding: 24px;
  border-radius: 8px;
}

.summary h3 {
  margin-top: 0;
  color: #1976D2;
}

.map-interaction {
  margin: 40px 0;
  text-align: center;
  padding: 30px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  color: white;
}

.map-hint {
  font-size: 16px;
  margin-bottom: 20px;
  font-weight: 500;
}

.map-btn {
  padding: 14px 32px;
  background: white;
  color: #667eea;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s ease;
}

.map-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.lesson-navigation {
  display: flex;
  justify-content: space-between;
  margin-top: 50px;
  padding-top: 30px;
  border-top: 2px solid #f0f0f0;
}

.nav-btn {
  padding: 14px 28px;
  border: 2px solid #667eea;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.prev-btn {
  background: white;
  color: #667eea;
}

.prev-btn:hover {
  background: #f5f5f5;
}

.complete-btn {
  background: #667eea;
  color: white;
  margin-left: auto;
}

.complete-btn:hover {
  background: #5568d3;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}
</style>
