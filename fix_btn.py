import sys

with open('src/components/MapSection.vue', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('''  .btn-learning-mode {
    top: 45%;''', '''  .btn-learning-mode {
    position: fixed !important;
    top: 45%;''')

with open('src/components/MapSection.vue', 'w', encoding='utf-8') as f:
    f.write(content)
