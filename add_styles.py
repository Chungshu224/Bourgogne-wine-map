import sys

with open('src/components/MapSection.vue', 'r', encoding='utf-8') as f:
    content = f.read()

# Find the @media (max-width: 768px) block and add mobile geology materials styles after layer-toggle-btn.active
mobile_geology_styles = '''
  .mobile-geology-materials {
    margin-top: 12px;
    padding-top: 12px;
    border-top: 1px solid #e0e0e0;
  }
  .mobile-geology-materials-title {
    font-size: 0.85rem;
    font-weight: 600;
    color: #666;
    margin-bottom: 8px;
  }
  .mobile-geology-item {
    margin-bottom: 6px;
  }
  .mobile-geology-toggle {
    width: 100%;
    padding: 8px 10px;
    border-radius: 6px;
    border: 1px solid #ddd;
    background: #f8f8f8;
    color: #333;
    font-weight: 500;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 8px;
    transition: all 0.2s;
  }
  .mobile-geology-toggle.active {
    background: #e8f5e9;
    border-color: #4CAF50;
    color: #2e7d32;
  }
  .mobile-geology-toggle .material-dot {
    width: 14px;
    height: 14px;
    border-radius: 50%;
    flex-shrink: 0;
  }

  .btn-reset {
    padding: 6px 10px;
    background: rgba(244, 67, 54, 0.9);
    color: white;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    font-size: 1.1rem;
    font-weight: bold;
    transition: all 0.2s ease;
    min-width: 36px;
    height: 36px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .btn-reset:hover {
    background: rgba(229, 57, 53, 0.95);
    transform: scale(1.05);
  }
'''

# Find the position after .layer-toggle-btn.active and insert the styles
target = '''  .layer-toggle-btn.active {
    background: #800020;
    color: white;
    border-color: #800020;
  }

}'''

replacement = '''  .layer-toggle-btn.active {
    background: #800020;
    color: white;
    border-color: #800020;
  }

''' + mobile_geology_styles + '''
}'''

content = content.replace(target, replacement)

with open('src/components/MapSection.vue', 'w', encoding='utf-8') as f:
    f.write(content)
print('Added mobile geology styles')
