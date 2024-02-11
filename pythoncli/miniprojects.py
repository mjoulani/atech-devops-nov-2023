import requests
import json

class TextAnalyzer:
    def __init__(self, text):
        self.text = text
        self.load_country_data()
        self.country_data = None

    def load_country_data(self):
        with open('country_codes.json', 'r') as file:
            self.country_data = json.load(file)
    
    def is_palindrome(self):
        check_text = ''.join(ch.lower() for ch in self.text if ch.isalnum())
        return check_text == check_text[::-1]

    def is_lower(self):
        return all(ch.islower() for ch in self.text)

    def is_digits(self):
        return all(ch.isdigit() for ch in self.text)

    def is_armstrong(self):
        num = int(self.text)
        order = len(str(num))
        sum_of_digits = sum(int(digit) ** order for digit in str(num))
        return num == sum_of_digits

    def nationalize(self):
        response = requests.get(f'https://api.nationalize.io/?name={self.text}')
        data = response.json()
        if data.get('country'):
            country_iso = data['country'][0]['country_id']
            country_name = self.get_country_name(country_iso)
            probability = data['country'][0]['probability'] * 100
            return f"{country_name} {probability:.1f}%"
        else:
            return "Unable to determine nationality."

    def get_country_name(self, country_iso):
        country_name = self.country_data.get(country_iso)
        return country_name if country_name else "Unknown"

# Main application
while True:

    print("""
1 - Palindrome - Check if the input is a palindrome
2 - Lower - Check if all characters in the input are lowercase
3 - Digits - Check if all characters in the input are digits
4 - Armstrong - Check if the input is an "Armstrong Number"
5 - Nationalize - Check the nationality probability of a given first name
6 - Exit - Exit successfully from the application
    """ )
    command = (input("Enter the number of command: "))

    if command == '6':
        print("Exiting the application.")
        break

    if command in ['1', '2', '3', '4', '5','6']:
        user_input = input("Enter the input: ")
        analyzer = TextAnalyzer(user_input)

        if command == '1': #plindrome
            result = analyzer.is_palindrome()
        elif command == '2':#lower
            result = analyzer.is_lower()
        elif command == '3':#digits
            result = analyzer.is_digits()
        elif command == '4':#armstrong
            result = analyzer.is_armstrong()
        elif command == '5':#nationalize
            result = analyzer.nationalize()
        print("The answer is: " + str(result))

    else:
        print("Invalid command. Please enter a valid command.")
