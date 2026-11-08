# Computer Networks & Communication Laboratory: Comprehensive Walkthrough & Theory Guide

This guide provides an end-to-end technical walkthrough of the network protocols, simulation paradigms, socket programming architectures, and routing algorithms implemented in the **Computer Networks Laboratory (Academic Year 2026–27)**.

---

## Table of Contents
1. [Architecture of Network Simulator 2 (NS-2)](#1-architecture-of-network-simulator-2-ns-2)
2. [NS-2 Trace File Mechanics & Packet Flow Lifecycle](#2-ns-2-trace-file-mechanics--packet-flow-lifecycle)
3. [TCP vs UDP Dynamics & Congestion Control (Reno vs Vegas)](#3-tcp-vs-udp-dynamics--congestion-control-reno-vs-vegas)
4. [CSMA/CD & Shared Ethernet LAN Emulation](#4-csmacd--shared-ethernet-lan-emulation)
5. [Data Link Layer Framing: Bit Stuffing & Transparency](#5-data-link-layer-framing-bit-stuffing--transparency)
6. [Cyclic Redundancy Check (CRC-CCITT) Polynomial Mathematics](#6-cyclic-redundancy-check-crc-ccitt-polynomial-mathematics)
7. [Packet Fragmentation & Buffer Reassembly Algorithms](#7-packet-fragmentation--buffer-reassembly-algorithms)
8. [Berkeley Sockets Architecture: Stream (TCP) vs Datagram (UDP)](#8-berkeley-sockets-architecture-stream-tcp-vs-datagram-udp)
9. [Distance Vector Routing & Bellman-Ford Convergence](#9-distance-vector-routing--bellman-ford-convergence)
10. [Troubleshooting & Protocol Debugging Guide](#10-troubleshooting--protocol-debugging-guide)

---

## 1. Architecture of Network Simulator 2 (NS-2)

### The Dual-Language Paradigm (C++ / OTcl Duality)
NS-2 utilizes a split-level software architecture to balance raw execution performance against rapid scenario scripting:

```
+-----------------------------------------------------------+
|                      User Simulation                      |
|                  (OTcl Script: exp1.tcl)                  |
+-----------------------------+-----------------------------+
                              |
                    TclCL Linkage Layer
              (TclClass, TclObject, bind())
                              |
==============================v==============================
                 C++ SIMULATION ENGINE (Core)
==============================+==============================
      Packet Processing  |  Event Scheduler  |  Protocols
      (DropTail Queue)   |  (Calendar/Heap)  |  (TCP, UDP)
```

1. **C++ (Data Plane / Fast Execution):**
   - High-frequency per-packet operations, queue packet queuing/dequeuing, checksumming, bit manipulation, and timer firing are implemented in compiled C++ for maximum throughput.
2. **OTcl - Object Tcl (Control Plane / Rapid Configuration):**
   - Topology configuration, node creation, link delay/bandwidth definition, parameter tuning, and event scheduling are written in Object Tcl.
3. **TclCL (C++ to Tcl Interface):**
   - Glues the C++ classes and OTcl objects together, mirroring C++ member variables (e.g., `cwnd_`, `packetSize_`) to OTcl variables so scripts can trace or modify them at runtime.

---

## 2. NS-2 Trace File Mechanics & Packet Flow Lifecycle

When `$ns trace-all $tf` is invoked, NS-2 records every significant packet event into a 12-column text file:

```
+  0.500000  0  1  cbr  500  -------  0  0.0  2.0  0  0
-  0.500000  0  1  cbr  500  -------  0  0.0  2.0  0  0
r  0.510000  0  1  cbr  500  -------  0  0.0  2.0  0  0
d  1.230400  1  2  cbr  500  -------  0  0.0  2.0  131  131
```

### Trace Field Breakdown
| Field Index | Field Name | Description |
|:---:|:---|:---|
| **`$1`** | Event Type | `+` (enqueued), `-` (dequeued), `r` (received), `d` (dropped) |
| **`$2`** | Time | Event timestamp in floating-point seconds |
| **`$3`** | From Node | Source node ID of the traversed link |
| **`$4`** | To Node | Destination node ID of the traversed link |
| **`$5`** | Packet Type | Payload protocol (`cbr`, `tcp`, `ack`, `udp`) |
| **`$6`** | Packet Size | Size of packet in bytes (including protocol headers) |
| **`$7`** | Flags | 7-character flag field (e.g., `-------`, `E` for ECN) |
| **`$8`** | Flow ID | IP flow identifier (`fid`) assigned in Tcl script |
| **`$9`** | Source Addr | Node and port address of traffic generator (`node.port`) |
| **`$10`** | Dest Addr | Node and port address of traffic sink (`node.port`) |
| **`$11`** | Sequence # | Transport protocol sequence number |
| **`$12`** | Packet ID | Global monotonically increasing packet counter |

### Packet Drop Mechanics (`exp1.awk`)
In DropTail queues, packets accumulate up to `queue-limit`. If an incoming packet arrives when buffer occupancy equals the limit, the packet cannot be queued:
```awk
if ($1 == "d") {
    count++;
    printf("%s\t %s\n", $5, $11);
}
```
Filtering lines starting with `d` extracts exact dropped packet IDs and total drop counts.

---

## 3. TCP vs UDP Dynamics & Congestion Control (Reno vs Vegas)

### TCP (Transmission Control Protocol)
- **Connection-Oriented:** Requires a 3-Way Handshake (`SYN`, `SYN-ACK`, `ACK`).
- **Reliable Stream:** Sliding window, sequence numbering, cumulative ACKs, and timeouts.
- **Congestion Controlled:** Throttles transmission dynamically using Additive Increase Multiplicative Decrease (AIMD).

### UDP (User Datagram Protocol)
- **Connectionless & Unreliable:** Fires datagrams with minimal 8-byte header overhead.
- **Inelastic:** Generates packets at a constant rate (CBR) regardless of link congestion. When competing with TCP over a bottleneck link (as demonstrated in Experiment 2), unyielding UDP traffic saturates router queues, causing TCP to suffer drops and repeatedly slash its congestion window.

### TCP Reno vs TCP Vegas (Experiment 4)

```
Congestion Window (cwnd)
  ^
  |        TCP Reno (Sawtooth, Loss-based)
  |            /\      /\
  |           /  \    /  \
  |          /    \  /    \
  |         /      \/      \
  |        /----------------\---- TCP Vegas (Smooth, Delay-based)
  |       /
  +-------------------------------------> Time (s)
```

| Parameter | TCP Reno | TCP Vegas |
|---|---|---|
| **Congestion Detection** | **Loss-based:** Senses congestion only *after* buffer overflow causes packet loss | **Delay-based:** Measures Round Trip Time ($RTT$) queuing delay *before* packets drop |
| **Window Adjustment** | Linear growth during Congestion Avoidance ($+1$ MSS/RTT); halves window on loss | Compares Expected vs Actual throughput; adjusts window to keep queue between $\alpha$ and $\beta$ |
| **Throughput Stability** | Oscillating sawtooth curve | Smooth, stable, near-optimal queue occupancy |
| **Fairness / Competition**| Aggressive; steals buffer capacity from Vegas | Conservative; backs off early when competing with Reno |

#### TCP Vegas Delay Equations:
$$\text{Expected Throughput} = \frac{cwnd}{RTT_{\min}}$$
$$\text{Actual Throughput} = \frac{cwnd}{RTT}$$
$$\text{Diff} = \text{Expected} - \text{Actual} = cwnd \times \left(1 - \frac{RTT_{\min}}{RTT}\right)$$
- If $\text{Diff} < \alpha$, increase $cwnd$ linearly.
- If $\text{Diff} > \beta$, decrease $cwnd$ linearly.
- If $\alpha \le \text{Diff} \le \beta$, keep $cwnd$ constant.

---

## 4. CSMA/CD & Shared Ethernet LAN Emulation

In Experiments 3 and 4, NS-2 emulates an IEEE 802.3 broadcast medium using:
```tcl
$ns make-lan "$n1 $n2 $n3 $n4 $n5 $n6" 2Mb 40ms LL Queue/DropTail Mac/802_3
```
- **Carrier Sense Multiple Access with Collision Detection (CSMA/CD):**
  - **1-Persistent CSMA:** Transmits immediately if channel is idle; senses channel continuously if busy.
  - **Collision Detection:** Transmitters compare transmitted signal with line voltage. On mismatch, a collision is detected.
  - **Jamming Signal:** When a collision occurs, the transmitting node transmits a 32-to-48 bit jam signal so all nodes register the collision.
  - **Truncated Binary Exponential Backoff:** The node chooses a random wait slot $k \in [0, 2^n - 1]$ before retransmitting, where $n = \min(\text{collision count}, 10)$.

---

## 5. Data Link Layer Framing: Bit Stuffing & Transparency

In synchronous transmission links (HDLC, PPP, SDLC), frames are bounded by the 8-bit flag sequence:
$$\text{Flag} = 01111110_2 \quad (0x7E)$$

```
+------------+---------------------------+------------+
| Flag (0x7E)|     Stuffed Payload       | Flag (0x7E)|
|  01111110  |  1 0 1 1 1 1 1 [0] 1 0 1  |  01111110  |
+------------+---------------------------+------------+
```

### The 5-Consecutive-Ones Rule:
1. **Transmitter:** Whenever 5 consecutive `1`s are encountered in the input bit stream, a `0` bit is unconditionally inserted (stuffed) after the fifth `1`.
2. **Receiver:** Scans the incoming bit stream. Whenever 5 consecutive `1`s are observed:
   - If the 6th bit is `0`, it is a stuffed bit $\to$ **drop it**.
   - If the 6th bit is `1` and the 7th bit is `0`, it is a **flag delimiter** ($01111110$) $\to$ **end of frame**.
   - If the 6th and 7th bits are `1` ($01111111$), an illegal error state occurred $\to$ **abort frame**.

---

## 6. Cyclic Redundancy Check (CRC-CCITT) Polynomial Mathematics

Cyclic Redundancy Check is an algebraic error-detecting code based on polynomial arithmetic over Galois Field $GF(2)$.

### Modulo-2 Arithmetic Properties:
- In $GF(2)$, binary addition and subtraction are identical and equivalent to bitwise XOR:
  $$1 \oplus 1 = 0, \quad 1 \oplus 0 = 1, \quad 0 \oplus 1 = 1, \quad 0 \oplus 0 = 0$$
- There are no carries or borrows.

### Encoding Procedure:
Let data bit string be represented by polynomial $D(x)$ of $k$ bits, and generator polynomial be $G(x)$ of degree $r = m - 1$:
1. Append $r$ zero bits to $D(x)$, yielding $D(x) \cdot x^r$.
2. Divide $D(x) \cdot x^r$ by $G(x)$ using modulo-2 division:
   $$\frac{D(x) \cdot x^r}{G(x)} = Q(x) + \frac{R(x)}{G(x)}$$
3. Subtract (XOR) remainder $R(x)$ from $D(x) \cdot x^r$:
   $$T(x) = D(x) \cdot x^r \oplus R(x)$$
   $T(x)$ is the transmitted codeword.

### Mathematical Proof of Error Detection:
The receiver receives $T'(x) = T(x) \oplus E(x)$, where $E(x)$ represents error bits:
$$\frac{T'(x)}{G(x)} = \frac{T(x) \oplus E(x)}{G(x)} = \frac{T(x)}{G(x)} \oplus \frac{E(x)}{G(x)} = 0 \oplus \frac{E(x)}{G(x)}$$
The error goes undetected **if and only if** $E(x)$ is an exact multiple of generator $G(x)$. Choosing standard polynomials like CRC-CCITT guarantees detection of:
- All single-bit and double-bit errors
- Any odd number of inverted bits
- Any burst error of length $\le r$ bits

---

## 7. Packet Fragmentation & Buffer Reassembly Algorithms

In packet-switched store-and-forward networks:
1. Senders fragment large application layer messages into smaller protocol data units (PDUs) capped by the Maximum Transmission Unit (MTU).
2. Each PDU receives an integer sequence number.
3. Routers forward packets independently over dynamic paths, causing jitter and out-of-order arrival.
4. The receiver maintains a reassembly buffer queue, orders packets monotonically (demonstrated via bubble sort in Experiment 7), and passes the contiguous byte stream up to the application.

---

## 8. Berkeley Sockets Architecture: Stream (TCP) vs Datagram (UDP)

```
        TCP (SOCK_STREAM)                           UDP (SOCK_DGRAM)
    Server              Client                  Server              Client
  socket()             socket()                socket()            socket()
     |                    |                       |                   |
  bind()                  |                    bind()                 |
     |                    |                       |                   |
  listen()                |                       |                   |
     |                    |                       |                   |
  accept() <----------- connect()                 |                   |
     |   (3-Way Handshake)|                       |                   |
     |                    |                       |                   |
  recv()   <----------- send()                 recvfrom() <-------- sendto()
  send()   -----------> recv()                 sendto()   --------> recvfrom()
     |                    |                       |                   |
  close()  <----------- close()                close()             close()
```

### Critical Implementation Safeguards:
- **`SO_REUSEADDR`:** Prevents `Address already in use` error when restarting a server whose bound port is in the kernel's `TIME_WAIT` state.
- **Client Socket Timeout:** UDP clients must invoke `client_socket.settimeout(seconds)` to prevent deadlocking indefinitely if a server goes down or request/reply datagrams are dropped.
- **Chunked File Streaming:** Sending large files across TCP should use a fixed buffer chunk loop (`recv(1024)`) until `recv()` returns empty bytes `b""` (indicating TCP `FIN` received).

---

## 9. Distance Vector Routing & Bellman-Ford Convergence

Distance Vector Routing is a distributed formulation of the Bellman-Ford dynamic programming algorithm.

### The Routing Equation:
For node $x$ wishing to reach node $y$ through adjacent neighbor $v$:
$$D_x(y) = \min_v \left\{ c(x, v) + D_v(y) \right\}$$
- $c(x, v)$ is the direct link cost from $x$ to neighbor $v$.
- $D_v(y)$ is neighbor $v$'s advertised shortest distance to destination $y$.

### Convergence & Iteration Bound:
For a network with $n$ routers, the longest simple path contains at most $n - 1$ edges. Thus, after $n - 1$ rounds of distance-vector updates, the routing tables of all routers are guaranteed to converge to the global optimal shortest path.

### The Count-to-Infinity Problem:
If a link between $A$ and $B$ fails, $A$ and $C$ may form a routing loop, iteratively incrementing costs: $C$ routes to $B$ via $A$ ($dist = 2$), $A$ routes to $B$ via $C$ ($dist = 3$), $C$ routes via $A$ ($dist = 4$), escalating until the infinity threshold is reached ($\infty = 16$ in RIP).
- **Remedies:** Split Horizon (never advertise a learned route back to the source), Poison Reverse (advertise the route back with distance $\infty$), and hold-down timers.

---

## 10. Troubleshooting & Protocol Debugging Guide

| Issue / Error | Root Cause | Solution |
|---|---|---|
| `nam: no display name and no $DISPLAY environment variable` | Running NAM in a headless SSH session or macOS terminal without X11 / XQuartz | Install and start XQuartz on macOS or run in an environment with an active X11 display server. Trace files (`out.tr`) remain fully valid without running NAM. |
| `xgraph: command not found` | Xgraph package not installed in the current environment | Install via package manager (`sudo apt install xgraph`) or plot coordinates with Gnuplot/Python Matplotlib. |
| `OSError: [Errno 48] Address already in use` | Previous TCP server instance was terminated and socket remains in `TIME_WAIT` | Ensure `server_socket.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)` is called before `bind()`. |
| `ConnectionRefusedError: [Errno 111] Connection refused` | Client attempted `connect()` before server completed `listen()` | Verify that `tcp_server.py` is actively running in a separate terminal before executing `tcp_client.py`. |
| `socket.timeout: timed out` on UDP client | Server is offline or packet was dropped on network interface | Check that `udp_server.py` is running on matching port (`20001`) and host (`127.0.0.1`). |
