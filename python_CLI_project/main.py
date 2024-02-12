import requests
import json

class Command:
     def execute(self, user_input):
         print("zone command")
        # pass

class PalindromeCommand(Command):
    def execute(self,user_input): 
       print("zone 1")
       return user_input == user_input[::-1] 
       

class LowerCommand(Command):
    def execute(self,user_input):
        print("zone 2")
        return user_input.islower()
        

class DigitsCommand(Command):
    def execute(self,user_input):
        print("zone 3")
        return user_input.isdigit()
        #pass

class ArmstrongCommand(Command):
    def execute(self,user_input):
        print("zone 4")
        n = len(user_input)
        total = sum(int(digit) ** n for digit in user_input)
        return total == int(user_input)
        
        #pass

class NationalizeCommand(Command):
    def execute(self,user_input):
        ''' print("zone 5")
        make_request = f"https://api.nationalize.io/?name={user_input}"
        response = requests.get(make_request)
        if not response.ok:
            print(f"Error: {response.status_code}, Connection Error: {response.reason}")
            return '''
        make_request = f"https://api.nationalize.io/?name={user_input}"

        try:
            response = requests.get(make_request)
            response.raise_for_status()  # Raise an HTTPError for bad responses
        except requests.exceptions.RequestException as e:
            print(f"Error: {e}")
            return  # Exit the method on error
        data = response.json()
        country_list = data.get('country',[])
        #print(country_list)
        country_id = []
        persent = []
        
        # Iterate over each dictionary in the 'country' list
        for country_info in country_list:
            # Access the value of 'country_id' key
            #print(country_info)
            prob=country_info.get('probability')*100
            
            if prob >= 1:
               id = country_info.get('country_id')
               country_id.append(id)
               persent.append(prob) 
               
        
        #file_path = (r"C:\Users\HP\python\Cli project\countray.json")
        #file_path = ("countray.json")
        #file_path = (r"Cli project\countray.json")
        file_path=CLIApplication.path_json
        
        try:
            with open(file_path, 'r') as the_file:
                 json_data = json.load(the_file)
        except FileNotFoundError:
            print(f"Error: The file '{file_path}' does not exist.")
            NewFilePath = input("Please enter the correct path for  coumtry.json  copying and past: ")
            CLIApplication.path_json= NewFilePath
            
            return
        except Exception as e:
            print(f"Error: An unexpected error occurred - {e}")
            return
        
        #result = []
        #for i in country_id:
            #for key in json_data:
                #if i == key:
                    #result.append(json_data[key])

        result = [json_data[key] for i in country_id for key in json_data if i == key]

        if result:
            # The enumerate() function in Python is used to iterate over a sequence (such as a list, tuple, or string)
            # while keeping track of the index (position) of the current element
            result_str = [f"{i} {round(persent[temp], 3)}%" for temp, i in enumerate(result)]
    
            return result_str     
        else:
            return "Nationality not found"                
       
        
         
        

class ExitCommand():
    def execute(self):
        print("Exiting the application.")
        exit()

class CLIApplication:
    path_json = "C:\atech-devops-nov-2023\python_CLI_project\country.json"
    
    def __init__(self):
        self.commands = {
            1: PalindromeCommand(),
            2: LowerCommand(),
            3: DigitsCommand(),
            4: ArmstrongCommand(),
            5: NationalizeCommand(),
            6: ExitCommand()
        }
    #The job of this function only to display the available clasee names
    def display_commands(self):
        print("Available commands:")
        for num, command in self.commands.items():
            print(f"{num}. {command.__class__.__name__}")
            #The command.__class__.__name__ to get the name of the available class
            #print("{}. {}".format(num, command.__class__.__name__))

             
    #To run the script in infinte loop and accept command from user
    def run(self):
            while True:
                try:
                    self.display_commands()
                    choice = input("Choose a command number: ")
                    choice=int(choice)
                except Exception as e:
                    print(f"An error occurred: {e}")
                    #choice = 100    
                if choice not in self.commands:
                    print("Invalid command number. Please try again.")
                    continue

                if choice == 5:
                   name = input("Enter a first name: ")
                   result = self.commands[choice].execute(name)
                elif choice == 6:
                    none=None
                    #tt = self.commands[choice]
                    #print("{}".format(tt.__class__.__name__))
                    self.commands[choice].execute()
                    #ExitCommand.execute()  
                else:
                   user_input = input("Enter an input: ")
                   result = self.commands[choice].execute(user_input)

                print("The answer is : ", result)


if __name__ == "__main__":
    t = CLIApplication()
    t.run()
