import os


def createfile(file):
    # isExisting = os.path.exists(file)
    f = open(os.getcwd()+"\\python_katas\\kata_1\\"+file, "a")
    f.write("Now the file has more content!\n")
    f.close()
    return None


def get_word_value(msg):
    return sum(ord(c)-96 for c in msg)



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
    # print(lines_list)

    res = "".join([chr(ord(c)+1) for c in "text"]) 
    # print(res)

    # print(get_word_value("day"))


    # numbers = [11,3,64,17,94]
    # for i,v in enumerate(numbers,50): 
    #     print(i, v) 

    #iterator
    # string_iterator = iter("Python")
    # print(next(string_iterator))
    # print(next(string_iterator))
    # numbers = [10, 12, 15, 18, 20]
    # print(iter(numbers))

    # list_comprehension = [x for x in range(20)]
    # print(list_comprehension)
    # print(type(list_comprehension)) 

    # gen = (x for x in range(20))
    # print(gen)
    # print(type(gen))

    # evens = {2,44,24,62,78}
    # t=(1,2,3)
    # t+=([],)
    # t[3].append(5)
    # print(t)


    



    