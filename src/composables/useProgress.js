/**
 * 課程進度管理 Composable
 * 統一管理所有 localStorage 操作，避免代碼重複
 */

export function useProgress() {
  /**
   * 獲取指定階段的進度
   * @param {number} levelId - 階段 ID (1-4)
   * @returns {Object} 進度物件 { moduleId: { completed: boolean, quizScore: number, completedAt: string } }
   */
  const getLevelProgress = (levelId) => {
    const key = `burgundy-level${levelId}-progress`
    const saved = localStorage.getItem(key)
    return saved ? JSON.parse(saved) : {}
  }

  /**
   * 保存模組進度
   * @param {number} levelId - 階段 ID
   * @param {string} moduleId - 模組 ID
   * @param {Object} data - 進度數據 { completed, quizScore, completedAt }
   */
  const saveModuleProgress = (levelId, moduleId, data) => {
    const key = `burgundy-level${levelId}-progress`
    const progress = getLevelProgress(levelId)
    progress[moduleId] = {
      ...progress[moduleId],
      ...data
    }
    localStorage.setItem(key, JSON.stringify(progress))
  }

  /**
   * 獲取模組已完成的課程列表
   * @param {string} moduleId - 模組 ID
   * @returns {Array<string>} 已完成課程 ID 列表
   */
  const getCompletedLessons = (moduleId) => {
    const key = `completed-lessons-${moduleId}`
    const saved = localStorage.getItem(key)
    return saved ? JSON.parse(saved) : []
  }

  /**
   * 保存模組已完成的課程列表
   * @param {string} moduleId - 模組 ID
   * @param {Array<string>} lessons - 已完成課程 ID 列表
   */
  const saveCompletedLessons = (moduleId, lessons) => {
    const key = `completed-lessons-${moduleId}`
    localStorage.setItem(key, JSON.stringify(lessons))
  }

  /**
   * 獲取模組的學習時長（分鐘）
   * @param {string} moduleId - 模組 ID
   * @returns {number} 累計學習時長（分鐘）
   */
  const getLearningTime = (moduleId) => {
    const key = `learningTime-${moduleId}`
    return parseInt(localStorage.getItem(key) || '0')
  }

  /**
   * 累加模組學習時長
   * @param {string} moduleId - 模組 ID
   * @param {number} minutes - 要累加的分鐘數
   */
  const addLearningTime = (moduleId, minutes) => {
    const key = `learningTime-${moduleId}`
    const currentTime = getLearningTime(moduleId)
    localStorage.setItem(key, (currentTime + minutes).toString())
  }

  /**
   * 獲取用戶名稱
   * @returns {string} 用戶名稱
   */
  const getUserName = () => {
    return localStorage.getItem('userName') || '學習者'
  }

  /**
   * 設置用戶名稱
   * @param {string} name - 用戶名稱
   */
  const setUserName = (name) => {
    localStorage.setItem('userName', name)
  }

  /**
   * 獲取所有證書
   * @returns {Array<Object>} 證書列表
   */
  const getCertificates = () => {
    const saved = localStorage.getItem('certificates')
    return saved ? JSON.parse(saved) : []
  }

  /**
   * 保存新證書
   * @param {Object} certificate - 證書數據
   */
  const saveCertificate = (certificate) => {
    const certificates = getCertificates()
    certificates.push(certificate)
    localStorage.setItem('certificates', JSON.stringify(certificates))
  }

  /**
   * 檢查階段是否完成
   * @param {number} levelId - 階段 ID
   * @param {number} totalModules - 該階段總模組數
   * @returns {boolean} 是否完成
   */
  const isLevelComplete = (levelId, totalModules) => {
    const progress = getLevelProgress(levelId)
    const completedCount = Object.keys(progress).filter(
      key => progress[key].completed
    ).length
    return completedCount >= totalModules
  }

  /**
   * 獲取階段完成進度百分比
   * @param {number} levelId - 階段 ID
   * @param {number} totalModules - 該階段總模組數
   * @returns {number} 完成百分比 (0-100)
   */
  const getLevelProgressPercent = (levelId, totalModules) => {
    const progress = getLevelProgress(levelId)
    const completedCount = Object.keys(progress).filter(
      key => progress[key].completed
    ).length
    return totalModules > 0 ? Math.round((completedCount / totalModules) * 100) : 0
  }

  return {
    // 階段進度
    getLevelProgress,
    saveModuleProgress,
    isLevelComplete,
    getLevelProgressPercent,
    
    // 課程完成狀態
    getCompletedLessons,
    saveCompletedLessons,
    
    // 學習時長
    getLearningTime,
    addLearningTime,
    
    // 用戶資料
    getUserName,
    setUserName,
    
    // 證書
    getCertificates,
    saveCertificate
  }
}
