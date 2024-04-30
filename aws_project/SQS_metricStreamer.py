import json    
import boto3
import time


def lambda_handler(event, context):
    
    # AWS configuration
    region_name = 'eu-central-1'
    AUTOSCALING_GROUP_NAME ='ASG-abedg-worker'
    QUEUE_NAME = 'Abed2Queue'
    NAMESPACE =  'AbedGZ-CloudWatch'
    METRIC_NAME = "BacklogPerInstance"

    # Initialize AWS clients
    sqs_client = boto3.client('sqs', region_name=region_name)  # Use sqs client
    asg_client = boto3.client('autoscaling', region_name=region_name)
    cloudwatch_client = boto3.client('cloudwatch', region_name=region_name)

    while True:
        # Get the number of messages in the SQS queue
        try:
            
            queue_url = f'https://sqs.eu-central-1.amazonaws.com/933060838752/Abed2Queue'
            response = sqs_client.get_queue_attributes(
                QueueUrl=queue_url,
                AttributeNames=['ApproximateNumberOfMessages']
            )
            msgs_in_queue = int(response['Attributes']['ApproximateNumberOfMessages'])
            
            # Get the desired capacity of the Auto Scaling Group
            asg_response = asg_client.describe_auto_scaling_groups(AutoScalingGroupNames=[AUTOSCALING_GROUP_NAME])
            if not asg_response['AutoScalingGroups']:
                raise RuntimeError('Autoscaling group not found')
            else:
                asg_size = asg_response['AutoScalingGroups'][0]['DesiredCapacity']
            
            print(f'Messages in Queue: {msgs_in_queue}')
            print(f'Desired Capacity of ASG: {asg_size}')
            
            
            # Avoid division by zero
            if asg_size == 0:
                backlog_per_instance = msgs_in_queue
            else:
                backlog_per_instance = msgs_in_queue / asg_size
            
            
            # Send the metric to CloudWatch
            cloudwatch_client.put_metric_data(
            Namespace=NAMESPACE,
            MetricData=[
                {
                    'MetricName': METRIC_NAME,
                    'Value': backlog_per_instance,
                    'Unit': 'Count',
                    'Dimensions': [
                        {
                            'Name': 'AutoScalingGroupName',
                            'Value': AUTOSCALING_GROUP_NAME
                        }
                    ]
                }
                ]
            )
            print(f'BacklogPerInstance: {backlog_per_instance}')
            body = json.dumps(response, indent=4)
            body_lines = body.split('\n')
            http_response = {
                'statusCode': 200,
                'body': '\n'.join(body_lines), 
                'headers': {
                    'Content-Type': 'application/json'
                }
            }
            
        except Exception as e:
            print(f'Error: {str(e)}')
            
            
        
        return http_response
    
    time.sleep(10)  # Run every 10 seconds