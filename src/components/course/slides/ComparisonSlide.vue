<template>
  <div class="comparison-slide">
    <div class="slide-header">
      <h2>{{ slide.title }}</h2>
    </div>
    <div class="slide-body">
      <!-- 金字塔分級顯示 -->
      <div v-if="slide.pyramid" class="pyramid-container">
        <div class="pyramid">
          <div 
            v-for="level in slide.pyramid.levels" 
            :key="level.level"
            class="pyramid-level"
            :style="{ 
              backgroundColor: level.color,
              width: `${level.level * 25}%`
            }"
          >
            <div class="level-content">
              <h3>{{ level.name }}</h3>
              <div class="level-stats">
                <span class="percentage">{{ level.percentage }}</span>
                <span class="yield">{{ level.maxYield }}</span>
              </div>
              <p class="level-desc">{{ level.description }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- 品種對比網格 -->
      <div v-else-if="slide.grapes" class="comparison-grid">
        <div 
          v-for="grape in slide.grapes" 
          :key="grape.name" 
          class="grape-card"
        >
          <div class="grape-header">
            <span class="grape-emoji">{{ grape.emoji }}</span>
            <h3>{{ grape.name }}</h3>
          </div>
          <div class="grape-content">
            <div 
              v-for="(value, key) in grape.characteristics" 
              :key="key" 
              class="char-row"
            >
              <strong>{{ formatKey(key) }}</strong>
              <span>{{ value }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 左右對比佈局 -->
      <div v-else-if="slide.leftTitle && slide.rightTitle" class="side-by-side-comparison">
        <div class="comparison-column left">
          <h3 class="column-title">{{ slide.leftTitle }}</h3>
          <ul class="comparison-points">
            <li v-for="(point, index) in slide.leftPoints" :key="index">
              {{ point }}
            </li>
          </ul>
        </div>
        <div class="comparison-divider">
          <span class="vs-text">VS</span>
        </div>
        <div class="comparison-column right">
          <h3 class="column-title">{{ slide.rightTitle }}</h3>
          <ul class="comparison-points">
            <li v-for="(point, index) in slide.rightPoints" :key="index">
              {{ point }}
            </li>
          </ul>
        </div>
      </div>

      <!-- 通用對比表 -->
      <div v-else-if="slide.comparison" class="comparison-table">
        <table>
          <thead>
            <tr>
              <th v-for="header in slide.comparison.headers" :key="header">
                {{ header }}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, index) in slide.comparison.rows" :key="index">
              <td v-for="(cell, cellIndex) in row" :key="cellIndex">
                {{ cell }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'

const props = defineProps({
  slide: {
    type: Object,
    required: true
  }
})

onMounted(() => {
  console.log('ComparisonSlide mounted')
  console.log('  slide:', props.slide)
  console.log('  slide.comparison:', props.slide.comparison)
  if (props.slide.comparison) {
    console.log('  headers:', props.slide.comparison.headers)
    console.log('  rows:', props.slide.comparison.rows)
  }
})

const formatKey = (key) => {
  const keyMap = {
    color: '顏色',
    body: '酒體',
    acidity: '酸度',
    tannin: '單寧',
    alcohol: '酒精度',
    aroma: '香氣',
    flavor: '風味'
  }
  return keyMap[key] || key
}
</script>

<style scoped>
.comparison-slide {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 48px 56px;
  border-radius: 24px;
}

.slide-header {
  margin-bottom: 28px;
}

.slide-header h2 {
  font-size: 2rem;
  font-weight: 700;
  color: #2c3e50;
  margin: 0;
  border-bottom: 3px solid #667eea;
  padding-bottom: 16px;
  line-height: 1.3;
}

.slide-body {
  flex: 1;
  overflow-y: auto;
}

.comparison-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
}

.grape-card {
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  border-radius: 14px;
  padding: 20px;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

.grape-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);
}

.grape-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 18px;
  padding-bottom: 14px;
  border-bottom: 2px solid #667eea;
}

.grape-emoji {
  font-size: 2rem;
}

.grape-header h3 {
  font-size: 1.375rem;
  font-weight: 700;
  color: #2c3e50;
  margin: 0;
  line-height: 1.3;
}

.grape-content {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.char-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 12px;
  background: white;
  border-radius: 8px;
  font-size: 0.9375rem;
}

.char-row strong {
  color: #667eea;
  font-weight: 600;
}

.char-row span {
  color: #2c3e50;
}

/* 金字塔樣式 */
.pyramid-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 480px;
}

.pyramid {
  display: flex;
  flex-direction: column-reverse;
  align-items: center;
  gap: 8px;
  width: 100%;
  max-width: 800px;
}

.pyramid-level {
  border-radius: 8px;
  padding: 18px;
  color: white;
  text-align: center;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  min-height: 95px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
}

.pyramid-level:hover {
  transform: scale(1.04);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
}

.level-content h3 {
  font-size: 1.25rem;
  font-weight: 700;
  margin: 0 0 8px 0;
  line-height: 1.3;
}

.level-stats {
  display: flex;
  gap: 18px;
  justify-content: center;
  margin-bottom: 6px;
  font-size: 0.9375rem;
  font-weight: 600;
}

.level-desc {
  font-size: 0.875rem;
  opacity: 0.95;
  margin: 4px 0 0 0;
  line-height: 1.5;
}

/* 對比表樣式 */
.comparison-table {
  width: 100%;
  overflow-x: auto;
}

.comparison-table table {
  width: 100%;
  border-collapse: collapse;
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
}

.comparison-table th {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  padding: 14px 16px;
  font-weight: 700;
  font-size: 0.9375rem;
  text-align: left;
}

.comparison-table td {
  padding: 12px 16px;
  border-bottom: 1px solid #e0e0e0;
  color: #2c3e50;
  font-size: 0.9375rem;
  line-height: 1.6;
}

.comparison-table tr:last-child td {
  border-bottom: none;
}

.comparison-table tr:hover {
  background: #f5f7fa;
}

/* 左右對比佈局樣式 */
.side-by-side-comparison {
  display: flex;
  align-items: stretch;
  gap: 32px;
  max-width: 1000px;
  margin: 0 auto;
  height: 100%;
  padding: 20px 0;
}

.comparison-column {
  flex: 1;
  background: linear-gradient(135deg, #f5f7fa 0%, #e3eaf2 100%);
  border-radius: 16px;
  padding: 32px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  flex-direction: column;
}

.comparison-column:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.25);
}

.comparison-column.left {
  border-left: 4px solid #667eea;
}

.comparison-column.right {
  border-right: 4px solid #764ba2;
}

.column-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: #2c3e50;
  margin: 0 0 24px 0;
  padding-bottom: 16px;
  border-bottom: 2px solid #667eea;
  text-align: center;
}

.comparison-column.right .column-title {
  border-bottom-color: #764ba2;
}

.comparison-points {
  list-style: none;
  padding: 0;
  margin: 0;
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.comparison-points li {
  font-size: 1.125rem;
  line-height: 1.6;
  color: #2c3e50;
  padding: 12px 16px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.06);
  position: relative;
  padding-left: 40px;
  transition: all 0.25s ease;
}

.comparison-points li:hover {
  transform: translateX(4px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
}

.comparison-points li::before {
  content: '✓';
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: #667eea;
  font-weight: 700;
  font-size: 1.25rem;
}

.comparison-column.right .comparison-points li::before {
  color: #764ba2;
}

.comparison-divider {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 60px;
  flex-shrink: 0;
}

.vs-text {
  font-size: 2rem;
  font-weight: 700;
  color: #667eea;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  padding: 16px;
  border: 3px solid #667eea;
  border-radius: 50%;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

@media (max-width: 768px) {
  .comparison-slide {
    padding: 40px 30px;
  }

  .slide-header h2 {
    font-size: 28px;
  }

  .comparison-grid {
    grid-template-columns: 1fr;
  }

  .grape-card {
    padding: 20px;
  }

  .grape-header h3 {
    font-size: 20px;
  }

  .side-by-side-comparison {
    flex-direction: column;
    gap: 24px;
  }

  .comparison-divider {
    width: 100%;
    height: 50px;
  }

  .vs-text {
    width: 50px;
    height: 50px;
    font-size: 1.5rem;
  }

  .comparison-column {
    padding: 24px;
  }

  .column-title {
    font-size: 1.25rem;
  }

  .comparison-points li {
    font-size: 1rem;
    padding: 10px 14px;
    padding-left: 36px;
  }
}
</style>
