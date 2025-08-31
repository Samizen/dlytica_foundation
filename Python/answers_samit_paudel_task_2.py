x = float(input("Enter 1st number: "))
y = float(input("Enter 2nd number: "))

sum = x + y
difference = x - y
product = x * y
if y != 0:
    quotient = x / y
else:
    quotient = "Error: division by 0"

print("Sum:", sum)
print("Difference:", difference)
print("Product:", product)
print("Quotient:", quotient)


