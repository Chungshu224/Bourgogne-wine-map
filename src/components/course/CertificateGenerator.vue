<template>
  <div class="certificate-generator">
    <div class="certificate-preview" ref="certificateRef">
      <div class="certificate-border">
        <div class="certificate-content">
          <!-- 頂部裝飾 -->
          <div class="certificate-header">
            <div class="ornament">🍇</div>
            <h1 class="certificate-title">布根地葡萄酒證書</h1>
            <div class="subtitle">Burgundy Wine Certificate</div>
            <div class="ornament">🍷</div>
          </div>

          <!-- 證書主體 -->
          <div class="certificate-body">
            <div class="awarded-to">此證書頒發給</div>
            <div class="recipient-name">{{ certificateData.userName || '學習者' }}</div>
            
            <div class="achievement-text">
              恭喜您成功完成
            </div>

            <div class="course-info">
              <div class="level-badge" :style="{ background: getLevelColor(certificateData.level) }">
                {{ getLevelName(certificateData.level) }}
              </div>
              <div class="course-name">{{ getCourseTitle(certificateData.level) }}</div>
            </div>

            <div class="stats-grid">
              <div class="stat-item">
                <div class="stat-label">完成模組</div>
                <div class="stat-value">{{ certificateData.completedModules }} / {{ certificateData.totalModules }}</div>
              </div>
              <div class="stat-item">
                <div class="stat-label">平均分數</div>
                <div class="stat-value">{{ certificateData.averageScore }}%</div>
              </div>
              <div class="stat-item">
                <div class="stat-label">學習時數</div>
                <div class="stat-value">{{ formatHours(certificateData.totalTime) }}</div>
              </div>
            </div>

            <div class="completion-date">
              完成日期：{{ formatDate(certificateData.completedAt) }}
            </div>
          </div>

          <!-- 底部簽名 -->
          <div class="certificate-footer">
            <div class="signature-section">
              <div class="signature-line"></div>
              <div class="signature-title">課程認證</div>
            </div>
            
            <div class="certificate-seal">
              <div class="seal-circle">
                <div class="seal-text">
                  <div>CERTIFIED</div>
                  <div class="seal-year">{{ new Date().getFullYear() }}</div>
                </div>
              </div>
            </div>

            <div class="certificate-id">
              證書編號：{{ certificateData.certificateId }}
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 操作按鈕 -->
    <div class="certificate-actions">
      <button class="download-btn" @click="downloadPDF">
        <span class="btn-icon">📥</span>
        下載 PDF
      </button>
      <button class="share-btn" @click="shareCertificate">
        <span class="btn-icon">📤</span>
        分享證書
      </button>
      <button class="print-btn" @click="printCertificate">
        <span class="btn-icon">🖨️</span>
        列印證書
      </button>
    </div>

    <!-- 分享對話框 -->
    <div v-if="showShareDialog" class="share-dialog-overlay" @click="showShareDialog = false">
      <div class="share-dialog" @click.stop>
        <h3>分享您的成就</h3>
        <div class="share-options">
          <button class="share-option" @click="shareToSocial('linkedin')">
            <span class="share-icon">💼</span>
            LinkedIn
          </button>
          <button class="share-option" @click="shareToSocial('facebook')">
            <span class="share-icon">📘</span>
            Facebook
          </button>
          <button class="share-option" @click="shareToSocial('twitter')">
            <span class="share-icon">🐦</span>
            Twitter
          </button>
          <button class="share-option" @click="copyLink">
            <span class="share-icon">🔗</span>
            複製連結
          </button>
        </div>
        <button class="close-dialog" @click="showShareDialog = false">關閉</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, defineProps } from 'vue'

const props = defineProps({
  certificateData: {
    type: Object,
    required: true,
    default: () => ({
      userName: '學習者',
      level: 1,
      completedModules: 0,
      totalModules: 0,
      averageScore: 0,
      totalTime: 0,
      completedAt: new Date(),
      certificateId: ''
    })
  }
})

const certificateRef = ref(null)
const showShareDialog = ref(false)

const getLevelName = (level) => {
  const levels = {
    1: '初階課程',
    2: '中階課程',
    3: '高階課程',
    4: '大師課程'
  }
  return levels[level] || '課程'
}

const getCourseTitle = (level) => {
  const titles = {
    1: '布根地葡萄酒入門',
    2: '布根地產區深度探索',
    3: '布根地風土與品鑑',
    4: '布根地葡萄酒專家認證'
  }
  return titles[level] || '布根地葡萄酒課程'
}

const getLevelColor = (level) => {
  const colors = {
    1: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    2: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
    3: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
    4: 'linear-gradient(135deg, #fa709a 0%, #fee140 100%)'
  }
  return colors[level] || colors[1]
}

const formatDate = (date) => {
  const d = new Date(date)
  return d.toLocaleDateString('zh-TW', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const formatHours = (minutes) => {
  const hours = Math.floor(minutes / 60)
  const mins = minutes % 60
  if (hours > 0) {
    return `${hours}小時${mins}分鐘`
  }
  return `${mins}分鐘`
}

const downloadPDF = async () => {
  // 使用 html2canvas 和 jsPDF 生成 PDF
  const element = certificateRef.value
  
  try {
    // 動態導入庫（需要先安裝）
    const html2canvas = (await import('html2canvas')).default
    const { jsPDF } = await import('jspdf')
    
    const canvas = await html2canvas(element, {
      scale: 2,
      backgroundColor: '#ffffff'
    })
    
    const imgData = canvas.toDataURL('image/png')
    const pdf = new jsPDF({
      orientation: 'landscape',
      unit: 'mm',
      format: 'a4'
    })
    
    const imgWidth = 297 // A4 landscape width in mm
    const imgHeight = (canvas.height * imgWidth) / canvas.width
    
    pdf.addImage(imgData, 'PNG', 0, 0, imgWidth, imgHeight)
    pdf.save(`Burgundy-Wine-Certificate-Level${props.certificateData.level}.pdf`)
  } catch (error) {
    console.error('PDF generation failed:', error)
    alert('PDF 下載功能需要安裝相關套件。請使用列印功能或截圖儲存證書。')
  }
}

const printCertificate = () => {
  window.print()
}

const shareCertificate = () => {
  showShareDialog.value = true
}

const shareToSocial = (platform) => {
  const text = `我完成了布根地葡萄酒${getLevelName(props.certificateData.level)}，平均分數 ${props.certificateData.averageScore}%！`
  const url = window.location.href
  
  const shareUrls = {
    linkedin: `https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(url)}`,
    facebook: `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(url)}`,
    twitter: `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent(url)}`
  }
  
  if (shareUrls[platform]) {
    window.open(shareUrls[platform], '_blank', 'width=600,height=400')
  }
}

const copyLink = async () => {
  try {
    await navigator.clipboard.writeText(window.location.href)
    alert('連結已複製到剪貼簿！')
  } catch (error) {
    console.error('Failed to copy:', error)
  }
}
</script>

<style scoped>
.certificate-generator {
  max-width: 1000px;
  margin: 0 auto;
  padding: 40px 20px;
}

.certificate-preview {
  background: white;
  padding: 40px;
  margin-bottom: 30px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
}

.certificate-border {
  border: 8px double #8b7355;
  padding: 40px;
  position: relative;
  background: linear-gradient(135deg, #fdfbfb 0%, #f7f4ed 100%);
}

.certificate-border::before {
  content: '';
  position: absolute;
  top: 20px;
  left: 20px;
  right: 20px;
  bottom: 20px;
  border: 2px solid #d4af37;
  pointer-events: none;
}

.certificate-content {
  position: relative;
  z-index: 1;
}

.certificate-header {
  text-align: center;
  margin-bottom: 40px;
  padding-bottom: 30px;
  border-bottom: 2px solid #d4af37;
}

.ornament {
  font-size: 48px;
  margin-bottom: 16px;
}

.certificate-title {
  font-size: 48px;
  font-family: 'Georgia', serif;
  color: #2c3e50;
  margin: 0 0 8px 0;
  font-weight: 700;
  letter-spacing: 2px;
}

.subtitle {
  font-size: 18px;
  color: #8b7355;
  font-style: italic;
  letter-spacing: 3px;
  margin-bottom: 16px;
}

.certificate-body {
  text-align: center;
  padding: 40px 0;
}

.awarded-to {
  font-size: 16px;
  color: #7f8c8d;
  text-transform: uppercase;
  letter-spacing: 2px;
  margin-bottom: 16px;
}

.recipient-name {
  font-size: 42px;
  font-family: 'Georgia', serif;
  color: #2c3e50;
  margin-bottom: 32px;
  font-weight: 700;
  font-style: italic;
}

.achievement-text {
  font-size: 18px;
  color: #555;
  margin-bottom: 24px;
}

.course-info {
  margin-bottom: 40px;
}

.level-badge {
  display: inline-block;
  padding: 12px 32px;
  color: white;
  font-size: 20px;
  font-weight: 700;
  border-radius: 30px;
  margin-bottom: 16px;
  letter-spacing: 1px;
}

.course-name {
  font-size: 28px;
  color: #2c3e50;
  font-weight: 700;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 30px;
  max-width: 600px;
  margin: 40px auto;
  padding: 30px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.stat-item {
  text-align: center;
}

.stat-label {
  font-size: 13px;
  color: #95a5a6;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-bottom: 8px;
}

.stat-value {
  font-size: 24px;
  color: #2c3e50;
  font-weight: 700;
}

.completion-date {
  font-size: 16px;
  color: #7f8c8d;
  margin-top: 24px;
}

.certificate-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 60px;
  padding-top: 30px;
  border-top: 2px solid #d4af37;
  position: relative;
}

.signature-section {
  flex: 1;
  text-align: center;
}

.signature-line {
  width: 200px;
  height: 2px;
  background: #2c3e50;
  margin: 0 auto 8px;
}

.signature-title {
  font-size: 14px;
  color: #7f8c8d;
}

.certificate-seal {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  top: -40px;
}

.seal-circle {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  background: linear-gradient(135deg, #d4af37 0%, #f4d03f 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  border: 4px solid #8b7355;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.seal-text {
  text-align: center;
  color: #8b4513;
  font-weight: 700;
}

.seal-text div:first-child {
  font-size: 11px;
  letter-spacing: 1px;
}

.seal-year {
  font-size: 20px;
  margin-top: 4px;
}

.certificate-id {
  flex: 1;
  text-align: center;
  font-size: 12px;
  color: #95a5a6;
  font-family: 'Courier New', monospace;
}

.certificate-actions {
  display: flex;
  justify-content: center;
  gap: 16px;
  margin-top: 30px;
}

.download-btn,
.share-btn,
.print-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 14px 28px;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.download-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.share-btn {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.print-btn {
  background: white;
  color: #667eea;
  border: 2px solid #667eea;
}

.download-btn:hover,
.share-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
}

.print-btn:hover {
  background: #f5f5f5;
}

.btn-icon {
  font-size: 20px;
}

/* 分享對話框 */
.share-dialog-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.share-dialog {
  background: white;
  padding: 40px;
  border-radius: 16px;
  max-width: 500px;
  width: 90%;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

.share-dialog h3 {
  font-size: 24px;
  color: #2c3e50;
  margin-bottom: 24px;
  text-align: center;
}

.share-options {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
  margin-bottom: 24px;
}

.share-option {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 16px;
  background: #f8f9fa;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.share-option:hover {
  background: #e8f4f8;
  border-color: #667eea;
  transform: translateY(-2px);
}

.share-icon {
  font-size: 24px;
}

.close-dialog {
  width: 100%;
  padding: 14px;
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.3s ease;
}

.close-dialog:hover {
  background: #5568d3;
}

/* 列印樣式 */
@media print {
  .certificate-actions {
    display: none;
  }
  
  .certificate-preview {
    box-shadow: none;
    padding: 0;
  }
  
  .certificate-generator {
    padding: 0;
  }
}
</style>
