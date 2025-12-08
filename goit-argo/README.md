# GitOps with ArgoCD


## 1. Розгортання ArgoCD (Terraform)

1. Перейдіть у папку з Terraform кодом:
   ```bash
   cd terraform/argocd
   ```

2. Ініціалізуйте та застосуйте:
    ```bash
    terraform init
    terraform apply -auto-approve
    ```

    <img src="screenshots/terraform.jpg" width="600"/>


3. Перевірте, що ArgoCD запустився:
    ```bash
    kubectl get pods -n infra-tools
    ```

## 2. Доступ до ArgoCD UI

1. Отримайте пароль адміністратора (початковий):
    ```bash
    [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl -n infra-tools get secret argocd-initial-admin-secret -o jsonpath="{.data.password}")))
    ```
2. Зробіть прокидання порту (Port Forward):
    ```bash
    kubectl port-forward svc/argocd-server -n ikubectl port-forward svc/argocd-server -n infra-tools 8080:80
    ```
3. Відкрийте у браузері: http://localhost:8080

-  Login: admin
-  Password: (той, що ви отримали у пункті 1)


  <img src="screenshots/argocd_1.jpg" width="600"/>

Password: (той, що ви отримали у пункті 1)

    ```bash

    ```

##  3. Деплой застосунку (Helm через Argo)
1. Запуште цей репозиторій на GitHub.
2. Застосуйте маніфест Application у кластер:
   ```bash
    kubectl apply -f nginx-app.yaml
    ```

3. Перевірте статус у UI ArgoCD або через CLI:

    ```bash
    kubectl get applications -n infra-tools
    ```
4. Перевірте, що Nginx запустився:
    ```bash
    kubectl get pods -n my-app-ns
    ```
---

### Чекліст:

1.  **Terraform:** Створіть файли з Частини 1, запустіть `terraform init` та `terraform apply`.
2.  **Git:** Створіть репозиторій на GitHub `goit-argo`. Додайте туди файли з Частини 2 та Частини 3. Зробіть `git push`.
3.  **Deploy:**
    * Виконайте команду для отримання паролю ArgoCD.
    * Запустіть `kubectl port-forward`, щоб зайти в інтерфейс.
    * Виконайте `kubectl apply -f nginx-app.yaml` (переконайтеся, що файл є локально).
    * Спостерігайте магію: ArgoCD побачить задачу, скачає Helm-чарт Bitnami Nginx і розгорне його в неймспейс `my-app-ns`.