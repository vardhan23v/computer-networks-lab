# udp_client.py - reads two numbers and an operator, asks the server to calculate
import socket
import sys
import math

SERVER_ADDRESS = ("127.0.0.1", 20001)  # (IP address, port) of the server
BUFFER_SIZE = 1024


def is_number(text):
    # True only for finite numbers such as 12, -3.5 or 1e3
    try:
        return math.isfinite(float(text))
    except ValueError:
        return False


# read and check the input before anything is sent
num1 = input("Enter first number : ").strip()
operator = input("Enter operator (+ - * / %) : ").strip()
num2 = input("Enter second number : ").strip()

if not is_number(num1) or not is_number(num2):
    sys.exit("Invalid input: both operands must be numbers.")
if operator not in ("+", "-", "*", "/", "%"):
    sys.exit("Invalid operator: use one of + - * / %")

# create a UDP socket; wait at most 5 seconds for the reply
client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
client_socket.settimeout(5)

request = num1 + " " + operator + " " + num2
client_socket.sendto(request.encode(), SERVER_ADDRESS)

try:
    reply, server_address = client_socket.recvfrom(BUFFER_SIZE)
    print(request, "=", reply.decode())
except (socket.timeout, ConnectionResetError):
    print("No reply from the server. Is udp_server.py running?")
finally:
    client_socket.close()
