import sys

with open('src/components/MapSection.vue', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace absolute with fixed for map-info-bar and mobile-grid-buttons in @media (max-width: 768px) block

content = content.replace('''  .map-info-bar {
    position: absolute !important;''', '''  .map-info-bar {
    position: fixed !important;''')

content = content.replace('''  .mobile-grid-buttons {
    display: flex;
    justify-content: space-around;
    align-items: center;
    position: absolute;''', '''  .mobile-grid-buttons {
    display: flex;
    justify-content: space-around;
    align-items: center;
    position: fixed;''')

content = content.replace('''  .mobile-layer-panel {
    position: absolute;''', '''  .mobile-layer-panel {
    position: fixed;''')

with open('src/components/MapSection.vue', 'w', encoding='utf-8') as f:
    f.write(content)
print("CSS updated position to fixed")
