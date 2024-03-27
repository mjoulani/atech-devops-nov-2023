pipeline {
    agent any

    stages {
        stage('Download from S3 Bucket') {
            steps {
                script{
                    println("=====================================${STAGE_NAME}=====================================")
                    download_from_s3("aws_cred","oferbakria","file_12.jpg","${WORKSPACE}")  
                }
            }
        }
    }
}


//============================================================FUNC=====================================================

def download_from_s3(def cred,def bucket, def file, def dest,def region='ap-southeast-2'){
    withAWS(credentials: cred, region: region ) {
        println("Downloading file name ${file} from bucket ${bucket} to ${dest}")
        // sh "aws s3 cp s3://${bucket}/${file} ${dest}"   
        s3Download(file:"downloaded_${file}", bucket:bucket, path:file, force:true)      
    }
}
    
