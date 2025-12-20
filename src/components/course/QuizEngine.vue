<template>
  <div class="quiz-engine">
    <!-- 測驗開始畫面 -->
    <div v-if="quizState === 'ready'" class="quiz-start">
      <div class="quiz-icon">📝</div>
      <h1>模組測驗</h1>
      <div class="quiz-info">
        <div class="info-item">
          <span class="label">題目數量</span>
          <span class="value">{{ quiz.questions.length }} 題</span>
        </div>
        <div class="info-item">
          <span class="label">及格分數</span>
          <span class="value">{{ quiz.passingScore }}%</span>
        </div>
        <div class="info-item">
          <span class="label">建議時間</span>
          <span class="value">15-20 分鐘</span>
        </div>
      </div>
      <button class="start-btn" @click="startQuiz">開始測驗</button>
    </div>

    <!-- 測驗進行中 -->
    <div v-else-if="quizState === 'inProgress'" class="quiz-progress">
      <div class="quiz-header">
        <div class="progress-bar">
          <div class="progress-fill" :style="{ width: progressPercentage + '%' }"></div>
        </div>
        <div class="quiz-meta">
          <span>題目 {{ currentQuestionIndex + 1 }} / {{ quiz.questions.length }}</span>
          <span class="timer">⏱️ {{ formatTime(elapsedTime) }}</span>
        </div>
      </div>

      <div class="question-container">
        <div class="question">
          <div class="question-number">第 {{ currentQuestionIndex + 1 }} 題</div>
          <h2>{{ currentQuestion.question }}</h2>
        </div>

        <div class="options">
          <div
            v-for="(option, index) in currentQuestion.options"
            :key="index"
            class="option"
            :class="{
              selected: selectedAnswer === index,
              correct: showAnswer && index === currentQuestion.correctAnswer,
              incorrect: showAnswer && selectedAnswer === index && index !== currentQuestion.correctAnswer
            }"
            @click="!showAnswer && selectAnswer(index)"
          >
            <div class="option-letter">{{ String.fromCharCode(65 + index) }}</div>
            <div class="option-text">{{ option }}</div>
            <div v-if="showAnswer && index === currentQuestion.correctAnswer" class="answer-icon">✓</div>
            <div v-if="showAnswer && selectedAnswer === index && index !== currentQuestion.correctAnswer" class="answer-icon">✗</div>
          </div>
        </div>

        <div v-if="showAnswer" class="explanation">
          <div class="explanation-header">
            <span v-if="selectedAnswer === currentQuestion.correctAnswer" class="correct-label">✓ 回答正確！</span>
            <span v-else class="incorrect-label">✗ 回答錯誤</span>
          </div>
          <p>{{ currentQuestion.explanation }}</p>
        </div>

        <div class="navigation-buttons">
          <button
            v-if="showAnswer && currentQuestionIndex < quiz.questions.length - 1"
            class="next-btn"
            @click="nextQuestion"
          >
            下一題 →
          </button>
          <button
            v-if="showAnswer && currentQuestionIndex === quiz.questions.length - 1"
            class="finish-btn"
            @click="finishQuiz"
          >
            完成測驗
          </button>
          <button
            v-if="!showAnswer && selectedAnswer !== null"
            class="submit-btn"
            @click="submitAnswer"
          >
            確認答案
          </button>
        </div>
      </div>
    </div>

    <!-- 測驗結果 -->
    <div v-else-if="quizState === 'completed'" class="quiz-result">
      <div class="result-icon" :class="passed ? 'pass' : 'fail'">
        {{ passed ? '🎉' : '📚' }}
      </div>
      <h1>{{ passed ? '恭喜通過！' : '請再接再厲' }}</h1>
      
      <div class="score-circle">
        <svg width="200" height="200" viewBox="0 0 200 200">
          <circle
            cx="100"
            cy="100"
            r="90"
            stroke="#f0f0f0"
            stroke-width="12"
            fill="none"
          />
          <circle
            cx="100"
            cy="100"
            r="90"
            :stroke="passed ? '#4CAF50' : '#FF9800'"
            stroke-width="12"
            fill="none"
            stroke-linecap="round"
            :stroke-dasharray="circumference"
            :stroke-dashoffset="circumference - (circumference * score) / 100"
            transform="rotate(-90 100 100)"
          />
        </svg>
        <div class="score-text">
          <div class="score-number">{{ score }}%</div>
          <div class="score-label">得分</div>
        </div>
      </div>

      <div class="result-details">
        <div class="detail-item">
          <span class="detail-label">正確題數</span>
          <span class="detail-value">{{ correctAnswers }} / {{ quiz.questions.length }}</span>
        </div>
        <div class="detail-item">
          <span class="detail-label">及格分數</span>
          <span class="detail-value">{{ quiz.passingScore }}%</span>
        </div>
        <div class="detail-item">
          <span class="detail-label">完成時間</span>
          <span class="detail-value">{{ formatTime(elapsedTime) }}</span>
        </div>
      </div>

      <div v-if="passed" class="success-message">
        <p>✨ 您已成功完成本模組測驗！</p>
        <p>{{ passMessage }}</p>
      </div>

      <div v-else class="retry-message">
        <p>💪 別氣餒！再次學習課程內容後重試吧</p>
        <p>建議：回顧您答錯的題目，加強理解相關概念</p>
      </div>

      <div class="result-actions">
        <button v-if="!passed" class="retry-btn" @click="retryQuiz">重新測驗</button>
        <button v-if="!passed" class="review-btn" @click="reviewLessons">複習課程</button>
        <button v-if="passed" class="continue-btn" @click="continueToNext">繼續下一模組</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, defineProps, defineEmits } from 'vue'

const props = defineProps({
  quiz: {
    type: Object,
    required: true
  },
  moduleId: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['quizComplete', 'reviewLessons', 'continueNext'])

// 狀態管理
const quizState = ref('ready') // ready, inProgress, completed
const currentQuestionIndex = ref(0)
const selectedAnswer = ref(null)
const showAnswer = ref(false)
const answers = ref([])
const elapsedTime = ref(0)
const timerInterval = ref(null)

// 計算屬性
const currentQuestion = computed(() => {
  return props.quiz.questions[currentQuestionIndex.value]
})

const progressPercentage = computed(() => {
  return ((currentQuestionIndex.value + 1) / props.quiz.questions.length) * 100
})

const correctAnswers = computed(() => {
  return answers.value.filter(a => a.correct).length
})

const score = computed(() => {
  return Math.round((correctAnswers.value / props.quiz.questions.length) * 100)
})

const passed = computed(() => {
  return score.value >= props.quiz.passingScore
})

const passMessage = computed(() => {
  if (score.value === 100) {
    return '完美！您對本模組的內容掌握得非常好！'
  } else if (score.value >= 85) {
    return '優秀！您已充分理解本模組的核心概念！'
  } else {
    return '做得好！您已達到及格標準！'
  }
})

const circumference = 2 * Math.PI * 90

// 方法
const startQuiz = () => {
  quizState.value = 'inProgress'
  currentQuestionIndex.value = 0
  selectedAnswer.value = null
  showAnswer.value = false
  answers.value = []
  elapsedTime.value = 0
  
  // 開始計時
  timerInterval.value = setInterval(() => {
    elapsedTime.value++
  }, 1000)
}

const selectAnswer = (index) => {
  selectedAnswer.value = index
}

const submitAnswer = () => {
  if (selectedAnswer.value === null) return
  
  const isCorrect = selectedAnswer.value === currentQuestion.value.correctAnswer
  answers.value.push({
    questionId: currentQuestion.value.id,
    selectedAnswer: selectedAnswer.value,
    correctAnswer: currentQuestion.value.correctAnswer,
    correct: isCorrect
  })
  
  showAnswer.value = true
}

const nextQuestion = () => {
  currentQuestionIndex.value++
  selectedAnswer.value = null
  showAnswer.value = false
}

const finishQuiz = () => {
  if (timerInterval.value) {
    clearInterval(timerInterval.value)
  }
  
  quizState.value = 'completed'
  
  // 儲存結果
  saveQuizResult()
  
  // 通知父組件
  emit('quizComplete', {
    moduleId: props.moduleId,
    passed: passed.value,
    score: score.value,
    correctAnswers: correctAnswers.value,
    totalQuestions: props.quiz.questions.length,
    timeSpent: elapsedTime.value,
    answers: answers.value
  })
}

const retryQuiz = () => {
  startQuiz()
}

const reviewLessons = () => {
  emit('reviewLessons')
}

const continueToNext = () => {
  emit('continueNext')
}

const formatTime = (seconds) => {
  const mins = Math.floor(seconds / 60)
  const secs = seconds % 60
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

const saveQuizResult = () => {
  const result = {
    moduleId: props.moduleId,
    score: score.value,
    passed: passed.value,
    correctAnswers: correctAnswers.value,
    totalQuestions: props.quiz.questions.length,
    timeSpent: elapsedTime.value,
    completedAt: new Date().toISOString(),
    answers: answers.value
  }
  
  // 儲存到 localStorage
  const quizHistory = JSON.parse(localStorage.getItem('quizHistory') || '[]')
  quizHistory.push(result)
  localStorage.setItem('quizHistory', JSON.stringify(quizHistory))
}

onUnmounted(() => {
  if (timerInterval.value) {
    clearInterval(timerInterval.value)
  }
})
</script>

<style scoped>
.quiz-engine {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

/* 開始畫面 */
.quiz-start {
  text-align: center;
  padding: 60px 40px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.quiz-icon {
  font-size: 80px;
  margin-bottom: 24px;
}

.quiz-start h1 {
  font-size: 32px;
  color: #2c3e50;
  margin-bottom: 40px;
}

.quiz-info {
  display: flex;
  justify-content: center;
  gap: 40px;
  margin-bottom: 40px;
}

.info-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.info-item .label {
  font-size: 13px;
  color: #95a5a6;
  text-transform: uppercase;
}

.info-item .value {
  font-size: 24px;
  font-weight: 700;
  color: #667eea;
}

.start-btn {
  padding: 16px 48px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 18px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s ease;
}

.start-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

/* 進行中 */
.quiz-progress {
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.quiz-header {
  padding: 24px;
  background: #f8f9fa;
  border-bottom: 1px solid #e0e0e0;
}

.progress-bar {
  width: 100%;
  height: 8px;
  background: #e0e0e0;
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 16px;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  transition: width 0.3s ease;
}

.quiz-meta {
  display: flex;
  justify-content: space-between;
  font-size: 14px;
  color: #7f8c8d;
  font-weight: 600;
}

.question-container {
  padding: 40px;
}

.question {
  margin-bottom: 32px;
}

.question-number {
  font-size: 13px;
  color: #95a5a6;
  text-transform: uppercase;
  margin-bottom: 12px;
  font-weight: 600;
}

.question h2 {
  font-size: 24px;
  color: #2c3e50;
  margin: 0;
  line-height: 1.5;
}

.options {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 32px;
}

.option {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  background: #f8f9fa;
  border: 2px solid #e0e0e0;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
}

.option:hover {
  background: #e8f4f8;
  border-color: #667eea;
}

.option.selected {
  background: #e8f4f8;
  border-color: #667eea;
}

.option.correct {
  background: #e8f5e9;
  border-color: #4CAF50;
}

.option.incorrect {
  background: #ffebee;
  border-color: #f44336;
}

.option-letter {
  width: 40px;
  height: 40px;
  background: white;
  border: 2px solid #e0e0e0;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  color: #667eea;
  font-size: 18px;
  flex-shrink: 0;
}

.option.selected .option-letter {
  background: #667eea;
  color: white;
  border-color: #667eea;
}

.option.correct .option-letter {
  background: #4CAF50;
  color: white;
  border-color: #4CAF50;
}

.option.incorrect .option-letter {
  background: #f44336;
  color: white;
  border-color: #f44336;
}

.option-text {
  flex: 1;
  font-size: 16px;
  color: #2c3e50;
  line-height: 1.6;
}

.answer-icon {
  font-size: 24px;
  font-weight: 700;
}

.option.correct .answer-icon {
  color: #4CAF50;
}

.option.incorrect .answer-icon {
  color: #f44336;
}

.explanation {
  background: #fff3cd;
  border-left: 4px solid #ffc107;
  padding: 24px;
  border-radius: 8px;
  margin-bottom: 32px;
}

.explanation-header {
  margin-bottom: 12px;
  font-weight: 700;
  font-size: 16px;
}

.correct-label {
  color: #4CAF50;
}

.incorrect-label {
  color: #f44336;
}

.explanation p {
  margin: 0;
  color: #2c3e50;
  line-height: 1.6;
}

.navigation-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.next-btn,
.finish-btn,
.submit-btn {
  padding: 14px 32px;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s ease;
}

.submit-btn {
  background: #667eea;
  color: white;
}

.submit-btn:hover {
  background: #5568d3;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.next-btn {
  background: #4CAF50;
  color: white;
}

.next-btn:hover {
  background: #45a049;
}

.finish-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.finish-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

/* 結果畫面 */
.quiz-result {
  text-align: center;
  padding: 60px 40px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.result-icon {
  font-size: 80px;
  margin-bottom: 24px;
}

.quiz-result h1 {
  font-size: 32px;
  margin-bottom: 40px;
}

.quiz-result h1 {
  color: #2c3e50;
}

.result-icon.pass + h1 {
  color: #4CAF50;
}

.result-icon.fail + h1 {
  color: #FF9800;
}

.score-circle {
  position: relative;
  display: inline-block;
  margin-bottom: 40px;
}

.score-text {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
}

.score-number {
  font-size: 48px;
  font-weight: 700;
  color: #2c3e50;
}

.score-label {
  font-size: 14px;
  color: #95a5a6;
  text-transform: uppercase;
}

.result-details {
  display: flex;
  justify-content: center;
  gap: 40px;
  margin-bottom: 40px;
}

.detail-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.detail-label {
  font-size: 13px;
  color: #95a5a6;
}

.detail-value {
  font-size: 20px;
  font-weight: 700;
  color: #2c3e50;
}

.success-message,
.retry-message {
  background: #f8f9fa;
  padding: 24px;
  border-radius: 12px;
  margin-bottom: 32px;
}

.success-message {
  border-left: 4px solid #4CAF50;
}

.retry-message {
  border-left: 4px solid #FF9800;
}

.success-message p,
.retry-message p {
  margin: 8px 0;
  color: #2c3e50;
  line-height: 1.6;
}

.result-actions {
  display: flex;
  justify-content: center;
  gap: 12px;
}

.retry-btn,
.review-btn,
.continue-btn {
  padding: 14px 32px;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s ease;
}

.retry-btn {
  background: #FF9800;
  color: white;
}

.retry-btn:hover {
  background: #f57c00;
}

.review-btn {
  background: white;
  color: #667eea;
  border: 2px solid #667eea;
}

.review-btn:hover {
  background: #f5f5f5;
}

.continue-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.continue-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}
</style>
