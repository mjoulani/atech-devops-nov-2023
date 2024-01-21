import utils.prints as prints
import utils.menu_tools as menu
import Python_cli_project.methods.polindrom as polindrom

from Python_cli_project.methods.armstrong import armstrong
from Python_cli_project.methods.digits import digits
from Python_cli_project.methods.lower import lower
from Python_cli_project.methods.nationalize import nationalize

white = "\033[97m"
black = "\033[30m\033[1m"
yellow = "\033[93m"
orange = "\033[38;5;208m"
blue = "\033[34m"
lblue = "\033[36m"
cln = "\033[0m"
green = "\033[92m"
fgreen = "\033[32m"
red = "\033[91m"
magenta = "\033[35m"
blackbg = "\033[100m"
whitebg = "\033[107m"
bluebg = "\033[44m"
lbluebg = "\033[106m"
greenbg = "\033[42m"
lgreenbg = "\033[102m"
yellowbg = "\033[43m"
lyellowbg = "\033[103m"
violetbg = "\033[48;5;129m"
redbg = "\033[101m"
grey = "\033[37m"
cyan = "\033[36m"
bold = "\033[1m"

while True:
    menu.cls()
    prints.print_ascii_banner("Python CLI")
    print(green + bold + "               Main Menu" + cln)
    print(green + bold + "=======================================" + cln)
    print("  [1]    Palindrome - Check if the input is a palindrome")
    print("  [2]    Lower - Check if all characters in the input are lowercase")
    print("  [3]    Digits - Check if all characters in the input are digits")
    print('  [4]    Armstrong - Check if the input is an "Armstrong Number"')
    print('  [5]    Nationalize - Check the nationality probability of a given first name.')
    print("  [6]    Exit\n")

    user_input = input("Select an option: ").lower()

    if user_input == '6':
        menu.exit_program()
    elif user_input == '1':
        menu.cls()
        prints.print_ascii_banner("Polindrom")
        num=input("Enter the input")
        poli = polindrom.palindrome_num(num)
        print(poli)
        if num is None:
            if menu.restart_program():
                continue
            else:
                menu.exit_program()
        else:
            if menu.restart_program():
                continue
            else:
                menu.exit_program()
    elif user_input == '2':
        menu.cls()
        prints.print_ascii_banner("Lower")
        string = input("Enter the input: ")
        output=lower(string)
        print(output)
        if string is None:
            if menu.restart_program():
                continue
            else:
                menu.exit_program()
        else:
            if menu.restart_program():
                continue
            else:
                menu.exit_program()

    elif user_input == '3':
        menu.cls()
        prints.print_ascii_banner("Digits")
        digi = input("Enter the input: ")
        output= digits(digi)
        print(output)

        if digi is None:
            if menu.restart_program():
                continue
            else:
                menu.exit_program()
        if menu.restart_program():
            continue
        else:
            menu.exit_program()
    elif user_input == '4':
        menu.cls()
        prints.print_ascii_banner("Armstrong")
        num = input("Enter the input: ")
        output = armstrong(num)
        print(output)
        if output is None:
            if menu.restart_program():
                continue
            else:
                menu.exit_program()
        if menu.restart_program():
            continue
        else:
            menu.exit_program()
    elif user_input == '5':
        menu.cls()
        prints.print_ascii_banner("Nationalize")
        name = input("Enter the input: ")
        output = nationalize(name)
        #print(output)
        if output is None:
            if menu.restart_program():
                continue
            else:
                menu.exit_program()
        if menu.restart_program():
            continue
        else:
            menu.exit_program()

    else:
        prints.error("Invalid input, please select an option from the provided list")
        if menu.restart_program():
            continue
        else:
            menu.exit_program()