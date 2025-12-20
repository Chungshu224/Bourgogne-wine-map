<template>
  <div class="title-slide">
    <div class="slide-content">
      <div class="icon">🍷</div>
      <h1 class="main-title">{{ slide.title }}</h1>
      <p class="subtitle">{{ slide.subtitle }}</p>
      <div class="description">{{ slide.description }}</div>
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
.title-slide {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 24px;
}

.slide-content {
  text-align: center;
  color: white;
  padding: 48px;
}

.icon {
  font-size: 4rem;
  margin-bottom: 24px;
  animation: bounce 2s infinite;
}

@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-8px); }
}

.main-title {
  font-size: 2.5rem;
  font-weight: 700;
  margin: 0 0 16px 0;
  line-height: 1.2;
}

.subtitle {
  font-size: 1.125rem;
  opacity: 0.92;
  margin: 0 0 24px 0;
  font-weight: 500;
}

.description {
  font-size: 1rem;
  line-height: 1.65;
  opacity: 0.95;
  max-width: 600px;
  margin: 0 auto;
}

@media (max-width: 768px) {
  .slide-content {
    padding: 40px 30px;
  }

  .icon {
    font-size: 60px;
  }

  .main-title {
    font-size: 32px;
  }

  .subtitle {
    font-size: 16px;
  }

  .description {
    font-size: 15px;
  }
}
</style>
