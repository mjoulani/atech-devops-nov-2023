import boto3



def download_image(image_name):
    try:
        s3 = boto3.client('s3')
        with open(image_name, 'wb') as f:
            s3.download_fileobj('abed-skout-devops',image_name, f)
        return image_name
    except Exception as e :
        print(e)
        




if __name__ == "__main__":
    # test()
    print(download_image('x'))
