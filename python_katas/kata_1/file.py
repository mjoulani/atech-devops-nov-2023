import os

def createfile(file):
    # isExisting = os.path.exists(file)
    f = open(os.getcwd()+"\\python_katas\\kata_1\\"+file+".txt", "a")
    f.write("Now the file has more content!\n")
    f.close()
    return None

if __name__ == '__main__':
    createfile("demo")