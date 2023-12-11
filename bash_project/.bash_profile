USER_NAME=$(whoami)
echo "Hello ${USER_NAME}"

export COURSE_ID='DevOpsBootcampElevation'


if [ -f ~/.token  ]; then
    PR=$(stat -c '%a' ~/.token)
    if [ $PR -ne 600 ]; then
        echo "Warning: .token file has too open permissions"
    fi
fi
umask 117

export PATH=$PATH:/home/${USER_NAME}/usercommands

echo "The current date is: $(date -u -Iseconds)"

alias ltxt="ls -a | grep *.txt "


if [ -r ~/tmp ]; then
   test -z $(ls -A ~/tmp) ||  rm -r ~/tmp/*
else
    mkdir ~/tmp
fi



P=$(lsof -t -i :8080)

if [ $? -eq 0 ]; then
   kill $P
fi
