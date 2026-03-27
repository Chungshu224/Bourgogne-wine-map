<template>
  <div class="aoc-list">
    <div class="list-header">
      <h2 class="list-title">{{ regionName }}</h2>
    </div>
    
    <div class="search-container">
      <span class="search-icon">🔍</span>
      <input
        type="text"
        class="aoc-search"
        placeholder="搜尋產區..."
        v-model="searchModel"
      />
    </div>
    
    <div v-for="(folderContent, folderName) in filteredGeojsonTree" :key="folderName">
      <div class="group-header" @click="toggleRegion(folderName)">
        <span class="group-icon">{{ expandedRegions[folderName] ? '▼' : '▶' }}</span>
        <span class="group-name">{{ folderName }}</span>
      </div>
      <div v-show="expandedRegions[folderName]" class="region-group">
        <!-- Files in the current folder -->
        <div
          v-for="file in folderContent.files"
          :key="file"
          class="aoc-item"
          :class="{ active: isActive(folderName, file) }"
          @click="$emit('selectAOC', folderName, file)"
        >
          <span class="aoc-dot" :style="{ background: aocColor(folderName) }"></span>
          <span class="aoc-name">{{ formatAOCName(file) }}</span>
        </div>
        
        <!-- Subfolders -->
        <div v-for="(subfolderContent, subfolderName) in folderContent.subfolders" :key="subfolderName">
          <div class="group-header" @click="toggleRegion(subfolderName)">
            <span class="group-icon" style="margin-left: 15px;">{{ expandedRegions[subfolderName] ? '▼' : '▶' }}</span>
            <span class="group-name">{{ subfolderName }}</span>
          </div>
          <div v-show="expandedRegions[subfolderName]" class="region-group" style="margin-left: 15px;">
            <div
              v-for="file in subfolderContent.files"
              :key="file"
              class="aoc-item"
              :class="{ active: isActive(subfolderName, file) }"
              @click="$emit('selectAOC', folderName + '/' + subfolderName, file)"
            >
              <span class="aoc-dot" :style="{ background: aocColor(subfolderName) }"></span>
              <span class="aoc-name">{{ formatAOCName(file) }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'

const props = defineProps({
  search: String,
  activeAOC: Object,
  aocColor: Function,
  indexPath: {
    type: String,
    default: '/geojson/index.json'
  },
  regionName: {
    type: String,
    default: 'Bourgogne wine map'
  }
})

const emit = defineEmits(['update:search', 'selectAOC'])

const geojsonTree = ref({})
const expandedRegions = ref({})

const searchModel = computed({
  get: () => props.search,
  set: (val) => emit('update:search', val)
})

const filteredGeojsonTree = computed(() => {
  if (!searchModel.value) {
    return geojsonTree.value;
  }
  const lowerCaseSearch = searchModel.value.toLowerCase();
  const result = {};

  for (const folderName in geojsonTree.value) {
    const folderContent = geojsonTree.value[folderName];
    const filteredFiles = folderContent.files.filter(file => formatAOCName(file).toLowerCase().includes(lowerCaseSearch));
    
    const filteredSubfolders = {};
    let hasSubfolderMatch = false;
    for (const subfolderName in folderContent.subfolders) {
      const subfolderContent = folderContent.subfolders[subfolderName];
      const filteredSubfolderFiles = subfolderContent.files.filter(file => formatAOCName(file).toLowerCase().includes(lowerCaseSearch));
      if (filteredSubfolderFiles.length > 0) {
        filteredSubfolders[subfolderName] = { ...subfolderContent, files: filteredSubfolderFiles };
        hasSubfolderMatch = true;
      }
    }

    if (filteredFiles.length > 0 || hasSubfolderMatch) {
      result[folderName] = {
        files: filteredFiles,
        subfolders: filteredSubfolders
      };
    }
  }
  return result;
});

const toggleRegion = (regionName) => {
  expandedRegions.value[regionName] = !expandedRegions.value[regionName]
}

const formatAOCName = (aoc) => {
  return aoc
    .replace('.geojson', '')
    .replace(/_/g, ' ')
    .replace(/-/g, ' ')
}

const isActive = (group, aoc) => {
  // To handle nested folders, we check if the active group path ends with the current group
  const activeGroupPath = props.activeAOC?.group || '';
  return activeGroupPath.endsWith(group) && props.activeAOC?.aoc === aoc;
}

const loadGeojsonIndex = async () => {
  try {
    const res = await fetch(props.indexPath);
    if (!res.ok) throw new Error('Failed to load geojson index');
    geojsonTree.value = await res.json();
    // Initialize expansion state
    for (const key in geojsonTree.value) {
      expandedRegions.value[key] = false;
      if (geojsonTree.value[key].subfolders) {
        for (const subkey in geojsonTree.value[key].subfolders) {
          expandedRegions.value[subkey] = false;
        }
      }
    }
  } catch (error) {
    console.error("Error loading geojson index:", error);
  }
}

onMounted(async () => {
  await loadGeojsonIndex();
});

// 當 indexPath 改變時重新載入
watch(() => props.indexPath, async () => {
  await loadGeojsonIndex();
});
</script>

<style scoped>
.aoc-list {
  flex: 0 0 340px;
  height: 100%;
  overflow-y: auto;
  background: linear-gradient(to bottom, #ffffff 0%, #f8f9fa 100%);
  border-right: 2px solid #e0e0e0;
  padding: 0;
  box-sizing: border-box;
  box-shadow: 2px 0 10px rgba(0, 0, 0, 0.05);
}

.list-header {
  position: sticky;
  top: 0;
  z-index: 10;
  background: linear-gradient(135deg, #8B0000 0%, #660000 100%);
  color: white;
  padding: 20px 20px 18px;
  margin-bottom: 0;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.list-title {
  margin: 0;
  font-size: 1.4rem;
  font-weight: 700;
  letter-spacing: 0.5px;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.search-container {
  position: relative;
  padding: 15px 20px;
  background: white;
  margin-bottom: 8px;
  border-bottom: 1px solid #e0e0e0;
}

.search-icon {
  position: absolute;
  left: 32px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 1rem;
  pointer-events: none;
  opacity: 0.5;
}

.aoc-search {
  width: 100%;
  padding: 10px 12px 10px 35px;
  border-radius: 8px;
  border: 2px solid #e0e0e0;
  font-size: 0.95rem;
  transition: all 0.3s ease;
  background: #fafafa;
}

.aoc-search:focus {
  outline: none;
  border-color: #8B0000;
  background: white;
  box-shadow: 0 0 0 3px rgba(139, 0, 0, 0.1);
}

.group-header {
  display: flex;
  align-items: center;
  padding: 10px 20px;
  cursor: pointer;
  border-radius: 0;
  background: white;
  border-bottom: 1px solid #f0f0f0;
  transition: all 0.2s ease;
  font-weight: 600;
  color: #333;
}

.group-header:hover {
  background: linear-gradient(to right, #f8f9fa 0%, white 100%);
  padding-left: 24px;
}

.region-header .group-name {
  font-size: 1rem;
  font-weight: 600;
}

.group-icon {
  font-size: 0.7rem;
  margin-right: 10px;
  width: 12px;
  color: #8B0000;
  font-weight: bold;
}

.group-name {
  font-size: 0.95rem;
}

.region-group {
  margin-left: 10px;
  background: #fafafa;
}

.region-content {
  margin-left: 20px;
}

.aoc-item {
  display: flex;
  align-items: center;
  padding: 9px 20px;
  margin: 0;
  border-radius: 0;
  cursor: pointer;
  font-size: 0.9rem;
  background: white;
  border-bottom: 1px solid #f5f5f5;
  transition: all 0.25s ease;
  position: relative;
}

.aoc-item::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 0;
  background: linear-gradient(to right, rgba(139, 0, 0, 0.1), transparent);
  transition: width 0.3s ease;
}

.aoc-item:hover {
  background: #f8f9fa;
  padding-left: 24px;
  color: #8B0000;
}

.aoc-item:hover::before {
  width: 4px;
  background: #8B0000;
}

.aoc-item.active {
  background: linear-gradient(to right, #fff5f5, white);
  font-weight: 600;
  color: #8B0000;
  border-left: 4px solid #8B0000;
  box-shadow: inset 0 0 0 1px rgba(139, 0, 0, 0.1);
}

.aoc-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  margin-right: 10px;
  flex-shrink: 0;
  border: 2px solid white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
}

@media (max-width: 768px) {
  .aoc-list {
    width: 100%;
    height: auto;
    flex: 0 0 auto;
    border-right: none;
    border-bottom: 1px solid #ddd;
  }
}
</style>