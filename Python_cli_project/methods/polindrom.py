def palindrome_num(num):

    new_num=str(num)
    j=len(new_num)-1
    for i in range(j//2):
        if new_num[i]==new_num[j]:
            i+=1
            j-=1
        else:
         return False
    return True