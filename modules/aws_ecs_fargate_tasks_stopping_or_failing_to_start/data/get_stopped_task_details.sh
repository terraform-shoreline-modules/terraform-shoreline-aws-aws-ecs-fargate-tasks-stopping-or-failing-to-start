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