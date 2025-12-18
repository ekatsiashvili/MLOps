

##  2. Запуск через GitHub Actions

Проект адаптовано для використання **GitHub Actions** замість GitLab CI.
Файл конфігурації: `.github/workflows/train.yml`.

Необхідні змінні (Settings -> Secrets and variables -> Actions):
* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

Пайплайн автоматично запускає AWS Step Function при push в репозиторій.