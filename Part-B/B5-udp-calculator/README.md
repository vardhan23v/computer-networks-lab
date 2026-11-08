# Experiment 9: Calculator using UDP Sockets

## 🎯 Aim & Objective
Using UDP sockets in Python, write a client-server calculation service. The client takes two numeric operands and an arithmetic operator (`+`, `-`, `*`, `/`, `%`) from standard input, validates inputs locally, and transmits a datagram request to the server. The server processes the arithmetic operation (safely handling division and modulo by zero) and transmits the computed result back to the client over connectionless UDP.

---

## 📦 Required Tools & Socket Primitives

| Component | Specification |
|---|---|
| **Language** | Python 3 (`socket`, `sys`, `math`) |
| **Transport Protocol**| UDP (`SOCK_DGRAM`, `IPPROTO_UDP`) |
| **Addressing Scheme** | IPv4 (`AF_INET`), `127.0.0.1`, Port `20001` |
| **I/O Functions** | `sendto(data, address)` and `recvfrom(bufsize)` |
| **Timeout Handling** | Client socket timeout configured to `5.0s` via `settimeout(5)` |
| **Supported Operations**| Addition (`+`), Subtraction (`-`), Multiplication (`*`), Division (`/`), Modulo (`%`) |
| **Error Handling** | Division by zero, Modulo by zero, non-numeric validation, invalid operator |

---

## 📂 Files in this Experiment

- [`udp_server.py`](./udp_server.py) - Connectionless UDP server calculating arithmetic expressions and replying via `sendto`.
- [`udp_client.py`](./udp_client.py) - Interactive UDP client validating user input, sending request datagram, and awaiting server response.

---

## 🛠 Execution Instructions

Open two terminal windows:

### Terminal 1: Run Server
```bash
python3 udp_server.py
```

### Terminal 2: Run Client
```bash
python3 udp_client.py
```

---

## 🔍 Code Walkthrough

### 1. UDP vs TCP Socket Architecture
- **No Handshake:** UDP is connectionless. There is no `listen()`, `connect()`, or `accept()` phase.
- **Datagrams:** Communication occurs via discrete messages (`SOCK_DGRAM`).
- **Sender Identification:** In UDP, each datagram carries its own source address; `recvfrom(BUFFER_SIZE)` returns both the message payload and the client's `(IP, Port)` tuple, allowing the server to reply back with `sendto(..., client_address)`.

### 2. Client-Side Input Validation (`udp_client.py`)
- `math.isfinite(float(text))`: Guarantees input strings represent real numbers (rejects `NaN`, `inf`, non-digit garbage).
- Operator white-listing restricts expressions to safe operations (`+`, `-`, `*`, `/`, `%`).
- `client_socket.settimeout(5)`: Prevents indefinite hanging if the UDP server is unreachable or datagrams are dropped.

### 3. Server-Side Execution (`udp_server.py`)
- Splits string into `num1, operator, num2`.
- Handles edge conditions:
  - Division by zero: `if b == 0: result = "Error: division by zero"`
  - Modulo by zero: `if b == 0: result = "Error: modulo by zero"`
- Formats result and transmits back to `client_address`.

---

## 🧪 Expected Output

### Terminal 1 (Server):
```text
$ python3 udp_server.py
UDP server up and listening on port 20001
Request from ('127.0.0.1', 42284) : 12 + 5
Result to client: 17.0
Request from ('127.0.0.1', 42871) : 20 / 4
Result to client: 5.0
Request from ('127.0.0.1', 59562) : 5 / 0
Result to client: Error: division by zero
^C
Server stopped
```

### Terminal 2 (Client):
```text
$ python3 udp_client.py
Enter first number : 12
Enter operator (+ - * / %) : +
Enter second number : 5
12 + 5 = 17.0

$ python3 udp_client.py
Enter first number : 20
Enter operator (+ - * / %) : /
Enter second number : 4
20 / 4 = 5.0

$ python3 udp_client.py
Enter first number : 5
Enter operator (+ - * / %) : /
Enter second number : 0
5 / 0 = Error: division by zero

$ python3 udp_client.py
Enter first number : abc
Enter operator (+ - * / %) : +
Enter second number : 5
Invalid input: both operands must be numbers.
```

---

## 💡 Viva Questions & Key Takeaways

1. **Why does UDP use `recvfrom()` and `sendto()` instead of `recv()` and `send()`?**
   - Because UDP is connectionless, a socket can receive packets from any arbitrary sender. `recvfrom()` returns the remote address with every packet. To reply, `sendto()` must explicitly specify the destination IP and port address in each transmission.
2. **What happens if a UDP packet is lost in transit?**
   - UDP does not provide retransmissions or acknowledgments. The datagram is simply dropped by the network. The client handles this via `client_socket.settimeout(5)` which catches `socket.timeout`.
3. **What is the UDP header overhead compared to TCP?**
   - UDP has a minimal 8-byte fixed header (Source Port, Destination Port, Length, Checksum) compared to TCP's 20–60 byte header, making it much faster for lightweight request-response queries.
4. **Is UDP reliable? When should UDP be preferred over TCP?**
   - UDP is unreliable and unordered, but delivers minimal latency and zero connection overhead. It is ideal for DNS lookups, VoIP, live video streaming, multiplayer gaming, and simple remote procedure queries like calculators.
