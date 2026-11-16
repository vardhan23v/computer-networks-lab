# Experiment 6: Error Detection using CRC (Cyclic Redundancy Check)
# Concept: Modulo-2 binary polynomial division using XOR operations.
# Divisor generator polynomial: div = [1, 0, 1, 1] (x^3 + x + 1)

div = [1, 0, 1, 1]
cdata = []
n = int(input("Enter the number of bits :"))
data = [int(input(f"Enter bit {i + 1}: ")) for i in range(n)]
m = len(div)

if n < m:
    print("Invalid data ")
else:
    # Append (m - 1) zeros to the data polynomial
    cdata = data.copy()
    for i in range(m - 1):
        cdata.append(0)
    print("Initial Codeword :", cdata)

    # Perform modulo-2 binary division using XOR
    for i in range(n):
        if cdata[i] == 1:
            for j in range(m):
                cdata[i + j] ^= div[j]

    # Append remainder (CRC checksum) to original data
    for i in range(n, n + m - 1):
        data.append(cdata[i])
    print("Codeword to be transmitted is:", data)

    # Optional error injection
    ch = input("Introduce Error - Y -> YES N->NO:")
    if ch.upper() == 'Y':
        p = int(input("Enter the position to change bit :"))
        if 1 <= p <= len(data):
            data[p - 1] ^= 1
        else:
            print("Invalid Position !")

    print("The message received is:", data)

    # Receiver-side verification (modulo-2 division of received codeword)
    for i in range(n):
        if data[i] == 1:
            for j in range(m):
                data[i + j] ^= div[j]

    # Check syndrome remainder
    flag = True
    for i in data:
        if i == 1:
            flag = False
            break

    if flag:
        print("No Error \nSuccessfully Transferred")
    else:
        print("Error !")
