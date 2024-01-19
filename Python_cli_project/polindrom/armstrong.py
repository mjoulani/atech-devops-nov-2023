def armstrong(n):
    arm=str(n)
    power=len(arm)
    sum=0
    for i in arm:
        sum+=int(i)**power
        if sum > n:
            return False
    return (sum==n)