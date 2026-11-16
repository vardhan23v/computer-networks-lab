# udp_server.py - receives "number operator number" and replies with the result
import socket

SERVER_IP = "127.0.0.1"
SERVER_PORT = 20001
BUFFER_SIZE = 1024

# create a UDP socket and bind it to (SERVER_IP, SERVER_PORT)
server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server_socket.bind((SERVER_IP, SERVER_PORT))
print("UDP server up and listening on port", SERVER_PORT)

try:
    while True:
        # wait for a datagram; recvfrom() also tells us who sent it
        data, client_address = server_socket.recvfrom(BUFFER_SIZE)
        request = data.decode(errors="replace")
        print("Request from", client_address, ":", request)

        # work out the result (or an error message)
        try:
            num1, operator, num2 = request.split()
            a = float(num1)
            b = float(num2)
            if operator == "+":
                result = a + b
            elif operator == "-":
                result = a - b
            elif operator == "*":
                result = a * b
            elif operator == "/":
                if b == 0:
                    result = "Error: division by zero"
                else:
                    result = a / b
            elif operator == "%":
                if b == 0:
                    result = "Error: modulo by zero"
                else:
                    result = a % b
            else:
                result = "Error: invalid operator"
        except ValueError:
            result = "Error: invalid request"

        print("Result to client:", result)
        server_socket.sendto(str(result).encode(), client_address)
except KeyboardInterrupt:
    print("\nServer stopped")
finally:
    server_socket.close()
