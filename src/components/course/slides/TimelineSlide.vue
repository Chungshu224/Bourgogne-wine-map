<template>
  <div class="timeline-slide">
    <div class="slide-header">
      <h2>{{ slide.title }}</h2>
    </div>
    <div class="slide-body">
      <div class="timeline">
        <div 
          v-for="(item, index) in slide.timeline" 
          :key="index" 
          class="timeline-item"
        >
          <div class="timeline-year">{{ item.year }}</div>
          <div class="timeline-connector"></div>
          <div class="timeline-event">{{ item.event }}</div>
        </div>
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
</script>

<style scoped>
.timeline-slide {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 60px;
  border-radius: 24px;
}

.slide-header {
  margin-bottom: 40px;
}

.slide-header h2 {
  font-size: 36px;
  font-weight: 700;
  color: #2c3e50;
  margin: 0;
  border-bottom: 4px solid #667eea;
  padding-bottom: 20px;
}

.slide-body {
  flex: 1;
  display: flex;
  align-items: center;
  overflow-y: auto;
}

.timeline {
  width: 100%;
}

.timeline-item {
  display: grid;
  grid-template-columns: 120px 40px 1fr;
  gap: 20px;
  margin-bottom: 30px;
  align-items: center;
}

.timeline-year {
  text-align: right;
  font-size: 24px;
  font-weight: 700;
  color: #667eea;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  padding: 12px 20px;
  border-radius: 12px;
}

.timeline-connector {
  width: 4px;
  height: 100%;
  min-height: 60px;
  background: linear-gradient(180deg, #667eea, #764ba2);
  border-radius: 2px;
  position: relative;
}

.timeline-connector::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 16px;
  height: 16px;
  background: #667eea;
  border-radius: 50%;
  box-shadow: 0 0 0 4px white, 0 0 0 6px #667eea;
}

.timeline-event {
  font-size: 18px;
  line-height: 1.6;
  color: #2c3e50;
  background: white;
  padding: 16px 24px;
  border-radius: 12px;
  border-left: 4px solid #667eea;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

@media (max-width: 768px) {
  .timeline-slide {
    padding: 40px 30px;
  }

  .slide-header h2 {
    font-size: 28px;
  }

  .timeline-item {
    grid-template-columns: 80px 30px 1fr;
    gap: 12px;
  }

  .timeline-year {
    font-size: 18px;
    padding: 8px 12px;
  }

  .timeline-event {
    font-size: 15px;
    padding: 12px 16px;
  }
}
</style>
