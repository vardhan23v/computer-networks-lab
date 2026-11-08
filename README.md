# Computer Networks Laboratory: Complete Code, NS-2 Simulations, Socket Programming & Viva Reference

This repository contains the complete laboratory curriculum for the **Computer Networks Laboratory (Academic Year 2026–27)**, Department of Computer Science and Engineering, NMAM Institute of Technology, Nitte.

Every experiment has been implemented, formatted, verified, and thoroughly documented with:
- **Aim & Concept:** Core objective, network protocol dynamics, and OSI layer architecture.
- **Tools, Agents & Language Standards:** Full mapping of NS-2 agents, AWK filters, Berkeley socket APIs, and C/Python implementations.
- **Complete Formatted Source Code:** Clean, standard-compliant, verified source code matching the lab manual.
- **Compilation & Execution Instructions:** Exact terminal commands, NS-2 execution flags, and multi-terminal socket test steps.
- **Detailed Step-by-Step Code Walkthrough:** Logic breakdown, trace file field mappings, packet flows, and state transitions.
- **Sample Input & Expected Output:** Verified terminal outputs, packet counters, and Xgraph plot coordinates matching the lab manual.
- **Viva Questions & Answers:** High-yield technical questions and answers for lab examinations.
- **Comprehensive Theory Guide:** Dedicated [WALKTHROUGH.md](./WALKTHROUGH.md) explaining NS-2 architecture, TCP Reno vs Vegas, Bit Stuffing, CRC polynomial math, Berkeley sockets, and Bellman-Ford routing.

---

## Table of Contents
1. [Environment & System Prerequisites](#environment--system-prerequisites)
2. [Quick Reference Index](#quick-reference-index)
3. [Makefile & Automated Automation](#makefile--automated-automation)
4. **Part A: Network Simulation (NS-2 & AWK)**
   - [Experiment 1: Point-to-point network: packet drops](#experiment-1-point-to-point-network-packet-drops)
   - [Experiment 2: TCP and UDP traffic: packet counts and throughput](#experiment-2-tcp-and-udp-traffic-packet-counts-and-throughput)
   - [Experiment 3: Ethernet LAN: throughput versus data rate and error rate](#experiment-3-ethernet-lan-throughput-versus-data-rate-and-error-rate)
   - [Experiment 4: Ethernet LAN: congestion window of TCP Vegas and Reno](#experiment-4-ethernet-lan-congestion-window-of-tcp-vegas-and-reno)
5. **Part B: Network Programming & Routing Algorithms**
   - [Experiment 5: Bit stuffing and destuffing](#experiment-5-bit-stuffing-and-destuffing)
   - [Experiment 6: Error detection using CRC (CRC-CCITT)](#experiment-6-error-detection-using-crc-crc-ccitt)
   - [Experiment 7: Frame sorting technique used in buffers](#experiment-7-frame-sorting-technique-used-in-buffers)
   - [Experiment 8: File transfer using TCP sockets](#experiment-8-file-transfer-using-tcp-sockets)
   - [Experiment 9: Calculator using UDP sockets](#experiment-9-calculator-using-udp-sockets)
   - [Experiment 10: Distance vector routing algorithm](#experiment-10-distance-vector-routing-algorithm)
6. [Quick Viva Cheat Sheet](#quick-viva-cheat-sheet)
7. [Troubleshooting & Common Errors](#troubleshooting--common-errors)
8. [Comprehensive Network Theory & Architecture Guide](./WALKTHROUGH.md)

---

## Environment & System Prerequisites

The experiments span discrete-event network simulation (NS-2, NAM, AWK, Xgraph), Python 3 network programming, and C routing algorithms.

| Component | Minimum Version | Recommended Version | Verification Command | Notes |
|---|---|---|---|---|
| **Operating System** | Ubuntu 20.04+ / macOS 11+ / WSL | **Ubuntu 22.04 LTS** | `uname -a` | Standard lab environment |
| **Network Simulator**| NS-2.35 | **NS-2.35** | `ns -v` | Discrete-event simulator |
| **Network Animator** | NAM 1.15 | **NAM 1.15** | `nam -v` | Topology visualization |
| **Plotting Tool** | Xgraph 12.1 | **Xgraph 12.1** | `xgraph -version` | Throughput and cwnd plots |
| **C Compiler** | GCC 9.0+ / Clang 11+ | **GCC 11.0+** | `gcc --version` | Compiles `exp10.c` |
| **Python** | Python 3.8+ | **Python 3.10+** | `python3 --version` | Powers Part B scripts |
| **Trace Filter** | GNU Awk 5.0+ | **GAwk 5.1+** | `awk --version` | Parses NS-2 trace files |
| **Build Automation** | GNU Make 4.0+ | **GNU Make 4.3+** | `make --version` | Unified `Makefile` runner |

---

## Quick Reference Index

| Exp # | Experiment Title | OSI Layer | Tools & Protocols | Source Code Link |
|:---:|---|:---:|---|:---:|
| **1** | Point-to-Point Network: Packet Drops | Network / Transport | NS-2, UDP, CBR, DropTail Queue, AWK | [Part-A/A1-point-to-point-packet-drops/](./Part-A/A1-point-to-point-packet-drops/) |
| **2** | TCP & UDP Traffic: Counts & Throughput | Transport Layer | NS-2, TCP, UDP, FTP, CBR, AWK, Xgraph | [Part-A/A2-tcp-udp-traffic-throughput/](./Part-A/A2-tcp-udp-traffic-throughput/) |
| **3** | Ethernet LAN: Throughput vs Error Rate | Data Link / Transport | NS-2, CSMA/CD 802.3, ErrorModel, TCP, AWK | [Part-A/A3-ethernet-lan-error-rate/](./Part-A/A3-ethernet-lan-error-rate/) |
| **4** | Ethernet LAN: TCP Vegas vs Reno `cwnd` | Transport Layer | NS-2, TCP Vegas, TCP Reno, `cwnd_`, AWK, Xgraph | [Part-A/A4-tcp-vegas-reno-congestion-window/](./Part-A/A4-tcp-vegas-reno-congestion-window/) |
| **5** | Bit Stuffing and Destuffing | Data Link Layer | Python 3, HDLC Flag Framing (`01111110`) | [Part-B/B1-bit-stuffing/](./Part-B/B1-bit-stuffing/) |
| **6** | Error Detection using CRC (CRC-CCITT) | Data Link Layer | Python 3, Modulo-2 XOR Division, $GF(2)$ | [Part-B/B2-crc-error-detection/](./Part-B/B2-crc-error-detection/) |
| **7** | Frame Sorting Technique in Buffers | Transport / Data Link | Python 3, Sequence Numbering, Bubble Sort | [Part-B/B3-frame-sorting/](./Part-B/B3-frame-sorting/) |
| **8** | File Transfer using TCP Sockets | Transport / Application | Python 3, `SOCK_STREAM`, Berkeley Sockets | [Part-B/B4-tcp-file-transfer/](./Part-B/B4-tcp-file-transfer/) |
| **9** | Calculator using UDP Sockets | Transport / Application | Python 3, `SOCK_DGRAM`, `sendto`, `recvfrom` | [Part-B/B5-udp-calculator/](./Part-B/B5-udp-calculator/) |
| **10** | Distance Vector Routing Algorithm | Network Layer | C (C99), Bellman-Ford equation, Routing Tables | [Part-B/B6-distance-vector-routing/](./Part-B/B6-distance-vector-routing/) |

---

## Makefile & Automated Automation

A root [`Makefile`](./Makefile) is provided to automate compilation, syntax verification, and test execution:

```bash
# 1. Compile C programs and syntax-check all Python scripts:
make all

# 2. Run automated validation tests across Part B algorithms:
make test

# 3. Clean all temporary trace files, graph files, and compiled binaries:
make clean

# 4. View available targets:
make help
```

---

## Part A: Network Simulation (NS-2 & AWK)

### Experiment 1: Point-to-point network: packet drops
- **Aim:** Simulate a 3-node point-to-point network with duplex links between them. Set queue size, vary bandwidth, and determine the number of packets dropped.
- **Directory:** [`Part-A/A1-point-to-point-packet-drops/`](./Part-A/A1-point-to-point-packet-drops/)
- **Files:** [`exp1.tcl`](./Part-A/A1-point-to-point-packet-drops/exp1.tcl), [`exp1.awk`](./Part-A/A1-point-to-point-packet-drops/exp1.awk)
- **Run Commands:**
  ```bash
  cd Part-A/A1-point-to-point-packet-drops
  ns exp1.tcl
  awk -f exp1.awk out.tr
  ```
- **Key Observation:** At 1 Mbps bandwidth on all links, 0 packets drop. When the bottleneck link `n1-n2` is lowered to 0.5 Mbps, buffer capacity (50 packets) overflows, dropping 252 packets.

---

### Experiment 2: TCP and UDP traffic: packet counts and throughput
- **Aim:** Simulate a 4-node network (`n0-n2`, `n1-n2`, `n2-n3`). Attach a TCP agent between `n0-n3` and a UDP agent between `n1-n3`. Determine packet counts and plot throughput over time.
- **Directory:** [`Part-A/A2-tcp-udp-traffic-throughput/`](./Part-A/A2-tcp-udp-traffic-throughput/)
- **Files:** [`exp2.tcl`](./Part-A/A2-tcp-udp-traffic-throughput/exp2.tcl), [`exp2.awk`](./Part-A/A2-tcp-udp-traffic-throughput/exp2.awk), [`exp2_throughput.awk`](./Part-A/A2-tcp-udp-traffic-throughput/exp2_throughput.awk)
- **Run Commands:**
  ```bash
  cd Part-A/A2-tcp-udp-traffic-throughput
  ns exp2.tcl
  awk -f exp2.awk out.tr
  awk -f exp2_throughput.awk out.tr > plot_throughput
  xgraph plot_throughput
  ```
- **Key Observation:** UDP sends significantly more packets than TCP (4786 vs 846) because UDP lacks flow and congestion control, aggressively competing for shared bandwidth.

---

### Experiment 3: Ethernet LAN: throughput versus data rate and error rate
- **Aim:** Simulate an Ethernet LAN using $N$ nodes (6–10) with CSMA/CD (`Mac/802_3`). Introduce an error model on the link, vary error rates, and observe throughput changes.
- **Directory:** [`Part-A/A3-ethernet-lan-error-rate/`](./Part-A/A3-ethernet-lan-error-rate/)
- **Files:** [`exp3.tcl`](./Part-A/A3-ethernet-lan-error-rate/exp3.tcl), [`exp3.awk`](./Part-A/A3-ethernet-lan-error-rate/exp3.awk)
- **Run Commands:**
  ```bash
  cd Part-A/A3-ethernet-lan-error-rate
  ns exp3.tcl
  xgraph exp3.graph
  ```
- **Key Observation:** Increasing the `ErrorModel` drop rate (`rate_ 0.01`) induces packet drops that trigger TCP retransmissions and window throttling, lowering effective throughput.

---

### Experiment 4: Ethernet LAN: congestion window of TCP Vegas and Reno
- **Aim:** Simulate an Ethernet LAN with multiple traffic sources. Determine collisions across nodes and plot the congestion window (`cwnd_`) for TCP Vegas vs TCP Reno.
- **Directory:** [`Part-A/A4-tcp-vegas-reno-congestion-window/`](./Part-A/A4-tcp-vegas-reno-congestion-window/)
- **Files:** [`exp4.tcl`](./Part-A/A4-tcp-vegas-reno-congestion-window/exp4.tcl), [`exp4.awk`](./Part-A/A4-tcp-vegas-reno-congestion-window/exp4.awk)
- **Run Commands:**
  ```bash
  cd Part-A/A4-tcp-vegas-reno-congestion-window
  ns exp4.tcl
  xgraph tcp1    # TCP Vegas cwnd
  xgraph tcp2    # TCP Reno cwnd
  ```
- **Key Observation:** TCP Reno displays a classic sawtooth oscillation (loss-based AIMD), while TCP Vegas maintains a smoother congestion window by predicting buffer backlog from RTT queuing delay.

---

## Part B: Network Programming & Routing Algorithms

### Experiment 5: Bit stuffing and destuffing
- **Aim:** Write a Python program to implement bit stuffing and destuffing in the data-link layer to ensure data transparency.
- **Directory:** [`Part-B/B1-bit-stuffing/`](./Part-B/B1-bit-stuffing/)
- **File:** [`exp5.py`](./Part-B/B1-bit-stuffing/exp5.py)
- **Run Command:**
  ```bash
  python3 Part-B/B1-bit-stuffing/exp5.py
  # Input: 1011111101
  # Output: Bit Stuffed: 10111110101 | Bit Destuffed: 1011111101
  ```

---

### Experiment 6: Error detection using CRC (CRC-CCITT)
- **Aim:** Write a program for error-detecting code using CRC with generator polynomial $x^3 + x + 1$ (`[1, 0, 1, 1]`).
- **Directory:** [`Part-B/B2-crc-error-detection/`](./Part-B/B2-crc-error-detection/)
- **File:** [`exp6.py`](./Part-B/B2-crc-error-detection/exp6.py)
- **Run Command:**
  ```bash
  python3 Part-B/B2-crc-error-detection/exp6.py
  ```

---

### Experiment 7: Frame sorting technique used in buffers
- **Aim:** Partition a message into fixed-size frames, attach sequence numbers, shuffle them to simulate out-of-order network arrival, and sort using bubble sort to reconstruct the original message.
- **Directory:** [`Part-B/B3-frame-sorting/`](./Part-B/B3-frame-sorting/)
- **File:** [`exp7.py`](./Part-B/B3-frame-sorting/exp7.py)
- **Run Command:**
  ```bash
  python3 Part-B/B3-frame-sorting/exp7.py
  # Input: NMAMIT NITTE
  ```

---

### Experiment 8: File transfer using TCP sockets
- **Aim:** Client-server program using TCP/IP stream sockets where client requests a file by name and server streams back file contents.
- **Directory:** [`Part-B/B4-tcp-file-transfer/`](./Part-B/B4-tcp-file-transfer/)
- **Files:** [`tcp_server.py`](./Part-B/B4-tcp-file-transfer/tcp_server.py), [`tcp_client.py`](./Part-B/B4-tcp-file-transfer/tcp_client.py), [`sample.txt`](./Part-B/B4-tcp-file-transfer/sample.txt)
- **Run Commands (Two Terminals):**
  ```bash
  # Terminal 1:
  python3 Part-B/B4-tcp-file-transfer/tcp_server.py

  # Terminal 2:
  python3 Part-B/B4-tcp-file-transfer/tcp_client.py
  # Request: sample.txt or missing.txt
  ```

---

### Experiment 9: Calculator using UDP sockets
- **Aim:** Client-server calculator using UDP datagram sockets. Client sends two numbers and an operator (`+`, `-`, `*`, `/`, `%`), and server computes and replies with the result.
- **Directory:** [`Part-B/B5-udp-calculator/`](./Part-B/B5-udp-calculator/)
- **Files:** [`udp_server.py`](./Part-B/B5-udp-calculator/udp_server.py), [`udp_client.py`](./Part-B/B5-udp-calculator/udp_client.py)
- **Run Commands (Two Terminals):**
  ```bash
  # Terminal 1:
  python3 Part-B/B5-udp-calculator/udp_server.py

  # Terminal 2:
  python3 Part-B/B5-udp-calculator/udp_client.py
  ```

---

### Experiment 10: Distance vector routing algorithm
- **Aim:** C program implementing the Bellman-Ford distance vector routing algorithm to calculate shortest paths and output routing tables for every node.
- **Directory:** [`Part-B/B6-distance-vector-routing/`](./Part-B/B6-distance-vector-routing/)
- **File:** [`exp10.c`](./Part-B/B6-distance-vector-routing/exp10.c)
- **Run Command:**
  ```bash
  gcc -Wall -Wextra Part-B/B6-distance-vector-routing/exp10.c -o exp10
  ./exp10
  ```

---

## Quick Viva Cheat Sheet

### Network Simulation & NS-2
1. **What is NS-2 and why does it use two languages?**
   - NS-2 is an event-driven network simulator. It pairs **C++** (for per-packet byte manipulation and fast event processing) with **OTcl** (for rapid topology scripting and parameter modification without recompilation).
2. **What are the trace events in an NS-2 trace file?**
   - `+` = Packet entered queue (enqueue)
   - `-` = Packet departed queue (dequeue)
   - `r` = Packet received at destination
   - `d` = Packet dropped due to full queue or channel error
3. **What is the difference between DropTail and RED?**
   - **DropTail:** Discards newly arriving packets only when the buffer is completely full.
   - **RED (Random Early Detection):** Discards packets with a calculated probability before buffer saturation to signal early congestion to TCP sources.

### Data Link Layer & Framing
1. **Why do we need bit stuffing?**
   - To provide data transparency. Without bit stuffing, user payload identical to frame flags (`01111110`) would be falsely recognized as end-of-frame delimiters.
2. **How does CRC handle error detection?**
   - Transmitter appends $r$ checksum bits generated by modulo-2 division of $D(x) \cdot x^r$ by $G(x)$. The receiver divides the received codeword by $G(x)$; a non-zero remainder proves transmission error.

### Socket Programming
1. **Explain the difference between TCP and UDP sockets.**
   - **TCP (`SOCK_STREAM`):** Connection-oriented, guarantees ordered and error-free byte streams, performs 3-way handshake, handles retransmissions and flow control.
   - **UDP (`SOCK_DGRAM`):** Connectionless, sends independent datagrams without handshake, unconfirmed delivery, minimal overhead, preserves packet boundaries.
2. **What does `accept()` do in TCP?**
   - `accept()` extracts the first connection on the queue of pending connections, creates a new socket file descriptor dedicated to that client, and leaves the listening socket free to accept subsequent incoming connections.

### Routing
1. **What is the Bellman-Ford equation?**
   - $D_x(y) = \min_v \{ c(x, v) + D_v(y) \}$, finding the minimum cost path to destination $y$ by minimizing the sum of the direct link cost to neighbor $v$ and $v$'s distance to $y$.
2. **How do protocols prevent Count-to-Infinity in Distance Vector?**
   - Using **Split Horizon** (never advertise routes back to the neighbor they were learned from) and **Poison Reverse** (advertising such routes with cost $\infty$).

---

## Troubleshooting & Common Errors

1. **`nam: no display name and no $DISPLAY environment variable`**
   - NAM requires an active X11 graphical display. On macOS, start XQuartz. On headless Linux/WSL, set `export DISPLAY=:0` or run simulation scripts without launching NAM (`out.tr` trace files are unaffected).
2. **`xgraph: command not found`**
   - Install via `sudo apt install xgraph`. Alternatively, use Python (`matplotlib`) to plot the generated columns in `plot_throughput`, `tcp1`, and `tcp2`.
3. **`OSError: [Errno 48] Address already in use`**
   - Occurs when the socket's port is held in kernel `TIME_WAIT`. Ensure `server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)` is invoked before `bind()`.
4. **`ConnectionRefusedError` in TCP Client**
   - The server process is not actively running or not yet in the `listen()` state. Ensure `python3 tcp_server.py` is running before launching `tcp_client.py`.

---

## Comprehensive Network Theory & Architecture Guide

For deep technical dives into packet trace formats, queuing theory, TCP Reno vs Vegas congestion algorithms, Galois field modulo-2 division proofs, and routing convergence bounds, see the full theoretical companion:

👉 **[WALKTHROUGH.md](./WALKTHROUGH.md)**
