import random
from pyfiglet import Figlet

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
redbg = "\033[101m";
grey = "\033[37m";
cyan = "\033[36m";
bold = "\033[1m";


def error(text):
    print(red + bold + "[X] " + text + cln)


def warning(text, indents=0):
    indents = " " * indents
    print(orange + indents + "[!] " + text + cln)


def info(text):
    print(grey + "[*] " + text + cln)


def success(text, indents=0):
    indents = " " * indents
    print(green + bold + indents + "[*] " + text + cln)


def print_ascii_banner(text):
    fonts_dict = ['graffiti', 'Big', 'Bulbhead', 'Doom', 'Graceful', 'Ogre', 'Rectangles']
    colors_dict = [red, green, yellow, orange, blue, magenta];
    random_font = random.choice(fonts_dict)
    random_color = random.choice(colors_dict)
    custom_fig = Figlet(random_font)
    print(random_color + custom_fig.renderText(text) + cln)