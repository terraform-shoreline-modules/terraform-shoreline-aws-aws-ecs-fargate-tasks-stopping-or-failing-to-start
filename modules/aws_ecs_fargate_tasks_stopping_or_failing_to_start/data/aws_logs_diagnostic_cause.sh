

#!/bin/bash



latest_stream=$(aws logs describe-log-streams --log-group-name ${LOG_GROUP_NAME} --order-by LastEventTime --descending --query 'logStreams[0].logStreamName' --output text)

# Get the latest ECS service event log

latest_events=$(aws logs get-log-events --log-group-name ${LOG_GROUP_NAME} --log-stream-name $latest_stream --limit 3 --output text)



# Get the diagnostic information from the latest ECS service event log

diagnostic_info=$(aws logs get-log-events --log-group-name ${LOG_GROUP_NAME} --log-stream-name $latest_stream --start-from-head --query 'events[*].message' --output text)



# Identify the cause of the issue from the diagnostic information

cause=$(echo "$diagnostic_info" | awk -F"Cause: | Exit Code:" '{print $2}')



echo "Cause of the issue: $cause"