<template>
  <div class="aoc-list">
    <h2>{{ regionName }} 產區清單</h2>
    
    <input
      type="text"
      class="aoc-search"
      placeholder="搜尋產區..."
      v-model="searchModel"
    />
    
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
  flex: 0 0 320px;
  height: 100%;
  overflow-y: auto;
  background: #f8f8f8;
  border-right: 1px solid #ddd;
  padding: 20px 15px;
  box-sizing: border-box;
}

h2 {
  margin-top: 0;
  margin-bottom: 15px;
  color: #800020; /* Burgundy color */
  letter-spacing: 1px;
}

.aoc-search {
  width: 100%;
  padding: 8px 12px;
  border-radius: 4px;
  border: 1px solid #ccc;
  margin-bottom: 15px;
  font-size: 0.9rem;
}

.aoc-search:focus {
  outline: none;
  border-color: #8B0000;
}

.group-header {
  display: flex;
  align-items: center;
  padding: 8px 5px;
  cursor: pointer;
  border-radius: 4px;
}

.group-header:hover {
  background: rgba(0, 0, 0, 0.05);
}

.region-header .group-name {
  font-size: 1rem;
  font-weight: 500;
}

.group-icon {
  font-size: 0.7rem;
  margin-right: 8px;
  width: 10px;
}

.region-group {
  margin-left: 10px;
}

.region-content {
  margin-left: 20px;
}

.aoc-item {
  display: flex;
  align-items: center;
  padding: 6px 8px;
  margin: 2px 0;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
}

.aoc-item:hover {
  background: rgba(0, 0, 0, 0.05);
}

.aoc-item.active {
  background: rgba(139, 0, 0, 0.1);
  font-weight: 500;
}

.aoc-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  margin-right: 8px;
  flex-shrink: 0;
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