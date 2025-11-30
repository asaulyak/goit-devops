terraform {
  backend "s3" {
    bucket         = "goit-devops-terraform-state"
    key            = "lesson-7/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

