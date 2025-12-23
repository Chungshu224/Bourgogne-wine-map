<template>
  <div class="image-slide">
    <div class="slide-header">
      <h2>{{ slide.title }}</h2>
    </div>
    <div class="slide-body">
      <img :src="slide.image" :alt="slide.title" class="slide-image" />
      <p v-if="slide.caption" class="image-caption">{{ slide.caption }}</p>
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
.image-slide {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  padding: 60px;
  border-radius: 24px;
}

.slide-header {
  margin-bottom: 30px;
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
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 20px;
}

.slide-image {
  max-width: 100%;
  max-height: 320px;
  border-radius: 16px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
  object-fit: contain;
}

.image-caption {
  font-size: 18px;
  color: #7f8c8d;
  text-align: center;
  font-style: italic;
}

@media (max-width: 768px) {
  .image-slide {
    padding: 40px 30px;
  }

  .slide-header h2 {
    font-size: 28px;
  }

  .slide-image {
    max-height: 260px;
  }

  .image-caption {
    font-size: 15px;
  }
}
</style>
