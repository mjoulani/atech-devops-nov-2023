# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi


# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH

###############################
#Greet the user
echo " Hello $(USER)"
###############################
#

############ Define Environment variable.
export COURSE_ID="DevOpsBootcampElevation"

#########################################
#
#
#
TOKEN="/home/${USER}/.token"
PERMISSION=`stat -c "%a" "$TOKEN"`
if [[ "$PERMISSION" != 600 ]]
then
        echo " Warning: .token file has too open permissions "
fi

##############################################################
#
#
#Change the umask of new created user
#777 - 660 ( octal)
umask 117
##############################################################
#
#
# Add /home/<username>/usercommands (while <username> is the linux username) to the end of the PATH env var
#
export PATH=$PATH:/home/${USER}/usercommands

###########################################
#
#Display Date
NEW_DATE=$(date "+%Y-%m-%d%T%H:%M%S%z")
echo "$NEW_DATE"
################################################
#
#
#Alias
alias ltxt="ls *.txt"
#########################################
#
#
#Check for ~/tmp
if [[ ! -d ~/tmp ]]
then
        mkdir ~/tmp
else
        cd ~/tmp && rm -rf *
fi

### if ~/tmp exists then kill the process bound ot port 8080:
#
if [[ -d ~/tmp ]]
then
        lsof -i:8080
        kill $(lsof -t -i:8080)
fi
