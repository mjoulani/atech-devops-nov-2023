import requests


class Command:
    def execute(self, input_text):
        pass


class PalindromeCommand(Command):
    def execute(self, input_text):
        return input_text == input_text[::-1]


class LowerCommand(Command):
    def execute(self, input_text):
        return input_text.islower()


class DigitsCommand(Command):
    def execute(self, input_text):
        return input_text.isdigit()


class ArmstrongCommand(Command):
    def execute(self, input_text):
        n = len(input_text)
        total = sum(int(digit) ** n for digit in input_text)
        return total == int(input_text)


class NationalizeCommand(Command):
    def execute(self, input_text):
        url = f"https://api.nationalize.io?name={input_text}"
        response = requests.get(url)
        data = response.json()

        if data.get('country') and data['country']:
            country_code = data['country'][0]['country_id']
            probability = data['country'][0]['probability'] * 100
            country_name = self.convert_country_code(country_code)
            return f"{country_name} {probability:.1f}%"
        else:
            return "Unable to determine nationality."

    def convert_country_code(self, country_code):
        # You can expand this method with a proper mapping or use a library for country code conversion.
        # For simplicity, let's assume a simple mapping for illustration.
        country_mapping = {'IL': 'Israel', 'US': 'United States', 'IN': 'India'}
        return country_mapping.get(country_code, country_code)


class ExitCommand(Command):
    def execute(self, input_text):
        print("Exiting the application.")
        exit()


class CommandProcessor:
    def __init__(self):
        self.commands = {
            1: PalindromeCommand(),
            2: LowerCommand(),
            3: DigitsCommand(),
            4: ArmstrongCommand(),
            5: NationalizeCommand(),
            6: ExitCommand()
        }

    def show_available_commands(self):
        print("Available commands:")
        for num, command in self.commands.items():
            print(f"{num}. {command.__class__.__name__}")

    def process_command(self, command_num, input_text):
        command = self.commands.get(command_num)
        if command:
            result = command.execute(input_text)
            print(f"Result: {result}")
        else:
            print("Invalid command number. Try again.")


if __name__ == "__main__":
    processor = CommandProcessor()

    while True:
        processor.show_available_commands()
        command_num = int(input("Choose a command number (or 6 to exit): "))

        if command_num == 6:
            processor.process_command(command_num, "")
            break

        input_text = input("Enter input: ")
        processor.process_command(command_num, input_text)
