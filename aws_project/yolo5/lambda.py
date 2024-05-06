import json
import boto3


def lambda_handler(event, context):
    # TODO implement

    sqs_client = boto3.resource('sqs', region_name='eu-west-1')
    asg_client = boto3.client('autoscaling', region_name='eu-west-1')

    AUTOSCALING_GROUP_NAME = 'Daniel-as'
    QUEUE_NAME = 'Daniel-sqs'

    queue = sqs_client.get_queue_by_name(QueueName=QUEUE_NAME)
    msgs_in_queue = int(queue.attributes.get('ApproximateNumberOfMessages'))
    asg_groups = asg_client.describe_auto_scaling_groups(AutoScalingGroupNames=[AUTOSCALING_GROUP_NAME])[
        'AutoScalingGroups']

    if not asg_groups:
        raise RuntimeError('Autoscaling group not found')
    else:
        asg_size = asg_groups[0]['DesiredCapacity']


    backlog_per_instance = msgs_in_queue / asg_size

# TODO send backlog_per_instance to cloudwatch...

}
