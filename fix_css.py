import sys

with open('src/components/MapSection.vue', 'r', encoding='utf-8') as f:
    content = f.read()

media_query_start = content.find('@media (max-width: 768px) {')
media_query_end = content.find('/* 收合狀態樣式 */')

if media_query_start != -1 and media_query_end != -1:
    old_block = content[media_query_start:media_query_end]
    new_block = '''@media (max-width: 768px) {
  .map-header {
    background: none;
    border: none;
    pointer-events: none;
    padding-top: 25px;
  }
  .map-header h1 {
    font-size: 1.25rem;
    color: #5b1d1d;
    text-shadow: 0 1px 4px rgba(255,255,255, 0.9), 0 0 10px rgba(255,255,255, 0.9), 0 0 15px rgba(255,255,255, 0.9);
    pointer-events: auto;
  }

  .btn-learning-mode {
    top: 45%;
    left: 10px;
    width: 60px;
    height: 60px;
    border-radius: 50%;
    padding: 0;
    background: #4CAF50; /* Green */
    color: #111;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 4px 12px rgba(0,0,0,0.3);
  }
  .btn-learning-mode .learning-icon {
    display: block;
    color: #111;
  }
  .btn-learning-mode .learning-text {
    display: none;
  }

  .btn-3d, .btn-contours, .geology-panel {
    display: none; /* Map tools moved to panels */
  }

  .desktop-only-buttons {
    display: none !important;
  }

  .info-header-bar {
    background: white;
    color: #333;
    padding: 12px 16px;
    border-bottom: none;
    border-radius: 20px 20px 0 0;
  }

  .aoc-info-title {
    color: #333;
    font-weight: 600;
  }

  .map-buttons-right {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .btn-collapse {
    background: #111 !important;
    color: white !important;
    border: none !important;
    border-radius: 10px !important;
    width: 38px;
    height: 38px;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .btn-audio-compact {
    background: #764ba2 !important;
    color: white !important;
    border: none !important;
    border-radius: 50% !important;
    width: 38px;
    height: 38px;
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 38px;
  }

  .map-info-bar {
    position: absolute !important;
    bottom: 85px !important;
    left: 15px !important;
    right: 15px !important;
    width: auto !important;
    max-width: none !important;
    margin: 0;
    border-radius: 20px 20px 0 0 !important;
    box-shadow: 0 -4px 15px rgba(0,0,0,0.1) !important;
    border-bottom: 1px solid #f0f0f0;
  }

  .mobile-grid-buttons {
    display: flex;
    justify-content: space-around;
    align-items: center;
    position: absolute;
    bottom: 15px;
    left: 15px;
    right: 15px;
    background: white;
    padding: 12px;
    border-radius: 20px;
    box-shadow: 0 4px 15px rgba(0,0,0,0.15);
    z-index: 1000;
  }
  .mobile-grid-buttons.merged-with-info {
    bottom: 15px;
    border-top-left-radius: 0;
    border-top-right-radius: 0;
    box-shadow: 0 8px 15px rgba(0,0,0,0.15);
    padding-top: 4px; /* Move slightly closer to the top piece */
  }

  .m-grid-btn {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    background: #FAEFEC;
    border-radius: 14px;
    border: none;
    padding: 10px 0;
    gap: 4px;
    color: #6D4C41;
    flex: 1;
    margin: 0 4px;
    transition: all 0.2s;
  }
  .m-grid-btn.active {
    background: white;
    color: #8B0000;
    box-shadow: inset 0 0 0 1px #8B0000;
  }
  .m-grid-icon {
    font-size: 1.1rem;
    font-weight: bold;
    display: flex;
    align-items: center;
    justify-content: center;
    background: none !important;
  }
  .m-grid-btn.active .m-grid-icon {
    background: none !important;
    color: #8B0000;
  }
  .m-grid-text {
    font-size: 0.75rem;
    font-weight: bold;
  }

  .mobile-layer-panel {
    position: absolute;
    bottom: 150px;
    left: 15px;
    background: white;
    padding: 16px;
    border-radius: 16px;
    box-shadow: 0 4px 16px rgba(0,0,0,0.2);
    z-index: 1000;
    width: 200px;
  }

  .layer-panel-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
  }
  .layer-panel-header h4 {
    margin: 0;
    font-size: 1rem;
    color: #333;
  }
  .close-layer-btn {
    background: none;
    border: none;
    font-size: 1.2rem;
    cursor: pointer;
    color: #999;
  }
  .layer-toggle-btn {
    width: 100%;
    padding: 10px;
    margin-bottom: 8px;
    border-radius: 6px;
    border: 1px solid #ddd;
    background: #f8f8f8;
    color: #333;
    font-weight: bold;
    cursor: pointer;
  }
  .layer-toggle-btn.active {
    background: #800020;
    color: white;
    border-color: #800020;
  }

}

'''
    content = content.replace(old_block, new_block)
    with open('src/components/MapSection.vue', 'w', encoding='utf-8') as f:
        f.write(content)
    print("CSS updated successfully")
