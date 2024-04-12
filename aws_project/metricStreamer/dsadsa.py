import time
import boto3

autoscaling_client = boto3.client('autoscaling', region_name='eu-west-1')
cloudwatch_client = boto3.client('cloudwatch', region_name='eu-west-1')

QUEUE_NAME = 'bashar_z_sqs'

# Function to get backlog per instance
def get_backlog_per_instance():
    sqs_client = boto3.resource('sqs', region_name='eu-west-1')
    queue = sqs_client.get_queue_by_name(QueueName=QUEUE_NAME)
    msgs_in_queue = int(queue.attributes.get('ApproximateNumberOfMessages'))
    return msgs_in_queue

# Main function
def main():
    backlog_per_instance = get_backlog_per_instance()

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

    print(f'BacklogPerInstance metric sent to CloudWatch with value: {backlog_per_instance}')

if __name__ == '__main__':
    while True:
        main()
        time.sleep(30)
