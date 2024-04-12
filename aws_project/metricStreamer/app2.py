import time
import boto3
from loguru import logger
autoscaling_client = boto3.client('autoscaling', region_name='eu-west-1')
cloudwatch_client = boto3.client('cloudwatch', region_name='eu-west-1')

AUTOSCALING_GROUP_NAME = 'basharziv_awsproject'
QUEUE_NAME = 'bashar_z_sqs'


# Function to get backlog per instance
def get_backlog_per_instance():
    sqs_client = boto3.resource('sqs', region_name='eu-west-1')
    queue = sqs_client.get_queue_by_name(QueueName=QUEUE_NAME)
    msgs_in_queue = int(queue.attributes.get('ApproximateNumberOfMessages'))

    asg_groups = autoscaling_client.describe_auto_scaling_groups(AutoScalingGroupNames=[AUTOSCALING_GROUP_NAME])[
        'AutoScalingGroups']
    if not asg_groups:
        raise RuntimeError('Autoscaling group not found')
    else:
        asg_size = asg_groups[0]['DesiredCapacity']

    backlog_per_instance = msgs_in_queue / asg_size
    return backlog_per_instance


# Function to create or update scaling policy
def create_or_update_scaling_policy(target_value):
    response = autoscaling_client.describe_auto_scaling_groups(AutoScalingGroupNames=[AUTOSCALING_GROUP_NAME])
    asg = response['AutoScalingGroups'][0]
    asg_arn = asg['AutoScalingGroupARN']

    scaling_policy_name = 'BacklogScalingPolicy'

    # Adjust target value to fall within acceptable range
    min_target_value = 1
    max_target_value = 3  # 1.0e15
    adjusted_target_value = max(min_target_value, min(max_target_value, round(target_value)))

    target_tracking_config = {
        'PredefinedMetricSpecification': {
            'PredefinedMetricType': 'ASGAverageCPUUtilization',
        },
        'TargetValue': adjusted_target_value,
        'DisableScaleIn': False
    }

    response = autoscaling_client.put_scaling_policy(
        AutoScalingGroupName=AUTOSCALING_GROUP_NAME,
        PolicyName=scaling_policy_name,
        PolicyType='TargetTrackingScaling',
        TargetTrackingConfiguration=target_tracking_config
    )

    policy_arn = response['PolicyARN']
    return policy_arn


# Main function
def main():
    backlog_per_instance = get_backlog_per_instance()
    target_value = min(10, backlog_per_instance)  # Ensure target value doesn't exceed 10
    policy_arn = create_or_update_scaling_policy(target_value)
    logger.info(f'Scaling policy created/updated with target value: {target_value}')
    # Send custom metric to CloudWatch
    cloudwatch_client.put_metric_data(
        Namespace='CustomMetrics',
        MetricData=[
            {
                'MetricName': 'BasharAwsProject',
                'Value': backlog_per_instance,
                'Unit': 'Count'
            }
        ]
    )

    logger.info(f'BacklogPerInstance metric sent to CloudWatch with value: {backlog_per_instance}')


if __name__ == '__main__':
    while True:
        main()
        time.sleep(30)
