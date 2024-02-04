import requests
import json


class Command:
    def execute(self, user_input):
        print("zone command")
    # pass


class PalindromeCommand(Command):
    def execute(self, user_input):
        print("zone 1")
        return user_input == user_input[::-1]


class LowerCommand(Command):
    def execute(self, user_input):
        print("zone 2")
        return user_input.islower()


class DigitsCommand(Command):
    def execute(self, user_input):
        print("zone 3")
        return user_input.isdigit()
        # pass


class ArmstrongCommand(Command):
    def execute(self, user_input):
        print("zone 4")
        n = len(user_input)
        total = sum(int(digit) ** n for digit in user_input)
        return total == int(user_input)

        # pass


class NationalizeCommand(Command):
    def execute(self, user_input):
        print("zone 5")
        make_request = f"https://api.nationalize.io/?name={user_input}"
        response = requests.get(make_request)
        data = response.json()
        country_list = data.get('country', [])
        # print(country_list)
        country_id = []
        persent = []
        # Iterate over each dictionary in the 'country' list

        for country_info in country_list:
            # Access the value of 'country_id' key
            prob = country_info.get('probability')
            prob = prob * 100

            if prob >= 1:
                id = country_info.get('country_id')
                country_id.append(id)
                if prob >= 100:
                    prob = 100
                persent.append(prob)

        # Print or use the country_id value as needed
        #the_file = open("countray.json")
        the_file = open(r"C:\atech-devops-nov-2023\python_CLI_project\country.json")
        json_data = json.load(the_file)

        result = []
        for i in country_id:
            for key in json_data:
                if i == key:
                    result.append(json_data[key])
        temp = 0
        if result:
            for i in result:
                print("The Result is : ", i, " ", round(persent[temp],3), "%")
                temp += 1
            return "for Nationality"
        else:
            return "Nationality not found"


class ExitCommand():
    def execute(self):
        print("Exiting the application.")
        exit()


class CLIApplication:
    def __init__(self):
        self.commands = {
            1: PalindromeCommand(),
            2: LowerCommand(),
            3: DigitsCommand(),
            4: ArmstrongCommand(),
            5: NationalizeCommand(),
            6: ExitCommand()
        }

    # The job of this function only to display the available
    def display_commands(self):
        print("Available commands:")
        for num, command in self.commands.items():
            print(f"{num}. {command.__class__.__name__}")
            # The command.__class__.__name__ to get the name of the available class
            # print("{}. {}".format(num, command.__class__.__name__))

    # To run the script in infinte loop and accept command from user
    def run(self):
        while True:
            self.display_commands()
            choice = input("Choose a command number: ")
            choice = int(choice)
            if choice not in self.commands:
                print("Invalid command number. Please try again.")
                continue

            if choice == 5:
                name = input("Enter a first name: ")
                result = self.commands[choice].execute(name)
            elif choice == 6:
                none = None
                # tt = self.commands[choice]
                # print("{}".format(tt.__class__.__name__))
                self.commands[choice].execute()
                # ExitCommand.execute()
            else:
                user_input = input("Enter an input: ")
                result = self.commands[choice].execute(user_input)

            print("The answer is : ", result)


if __name__ == "__main__":
    t = CLIApplication()
    t.run()