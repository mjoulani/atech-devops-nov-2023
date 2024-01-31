

#!/bin/bash
export KEY_PATH
read -s KEY_PAqTH < PATH.txt
1
bastion_ip=$1
private_ip=$2
remote_command=$3

# בדיקה אם ניתנה כתובת IP של בסטיון
if [ -z "$bastion_ip" ]; then
    echo "Please provide bastion IP address"
    exit 5
fi

# בדיקה שהמשתנה KEY_PATH מוגדר
if [ -z "$KEY_PATH" ]; then
    echo "KEY_PATH env var is `expected"
    exit 5
fi

# הוספת מפתח SSH ל-agent
ssh-add $KEY_PATH

# בדיקה אם ניתנה פקודה לביצוע בשרת הפרטי
if [ ! -z "$remote_command" ]; then
    ssh -t -A ubuntu@$bastion_ip "ssh ubuntu@$private_ip '$remote_command'"
# בדיקה אם ניתנה כתובת IP של שרת פרטי
elif [ ! -z "$private_ip" ]; then
    ssh -t -A ubuntu@$bastion_ip "ssh ubuntu@$private_ip"

# אם לא ניתנה כתובת IP של שרת פרטי

else
    ssh -t -A ubuntu@$bastion_ip
fi
