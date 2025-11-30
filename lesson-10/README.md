# Lesson 10: Jenkins, Argo CD та RDS з Terraform

> **Примітка:** Цей проєкт базується на [lesson-8-9](../lesson-8-9/) та розширює його функціональність додаванням модуля RDS.

Цей проєкт містить Terraform конфігурацію для створення:
- S3 бакет та DynamoDB для зберігання та блокування стейт-файлів Terraform
- VPC з публічними та приватними підмережами
- ECR репозиторій для зберігання Docker-образів
- EKS кластер Kubernetes з EBS CSI driver
- Jenkins встановлений через Helm з Kubernetes Agent (Kaniko + Git)
- Argo CD встановлений через Helm з автоматичною синхронізацією
- **RDS модуль для створення бази даних (Aurora Cluster або звичайна RDS instance)**

## Структура проєкту

```
lesson-10/
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
│   ├── argo_cd/             # Модуль для Helm-установки Argo CD
│   │   ├── argo_cd.tf       # Helm release для Argo CD
│   │   ├── variables.tf     # Змінні (версія чарта, namespace, repo URL тощо)
│   │   ├── providers.tf     # Kubernetes+Helm провайдери
│   │   ├── values.yaml      # Кастомна конфігурація Argo CD
│   │   ├── outputs.tf       # Виводи (hostname, initial admin password)
│   │   └── charts/          # Helm-чарт для створення app'ів
│   │       ├── Chart.yaml
│   │       ├── values.yaml  # Список applications, repositories
│   │       └── templates/
│   │           ├── application.yaml
│   │           └── repository.yaml
│   │
│   └── rds/                 # Модуль для RDS бази даних
│       ├── rds.tf           # Створення звичайної RDS instance
│       ├── aurora.tf        # Створення Aurora кластера бази даних
│       ├── shared.tf        # Спільні ресурси (Subnet Group, Security Group, Parameter Groups)
│       ├── variables.tf     # Змінні (ресурси, креденшели, values)
│       └── outputs.tf        # Виведення інформації про базу даних
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

### 7. Використання RDS модуля

RDS модуль підтримує створення як звичайної RDS instance, так і Aurora Cluster на основі змінної `use_aurora`.

#### Приклад 1: Створення звичайної RDS instance (PostgreSQL)

Додайте до `main.tf`:

```hcl
module "rds" {
  source = "./modules/rds"
  
  use_aurora = false
  
  db_identifier = "lesson-10-db"
  engine        = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.micro"
  
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  
  db_name  = "mydb"
  username = "admin"
  password = "YourSecurePassword123!"  # Використовуйте terraform.tfvars або AWS Secrets Manager
  
  vpc_id     = module.vpc.vpc_id
  vpc_cidr   = module.vpc.vpc_cidr_block
  subnet_ids = module.vpc.private_subnet_ids
  
  publicly_accessible = false
  multi_az            = false
  
  backup_retention_period = 7
  deletion_protection     = false
  skip_final_snapshot     = true
  
  tags = var.tags
}
```

#### Приклад 2: Створення Aurora Cluster (PostgreSQL)

Додайте до `main.tf`:

```hcl
module "rds_aurora" {
  source = "./modules/rds"
  
  use_aurora = true
  
  db_identifier = "lesson-10-aurora"
  engine        = "aurora-postgresql"
  engine_version = "15.4"
  instance_class = "db.t3.medium"
  
  aurora_engine_mode   = "provisioned"
  aurora_instance_count = 2
  
  db_name  = "mydb"
  username = "admin"
  password = "YourSecurePassword123!"  # Використовуйте terraform.tfvars або AWS Secrets Manager
  
  vpc_id     = module.vpc.vpc_id
  vpc_cidr   = module.vpc.vpc_cidr_block
  subnet_ids = module.vpc.private_subnet_ids
  
  publicly_accessible = false
  
  backup_retention_period = 7
  deletion_protection     = false
  skip_final_snapshot     = true
  
  tags = var.tags
}
```

#### Приклад 3: Aurora Serverless v2

Для використання Aurora Serverless v2:

```hcl
module "rds_aurora_serverless" {
  source = "./modules/rds"
  
  use_aurora = true
  
  db_identifier = "lesson-10-aurora-serverless"
  engine        = "aurora-postgresql"
  engine_version = "15.4"
  instance_class = "db.serverless"  # Для Serverless v2
  
  aurora_engine_mode = "provisioned"
  aurora_serverless_v2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 16
  }
  
  # ... інші параметри
}
```

#### Отримання інформації про базу даних

Після створення бази даних, ви можете отримати endpoint через outputs:

```bash
# Для звичайного RDS
terraform output rds_instance_endpoint

# Для Aurora
terraform output aurora_cluster_endpoint
terraform output aurora_cluster_reader_endpoint  # Reader endpoint для read-only операцій

# Універсальний endpoint (працює для обох типів)
terraform output database_endpoint
```

#### Підключення до бази даних

Для підключення з EKS кластера або інших ресурсів у VPC:

1. Використовуйте `database_endpoint` з outputs
2. Security Group автоматично дозволяє доступ з VPC CIDR
3. Для додаткових Security Groups, передайте їх ID через `allowed_security_group_ids`:

```hcl
module "rds" {
  # ... інші параметри
  
  allowed_security_group_ids = [
    module.eks.cluster_security_group_id  # Якщо EKS має security group
  ]
}
```

#### Важливі зауваження

- **Паролі:** Ніколи не зберігайте паролі в коді. Використовуйте `terraform.tfvars` (додайте до `.gitignore`) або AWS Secrets Manager
- **Parameter Groups:** Модуль автоматично створює Parameter Groups для обох типів БД
- **Subnet Group:** Автоматично створюється на основі переданих `subnet_ids`
- **Security Group:** Автоматично створюється з правилами для доступу з VPC
- **Backup:** За замовчуванням резервне копіювання увімкнено на 7 днів
- **Encryption:** За замовчуванням шифрування увімкнено

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

### 4. Модуль RDS

**Особливості:**
- Універсальний модуль: підтримка як звичайного RDS, так і Aurora Cluster
- Автоматичне створення DB Subnet Group, Security Group та Parameter Groups
- Підтримка різних движків БД (PostgreSQL, MySQL, Aurora)
- Налаштування резервного копіювання, шифрування та моніторингу
- Підтримка Aurora Serverless v2

**Ресурси:**
- `aws_db_subnet_group` - DB Subnet Group
- `aws_security_group` - Security Group для RDS
- `aws_db_parameter_group` - Parameter Group для звичайного RDS
- `aws_rds_cluster_parameter_group` - Cluster Parameter Group для Aurora
- `aws_db_instance` - Звичайна RDS instance (якщо `use_aurora = false`)
- `aws_rds_cluster` - Aurora Cluster (якщо `use_aurora = true`)
- `aws_rds_cluster_instance` - Aurora Cluster instances

**Основні змінні:**
- `use_aurora` - Використовувати Aurora Cluster (за замовчуванням: `false`)
- `db_identifier` - Унікальний ідентифікатор бази даних
- `engine` - Тип движка БД (`postgres`, `mysql`, `aurora-postgresql`, `aurora-mysql`)
- `instance_class` - Клас інстансу БД
- `username` / `password` - Креденшели для доступу до БД
- `vpc_id` / `vpc_cidr` / `subnet_ids` - Мережеві параметри

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

- **RDS:**
  - `rds_instance_endpoint` - Endpoint звичайного RDS instance
  - `aurora_cluster_endpoint` - Writer endpoint Aurora cluster
  - `aurora_cluster_reader_endpoint` - Reader endpoint Aurora cluster
  - `database_endpoint` - Універсальний endpoint (працює для обох типів)
  - `database_address` - Address бази даних
  - `database_port` - Port бази даних
  - `security_group_id` - ID Security Group для RDS
  - `db_subnet_group_name` - Name DB Subnet Group

## Важливі зауваження

1. **Jenkins Kaniko:** Для роботи Kaniko потрібен Service Account з правами доступу до ECR. Переконайтеся, що IAM роль налаштована правильно.

2. **Argo CD Git:** Для моніторингу Git репозиторію встановіть `git_repository_url` у змінних.

3. **LoadBalancer:** Jenkins та Argo CD створюють AWS Load Balancers, які можуть зайняти кілька хвилин для налаштування.

4. **Витрати:** Jenkins, Argo CD та Load Balancers є платними ресурсами. Врахуйте це при тестуванні.

5. **RDS Паролі:** Ніколи не зберігайте паролі БД у коді. Використовуйте `terraform.tfvars` (додайте до `.gitignore`) або AWS Secrets Manager для безпечного зберігання креденшелів.

6. **RDS Subnets:** RDS потребує мінімум 2 підмережі в різних Availability Zones. Переконайтеся, що передаєте достатню кількість `subnet_ids`.

## Видалення інфраструктури

```bash
# Видалення Helm-релізів
helm uninstall jenkins -n jenkins
helm uninstall argocd -n argocd

# Видалення інфраструктури
terraform destroy
```
