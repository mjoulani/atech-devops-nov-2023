#Runnig the project with lambda fuction which trigger with aws Amazon EventBridge every 1 min 
import json
import boto3
import time

# Initialize AWS clients
sqs_client = boto3.client('sqs', region_name='us-west-1')
asg_client = boto3.client('autoscaling', region_name='us-west-1')
ec2_client = boto3.client('ec2', region_name='us-west-1')
cloudwatch_client = boto3.client('cloudwatch', region_name='us-west-1')

# Constants
AUTOSCALING_GROUP_NAME = 'muh_autoscaling_yolo5'
QUEUE_NAME = 'muh_sqs'
NAMESPACE = 'muh_cloudwatch'
METRIC_NAME = 'DesiredCapacity'


def namespace_exists(namespace):
    try:
        response = cloudwatch_client.list_metrics(
            Namespace=namespace
        )
        metrics = response.get('Metrics', [])
        return len(metrics) > 0
    except Exception as e:
        print(f"Error checking namespace existence: {e}")
        return False


def metric_exists(namespace, metric_name):
    try:
        response = cloudwatch_client.list_metrics(
            Namespace=namespace,
            MetricName=metric_name
        )
        metrics = response.get('Metrics', [])
        return len(metrics) > 0
    except Exception as e:
        print(f"Error checking metric existence: {e}")
        return False

def create_namespace(namespace):
    if namespace_exists(namespace):
        print(f"Namespace '{namespace}' already exists.")
    else:
        try:
            cloudwatch_client.put_metric_data(
                Namespace=namespace,
                MetricData=[
                    {
                        'MetricName': 'DummyMetric',
                        'Value': 0,
                        'Unit': 'None'
                    }
                ]
            )
            print(f"Created namespace: {namespace}")
        except Exception as e:
            print(f"Error creating namespace: {e}")

def create_metric(namespace, metric_name):
    if metric_exists(namespace, metric_name):
        print(f"Metric '{metric_name}' already exists.")
    else:
        try:
            cloudwatch_client.put_metric_data(
                Namespace=namespace,
                MetricData=[
                    {
                        'MetricName': metric_name,
                        'Value': 0,
                        'Unit': 'Count'
                    }
                ]
            )
            print(f"Created metric: {metric_name}")
        except Exception as e:
            print(f"Error creating metric: {e}")

def calculate_backlog_per_instance():
    # Get number of messages in SQS queue
    queue_url = sqs_client.get_queue_url(QueueName=QUEUE_NAME)['QueueUrl']
    queue_attributes = sqs_client.get_queue_attributes(QueueUrl=queue_url, AttributeNames=['ApproximateNumberOfMessages'])
    msgs_in_queue = int(queue_attributes['Attributes']['ApproximateNumberOfMessages'])
    print(f"Number of messages: {msgs_in_queue}")
    
    # Get running capacity of the Auto Scaling group
    asg_response = asg_client.describe_auto_scaling_groups(AutoScalingGroupNames=[AUTOSCALING_GROUP_NAME])
    asg_size = asg_response['AutoScalingGroups'][0].get('DesiredCapacity', 0)
    print(f"asg_size: {asg_size}")
    
    # Check the state of the EC2 instance
    ec2_state = 'yolo5_aws_muh'
    response = ec2_client.describe_instances(Filters=[{'Name': 'tag:Name','Values': [ec2_state]}]) 
    
    # Extract the instance status
    ec2_state = response['Reservations'][0]['Instances'][0]['State']['Name']
        
    print(f'ec2_state : {ec2_state}')
    
    return msgs_in_queue, asg_size, ec2_state

def scale_out(asg_group_name, desired_capacity):
    print(asg_group_name)
    print(f'desired_capacity_out = {desired_capacity}')
    response = asg_client.set_desired_capacity(AutoScalingGroupName=asg_group_name, DesiredCapacity=desired_capacity)
    #print("Scaling out:", response)

def scale_in(asg_group_name, desired_capacity):
    print(asg_group_name)
    print(f'desired_capacity_in = {desired_capacity}')
    response = asg_client.set_desired_capacity(AutoScalingGroupName=asg_group_name, DesiredCapacity=desired_capacity)
    #print("Scaling in:", response)

def send_metric(metric_name, value, scaling_action):
    # # Map scaling actions to units
    # unit_mapping = {
    #     'ScaleOut': 'out',
    #     'ScaleIn': 'in',
    #     'NoChange': 'nh',
    #     'NoScalingNeeded' : 'nsn'
    # }
    # Map scaling actions to CloudWatch valid units
    unit_mapping = {
        'ScaleOut': 'Count',
        'ScaleIn': 'Count',
        'NoChange': 'None',  # 'None' is a valid unit for no change
        'NoScalingNeeded': 'None'  # Similarly for 'NoScalingNeeded'
    }
    
    # Get the unit based on the scaling action
    unit = unit_mapping.get(scaling_action, 'Count')  # Default to 'Count' if scaling action is not recognized
    try:
        cloudwatch_client.put_metric_data(
            Namespace=NAMESPACE,
            MetricData=[
                {
                    'MetricName': metric_name,
                    'Value': value,
                    'Unit': unit,
                    'Dimensions': [
                        {
                            'Name': 'ScalingAction',
                            'Value': scaling_action
                        }
                    ]
                }
            ]
        )
        print(f"Sent metric data: {metric_name}={value}, ScalingAction={scaling_action}")
    except Exception as e:
        print(f"Error sending metric data: {e}")
    
   

    

def scale_out(asg_group_name, desired_capacity):
    print(asg_group_name)
    print(f'desired_capacity_out = {desired_capacity}')
    response = asg_client.set_desired_capacity(AutoScalingGroupName=asg_group_name,DesiredCapacity=desired_capacity,)
    print("Scaling out:", response)
    

def scale_in(asg_group_name, desired_capacity):
    print(asg_group_name)
    print(f'desired_capacity_in = {desired_capacity}')
    response = asg_client.set_desired_capacity(AutoScalingGroupName=asg_group_name,DesiredCapacity=desired_capacity,)
    print("Scaling in:", response)
   

def lambda_handler(event, context):
    if not namespace_exists(NAMESPACE):
        create_namespace(NAMESPACE)
    else:
        print("The namespace already exists")    
    if not metric_exists(NAMESPACE, METRIC_NAME):
        create_metric(NAMESPACE, METRIC_NAME)
    else:
        print("The metric already exists")   

    messages_number, asg_size, ec2_state = calculate_backlog_per_instance()
    
    if messages_number is None or asg_size is None or ec2_state is None:
        print("Error occurred while calculating backlog per instance. No action can be taken.")
        return {
            'statusCode': 500,
            'body': 'Error occurred while calculating backlog per instance.'
        }    

    
    SCALING_STATUS = ''
    if asg_size == 0 and messages_number == 0 and ec2_state != 'running':
        print("L1 No instances running in the Auto Scaling group and the original EC2 instance is not running. No action required.")
        scale_out(asg_group_name=AUTOSCALING_GROUP_NAME, desired_capacity=1)
        asg_size = 1
        print('Scaled out by 1 instance')
        SCALING_STATUS = 'ScaleOut'
    elif asg_size == 1 and messages_number == 0 and ec2_state != 'running':
        print("L2 No action required.")
        SCALING_STATUS = 'NoChange'
    elif asg_size > 1 and messages_number == 0 and ec2_state != 'running':
        print("L3 Backlog per instance is below threshold. Scaling in...")
        scale_in(asg_group_name=AUTOSCALING_GROUP_NAME, desired_capacity=1)
        asg_size = 1
        SCALING_STATUS = 'ScaleIn'
    elif asg_size == 0 and messages_number >= 1 and ec2_state != 'running':
        print("L4 Backlog per instance is below threshold. Scaling out...")
        if messages_number <=5 :
            number = 1
        else : 
            number = round(messages_number / 10) 
        scale_out(asg_group_name=AUTOSCALING_GROUP_NAME, desired_capacity=number)
        SCALING_STATUS = 'ScaleOut'
        asg_size = number
    elif asg_size >= 1 and messages_number >= 1 and ec2_state != 'running':
        print("L5 Backlog per instance is below threshold. Scaling in or Scaling out...")
        if messages_number <=5 :
            number = 1
        else : 
            number = round(messages_number / 10) 
        if number <= 1 and asg_size == 1:
            print("L5_a No action required.")
            SCALING_STATUS = 'NoChange'
        elif number == asg_size:
            print("L5_b No action needed.")
            SCALING_STATUS = 'NoChange'
        elif number < asg_size:
            print("L5_c Backlog per instance is below threshold. Scaling in...")
            scale_in(asg_group_name=AUTOSCALING_GROUP_NAME, desired_capacity=number)
            SCALING_STATUS = 'ScaleIn'
            asg_size = number
        elif number > asg_size:
            print("L5_dBacklog per instance exceeds threshold. Scaling out...")
            scale_out(asg_group_name=AUTOSCALING_GROUP_NAME, desired_capacity=number)
            SCALING_STATUS = 'ScaleOut'
            asg_size = number
    elif asg_size == 0 and messages_number == 0 and ec2_state == 'running':
        print("L6 No instances running in the Auto Scaling group and the original EC2 instance is running and no message. No action required.")
        SCALING_STATUS = 'NoScalingNeeded'
    elif asg_size == 0 and messages_number <= 14 and ec2_state == 'running':
        print("L7 No action needed.")
        SCALING_STATUS = 'NoScalingNeeded'
    elif asg_size == 0 and messages_number >= 15 and ec2_state == 'running':
        print("L7 b  action needed.")
        number = round(messages_number / 10)
        diff = number - asg_size - 1 
        print("L7_b Scaling out...")
        scale_out(asg_group_name=AUTOSCALING_GROUP_NAME, desired_capacity=diff)
        asg_size = diff
        SCALING_STATUS = 'ScaleOut'
    elif asg_size >= 1 and messages_number == 0 and ec2_state == 'running':
        print("L8 Backlog per instance is below threshold. Scaling in or Scaling out...")
        scale_in(asg_group_name=AUTOSCALING_GROUP_NAME, desired_capacity=0)
        asg_size = 0
        SCALING_STATUS = 'ScaleIn'
    elif asg_size >= 1 and messages_number <= 14 and ec2_state == 'running': 
        print("L9 Scaling in...")
        scale_in(asg_group_name=AUTOSCALING_GROUP_NAME, desired_capacity=0)
        asg_size = 0
        SCALING_STATUS = 'ScaleIn'
    elif asg_size >= 1 and messages_number >= 15 and ec2_state == 'running':      
        number = round(messages_number / 10)
        print("the number = ",number)
        print("the asg_size = ",asg_size)
        if (asg_size+1 == number):
            print("Lv10 no action need")
            SCALING_STATUS = 'NoChange'
           
        elif number > asg_size:
            diff = number - asg_size 
            total = diff + asg_size -1
            
            print("the number = ",number)
            print("the asg_size = ",asg_size)
            print("the diff = ",diff)
            
            if not(diff == 0):
                scale_out(asg_group_name=AUTOSCALING_GROUP_NAME, desired_capacity=total)
                SCALING_STATUS = 'ScaleOut'
                print("L10_a Scaling out...")
                asg_size = total
            else :
                print("no action need")
                SCALING_STATUS = 'NoChange' 
                print("L10_a_b no action needed...")   
        elif number < asg_size:
            diff = asg_size - number + 1
            total = asg_size - diff
            print("L10_b Scaling in...")
            scale_in(asg_group_name=AUTOSCALING_GROUP_NAME, desired_capacity=total)
            SCALING_STATUS = 'ScaleIn'
            asg_size = total
        elif number == asg_size :
            print("L10_c Scaling in...")
            scale_in(asg_group_name=AUTOSCALING_GROUP_NAME, desired_capacity=asg_size-1)
            asg_size -=1
            SCALING_STATUS = 'ScaleIn'    
            
            
            
    send_metric(METRIC_NAME, asg_size, SCALING_STATUS)
    time.sleep(30)
                
    
    return {
        'statusCode': 200,
        'body': 'Completed Lambda execution.'
    }


#Runnig the project with lambda fuction which trigger with aws Amazon EventBridge every 1 min 