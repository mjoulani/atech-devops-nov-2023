# Bash Project 

## Overview

This project covers various topics in both Linux and Bash, including working with files and permissions, configuring the Bash environment, variables, conditional statements, user management, processes, ports, Git, and more.

## Learning Outcomes

- Writing Bash scripts integrated into a larger system.
- Deepening Linux and Bash skills.
- Developing programming skills through precise code writing and automated tests.

## Default Bash Profile for New Linux Users

This project implements a Bash script to apply default Bash profile configurations for new Linux users. The script is designed to be added to the `/etc/skel/.bash_profile` file, which is used when creating new user accounts.

### Instructions for Implementation:

1. Copy the content of the provided `.bash_profile` script into the `/etc/skel/.bash_profile` file on your Ubuntu system.
2. Customize the script based on your specific requirements.
3. Use the `adduser` command to create a new Linux user.
4. Log in to the new user's terminal session using `su -l <username>` (replace `<username>` with the created user's username).
5. Verify that the custom script profile is applied by checking the user's terminal behavior.


## Example User Session

```bash
$ su -l <username>
Password:
Hello <username>
Warning: .token file has too open permissions
The current date is: 2022-03-18T08:54:21+00:00
<username>@localhost:~$ ltxt
a.txt
<username>@localhost:~$ echo $COURSE_ID
DevOpsBootcampElevation
<username>@localhost:~$ ls -l tmp
total 0
<username>@localhost:~$ echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/<username>/usercommands
