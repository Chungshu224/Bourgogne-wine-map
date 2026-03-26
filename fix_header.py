import sys

with open('src/components/MapSection.vue', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('''  .map-header {
    background: none;
    border: none;
    pointer-events: none;
    padding-top: 25px;
  }''', '''  .map-header {
    position: fixed;
    background: none;
    border: none;
    pointer-events: none;
    padding-top: 25px;
    z-index: 1000;
  }''')

with open('src/components/MapSection.vue', 'w', encoding='utf-8') as f:
    f.write(content)
