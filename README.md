
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# AWS ECS Fargate Tasks Stopping or Failing to Start
---

This incident type refers to the issue of Amazon Elastic Container Service (Amazon ECS) containers exiting unexpectedly, resulting in tasks stopping or failing to start when deployed on AWS ECS Fargate. This issue can occur due to various reasons, such as application issues, resource constraints, or other issues. To resolve this issue, the troubleshooting steps involve checking the diagnostic information in the service event log, checking for errors in stopped tasks, and configuring log driver options to send logs to a custom driver for the container. Additionally, memory constraint issues need to be addressed, and if the awslogs log driver is configured, checking the awslogs container logs in CloudWatch Logs can help resolve the issue.

### Parameters
```shell
export LOG_GROUP_NAME="PLACEHOLDER"

export LOG_STREAM_NAME="PLACEHOLDER"

export CLUSTER_NAME="PLACEHOLDER"

export SERVICE_NAME="PLACEHOLDER"

export TASK_DEFINITION_NAME="PLACEHOLDER"

export TASK_ARNS="PLACEHOLDER"

export CONTAINER_NAME="PLACEHOLDER"

export IMAGE_URL="PLACEHOLDER"
```

## Debug

### Get the list of stopped tasks
```shell
aws ecs list-tasks --cluster $CLUSTER_NAME --desired-status STOPPED
```

### Get the logs of a container instance
```shell
aws logs get-log-events --log-group ${LOG_GROUP_NAME} --log-stream-name ${LOG_STREAM_NAME}
```

### Check the events of a service
```shell
aws ecs describe-services --cluster ${CLUSTER_NAME} --services ${SERVICE_NAME} --query "services[].events"
```

### Get the details of a task definition
```shell
aws ecs describe-task-definition --task-definition ${TASK_DEFINITION_NAME}
```

### Get the list of stopped tasks and check details and status of the stopped task 
```shell
#!/bin/bash



CLUSTER_NAME=${CLUSTER_NAME}



# Get the list of stopped tasks

TASK_ARNS=$(aws ecs list-tasks --cluster $CLUSTER_NAME --desired-status STOPPED --query "taskArns[]" --output text)



# Loop over each ARN to get task details and status

for ARN in ${TASK_ARNS}; do

    echo "Details for task ARN: $ARN"

    aws ecs describe-tasks --cluster $CLUSTER_NAME --tasks $ARN

    

    echo "Status for task ARN: $ARN"

    STATUS=$(aws ecs describe-tasks --cluster $CLUSTER_NAME --tasks $ARN --query "tasks[].lastStatus" --output text)

    echo $STATUS

done


```

## Repair

### Check the diagnostic information in the service event log to identify the cause of the issue.
```shell


#!/bin/bash



latest_stream=$(aws logs describe-log-streams --log-group-name ${LOG_GROUP_NAME} --order-by LastEventTime --descending --query 'logStreams[0].logStreamName' --output text)

# Get the latest ECS service event log

latest_events=$(aws logs get-log-events --log-group-name ${LOG_GROUP_NAME} --log-stream-name $latest_stream --limit 3 --output text)



# Get the diagnostic information from the latest ECS service event log

diagnostic_info=$(aws logs get-log-events --log-group-name ${LOG_GROUP_NAME} --log-stream-name $latest_stream --start-from-head --query 'events[*].message' --output text)



# Identify the cause of the issue from the diagnostic information

cause=$(echo "$diagnostic_info" | awk -F"Cause: | Exit Code:" '{print $2}')



echo "Cause of the issue: $cause"


```

### Increase the task memory limit if it is too low to accommodate the application.
```shell


#!/bin/bash



# Set variables

CLUSTER_NAME=${CLUSTER_NAME}

SERVICE_NAME=${SERVICE_NAME}

TASK_DEFINITION=${TASK_DEFINITION_NAME}



# Get the current task memory limit

CURRENT_MEMORY_LIMIT=$(aws ecs describe-task-definition --task-definition $TASK_DEFINITION | jq -r '.taskDefinition.containerDefinitions[0].memory')



# Increase the task memory limit

NEW_MEMORY_LIMIT=$(($CURRENT_MEMORY_LIMIT + 512))

echo "Increasing task memory limit from $CURRENT_MEMORY_LIMIT MB to $NEW_MEMORY_LIMIT MB"

aws ecs register-task-definition --family $TASK_DEFINITION --container-definitions '[{"name":"${CONTAINER_NAME}","memory":'$NEW_MEMORY_LIMIT',"image":"${IMAGE_URL}","essential":true}]'



# Update the service with the new task definition

echo "Updating service with new task definition"

aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --force-new-deployment


```