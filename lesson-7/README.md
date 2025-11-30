# Lesson 7: Kubernetes Cluster (EKS) та Helm Chart для Django

Цей проєкт містить Terraform конфігурацію для створення:
- S3 бакет та DynamoDB для зберігання та блокування стейт-файлів Terraform
- VPC з публічними та приватними підмережами
- ECR репозиторій для зберігання Docker-образів
- EKS кластер Kubernetes
- Helm-чарт для розгортання Django додатку

## Структура проєкту

```
lesson-7/
│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── variables.tf             # Загальні змінні проєкту
├── outputs.tf              # Загальне виведення ресурсів
│
├── modules/                 # Каталог з усіма модулями
│   │
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   │   ├── s3.tf            # Створення S3-бакета
│   │   ├── dynamodb.tf     # Створення DynamoDB
│   │   ├── variables.tf     # Змінні для S3
│   │   └── outputs.tf       # Виведення інформації про S3 та DynamoDB
│   │
│   ├── vpc/                 # Модуль для VPC
│   │   ├── vpc.tf           # Створення VPC, підмереж, Internet Gateway
│   │   ├── routes.tf        # Налаштування маршрутизації
│   │   ├── variables.tf     # Змінні для VPC
│   │   └── outputs.tf       # Виведення інформації про VPC
│   │
│   ├── ecr/                 # Модуль для ECR
│   │   ├── ecr.tf           # Створення ECR репозиторію
│   │   ├── variables.tf     # Змінні для ECR
│   │   └── outputs.tf       # Виведення URL репозиторію ECR
│   │
│   └── eks/                 # Модуль для Kubernetes кластера
│       ├── eks.tf           # Створення кластера
│       ├── variables.tf     # Змінні для EKS
│       └── outputs.tf       # Виведення інформації про кластер
│
├── charts/
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml    # Deployment для Django
│       │   ├── service.yaml        # Service типу LoadBalancer
│       │   ├── configmap.yaml      # ConfigMap зі змінними середовища
│       │   ├── hpa.yaml            # Horizontal Pod Autoscaler
│       │   └── _helpers.tpl        # Helper шаблони
│       ├── Chart.yaml              # Метадані Helm-чарту
│       └── values.yaml             # Значення за замовчуванням
│
└── README.md                # Документація проєкту
```

## Передумови

1. Встановлений Terraform (версія >= 1.0)
2. Налаштовані AWS credentials (через `aws configure` або змінні оточення)
3. AWS CLI встановлений та налаштований
4. kubectl встановлений
5. Helm 3 встановлений
6. Docker встановлений (для побудови та завантаження образу)

## Кроки виконання

### 1. Ініціалізація та розгортання інфраструктури

```bash
# Ініціалізація Terraform
terraform init

# Перегляд плану змін
terraform plan

# Застосування змін (створення інфраструктури)
terraform apply
```

**Важливо:** Перед першим запуском переконайтеся, що S3-бакет та DynamoDB таблиця вже існують, або створіть їх окремо.

### 2. Налаштування kubectl для доступу до кластера

Після успішного створення EKS кластера, налаштуйте kubectl:

```bash
# Отримайте команду з outputs
terraform output kubectl_config_command

# Або виконайте вручну (замініть на ваші значення)
aws eks update-kubeconfig --region us-east-2 --name lesson-7-eks

# Перевірте підключення
kubectl get nodes
```

### 3. Завантаження Docker-образу до ECR

**Варіант 1: Використання скрипта (рекомендовано)**

```bash
# Виконайте скрипт для автоматичного завантаження образу
./scripts/push-to-ecr.sh
```

**Варіант 2: Вручну**

```bash
# Отримайте URL ECR репозиторію
ECR_URL=$(terraform output -raw ecr_repository_url)
AWS_REGION=$(terraform output -raw aws_region || echo "us-east-2")

# Авторизуйтеся в ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URL

# Побудуйте Docker-образ (з кореня проєкту, де знаходиться Dockerfile)
cd /home/eugene/Projects/goit/hw/cicd/goit-devops
docker build -t django-app:latest .

# Тегуйте образ для ECR
docker tag django-app:latest $ECR_URL:latest

# Завантажте образ до ECR
docker push $ECR_URL:latest
```

### 4. Оновлення values.yaml з URL ECR репозиторію

Після отримання URL ECR репозиторію, оновіть `charts/django-app/values.yaml`:

```yaml
image:
  repository: "<ECR_REPOSITORY_URL>"  # Замініть на реальний URL
  tag: "latest"
  pullPolicy: IfNotPresent
```

Або використовуйте Helm з параметрами:

```bash
ECR_URL=$(terraform output -raw ecr_repository_url)
helm install django-app ./charts/django-app \
  --set image.repository=$ECR_URL \
  --set configMap.DB_HOST=your-db-host \
  --set configMap.DB_NAME=your-db-name \
  --set configMap.DB_USER=your-db-user \
  --set configMap.DB_PASSWORD=your-db-password
```

### 5. Встановлення Helm-чарту

```bash
# Перейдіть до директорії з Helm-чартом
cd charts/django-app

# Встановіть Helm-чарт
helm install django-app . \
  --set image.repository=<ECR_REPOSITORY_URL> \
  --set configMap.DB_HOST=your-db-host \
  --set configMap.DB_NAME=your-db-name \
  --set configMap.DB_USER=your-db-user \
  --set configMap.DB_PASSWORD=your-db-password \
  --set configMap.DB_PORT=5432

# Або використовуйте файл values.yaml (після оновлення image.repository)
helm install django-app . -f values.yaml
```

### 6. Перевірка розгортання

```bash
# Перевірте статус подів
kubectl get pods

# Перевірте сервіси
kubectl get services

# Перевірте HPA
kubectl get hpa

# Отримайте зовнішній IP LoadBalancer
kubectl get service django-app-service
```

### 7. Оновлення Helm-чарту

```bash
# Після змін у values.yaml або шаблонах
helm upgrade django-app . -f values.yaml

# Або з параметрами
helm upgrade django-app . \
  --set image.tag=new-tag \
  --reuse-values
```

### 8. Видалення

```bash
# Видалення Helm-релізу
helm uninstall django-app

# Видалення інфраструктури
terraform destroy
```

## Компоненти Helm-чарту

### Deployment

- Використовує образ Django з ECR
- Підключає ConfigMap через `envFrom`
- Налаштовані liveness та readiness проби
- Ресурсні обмеження (CPU та пам'ять)

### Service

- Тип: `LoadBalancer` для зовнішнього доступу
- Порт: 80 (зовнішній) → 8000 (внутрішній)
- Автоматично створює AWS Load Balancer

### ConfigMap

Містить змінні середовища для Django:
- `DB_HOST` - хост бази даних
- `DB_NAME` - ім'я бази даних
- `DB_USER` - користувач бази даних
- `DB_PASSWORD` - пароль бази даних
- `DB_PORT` - порт бази даних

### HPA (Horizontal Pod Autoscaler)

- Мінімальна кількість подів: 2
- Максимальна кількість подів: 6
- Масштабування при CPU > 70%
- Масштабування при Memory > 70%

## Змінні

Основні змінні проєкту (можна перевизначити через `terraform.tfvars`):

- `aws_region` - AWS регіон (за замовчуванням: `us-east-2`)
- `cluster_name` - Ім'я EKS кластера (за замовчуванням: `lesson-7-eks`)
- `cluster_version` - Версія Kubernetes (за замовчуванням: `1.28`)
- `node_group_instance_types` - Типи інстансів для node group (за замовчуванням: `["t3.medium"]`)
- `node_group_desired_size` - Бажана кількість нод (за замовчуванням: `2`)
- `node_group_min_size` - Мінімальна кількість нод (за замовчуванням: `1`)
- `node_group_max_size` - Максимальна кількість нод (за замовчуванням: `4`)

## Вихідні дані

Проєкт виводить наступну інформацію:

- **EKS:**
  - `eks_cluster_name` - Ім'я кластера
  - `eks_cluster_endpoint` - Endpoint кластера
  - `eks_cluster_arn` - ARN кластера
  - `kubectl_config_command` - Команда для налаштування kubectl

- **ECR:**
  - `ecr_repository_url` - URL репозиторію ECR
  - `ecr_repository_arn` - ARN репозиторію ECR

## Важливі зауваження

1. **Час створення:** EKS кластер може створюватися 10-15 хвилин.

2. **Витрати:** EKS кластер, ноди та Load Balancer є платними ресурсами. Врахуйте це при тестуванні.

3. **ECR образ:** Переконайтеся, що образ завантажено до ECR перед встановленням Helm-чарту.

4. **База даних:** ConfigMap містить змінні для підключення до бази даних. Налаштуйте їх відповідно до вашої конфігурації.

5. **IAM ролі:** EKS автоматично створює необхідні IAM ролі для кластера та node group.

6. **Load Balancer:** Service типу LoadBalancer створить AWS Application Load Balancer, який може зайняти кілька хвилин для налаштування.

## Додаткова інформація

Для більш детальної інформації про кожен модуль, дивіться коментарі у відповідних `.tf` файлах.

### Корисні команди

```bash
# Перегляд логів подів
kubectl logs -l app.kubernetes.io/name=django-app

# Опис поду
kubectl describe pod <pod-name>

# Перегляд подій
kubectl get events --sort-by='.lastTimestamp'

# Масштабування вручну (якщо потрібно)
kubectl scale deployment django-app --replicas=4

# Перегляд метрик HPA
kubectl describe hpa django-app-hpa
```

