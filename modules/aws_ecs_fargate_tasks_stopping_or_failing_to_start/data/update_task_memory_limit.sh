

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