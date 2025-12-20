<template>
  <div class="region-selector">
    <div class="region-header">
      <h2>布根地葡萄酒產區</h2>
      <p class="subtitle">Bourgogne Wine Regions</p>
    </div>
    
    <div class="region-grid">
      <div 
        v-for="region in regions" 
        :key="region.id"
        class="region-card"
        :class="{ active: currentRegion === region.id }"
        @click="selectRegion(region.id)"
      >
        <div class="region-icon">{{ region.icon }}</div>
        <h3>{{ region.name }}</h3>
        <p class="region-name-fr">{{ region.nameFr }}</p>
        <div class="region-stats">
          <span>{{ region.aocCount }} AOC</span>
          <span>{{ region.area }}</span>
        </div>
      </div>
    </div>

    <!-- 麵包屑導航 -->
    <div v-if="currentRegion" class="breadcrumb">
      <span class="breadcrumb-item" @click="selectRegion(null)">
        所有產區
      </span>
      <span class="breadcrumb-separator">›</span>
      <span class="breadcrumb-item active">
        {{ regions.find(r => r.id === currentRegion)?.name }}
      </span>
    </div>
  </div>
</template>

<script setup>
import { ref, defineEmits } from 'vue';

const emit = defineEmits(['region-selected']);

const currentRegion = ref(null);

const regions = ref([
  {
    id: 'chablis',
    name: '夏布利與大歐塞瓦',
    nameFr: 'Chablis & Grand Auxerrois',
    icon: '🍇',
    aocCount: 15,
    area: '~5,800 ha',
    center: [3.8, 47.8],
    zoom: 10
  },
  {
    id: 'cote-de-nuits',
    name: '夜丘',
    nameFr: 'Côte de Nuits',
    icon: '🍷',
    aocCount: 24,
    area: '~3,000 ha',
    center: [4.95, 47.15],
    zoom: 11.5
  },
  {
    id: 'cote-de-beaune',
    name: '伯恩丘',
    nameFr: 'Côte de Beaune',
    icon: '🥂',
    aocCount: 22,
    area: '~6,000 ha',
    center: [4.85, 47.0],
    zoom: 11.5
  },
  {
    id: 'cote-chalonnaise',
    name: '夏隆內丘',
    nameFr: 'Côte Chalonnaise',
    icon: '🍾',
    aocCount: 5,
    area: '~3,900 ha',
    center: [4.75, 46.80],
    zoom: 11
  },
  {
    id: 'maconnais',
    name: '馬貢內',
    nameFr: 'Mâconnais',
    icon: '🥃',
    aocCount: 11,
    area: '~6,700 ha',
    center: [4.80, 46.35],
    zoom: 10.5
  },
  {
    id: 'beaujolais',
    name: '薄酒萊',
    nameFr: 'Beaujolais',
    icon: '🍒',
    aocCount: 12,
    area: '~22,000 ha',
    center: [4.65, 46.15],
    zoom: 10
  }
]);

const selectRegion = (regionId) => {
  currentRegion.value = regionId;
  const region = regions.value.find(r => r.id === regionId);
  emit('region-selected', region);
};
</script>

<style scoped>
.region-selector {
  padding: 2rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.region-header {
  text-align: center;
  margin-bottom: 2rem;
}

.region-header h2 {
  font-size: 2.5rem;
  margin-bottom: 0.5rem;
  font-weight: 700;
  text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
}

.subtitle {
  font-size: 1.1rem;
  opacity: 0.9;
  font-style: italic;
}

.region-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
  max-width: 1400px;
  margin: 0 auto;
}

.region-card {
  background: rgba(255, 255, 255, 0.95);
  color: #333;
  border-radius: 16px;
  padding: 2rem;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
  border: 3px solid transparent;
}

.region-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 12px 24px rgba(0,0,0,0.2);
  border-color: #667eea;
}

.region-card.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: #fff;
  transform: scale(1.05);
}

.region-icon {
  font-size: 3rem;
  text-align: center;
  margin-bottom: 1rem;
}

.region-card h3 {
  font-size: 1.5rem;
  margin-bottom: 0.5rem;
  text-align: center;
  font-weight: 600;
}

.region-name-fr {
  font-size: 0.95rem;
  opacity: 0.8;
  font-style: italic;
  text-align: center;
  margin-bottom: 1rem;
}

.region-stats {
  display: flex;
  justify-content: space-around;
  padding-top: 1rem;
  border-top: 1px solid rgba(0,0,0,0.1);
  font-size: 0.9rem;
}

.region-card.active .region-stats {
  border-top-color: rgba(255,255,255,0.3);
}

.breadcrumb {
  margin-top: 2rem;
  padding: 1rem;
  background: rgba(255,255,255,0.2);
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  max-width: 600px;
  margin-left: auto;
  margin-right: auto;
}

.breadcrumb-item {
  cursor: pointer;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  transition: background 0.2s;
}

.breadcrumb-item:hover:not(.active) {
  background: rgba(255,255,255,0.3);
}

.breadcrumb-item.active {
  font-weight: 600;
}

.breadcrumb-separator {
  opacity: 0.6;
}

@media (max-width: 768px) {
  .region-grid {
    grid-template-columns: 1fr;
  }
  
  .region-header h2 {
    font-size: 2rem;
  }
}
</style>
