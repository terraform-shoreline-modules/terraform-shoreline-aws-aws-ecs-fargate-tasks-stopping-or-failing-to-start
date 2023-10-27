resource "shoreline_notebook" "aws_ecs_fargate_tasks_stopping_or_failing_to_start" {
  name       = "aws_ecs_fargate_tasks_stopping_or_failing_to_start"
  data       = file("${path.module}/data/aws_ecs_fargate_tasks_stopping_or_failing_to_start.json")
  depends_on = [shoreline_action.invoke_get_stopped_task_details,shoreline_action.invoke_aws_logs_diagnostic_cause,shoreline_action.invoke_update_task_memory_limit]
}

resource "shoreline_file" "get_stopped_task_details" {
  name             = "get_stopped_task_details"
  input_file       = "${path.module}/data/get_stopped_task_details.sh"
  md5              = filemd5("${path.module}/data/get_stopped_task_details.sh")
  description      = "Get the list of stopped tasks and check details and status of the stopped task"
  destination_path = "/tmp/get_stopped_task_details.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "aws_logs_diagnostic_cause" {
  name             = "aws_logs_diagnostic_cause"
  input_file       = "${path.module}/data/aws_logs_diagnostic_cause.sh"
  md5              = filemd5("${path.module}/data/aws_logs_diagnostic_cause.sh")
  description      = "Check the diagnostic information in the service event log to identify the cause of the issue."
  destination_path = "/tmp/aws_logs_diagnostic_cause.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "update_task_memory_limit" {
  name             = "update_task_memory_limit"
  input_file       = "${path.module}/data/update_task_memory_limit.sh"
  md5              = filemd5("${path.module}/data/update_task_memory_limit.sh")
  description      = "Increase the task memory limit if it is too low to accommodate the application."
  destination_path = "/tmp/update_task_memory_limit.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_get_stopped_task_details" {
  name        = "invoke_get_stopped_task_details"
  description = "Get the list of stopped tasks and check details and status of the stopped task"
  command     = "`chmod +x /tmp/get_stopped_task_details.sh && /tmp/get_stopped_task_details.sh`"
  params      = ["TASK_ARNS","CLUSTER_NAME"]
  file_deps   = ["get_stopped_task_details"]
  enabled     = true
  depends_on  = [shoreline_file.get_stopped_task_details]
}

resource "shoreline_action" "invoke_aws_logs_diagnostic_cause" {
  name        = "invoke_aws_logs_diagnostic_cause"
  description = "Check the diagnostic information in the service event log to identify the cause of the issue."
  command     = "`chmod +x /tmp/aws_logs_diagnostic_cause.sh && /tmp/aws_logs_diagnostic_cause.sh`"
  params      = ["LOG_GROUP_NAME"]
  file_deps   = ["aws_logs_diagnostic_cause"]
  enabled     = true
  depends_on  = [shoreline_file.aws_logs_diagnostic_cause]
}

resource "shoreline_action" "invoke_update_task_memory_limit" {
  name        = "invoke_update_task_memory_limit"
  description = "Increase the task memory limit if it is too low to accommodate the application."
  command     = "`chmod +x /tmp/update_task_memory_limit.sh && /tmp/update_task_memory_limit.sh`"
  params      = ["TASK_DEFINITION_NAME","IMAGE_URL","SERVICE_NAME","CONTAINER_NAME","CLUSTER_NAME"]
  file_deps   = ["update_task_memory_limit"]
  enabled     = true
  depends_on  = [shoreline_file.update_task_memory_limit]
}

