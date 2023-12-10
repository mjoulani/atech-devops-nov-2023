!/bin/bash


echo "Hello $USER"


export COURSE_ID=DevOpsBootcampElevation

if [ -e ~/.token ]; then
  token_permissions=$(stat -c "%a" ~/.token)
  if [ "$token_permissions" -ne 600 ]; then
    echo "Warning: .token file has too open permissions"
  fi
fi


umask 0006

export PATH=$PATH:/home/$USER/usercommands

echo "The current date is: $(date -u +"%Y-%m-%dT%H:%M:%S%:z")"

alias ltxt='ls *.txt'


if [ -d ~/tmp ]; then
  rm -rf ~/tmp/*
else
  mkdir ~/tmp
fi


if lsof -i :8080; then
  lsof -i :8080 | awk 'NR!=1 {print $2}' | xargs kill
fi

!/bin/bash


echo "Hello $USER"


export COURSE_ID=DevOpsBootcampElevation

if [ -e ~/.token ]; then
  token_permissions=$(stat -c "%a" ~/.token)
  if [ "$token_permissions" -ne 600 ]; then
    echo "Warning: .token file has too open permissions"
  fi
fi


umask 0006

export PATH=$PATH:/home/$USER/usercommands

echo "The current date is: $(date -u +"%Y-%m-%dT%H:%M:%S%:z")"

alias ltxt='ls *.txt'


if [ -d ~/tmp ]; then
  rm -rf ~/tmp/*
else
  mkdir ~/tmp
fi


if lsof -i :8080; then
  lsof -i :8080 | awk 'NR!=1 {print $2}' | xargs kill
fi

