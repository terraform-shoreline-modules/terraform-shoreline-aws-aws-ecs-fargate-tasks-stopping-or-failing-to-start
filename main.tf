terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "aws_ecs_fargate_tasks_stopping_or_failing_to_start" {
  source    = "./modules/aws_ecs_fargate_tasks_stopping_or_failing_to_start"

  providers = {
    shoreline = shoreline
  }
}