# Lesson 8-9: Jenkins та Argo CD з Terraform

Цей проєкт містить Terraform конфігурацію для створення:
- S3 бакет та DynamoDB для зберігання та блокування стейт-файлів Terraform
- VPC з публічними та приватними підмережами
- ECR репозиторій для зберігання Docker-образів
- EKS кластер Kubernetes з EBS CSI driver
- Jenkins встановлений через Helm з Kubernetes Agent (Kaniko + Git)
- Argo CD встановлений через Helm з автоматичною синхронізацією

## Структура проєкту

```
lesson-8-9/
│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── variables.tf             # Загальні змінні проєкту
├── outputs.tf              # Загальне виведення ресурсів
├── providers.tf            # Налаштування провайдерів Kubernetes та Helm
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
│   ├── eks/                 # Модуль для Kubernetes кластера
│   │   ├── eks.tf           # Створення кластера
│   │   ├── aws_ebs_csi_driver.tf # Встановлення EBS CSI driver
│   │   ├── variables.tf     # Змінні для EKS
│   │   └── outputs.tf       # Виведення інформації про кластер
│   │
│   ├── jenkins/             # Модуль для Helm-установки Jenkins
│   │   ├── jenkins.tf       # Helm release для Jenkins
│   │   ├── variables.tf     # Змінні (ресурси, креденшели, values)
│   │   ├── providers.tf     # Оголошення провайдерів
│   │   ├── values.yaml      # Конфігурація Jenkins
│   │   └── outputs.tf       # Виводи (URL, пароль адміністратора)
│   │
│   └── argo_cd/             # Модуль для Helm-установки Argo CD
│       ├── argo_cd.tf       # Helm release для Argo CD
│       ├── variables.tf     # Змінні (версія чарта, namespace, repo URL тощо)
│       ├── providers.tf     # Kubernetes+Helm провайдери
│       ├── values.yaml      # Кастомна конфігурація Argo CD
│       ├── outputs.tf       # Виводи (hostname, initial admin password)
│       └── charts/          # Helm-чарт для створення app'ів
│           ├── Chart.yaml
│           ├── values.yaml  # Список applications, repositories
│           └── templates/
│               ├── application.yaml
│               └── repository.yaml
│
├── charts/
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   └── hpa.yaml
│       ├── Chart.yaml
│       └── values.yaml      # ConfigMap зі змінними середовища
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

```bash
# Отримайте команду з outputs
terraform output kubectl_config_command

# Або виконайте вручну
aws eks update-kubeconfig --region us-east-2 --name lesson-8-9-eks

# Перевірте підключення
kubectl get nodes
```

### 3. Доступ до Jenkins

```bash
# Отримати LoadBalancer URL
kubectl get svc jenkins -n jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Отримати адміністраторський пароль
kubectl get secret jenkins -n jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 -d
```

Відкрийте браузер та перейдіть за LoadBalancer URL.

### 4. Налаштування Jenkins Pipeline

Jenkins налаштований з:
- Kubernetes Cloud для запуску агентів
- Kaniko для збірки Docker образів без Docker daemon
- Git для клонування репозиторіїв

**Приклад Jenkinsfile:**

Дивіться файл `Jenkinsfile.example` для повного прикладу pipeline, який:
- Збирає Docker образ через Kaniko
- Пушить образ до ECR
- Оновлює тег у values.yaml
- Пушить зміни в Git репозиторій

**Короткий приклад:**

```groovy
pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins-kaniko
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
    - /busybox/sh
    - -c
    - sleep 3600
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
  volumes:
  - name: docker-config
    configMap:
      name: docker-config
"""
        }
    }
    stages {
        stage('Build and Push') {
            steps {
                container('kaniko') {
                    sh '''
                        /kaniko/executor \
                          --context . \
                          --dockerfile Dockerfile \
                          --destination ${ECR_REPOSITORY_URL}:${BUILD_NUMBER} \
                          --destination ${ECR_REPOSITORY_URL}:latest
                    '''
                }
            }
        }
        stage('Update values.yaml') {
            steps {
                sh '''
                    git config user.name "Jenkins"
                    git config user.email "jenkins@example.com"
                    sed -i "s|repository:.*|repository: ${ECR_REPOSITORY_URL}|g" charts/django-app/values.yaml
                    sed -i "s|tag:.*|tag: ${BUILD_NUMBER}|g" charts/django-app/values.yaml
                    git add charts/django-app/values.yaml
                    git commit -m "Update image tag to ${BUILD_NUMBER}"
                    git push origin main
                '''
            }
        }
    }
    environment {
        ECR_REPOSITORY_URL = '879381271147.dkr.ecr.us-east-2.amazonaws.com/lesson-8-9-ecr'
    }
}
```

### 5. Доступ до Argo CD

```bash
# Отримати LoadBalancer URL
kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Отримати адміністраторський пароль
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

Відкрийте браузер та перейдіть за LoadBalancer URL.

### 6. Налаштування Argo CD Application

Argo CD автоматично моніторить Git репозиторій та синхронізує зміни. Для налаштування:

1. Встановіть змінну `git_repository_url` у `variables.tf` або через `terraform.tfvars`
2. Виконайте `terraform apply`

Argo CD Application буде автоматично створено та налаштовано для моніторингу Helm-чарту Django.

## Модулі

### 1. Модуль Jenkins

**Особливості:**
- Встановлення через Helm chart
- Kubernetes Cloud для агентів
- Kaniko для збірки образів
- Налаштування для роботи з ECR
- LoadBalancer для зовнішнього доступу

**Ресурси:**
- `kubernetes_namespace` - Namespace для Jenkins
- `helm_release` - Jenkins Helm release

### 2. Модуль Argo CD

**Особливості:**
- Встановлення через Helm chart
- Автоматична синхронізація з Git
- Helm-чарт для створення Applications
- LoadBalancer для зовнішнього доступу

**Ресурси:**
- `kubernetes_namespace` - Namespace для Argo CD
- `helm_release` - Argo CD Helm release
- `helm_release` - Argo CD Applications Helm release

### 3. EBS CSI Driver

Додано до EKS модуля для підтримки персистентних томів.

## Змінні

Основні змінні проєкту (можна перевизначити через `terraform.tfvars`):

- `jenkins_namespace` - Namespace для Jenkins (за замовчуванням: `jenkins`)
- `jenkins_chart_version` - Версія Jenkins Helm chart (за замовчуванням: `5.0.0`)
- `argocd_namespace` - Namespace для Argo CD (за замовчуванням: `argocd`)
- `argocd_chart_version` - Версія Argo CD Helm chart (за замовчуванням: `7.2.0`)
- `git_repository_url` - URL Git репозиторію для Argo CD (за замовчуванням: `""`)
- `git_repository_path` - Шлях до Helm-чарту в репозиторії (за замовчуванням: `charts/django-app`)

## Вихідні дані

Проєкт виводить наступну інформацію:

- **Jenkins:**
  - `jenkins_url` - Внутрішній URL Jenkins
  - `jenkins_loadbalancer_url` - Команда для отримання LoadBalancer URL
  - `jenkins_admin_password_command` - Команда для отримання пароля адміністратора

- **Argo CD:**
  - `argocd_url` - Внутрішній URL Argo CD
  - `argocd_loadbalancer_url` - Команда для отримання LoadBalancer URL
  - `argocd_admin_password_command` - Команда для отримання пароля адміністратора

## Важливі зауваження

1. **Jenkins Kaniko:** Для роботи Kaniko потрібен Service Account з правами доступу до ECR. Переконайтеся, що IAM роль налаштована правильно.

2. **Argo CD Git:** Для моніторингу Git репозиторію встановіть `git_repository_url` у змінних.

3. **LoadBalancer:** Jenkins та Argo CD створюють AWS Load Balancers, які можуть зайняти кілька хвилин для налаштування.

4. **Витрати:** Jenkins, Argo CD та Load Balancers є платними ресурсами. Врахуйте це при тестуванні.

## Видалення інфраструктури

```bash
# Видалення Helm-релізів
helm uninstall jenkins -n jenkins
helm uninstall argocd -n argocd

# Видалення інфраструктури
terraform destroy
```
