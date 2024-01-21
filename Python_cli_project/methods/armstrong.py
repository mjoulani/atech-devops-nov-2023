def armstrong(n):

    arm_str=str(n)
    arm_int=int(n)
    power=len(arm_str)
    sum=0
    for i in arm_str:
        sum+=int(i)**power
        if sum > arm_int:
            return False
    return (sum==n)