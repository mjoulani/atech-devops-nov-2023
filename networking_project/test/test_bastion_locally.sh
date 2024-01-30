set -e

source ../vpc.sh
PUBLIC_EC2_IP="13.54.114.124"
PRIVATE_EC2_IP="10.0.2.187"
bash ../bastion_connect.sh $PUBLIC_EC2_IP $PRIVATE_EC2_IP "ls"

if [ $? -ne "0" ]
then
  echo -e "\n\nbad bastion_connect.sh script"
  exit 1
else
  echo -e "\n\ngood bastion_connect.sh script! well done!"
fi