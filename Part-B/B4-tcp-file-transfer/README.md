# Experiment 8: File Transfer using TCP Sockets

## 🎯 Aim & Objective
Using TCP/IP Berkeley sockets in Python, write a client-server program in which the client connects to the server over a reliable stream-oriented TCP connection, requests a file by name, and the server reads the file from disk and streams its contents back to the client. If the requested file is missing, the server sends an error message.

---

## 📦 Required Tools & Socket Primitives

| Component | Specification |
|---|---|
| **Language** | Python 3 (`socket`, `sys`, `os` modules) |
| **Transport Protocol**| TCP (`SOCK_STREAM`, `IPPROTO_TCP`) |
| **Addressing Scheme** | IPv4 (`AF_INET`), `127.0.0.1` (localhost), Port `8888` |
| **Socket Options** | `SOL_SOCKET`, `SO_REUSEADDR = 1` (avoids `TIME_WAIT` address bind conflicts) |
| **Transmission Mode**| Chunked binary transfer (`BUFFER_SIZE = 1024` bytes) |
| **Connection Flow** | 3-Way Handshake (`SYN`, `SYN-ACK`, `ACK`), stream transfer, active close (`FIN`) |

---

## 📂 Files in this Experiment

- [`tcp_server.py`](./tcp_server.py) - Iterative TCP server listening for file requests and transmitting payloads.
- [`tcp_client.py`](./tcp_client.py) - TCP client querying the server, receiving byte stream, and saving file to disk.
- [`sample.txt`](./sample.txt) - Sample text file used for verification.

---

## 🛠 Execution Instructions

Open two terminal windows:

### Terminal 1: Run Server
```bash
python3 tcp_server.py
```

### Terminal 2: Run Client
```bash
# Case 1: Request existing file
python3 tcp_client.py
Enter the file name: sample.txt

# Case 2: Request non-existent file
python3 tcp_client.py
Enter the file name: missing.txt
```

---

## 🔍 Code Walkthrough

### 1. Server Architecture (`tcp_server.py`)
- **Socket Creation & Reuse:**
  ```python
  server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
  server_socket.bind((HOST, PORT))
  server_socket.listen(1)
  ```
  `SO_REUSEADDR` allows immediate restart without waiting for OS socket cleanup timeout.
- **Connection Acceptance:**
  - `server_socket.accept()` blocks until a client completes the TCP 3-way handshake, returning a dedicated connection socket `client_socket` and `client_address`.
- **Payload Streaming:**
  - If `os.path.isfile(file_name)` is true, opens file in binary mode (`"rb"`) and transmits data using `client_socket.sendall()`.
  - Otherwise, transmits `b"File not found"`.

### 2. Client Architecture (`tcp_client.py`)
- **Connection Establishment:**
  - `client_socket.connect(SERVER_ADDRESS)` initiates TCP connection to server.
- **Request & Stream Reception:**
  - Sends filename: `client_socket.sendall(file_name.encode())`.
  - Loops on `client_socket.recv(BUFFER_SIZE)` until an empty byte string (`b""`) is returned, signaling server has cleanly closed connection (`EOF`).
- **File Reconstruction:**
  - Saves received binary buffer as `received_<basename>`.

---

## 🧪 Expected Output

### Terminal 1 (Server):
```text
$ python3 tcp_server.py
Server is listening on 127.0.0.1 port 8888
Accepted connection from ('127.0.0.1', 48040)
Received file name = sample.txt
File sent
Accepted connection from ('127.0.0.1', 48042)
Received file name = missing.txt
File not found
^C
Server stopped
```

### Terminal 2 (Client):
```text
$ python3 tcp_client.py
Enter the file name: sample.txt
File contents:
Computer Networks Laboratory
Experiment 8: file transfer using TCP sockets
This file was sent by the server.
File received and saved as 'received_sample.txt'

$ python3 tcp_client.py
Enter the file name: missing.txt
File not found on the server.
```

---

## 💡 Viva Questions & Key Takeaways

1. **Why does TCP use `SOCK_STREAM`?**
   - `SOCK_STREAM` represents a connection-oriented, reliable, bidirectional byte stream. It guarantees in-order delivery, error detection, duplicate suppression, and congestion control via underlying TCP.
2. **What does `server_socket.listen(1)` specify?**
   - The argument specifies the `backlog`—the maximum length of the queue of pending incoming connections waiting to be accepted by `accept()`.
3. **Why is `SO_REUSEADDR` important in socket programming?**
   - After a TCP server terminates, the port remains in `TIME_WAIT` state for typically 2MSL (30–120 seconds). Setting `SO_REUSEADDR` permits the socket to bind to the port immediately upon server restart.
4. **How does the client know that file transmission has finished?**
   - In TCP, when the sending side closes the connection (or signals shutdown), `recv()` returns `0` bytes (an empty bytes object `b""`), which serves as the end-of-file (EOF) indicator.
