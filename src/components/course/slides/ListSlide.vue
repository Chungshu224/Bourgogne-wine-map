<template>
  <div class="list-slide">
    <div class="slide-header">
      <h2>{{ slide.title }}</h2>
    </div>
    <div class="slide-body">
      <ul class="points-list">
        <li v-for="(point, index) in slide.points" :key="index" class="point-item">
          <span class="point-number">{{ index + 1 }}</span>
          <span class="point-text">{{ point }}</span>
        </li>
      </ul>
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
</script>

<style scoped>
.list-slide {
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
  display: flex;
  align-items: flex-start;
  overflow-y: auto;
  padding-top: 8px;
}

.points-list {
  list-style: none;
  padding: 0;
  margin: 0;
  width: 100%;
}

.point-item {
  display: flex;
  align-items: flex-start;
  gap: 16px;
  padding: 16px 18px;
  margin-bottom: 12px;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  border-radius: 10px;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

.point-item:hover {
  transform: translateX(8px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.point-number {
  flex-shrink: 0;
  width: 36px;
  height: 36px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 1rem;
  margin-top: 2px;
}

.point-text {
  font-size: 1rem;
  color: #2c3e50;
  line-height: 1.65;
  padding-top: 6px;
}

@media (max-width: 768px) {
  .list-slide {
    padding: 40px 30px;
  }

  .slide-header h2 {
    font-size: 28px;
  }

  .point-item {
    padding: 16px;
    gap: 12px;
  }

  .point-number {
    width: 32px;
    height: 32px;
    font-size: 16px;
  }

  .point-text {
    font-size: 16px;
  }
}
</style>
