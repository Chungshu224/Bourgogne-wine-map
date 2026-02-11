<template>
  <div class="chart-slide">
    <h2 class="slide-title">{{ slide.title }}</h2>
    <p v-if="slide.content" class="slide-description">{{ slide.content }}</p>
    
    <!-- 图表容器 -->
    <div class="chart-container" :class="`chart-type-${slide.chartType}`">
      <!-- 雷达图 -->
      <div v-if="slide.chartType === 'radar'" class="radar-chart">
        <svg :width="chartSize" :height="chartSize" :viewBox="`0 0 ${chartSize} ${chartSize}`">
          <!-- 网格线 -->
          <g v-for="level in 5" :key="`level-${level}`">
            <polygon
              :points="getPolygonPoints(level / 5)"
              fill="none"
              :stroke="level === 5 ? '#ddd' : '#eee'"
              :stroke-width="level === 5 ? 2 : 1"
            />
          </g>
          
          <!-- 轴线和标签 -->
          <g v-for="(dimension, index) in slide.data.dimensions" :key="`axis-${index}`">
            <line
              :x1="centerX"
              :y1="centerY"
              :x2="getAxisPoint(index).x"
              :y2="getAxisPoint(index).y"
              stroke="#ddd"
              stroke-width="1"
            />
            <text
              :x="getLabelPoint(index).x"
              :y="getLabelPoint(index).y"
              text-anchor="middle"
              dominant-baseline="middle"
              class="dimension-label"
            >
              {{ dimension }}
            </text>
          </g>
          
          <!-- 数据多边形 -->
          <g v-for="(dataset, idx) in slide.data.datasets" :key="`dataset-${idx}`">
            <polygon
              :points="getDataPolygonPoints(dataset.values)"
              :fill="dataset.color"
              :fill-opacity="dataset.opacity || 0.3"
              :stroke="dataset.color"
              :stroke-width="2"
            />
            <!-- 数据点 -->
            <circle
              v-for="(value, i) in dataset.values"
              :key="`point-${idx}-${i}`"
              :cx="getDataPoint(i, value).x"
              :cy="getDataPoint(i, value).y"
              :r="4"
              :fill="dataset.color"
            />
          </g>
        </svg>
        
        <!-- 图例 -->
        <div class="chart-legend">
          <div v-for="(dataset, idx) in slide.data.datasets" :key="`legend-${idx}`" class="legend-item">
            <span class="legend-color" :style="{ backgroundColor: dataset.color }"></span>
            <span class="legend-label">{{ dataset.label }}</span>
          </div>
        </div>
      </div>
      
      <!-- 条形图 -->
      <div v-if="slide.chartType === 'bar'" class="bar-chart">
        <div class="bar-chart-grid">
          <div v-for="item in slide.data.items" :key="item.label" class="bar-item">
            <div class="bar-label">{{ item.label }}</div>
            <div class="bar-wrapper">
              <div 
                class="bar-fill" 
                :style="{ 
                  width: `${item.value}%`, 
                  backgroundColor: item.color || '#8B4789' 
                }"
              >
                <span class="bar-value">{{ item.displayValue || item.value }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- 饼图 -->
      <div v-if="slide.chartType === 'pie'" class="pie-chart">
        <svg :width="pieSize" :height="pieSize" :viewBox="`0 0 ${pieSize} ${pieSize}`">
          <g :transform="`translate(${pieSize/2}, ${pieSize/2})`">
            <path
              v-for="(slice, index) in pieSlices"
              :key="`slice-${index}`"
              :d="slice.path"
              :fill="slice.color"
              :stroke="'white'"
              :stroke-width="2"
            />
            <!-- 百分比标签 -->
            <text
              v-for="(slice, index) in pieSlices"
              :key="`label-${index}`"
              :x="slice.labelX"
              :y="slice.labelY"
              text-anchor="middle"
              dominant-baseline="middle"
              class="slice-label"
            >
              {{ slice.percentage }}%
            </text>
          </g>
        </svg>
        
        <!-- 图例 -->
        <div class="chart-legend pie-legend">
          <div v-for="(item, idx) in slide.data.items" :key="`pie-legend-${idx}`" class="legend-item">
            <span class="legend-color" :style="{ backgroundColor: item.color }"></span>
            <span class="legend-label">{{ item.label }}</span>
            <span class="legend-value">{{ item.value }}{{ slide.data.unit || '%' }}</span>
          </div>
        </div>
      </div>
      
      <!-- 时间轴图 -->
      <div v-if="slide.chartType === 'timeline'" class="timeline-chart">
        <div class="timeline-item" v-for="item in slide.data.items" :key="item.year">
          <div class="timeline-year">{{ item.year }}</div>
          <div class="timeline-bar-container">
            <div 
              class="timeline-bar" 
              :style="{ 
                width: `${(item.score / 100) * 100}%`,
                backgroundColor: getScoreColor(item.score)
              }"
            >
              <span class="timeline-score">{{ item.score }}</span>
            </div>
          </div>
          <div class="timeline-label">{{ item.label }}</div>
        </div>
      </div>
      
      <!-- 对比表格 -->
      <div v-if="slide.chartType === 'comparison'" class="comparison-table">
        <table>
          <thead>
            <tr>
              <th>{{ slide.data.rowHeader }}</th>
              <th v-for="col in slide.data.columns" :key="col">{{ col }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in slide.data.rows" :key="row.label">
              <td class="row-label">{{ row.label }}</td>
              <td v-for="(value, idx) in row.values" :key="`cell-${idx}`">{{ value }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      
      <!-- 香氣輪 -->
      <div v-if="slide.chartType === 'aromaWheel'" class="aroma-wheel">
        <svg :width="pieSize * 1.5" :height="pieSize * 1.5" :viewBox="`0 0 ${pieSize * 1.5} ${pieSize * 1.5}`">
          <g :transform="`translate(${pieSize * 0.75}, ${pieSize * 0.75})`">
            <!-- 外圈 - 具體香氣 -->
            <g v-for="(segment, idx) in aromaWheelSegments" :key="`outer-${idx}`">
              <path
                :d="segment.outerPath"
                :fill="segment.color"
                :stroke="'white'"
                :stroke-width="2"
                class="aroma-segment"
              />
              <text
                :x="segment.outerLabelX"
                :y="segment.outerLabelY"
                :transform="`rotate(${segment.labelRotation}, ${segment.outerLabelX}, ${segment.outerLabelY})`"
                text-anchor="middle"
                class="aroma-label-outer"
              >
                {{ segment.item }}
              </text>
            </g>
            <!-- 內圈 - 主要類別 -->
            <g v-for="(category, idx) in aromaCategories" :key="`inner-${idx}`">
              <path
                :d="category.innerPath"
                :fill="category.color"
                :fill-opacity="0.8"
                :stroke="'white'"
                :stroke-width="3"
                class="aroma-category"
              />
              <text
                :x="category.innerLabelX"
                :y="category.innerLabelY"
                text-anchor="middle"
                dominant-baseline="middle"
                class="aroma-label-inner"
              >
                {{ category.name }}
              </text>
            </g>
            <!-- 中心標題 -->
            <circle r="40" fill="white" stroke="#ddd" stroke-width="2"/>
            <text text-anchor="middle" dominant-baseline="middle" class="aroma-title">
              {{ slide.data.centerLabel || '香氣輪' }}
            </text>
          </g>
        </svg>
      </div>
    </div>
    
    <!-- 备注 -->
    <div v-if="slide.note" class="chart-note">
      <span class="note-icon">💡</span>
      {{ slide.note }}
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  slide: {
    type: Object,
    required: true
  }
})

// 图表尺寸
const chartSize = 400
const centerX = chartSize / 2
const centerY = chartSize / 2
const radius = 150
const pieSize = 300

// 雷达图计算
const getAxisPoint = (index) => {
  const dimensions = props.slide.data?.dimensions?.length || 1
  const angle = (Math.PI * 2 * index) / dimensions - Math.PI / 2
  return {
    x: centerX + radius * Math.cos(angle),
    y: centerY + radius * Math.sin(angle)
  }
}

const getLabelPoint = (index) => {
  const dimensions = props.slide.data?.dimensions?.length || 1
  const angle = (Math.PI * 2 * index) / dimensions - Math.PI / 2
  const labelRadius = radius + 30
  return {
    x: centerX + labelRadius * Math.cos(angle),
    y: centerY + labelRadius * Math.sin(angle)
  }
}

const getPolygonPoints = (scale) => {
  const dimensions = props.slide.data?.dimensions?.length || 1
  const points = []
  for (let i = 0; i < dimensions; i++) {
    const angle = (Math.PI * 2 * i) / dimensions - Math.PI / 2
    const x = centerX + radius * scale * Math.cos(angle)
    const y = centerY + radius * scale * Math.sin(angle)
    points.push(`${x},${y}`)
  }
  return points.join(' ')
}

const getDataPoint = (index, value) => {
  const dimensions = props.slide.data?.dimensions?.length || 1
  const angle = (Math.PI * 2 * index) / dimensions - Math.PI / 2
  const scale = value / 10 // 假设最大值为10
  return {
    x: centerX + radius * scale * Math.cos(angle),
    y: centerY + radius * scale * Math.sin(angle)
  }
}

const getDataPolygonPoints = (values) => {
  const points = values.map((value, index) => {
    const point = getDataPoint(index, value)
    return `${point.x},${point.y}`
  })
  return points.join(' ')
}

// 饼图计算
const pieSlices = computed(() => {
  if (props.slide.chartType !== 'pie' || !props.slide.data?.items) return []
  
  const items = props.slide.data.items
  const total = items.reduce((sum, item) => sum + item.value, 0)
  let currentAngle = -90 // 从12点方向开始
  
  return items.map(item => {
    const percentage = (item.value / total * 100).toFixed(1)
    const angleSize = (item.value / total) * 360
    const startAngle = currentAngle * Math.PI / 180
    const endAngle = (currentAngle + angleSize) * Math.PI / 180
    
    const x1 = Math.cos(startAngle) * 120
    const y1 = Math.sin(startAngle) * 120
    const x2 = Math.cos(endAngle) * 120
    const y2 = Math.sin(endAngle) * 120
    
    const largeArc = angleSize > 180 ? 1 : 0
    const path = `M 0 0 L ${x1} ${y1} A 120 120 0 ${largeArc} 1 ${x2} ${y2} Z`
    
    // 标签位置（在扇形中心）
    const midAngle = (startAngle + endAngle) / 2
    const labelX = Math.cos(midAngle) * 70
    const labelY = Math.sin(midAngle) * 70
    
    currentAngle += angleSize
    
    return {
      path,
      color: item.color,
      percentage,
      labelX,
      labelY
    }
  })
})

// 分数颜色映射
const getScoreColor = (score) => {
  if (score >= 95) return '#9C27B0' // 紫色 - 卓越
  if (score >= 90) return '#4CAF50' // 绿色 - 优秀
  if (score >= 85) return '#FF9800' // 橙色 - 良好
  return '#9E9E9E' // 灰色 - 普通
}

// 香氣輪計算
const aromaCategories = computed(() => {
  if (props.slide.chartType !== 'aromaWheel' || !props.slide.data?.categories) return []
  
  const categories = props.slide.data.categories
  const totalItems = categories.reduce((sum, cat) => sum + cat.items.length, 0)
  let currentAngle = -90
  
  return categories.map(category => {
    const categoryAngleSize = (category.items.length / totalItems) * 360
    const startAngle = currentAngle * Math.PI / 180
    const endAngle = (currentAngle + categoryAngleSize) * Math.PI / 180
    const midAngle = (startAngle + endAngle) / 2
    
    // 內圈路徑 (半徑 60-120)
    const innerRadius = 60
    const outerRadius = 120
    const x1 = Math.cos(startAngle) * innerRadius
    const y1 = Math.sin(startAngle) * innerRadius
    const x2 = Math.cos(endAngle) * innerRadius
    const y2 = Math.sin(endAngle) * innerRadius
    const x3 = Math.cos(endAngle) * outerRadius
    const y3 = Math.sin(endAngle) * outerRadius
    const x4 = Math.cos(startAngle) * outerRadius
    const y4 = Math.sin(startAngle) * outerRadius
    
    const largeArc = categoryAngleSize > 180 ? 1 : 0
    const innerPath = `M ${x1} ${y1} A ${innerRadius} ${innerRadius} 0 ${largeArc} 1 ${x2} ${y2} L ${x3} ${y3} A ${outerRadius} ${outerRadius} 0 ${largeArc} 0 ${x4} ${y4} Z`
    
    // 標籤位置
    const labelRadius = 90
    const innerLabelX = Math.cos(midAngle) * labelRadius
    const innerLabelY = Math.sin(midAngle) * labelRadius
    
    currentAngle += categoryAngleSize
    
    return {
      name: category.name,
      color: category.color,
      innerPath,
      innerLabelX,
      innerLabelY
    }
  })
})

const aromaWheelSegments = computed(() => {
  if (props.slide.chartType !== 'aromaWheel' || !props.slide.data?.categories) return []
  
  const categories = props.slide.data.categories
  const totalItems = categories.reduce((sum, cat) => sum + cat.items.length, 0)
  let currentAngle = -90
  const segments = []
  
  categories.forEach(category => {
    const itemAngleSize = 360 / totalItems
    
    category.items.forEach(item => {
      const startAngle = currentAngle * Math.PI / 180
      const endAngle = (currentAngle + itemAngleSize) * Math.PI / 180
      const midAngle = (startAngle + endAngle) / 2
      
      // 外圈路徑 (半徑 120-180)
      const innerRadius = 120
      const outerRadius = 180
      const x1 = Math.cos(startAngle) * innerRadius
      const y1 = Math.sin(startAngle) * innerRadius
      const x2 = Math.cos(endAngle) * innerRadius
      const y2 = Math.sin(endAngle) * innerRadius
      const x3 = Math.cos(endAngle) * outerRadius
      const y3 = Math.sin(endAngle) * outerRadius
      const x4 = Math.cos(startAngle) * outerRadius
      const y4 = Math.sin(startAngle) * outerRadius
      
      const largeArc = itemAngleSize > 180 ? 1 : 0
      const outerPath = `M ${x1} ${y1} A ${innerRadius} ${innerRadius} 0 ${largeArc} 1 ${x2} ${y2} L ${x3} ${y3} A ${outerRadius} ${outerRadius} 0 ${largeArc} 0 ${x4} ${y4} Z`
      
      // 標籤位置和旋轉
      const labelRadius = 150
      const outerLabelX = Math.cos(midAngle) * labelRadius
      const outerLabelY = Math.sin(midAngle) * labelRadius
      const labelRotation = (midAngle * 180 / Math.PI + 90)
      
      segments.push({
        item,
        color: category.color,
        outerPath,
        outerLabelX,
        outerLabelY,
        labelRotation: labelRotation > 90 && labelRotation < 270 ? labelRotation + 180 : labelRotation
      })
      
      currentAngle += itemAngleSize
    })
  })
  
  return segments
})
</script>

<style scoped>
.chart-slide {
  width: 100%;
  height: 100%;
  padding: 48px;
  background: white;
  display: flex;
  flex-direction: column;
  align-items: center;
  overflow-y: auto;
}

.slide-title {
  font-size: 32px;
  font-weight: 700;
  color: #2c3e50;
  margin-bottom: 16px;
  text-align: center;
}

.slide-description {
  font-size: 16px;
  color: #666;
  text-align: center;
  margin-bottom: 32px;
  max-width: 800px;
}

.chart-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 100%;
  max-width: 900px;
}

/* 雷达图 */
.radar-chart {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
}

.dimension-label {
  font-size: 14px;
  font-weight: 600;
  fill: #333;
}

/* 条形图 */
.bar-chart-grid {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.bar-item {
  display: grid;
  grid-template-columns: 180px 1fr;
  align-items: center;
  gap: 16px;
}

.bar-label {
  font-size: 15px;
  font-weight: 600;
  color: #333;
  text-align: right;
}

.bar-wrapper {
  background: #f0f0f0;
  border-radius: 8px;
  height: 32px;
  position: relative;
  overflow: hidden;
}

.bar-fill {
  height: 100%;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  padding-right: 12px;
  transition: width 0.8s ease;
}

.bar-value {
  color: white;
  font-weight: 700;
  font-size: 13px;
}

/* 饼图 */
.pie-chart {
  display: flex;
  align-items: center;
  gap: 48px;
}

.slice-label {
  font-size: 16px;
  font-weight: 700;
  fill: white;
  text-shadow: 1px 1px 3px rgba(0,0,0,0.5);
}

.pie-legend {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

/* 时间轴图 */
.timeline-chart {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.timeline-item {
  display: grid;
  grid-template-columns: 80px 1fr 200px;
  align-items: center;
  gap: 16px;
}

.timeline-year {
  font-size: 18px;
  font-weight: 700;
  color: #333;
  text-align: right;
}

.timeline-bar-container {
  background: #f0f0f0;
  border-radius: 6px;
  height: 28px;
  position: relative;
  overflow: hidden;
}

.timeline-bar {
  height: 100%;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  padding-right: 8px;
  transition: width 0.8s ease;
}

.timeline-score {
  color: white;
  font-weight: 700;
  font-size: 12px;
}

.timeline-label {
  font-size: 13px;
  color: #666;
}

/* 对比表格 */
.comparison-table {
  width: 100%;
  overflow-x: auto;
}

.comparison-table table {
  width: 100%;
  border-collapse: collapse;
  background: white;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  border-radius: 8px;
  overflow: hidden;
}

.comparison-table th {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 16px;
  text-align: left;
  font-weight: 600;
}

.comparison-table td {
  padding: 12px 16px;
  border-bottom: 1px solid #eee;
}

.comparison-table tr:last-child td {
  border-bottom: none;
}

.row-label {
  font-weight: 600;
  color: #333;
}

/* 图例 */
.chart-legend {
  display: flex;
  gap: 24px;
  flex-wrap: wrap;
  justify-content: center;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.legend-color {
  width: 20px;
  height: 20px;
  border-radius: 4px;
}

.legend-label {
  font-size: 14px;
  font-weight: 600;
  color: #333;
}

.legend-value {
  font-size: 13px;
  color: #666;
}

/* 备注 */
.chart-note {
  margin-top: 24px;
  padding: 16px 24px;
  background: #fff8e1;
  border-left: 4px solid #ffc107;
  border-radius: 4px;
  font-size: 14px;
  color: #666;
  max-width: 800px;
}

.note-icon {
  margin-right: 8px;
}

/* 香氣輪 */
.aroma-wheel {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.aroma-segment {
  cursor: pointer;
  transition: opacity 0.2s;
}

.aroma-segment:hover {
  opacity: 0.8;
}

.aroma-category {
  cursor: pointer;
  transition: opacity 0.2s;
}

.aroma-category:hover {
  opacity: 0.9;
}

.aroma-label-inner {
  font-size: 14px;
  font-weight: 700;
  fill: white;
  pointer-events: none;
}

.aroma-label-outer {
  font-size: 11px;
  font-weight: 600;
  fill: white;
  pointer-events: none;
}

.aroma-title {
  font-size: 16px;
  font-weight: 700;
  fill: #333;
}
</style>
