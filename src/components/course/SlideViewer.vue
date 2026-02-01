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
import MapSlide from './slides/MapSlide.vue'
import WinerySlide from './slides/WinerySlide.vue'

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

  // 2. 地圖投影片（如果有的話，放在第二頁）
  if (props.lesson.content?.mapSlide) {
    slideArray.push({
      type: 'map',
      title: props.lesson.content.mapSlide.title || '產區地圖',
      content: props.lesson.content.mapSlide.content,
      mapConfig: props.lesson.content.mapSlide.mapConfig,
      geojsonFiles: props.lesson.content.mapSlide.geojsonFiles,
      markers: props.lesson.content.mapSlide.markers
    })
  }

  // 2b. 多個地圖投影片（如果有的話）
  if (props.lesson.content?.mapSlides && Array.isArray(props.lesson.content.mapSlides)) {
    console.log('找到 mapSlides，數量:', props.lesson.content.mapSlides.length)
    props.lesson.content.mapSlides.forEach((mapSlide, index) => {
      console.log(`添加地圖 ${index + 1}:`, mapSlide.title)
      slideArray.push({
        type: 'map',
        title: mapSlide.title || '產區地圖',
        content: mapSlide.content,
        mapConfig: mapSlide.mapConfig,
        geojsonFiles: mapSlide.geojsonFiles,
        markers: mapSlide.markers
      })
    })
  } else {
    console.log('未找到 mapSlides 或不是陣列')
  }

  // 3. 內容投影片
  if (props.lesson.content?.sections) {
    console.log('📚 處理 sections, 數量:', props.lesson.content.sections.length)
    props.lesson.content.sections.forEach((section, index) => {
      console.log(`  Section ${index}:`, {
        hasHeading: !!section.heading,
        hasMapSlide: !!section.mapSlide,
        heading: section.heading
      })
      // 如果這個 section 有地圖配置，先添加地圖投影片
      if (section.mapSlide) {
        console.log('🗺️ 創建地圖投影片:', section.mapSlide.title)
        slideArray.push({
          type: 'map',
          title: section.mapSlide.title,
          mapConfig: section.mapSlide.mapConfig,
          geojsonFiles: section.mapSlide.geojsonFiles,
          markers: section.mapSlide.markers,
          interactive: true,
          buttonPosition: section.mapSlide.buttonPosition || 'left'
        })
      }

      if (section.heading) {
        let slideCreated = false
        
        try {
          // ===== 優先處理複雜的結構（互斥處理，按優先級）=====
          
          // 1. 如果有分類列表（如薄酒萊特級村分類）
          if (!slideCreated && section.categories && Array.isArray(section.categories) && section.categories.length > 0) {
            slideCreated = true
            console.log('✅ 處理 categories:', section.heading)
            
            // 先添加介紹投影片（如果有 text）
            if (section.text && typeof section.text === 'string') {
              slideArray.push({
                type: 'content',
                title: section.heading,
                content: section.text
              })
            }
            
            // 為每個分類創建投影片
            section.categories.forEach(category => {
              if (!category || typeof category !== 'object') return
              
              const contentParts = []
              if (category.type) contentParts.push(`**${category.type}**`)
              if (category.description) contentParts.push(`${category.description}\n`)
              
              if (category.villages && Array.isArray(category.villages) && category.villages.length > 0) {
                contentParts.push('**代表村莊：**')
                category.villages.forEach(v => {
                  if (v) contentParts.push(`• ${v}`)
                })
                contentParts.push('')
              }
              
              if (category.recommendation) contentParts.push(`📌 ${category.recommendation}`)
              
              if (contentParts.length > 0) {
                slideArray.push({
                  type: 'content',
                  title: section.heading,
                  content: contentParts.join('\n')
                })
              }
            })
          }
          
          // 2. 如果有村莊風味輪廓（為每個村莊創建獨立投影片）
          if (!slideCreated && section.villageProfiles && Array.isArray(section.villageProfiles) && section.villageProfiles.length > 0) {
            slideCreated = true
            console.log('✅ 處理 villageProfiles:', section.heading, section.villageProfiles.length, '個村莊')
            
            section.villageProfiles.forEach(profile => {
              if (!profile || typeof profile !== 'object') return
              
              const contentParts = []
              if (profile.village) contentParts.push(`**${profile.village}**`)
              contentParts.push('')
              if (profile.aroma) contentParts.push(`🌸 **香氣**：${profile.aroma}`)
              if (profile.palate) contentParts.push(`👅 **口感**：${profile.palate}`)
              if (profile.finish) contentParts.push(`✨ **尾韻**：${profile.finish}`)
              
              if (contentParts.length > 1) {
                slideArray.push({
                  type: 'content',
                  title: section.heading,
                  content: contentParts.join('\n')
                })
              }
            })
          }
          
          // 3. 如果有品鑑步驟（多張投影片方式）
          if (!slideCreated && section.tastingSteps && Array.isArray(section.tastingSteps) && section.tastingSteps.length > 0) {
            slideCreated = true
            console.log('✅ 處理 tastingSteps:', section.heading)
            
            section.tastingSteps.forEach((step, index) => {
              if (!step || typeof step !== 'object') return
              
              const contentParts = []
              if (step.step) contentParts.push(`**${index + 1}. ${step.step}**`)
              if (step.description) contentParts.push(step.description)
              if (step.details) contentParts.push('', step.details)
              
              if (contentParts.length > 0) {
                slideArray.push({
                  type: 'content',
                  title: section.heading,
                  content: contentParts.join('\n')
                })
              }
            })
          }
          
          // 4. 如果有配餐法則（物件陣列，單張投影片）
          if (!slideCreated && section.pairingRules && Array.isArray(section.pairingRules) && section.pairingRules.length > 0) {
            slideCreated = true
            console.log('✅ 處理 pairingRules:', section.heading)
            
            const contentParts = []
            if (section.text && typeof section.text === 'string') {
              contentParts.push(section.text)
              contentParts.push('')
            }
            
            section.pairingRules.forEach(rule => {
              if (!rule) return
              
              if (typeof rule === 'string') {
                contentParts.push(rule)
                contentParts.push('')
              } else if (typeof rule === 'object') {
                if (rule.rule) contentParts.push(`**${rule.rule}**`)
                if (rule.description) contentParts.push(rule.description)
                if (rule.avoid) contentParts.push(`${rule.avoid}`)
                if (rule.examples) contentParts.push(`${rule.examples}`)
                contentParts.push('')
              }
            })
            
            if (contentParts.length > 0) {
              slideArray.push({
                type: 'content',
                title: section.heading,
                content: contentParts.join('\n')
              })
            }
          }
          
          // 4a. 如果有品鑑對比（comparison 陣列，多張投影片）
          if (!slideCreated && section.comparison && Array.isArray(section.comparison) && section.comparison.length > 0) {
            slideCreated = true
            console.log('✅ 處理 comparison（品鑑對比）:', section.heading, section.comparison.length, '種類型')
            
            // 先創建一張總覽投影片
            if (section.text) {
              slideArray.push({
                type: 'content',
                title: section.heading,
                content: section.text
              })
            }
            
            // 為每種類型創建獨立投影片
            section.comparison.forEach(item => {
              if (!item || typeof item !== 'object') return
              
              const contentParts = []
              if (item.type) contentParts.push(`**${item.type}**`)
              contentParts.push('')
              
              if (item.color) contentParts.push(`🎨 **色澤**：${item.color}`)
              if (item.aroma) contentParts.push(`👃 **香氣**：${item.aroma}`)
              if (item.palate) contentParts.push(`👅 **口感**：${item.palate}`)
              if (item.temperature) contentParts.push(`🌡️ **適飲溫度**：${item.temperature}`)
              if (item.drink) contentParts.push(`⏳ **適飲期**：${item.drink}`)
              
              if (contentParts.length > 1) {
                slideArray.push({
                  type: 'content',
                  title: section.heading,
                  content: contentParts.join('\n')
                })
              }
            })
          }
          
          // 4b. 如果有餐酒搭配（pairings 物件陣列，多張投影片）
          if (!slideCreated && section.pairings && Array.isArray(section.pairings) && section.pairings.length > 0 && typeof section.pairings[0] === 'object') {
            slideCreated = true
            console.log('✅ 處理 pairings（餐酒搭配詳細）:', section.heading, section.pairings.length, '種料理')
            
            // 先創建一張總覽投影片
            if (section.text) {
              slideArray.push({
                type: 'content',
                title: section.heading,
                content: section.text
              })
            }
            
            // 為每個料理類別創建獨立投影片
            section.pairings.forEach(pairing => {
              if (!pairing || typeof pairing !== 'object') return
              
              const contentParts = []
              if (pairing.category) {
                contentParts.push(`**${pairing.category}**`)
                contentParts.push('')
              }
              
              if (pairing.dishes && Array.isArray(pairing.dishes)) {
                pairing.dishes.forEach(dish => {
                  contentParts.push(`• ${dish}`)
                })
              }
              
              if (contentParts.length > 0) {
                slideArray.push({
                  type: 'content',
                  title: section.heading,
                  content: contentParts.join('\n')
                })
              }
            })
          }
          
          // 4c. 如果有配餐規則（rules 陣列，單張投影片）
          if (!slideCreated && section.rules && Array.isArray(section.rules) && section.rules.length > 0) {
            slideCreated = true
            console.log('✅ 處理 rules（配餐規則）:', section.heading)
            
            const contentParts = []
            if (section.text && typeof section.text === 'string') {
              contentParts.push(section.text)
              contentParts.push('')
            }
            
            section.rules.forEach(rule => {
              if (typeof rule === 'string') {
                contentParts.push(rule)
              }
            })
            
            if (contentParts.length > 0) {
              slideArray.push({
                type: 'content',
                title: section.heading,
                content: contentParts.join('\n')
              })
            }
          }
          
          // 5. 如果有料理類型配對（單張投影片）
          if (!slideCreated && section.cuisineTypes && Array.isArray(section.cuisineTypes) && section.cuisineTypes.length > 0) {
            slideCreated = true
            console.log('✅ 處理 cuisineTypes:', section.heading)
            
            const contentParts = []
            section.cuisineTypes.forEach(cuisine => {
              if (!cuisine || typeof cuisine !== 'object') return
              
              if (cuisine.type) contentParts.push(`**${cuisine.type}**`)
              if (cuisine.wines) contentParts.push(`🍷 推薦：${cuisine.wines}`)
              if (cuisine.dishes) contentParts.push(`🍽️ 菜餚：${cuisine.dishes}`)
              if (cuisine.reason) contentParts.push(`💡 ${cuisine.reason}`)
              contentParts.push('')
            })
            
            if (contentParts.length > 0) {
              slideArray.push({
                type: 'content',
                title: section.heading,
                content: contentParts.join('\n')
              })
            }
          }
          
          // 5a. 如果有選擇指南（guide 物件）
          if (!slideCreated && section.guide && typeof section.guide === 'object') {
            slideCreated = true
            console.log('✅ 處理 guide:', section.heading)
            
            const contentParts = []
            if (section.text && typeof section.text === 'string') {
              contentParts.push(section.text)
              contentParts.push('')
            }
            
            Object.entries(section.guide).forEach(([category, villages]) => {
              contentParts.push(`**${category}**`)
              contentParts.push(`${villages}`)
              contentParts.push('')
            })
            
            if (contentParts.length > 0) {
              slideArray.push({
                type: 'content',
                title: section.heading,
                content: contentParts.join('\n')
              })
            }
          }
          
          // 6. 如果有子產區詳細資料（多張投影片）
          if (!slideCreated && section.subRegions && Array.isArray(section.subRegions) && section.subRegions.length > 0 && typeof section.subRegions[0] === 'object') {
            slideCreated = true
            console.log('✅ 處理 subRegions:', section.heading)
            
            section.subRegions.forEach(subRegion => {
              if (!subRegion || typeof subRegion !== 'object') return
              
              const contentParts = []
              if (subRegion.description) contentParts.push(subRegion.description)
              
              if (subRegion.flavorProfile && typeof subRegion.flavorProfile === 'object') {
                if (subRegion.flavorProfile.aroma) contentParts.push(`\n**香氣：** ${subRegion.flavorProfile.aroma}`)
                if (subRegion.flavorProfile.palate) contentParts.push(`**口感：** ${subRegion.flavorProfile.palate}`)
                
                const bodyAcidAlc = []
                if (subRegion.flavorProfile.body) bodyAcidAlc.push(`**酒體：** ${subRegion.flavorProfile.body}`)
                if (subRegion.flavorProfile.acidity) bodyAcidAlc.push(`**酸度：** ${subRegion.flavorProfile.acidity}`)
                if (subRegion.flavorProfile.alcohol) bodyAcidAlc.push(`**酒精度：** ${subRegion.flavorProfile.alcohol}`)
                if (bodyAcidAlc.length > 0) contentParts.push(bodyAcidAlc.join(' | '))
              }
              
              if (subRegion.agingPotential) contentParts.push(`\n**陳年潛力：** ${subRegion.agingPotential}`)
              if (subRegion.servingTemp) contentParts.push(`**適飲溫度：** ${subRegion.servingTemp}`)
              if (subRegion.foodPairing) contentParts.push(`**餐酒搭配：** ${subRegion.foodPairing}`)
              if (subRegion.priceRange) contentParts.push(`\n**價格區間：** ${subRegion.priceRange}`)
              
              if (subRegion.notablePremierCrus && Array.isArray(subRegion.notablePremierCrus) && subRegion.notablePremierCrus.length > 0) {
                contentParts.push(`\n**著名一級園：**\n${subRegion.notablePremierCrus.map(c => `• ${c}`).join('\n')}`)
              }
              
              if (subRegion.note) contentParts.push(`\n*${subRegion.note}*`)
              
              if (contentParts.length > 0) {
                slideArray.push({
                  type: 'content',
                  title: subRegion.level || section.heading,
                  content: contentParts.join('\n')
                })
              }
            })
          }
          
          // 7. 如果有分級列表（levels）- 創建對比表或地圖
          if (!slideCreated && section.levels && Array.isArray(section.levels) && section.levels.length > 0) {
            slideCreated = true
            console.log('✅ 處理 levels:', section.heading)
            
            slideArray.push({
              type: 'comparison',
              title: section.heading,
              pyramid: {
                levels: section.levels.map((level, index) => {
                  if (!level || typeof level !== 'object') return null
                  
                  return {
                    level: section.levels.length - index,
                    name: level.name || '',
                    percentage: level.percentage || '',
                    maxYield: level.price || '',
                    description: `${level.area || ''} • ${level.style || ''} • ${level.drink || ''}`,
                    color: level.color || ['#F4E4C1', '#E8D5A8', '#DBC68F', '#CEB776'][index] || '#E0E0E0'
                  }
                }).filter(l => l !== null)
              }
            })
            
            // 如果有互動地圖，額外創建地圖投影片
            if (section.interactiveMap && typeof section.interactiveMap === 'object') {
              slideArray.push({
                type: 'map',
                title: section.interactiveMap.title || '產區地圖',
                mapConfig: section.interactiveMap.mapConfig,
                geojsonFiles: [
                  { 
                    id: "base-burgundy", 
                    url: "/geojson/AOC Bourgogne map.geojson", 
                    isBase: true, 
                    fillColor: "#E6E6FA", 
                    fillOpacity: 0.05, 
                    lineColor: "#9370DB", 
                    lineWidth: 1, 
                    showLabels: false 
                  },
                  ...(section.interactiveMap.layers || [])
                ],
                buttonPosition: section.interactiveMap.buttonPosition || 'left',
                interactive: true
              })
            }
          }
          
          // 8. 如果有土壤類型（soilTypes）
          if (!slideCreated && section.soilTypes && Array.isArray(section.soilTypes) && section.soilTypes.length > 0) {
            slideCreated = true
            console.log('✅ 處理 soilTypes:', section.heading)
            
            const contentParts = []
            if (section.text && typeof section.text === 'string') {
              contentParts.push(section.text)
              contentParts.push('')
            }
            
            section.soilTypes.forEach(soil => {
              if (!soil || typeof soil !== 'object') return
              contentParts.push(`**${soil.name}**`)
              if (soil.location) contentParts.push(`📍 位置：${soil.location}`)
              if (soil.character) contentParts.push(`✨ 特色：${soil.character}`)
              contentParts.push('')
            })
            
            if (contentParts.length > 0) {
              slideArray.push({
                type: 'content',
                title: section.heading,
                content: contentParts.join('\n')
              })
            }
          }
          
          // ===== 處理簡單列表類型（互斥處理）=====
          if (!slideCreated) {
            if (section.temperatures && Array.isArray(section.temperatures) && section.temperatures.length > 0) {
              console.log('✅ 處理 temperatures:', section.heading)
              slideArray.push({
                type: 'list',
                title: section.heading,
                content: section.text || '',
                points: section.temperatures.map(t => 
                  (t && typeof t === 'object') 
                    ? `${t.range || ''} - ${t.villages || ''}：${t.reason || ''}` 
                    : String(t)
                )
              })
              slideCreated = true
            } else if (section.keyPoints && Array.isArray(section.keyPoints) && section.keyPoints.length > 0) {
              console.log('✅ 處理 keyPoints:', section.heading)
              slideArray.push({
                type: 'list',
                title: section.heading,
                content: section.text || '',
                points: section.keyPoints.map(p => String(p))
              })
              slideCreated = true
            } else if (section.tips && Array.isArray(section.tips) && section.tips.length > 0) {
              console.log('✅ 處理 tips:', section.heading)
              slideArray.push({
                type: 'list',
                title: section.heading,
                content: section.text || '',
                points: section.tips.map(t => String(t))
              })
              slideCreated = true
            } else if (section.pairings && Array.isArray(section.pairings) && section.pairings.length > 0) {
              console.log('✅ 處理 pairings（簡單列表）:', section.heading)
              slideArray.push({
                type: 'list',
                title: section.heading,
                content: section.text || '',
                points: section.pairings.map(p => String(p))
              })
              slideCreated = true
            } else if (section.formula && Array.isArray(section.formula) && section.formula.length > 0) {
              console.log('✅ 處理 formula:', section.heading)
              slideArray.push({
                type: 'list',
                title: section.heading,
                content: section.text || '',
                points: section.formula.map(f => String(f))
              })
              slideCreated = true
            } else if (section.villages && Array.isArray(section.villages) && section.villages.length > 0) {
              console.log('✅ 處理 villages:', section.heading)
              slideArray.push({
                type: 'list',
                title: section.heading,
                content: section.text || '',
                points: section.villages.map(v => 
                  typeof v === 'string' ? v : (v && (v.name || v.village)) || String(v)
                )
              })
              slideCreated = true
            } else if (section.grandCrus && Array.isArray(section.grandCrus) && section.grandCrus.length > 0) {
              console.log('✅ 處理 grandCrus:', section.heading)
              slideArray.push({
                type: 'list',
                title: section.heading,
                content: section.text || '',
                points: section.grandCrus.map(c => {
                  if (typeof c === 'string') return c
                  if (!c || typeof c !== 'object') return ''
                  const size = c.size ? ` (${c.size})` : ''
                  const style = c.style || c.character || ''
                  return `${c.name || ''}${size}${style ? ` - ${style}` : ''}`
                }).filter(p => p !== '')
              })
              slideCreated = true
            } else if (section.crus && Array.isArray(section.crus) && section.crus.length > 0) {
              console.log('✅ 處理 crus（為每個特級村創建詳細投影片）:', section.heading, section.crus.length, '個')
              
              // 先創建一張總覽投影片
              slideArray.push({
                type: 'content',
                title: section.heading,
                content: `薄酒萊十大特級村是薄酒萊的精華所在，每個村莊都有獨特的風土特色。\n\n接下來，我們將逐一深入了解這10個特級村的詳細資訊。`
              })
              
              // 為每個特級村創建獨立的詳細投影片
              section.crus.forEach((cru, index) => {
                if (!cru || typeof cru !== 'object') return
                
                const contentParts = []
                
                // 標題：村莊名稱 + 中文名
                if (cru.name) {
                  let title = `**${cru.name}**`
                  if (cru.chinese) title += ` ${cru.chinese}`
                  contentParts.push(title)
                  contentParts.push('')
                }
                
                // 基本資訊
                const basicInfo = []
                if (cru.area) basicInfo.push(`📏 **面積**：${cru.area}`)
                if (cru.soil) basicInfo.push(`🪨 **土壤**：${cru.soil}`)
                if (cru.aging) basicInfo.push(`⏳ **陳年潛力**：${cru.aging}`)
                if (basicInfo.length > 0) {
                  contentParts.push(basicInfo.join('\n'))
                  contentParts.push('')
                }
                
                // 風格定位
                if (cru.style) {
                  contentParts.push(`🎯 **風格定位**`)
                  contentParts.push(cru.style)
                  contentParts.push('')
                }
                
                // 風味特色
                if (cru.character) {
                  contentParts.push(`🍷 **風味特色**`)
                  contentParts.push(cru.character)
                  contentParts.push('')
                }
                
                // 價格區間與餐酒搭配
                const priceFood = []
                if (cru.price) priceFood.push(`💰 **價格**：${cru.price}`)
                if (cru.food) priceFood.push(`🍽️ **搭配**：${cru.food}`)
                if (priceFood.length > 0) {
                  contentParts.push(priceFood.join('\n'))
                }
                
                if (contentParts.length > 0) {
                  slideArray.push({
                    type: 'content',
                    title: `${cru.name || '特級村'} ${cru.chinese || ''}`,
                    content: contentParts.join('\n')
                  })
                }
              })
              
              slideCreated = true
            }
          }
          
          // ===== 對比表處理（只在沒有其他內容時）=====
          if (!slideCreated && section.comparisonTable && typeof section.comparisonTable === 'object') {
            console.log('✅ 處理 comparisonTable:', section.comparisonTable.title || section.heading)
            
            if (section.comparisonTable.headers && section.comparisonTable.rows) {
              slideArray.push({
                type: 'comparison',
                title: section.comparisonTable.title || section.heading,
                comparison: {
                  headers: section.comparisonTable.headers,
                  rows: section.comparisonTable.rows
                }
              })
              slideCreated = true
            }
          }
          
          // ===== 最後的備案：只有 text 的情況 =====
          if (!slideCreated && section.text && typeof section.text === 'string') {
            console.log('✅ 處理純 text:', section.heading)
            slideArray.push({
              type: 'content',
              title: section.heading,
              content: section.text
            })
            slideCreated = true
          }
          
          // 如果什麼都沒創建，記錄警告
          if (!slideCreated) {
            console.warn('⚠️ Section 未能創建投影片:', section.heading, 'Keys:', Object.keys(section))
          }
          
        } catch (error) {
          console.error('❌ 處理 section 時發生錯誤:', section.heading, error)
          // 即使出錯，也創建一個錯誤投影片，避免整個課程崩潰
          slideArray.push({
            type: 'content',
            title: section.heading || '處理錯誤',
            content: `此部分內容處理時發生錯誤\n\n錯誤訊息: ${error.message || '未知錯誤'}`
          })
        }
        
        // 如果有酒標圖片，添加一個圖片投影片（不受 slideCreated 影響，可以獨立存在）
        if (section.labelImage) {
          slideArray.push({
            type: 'image',
            title: section.labelCaption || `${section.heading} 酒標範例`,
            image: section.labelImage,
            caption: section.labelCaption
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

  // 7. 對比表投影片
  if (props.lesson.content?.comparisonTable) {
    slideArray.push({
      type: 'comparison',
      title: props.lesson.content.comparisonTable.title || '對比表',
      comparison: props.lesson.content.comparisonTable
    })
  }

  // 8. 提示與技巧投影片
  if (props.lesson.content?.tips && props.lesson.content.tips.length > 0) {
    slideArray.push({
      type: 'list',
      title: '💡 實用技巧',
      points: props.lesson.content.tips
    })
  }

  // 9. 總結投影片
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
    case 'map': return MapSlide
    case 'winery': return WinerySlide
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
