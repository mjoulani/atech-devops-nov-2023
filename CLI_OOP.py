import requests, json
from country_list import countries_for_language

class CLI():
    def __init__(self, funNum, Value):
        self.funNum = funNum
        self.Value = Value

    def usage(self):
        return """
    Welcome to the mini CLI
    The available commands are:
    1 - Palindrome - Check if the input is a Palinrome
    2 - Lower - Check if all characters in the input are lower case
    3 - Digits - Check if all characters are digits
    4 - Armstrong - Check if the imput is an armstrong number
    5 - Nationalize - Check the nationality probability of a give
            first name
    6 - Exit - Exit successfully from the application
    """
    
    ##PALINDROME FUNCTION
    def palindrome(self):
        if self.Value[::-1] == self.Value:
            return True
        else:
            return False

    ##LOWER FUNCTION
    def is_it_lower(self):
        if self.Value.islower():
            return True
        else:
            return False
    
    ##DIGITS FUNCTION
    def is_it_a_digit(self):
        if self.Value.isdigit():
            return True
        else:
            return False
    
    ##IF ARM STRONG NUMBER FUNCTION
    def is_armstrong(self):
        #153
        ls = [i for i in self.Value]
        pw = len(ls)
        try:
            rs = sum([pow(int(n),pw) for n in ls])
        except ValueError:
            print("Value should be a number")
        if rs == int(self.Value):
            return True
        else:
            return False

    ##NATIONALIZE FUNCTION
    def nationalize(self):
        countries = dict(countries_for_language('en'))
        response = requests.get(f"https://api.nationalize.io/?name={self.Value}")
        if response.status_code == 200:
            content = response.json()
            if content['count'] == 0:
                print("Name not found")
            v = content.get('country')
            percent = f"{float(f'{v[0]['probability']}'):.1%}"
            return f"{countries[f'{v[0]['country_id']}']} {percent}"
        else:
            raise ConnectionError

    ##EXIT FUNCTION
    def exit_function(self):
        return "Thank you for using my CLI :)"


def main():
    while True:
        usage = CLI("","")
        print(usage.usage())
        fNum = input("Enter function number: ")
        if fNum == "6":
            obj = CLI("", "")
            print(obj.exit_function())
            return
        val = input("Enter Value: ")
        obj = CLI(fNum, val)
        match fNum:
            case "1":
                print(obj.palindrome())
            case "2":
                print(obj.is_it_lower())
            case "3":
                print(obj.is_it_a_digit())
            case "4":
                print(obj.is_armstrong())
            case "5":
                print(obj.nationalize())
            case _:
                print("Yooooooooo bad usage")
                continue



main()