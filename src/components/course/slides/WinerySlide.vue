<template>
  <div class="winery-slide">
    <div class="slide-header">
      <h2>{{ slide.title }}</h2>
    </div>
    <div class="slide-body">
      <div class="wineries-grid">
        <div 
          v-for="(winery, index) in slide.wineries" 
          :key="index"
          class="winery-card"
        >
          <div class="winery-icon">🏰</div>
          <h3 class="winery-name">{{ winery.name }}</h3>
          <p class="winery-description">{{ winery.description }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  slide: {
    type: Object,
    required: true
  }
})
</script>

<style scoped>
.winery-slide {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 48px 56px;
  border-radius: 24px;
}

.slide-header {
  margin-bottom: 40px;
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
  align-items: center;
  justify-content: center;
  overflow-y: auto;
  padding: 0 20px;
}

.wineries-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 24px;
  width: 100%;
  max-width: 1000px;
}

.winery-card {
  background: linear-gradient(135deg, #f5f7fa 0%, #e3eaf2 100%);
  border-radius: 16px;
  padding: 28px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border: 2px solid transparent;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.winery-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.25);
  border-color: #667eea;
  background: linear-gradient(135deg, #ffffff 0%, #f5f7fa 100%);
}

.winery-icon {
  font-size: 3rem;
  margin-bottom: 16px;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.1));
}

.winery-name {
  font-size: 1.25rem;
  font-weight: 700;
  color: #2c3e50;
  margin: 0 0 12px 0;
  line-height: 1.4;
}

.winery-description {
  font-size: 1rem;
  line-height: 1.6;
  color: #5a6c7d;
  margin: 0;
}

/* 響應式設計 */
@media (max-width: 1024px) {
  .wineries-grid {
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 20px;
  }
}

@media (max-width: 768px) {
  .winery-slide {
    padding: 40px 30px;
  }

  .slide-header h2 {
    font-size: 1.6rem;
  }

  .wineries-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .winery-card {
    padding: 24px;
  }

  .winery-icon {
    font-size: 2.5rem;
  }

  .winery-name {
    font-size: 1.1rem;
  }

  .winery-description {
    font-size: 0.95rem;
  }
}

@media (max-width: 480px) {
  .winery-slide {
    padding: 32px 24px;
  }

  .slide-header h2 {
    font-size: 1.4rem;
  }

  .winery-card {
    padding: 20px;
  }
}
</style>
