origin_list = [1, 2, 3, 4, 5]

new_list = []

for i in origin_list:
    new_list.append(i ** 2)

print(f"new_list: {new_list}")

new2_list = [i ** 2 if i == 2 else i + 1 if i == 5 else i for i in origin_list]
print(f"new2_list: {new2_list}")
