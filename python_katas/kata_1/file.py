import os

def createfile(file):
    # isExisting = os.path.exists(file)
    f = open(os.getcwd()+"\\python_katas\\kata_1\\"+file, "a")
    f.write("Now the file has more content!\n")
    f.close()
    return None

if __name__ == '__main__':
    file="demo.txt"
    createfile(file)
    # Open the file for reading
    with open("python_katas\\kata_1\\"+file, "r") as my_file:
        # Initialize an empty list to store the lines
        lines_list = []
        
        # Read and append each line to the list
        for line in my_file:
            lines_list.append(line.strip())  # strip() is used to remove newline characters
        
        # my_file.seek(0)

    # Print the list of lines
    print(lines_list)