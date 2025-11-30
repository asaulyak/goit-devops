# Основні змінні

variable "use_aurora" {
  description = "Використовувати Aurora Cluster замість звичайного RDS instance"
  type        = bool
  default     = false
}

variable "db_identifier" {
  description = "Унікальний ідентифікатор для бази даних"
  type        = string
}

variable "engine" {
  description = "Тип движка БД (mysql, postgres, aurora-mysql, aurora-postgresql)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Версія движка БД"
  type        = string
  default     = null
}

variable "instance_class" {
  description = "Клас інстансу БД"
  type        = string
  default     = "db.t3.micro"
}

# Змінні для звичайного RDS
variable "allocated_storage" {
  description = "Розмір виділеного сховища в GB (тільки для звичайного RDS)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Максимальний розмір сховища для автоматичного масштабування (тільки для звичайного RDS)"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Тип сховища (gp2, gp3, io1, io2) (тільки для звичайного RDS)"
  type        = string
  default     = "gp3"
}

# Змінні для Aurora
variable "aurora_engine_mode" {
  description = "Режим роботи Aurora (provisioned, serverless, parallelquery, global, multimaster)"
  type        = string
  default     = "provisioned"
}

variable "aurora_instance_count" {
  description = "Кількість інстансів в Aurora кластері"
  type        = number
  default     = 2
}

variable "aurora_serverless_v2_scaling_configuration" {
  description = "Конфігурація масштабування для Aurora Serverless v2"
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = null
}

# Змінні для бази даних
variable "db_name" {
  description = "Назва бази даних"
  type        = string
  default     = null
}

variable "username" {
  description = "Ім'я користувача для бази даних"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "Пароль для бази даних"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Порт бази даних"
  type        = number
  default     = 5432
}

# Мережеві змінні
variable "vpc_id" {
  description = "ID VPC для створення ресурсів"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR блок VPC для дозволу доступу"
  type        = string
}

variable "subnet_ids" {
  description = "Список ID підмереж для DB Subnet Group"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Список ID Security Groups, яким дозволено доступ до БД"
  type        = list(string)
  default     = []
}

variable "publicly_accessible" {
  description = "Чи має БД бути доступною з інтернету"
  type        = bool
  default     = false
}

# Змінні для Parameter Group
variable "parameter_group_family" {
  description = "Сімейство параметрів для Parameter Group"
  type        = string
  default     = "postgres15"
}

variable "db_parameters" {
  description = "Список параметрів для Parameter Group"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# Змінні для резервного копіювання та обслуговування
variable "backup_retention_period" {
  description = "Період зберігання резервних копій (дні)"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Вікно для резервного копіювання (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Вікно для обслуговування (UTC)"
  type        = string
  default     = "mon:04:00-mon:05:00"
}

# Змінні для безпеки
variable "storage_encrypted" {
  description = "Чи шифрувати сховище"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ID KMS ключа для шифрування (якщо не вказано, використовується ключ за замовчуванням)"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "Чи увімкнути захист від видалення"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Чи пропустити фінальний снапшот при видаленні"
  type        = bool
  default     = false
}

variable "copy_tags_to_snapshot" {
  description = "Чи копіювати теги в снапшоти"
  type        = bool
  default     = true
}

# Змінні для звичайного RDS
variable "multi_az" {
  description = "Чи створювати Multi-AZ deployment (тільки для звичайного RDS)"
  type        = bool
  default     = false
}

# Змінні для моніторингу
variable "enabled_cloudwatch_logs_exports" {
  description = "Список типів логів для експорту в CloudWatch"
  type        = list(string)
  default     = []
}

variable "performance_insights_enabled" {
  description = "Чи увімкнути Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Період зберігання Performance Insights (7 або 731 день)"
  type        = number
  default     = 7
}

variable "auto_minor_version_upgrade" {
  description = "Чи дозволити автоматичне оновлення мінорних версій"
  type        = bool
  default     = true
}

# Теги
variable "tags" {
  description = "Додаткові теги для ресурсів"
  type        = map(string)
  default     = {}
}

