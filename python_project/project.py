import requests
import json
class Game:
    def polindrom(self,par):
        num=str(par)
        for i in range(len(num)):
            if(num[i]!=num[len(num)-i-1]):
                return "Not Polindrom"
        return "Polindrom"

    def lower(self,par):
        lower=str(par).islower()
        if(lower):
            return "All characters are lowercase"
        return "Not all characters are lowercase"
        

    def digit(self,par):
        dig=(par).isdigit()
        if(dig):
            return "All characters are digits"
        return "Not all characters are digits"

    def is_armstrong(self,par):
        num_str = str(par)
        num_digits = len(par)
        sum_of_powers = sum(int(digit)**num_digits for digit in num_str)
        if(sum_of_powers == int(par)):
            return "Armstrong"
        return "Not Armstrong"
        

    def nationalize (self,par):
        response_API = requests.get('https://api.nationalize.io?name='+par)
        data = response_API.text
        parse_json = json.loads(data)
        country=parse_json['country'][0]['country_id']
        probability=parse_json['country'][0]['probability']
        f = open('python_project/data.json')
        data = json.load(f)
        country=data[country]
        return "{} {}%".format(country, probability*100)

if __name__ == "__main__":
    game = Game()
    loop=True
    while loop:
        print("The available command are \n1-Polindrom\n2-isLower\n3-Digits\n4-Amstrong\n5-Nationalize\n6-Exit Program")
        num=input("Enter the number of the command: ")
        num = int(num)
        if num == 1:
            print(game.polindrom(input("input a string to check Polindrom.. ")))
        elif num == 2:
            print(game.lower(input("input a string to check if it lower.. ")))
        elif num == 3:
            print(game.digit(input("input a string to check if it Digits.. ")))
        elif num == 4:
            inp=input("input a number to check if it Amstrong.. ")
            print(game.is_armstrong(inp))
        elif num == 5:
            print(game.nationalize(input("input a name to check  Nationalize.. ")))
        elif num == 6:
            print("Exiting , have a good day.")
            loop = False
        else:
            print("You have entered an invalid number .")


