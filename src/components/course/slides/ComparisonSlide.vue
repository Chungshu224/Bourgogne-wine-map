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
defineProps({
  slide: {
    type: Object,
    required: true
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
}
</style>
