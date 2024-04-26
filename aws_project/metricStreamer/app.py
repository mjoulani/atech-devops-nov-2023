import time
import boto3
import logging
import os

sqs_client = boto3.resource('sqs', region_name='eu-north-1')
asg_client = boto3.client('autoscaling', region_name='eu-north-1')

QUEUE_NAME = os.environ['SQS_QUEUE_NAME']
AUTOSCALING_GROUP_NAME = os.environ['ASG-NAME']

def calculate():
    queue = sqs_client.get_queue_by_name(QueueName=QUEUE_NAME)
    """
    Calculates the backlog per instance and sends it to CloudWatch.

    This function retrieves the number of messages in the SQS queue and the desired capacity of the auto scaling group. It then calculates the backlog per instance by dividing the number of messages by the desired capacity. The calculated backlog per instance is then sent to CloudWatch as a custom metric.

    Returns:
        str: The status of the operation. Returns "ok" if the backlog per instance was successfully sent to CloudWatch, and "error" if an exception occurred.

    Raises:
        RuntimeError: If the auto scaling group is not found.
    """
    msgs_in_queue = int(queue.attributes.get('ApproximateNumberOfMessages'))
    asg_groups = asg_client.describe_auto_scaling_groups(AutoScalingGroupNames=[AUTOSCALING_GROUP_NAME])[
        'AutoScalingGroups']

    if not asg_groups:
        raise RuntimeError('Autoscaling group not found')
    else:
        asg_size = asg_groups[0]['DesiredCapacity']

    backlog_per_instance = msgs_in_queue / asg_size

    try:
    # TODO send backlog_per_instance to cloudwatch...
        cloudwatch = boto3.client('cloudwatch', region_name='eu-north-1')
        cloudwatch.put_metric_data(
            Namespace='polybot',
            MetricData=[
                {
                    'MetricName': 'backlog',#TODO make cloudwatch metric name
                    'Value': backlog_per_instance,
                    'Unit': 'Count'
                }
            ]
        )
        logging.info(f"Backlog per instance: {backlog_per_instance} has been sent to cloudwatch")
    except Exception as e:
        print(e)
        return "error"
    return "ok"


if __name__ == "__main__":
    while True:
        calculate()
        time.sleep(30)