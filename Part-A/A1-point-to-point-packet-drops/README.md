# Experiment 1: Point-to-Point Network: Packet Drops

## 🎯 Aim & Objective
Simulate a three-node point-to-point network with duplex links between them using NS-2 (Network Simulator 2). Set the queue size, vary the link bandwidth, and determine the number of packets dropped using an AWK script.

---

## 📦 Required Tools & Simulation Parameters

| Component | Specification |
|---|---|
| **Simulator** | NS-2 (`ns` v2.35) |
| **Animator** | NAM (Network Animator) |
| **Trace Analysis** | AWK (GNU Awk / POSIX Awk) |
| **Network Topology** | 3 Nodes (`n0` — `n1` — `n2`) |
| **Queue Management** | DropTail (FIFO queue) |
| **Queue Limit** | 50 packets |
| **Traffic Source** | UDP Agent with CBR (Constant Bit Rate) Application |
| **Packet Size & Interval**| 500 bytes, 0.005s (200 pkts/sec = 800 Kbps) |
| **Default Link Parameters** | Link `n0-n1`: 1 Mbps, 10ms delay; Link `n1-n2`: 1 Mbps, 10ms delay |
| **Bottleneck Link Parameters** | Link `n1-n2`: Changed to 0.5 Mbps to induce packet drops |

---

## 📂 Files in this Experiment

- [`exp1.tcl`](./exp1.tcl) - OTcl simulation script setting up topology, agents, traffic, and trace files.
- [`exp1.awk`](./exp1.awk) - AWK script filtering `d` (drop) events from `out.tr` and tallying dropped packets.

---

## 🛠 Execution Instructions

```bash
# 1. Run the NS-2 simulation script
ns exp1.tcl

# 2. Parse trace file to count packet drops with standard 1Mb bandwidth
awk -f exp1.awk out.tr

# 3. Modify link n1-n2 bandwidth to 0.5Mb to observe packet congestion and drops:
# In exp1.tcl, line 29: change '1Mb' to '0.5Mb'
# $ns duplex-link $n1 $n2 0.5Mb 10ms DropTail
ns exp1.tcl
awk -f exp1.awk out.tr
```

---

## 🔍 Code Walkthrough

### 1. NS-2 Simulation Script (`exp1.tcl`)
- **Simulator Initialization:** `set ns [new Simulator]` instantiates the event scheduler.
- **Trace & NAM File Binding:**
  - `out.nam` records animation events for NAM visualization via `$ns namtrace-all $nf`.
  - `out.tr` logs discrete simulation packet events via `$ns trace-all $tf`.
- **Node & Link Creation:**
  - Nodes `n0`, `n1`, `n2` are created via `$ns node`.
  - Duplex links are established with DropTail queues.
- **Agent Attachment:**
  - `Agent/UDP` attached to node `n0` acts as the unacknowledged transport source.
  - `Agent/Null` attached to node `n2` serves as the packet sink.
- **CBR Traffic Generator:**
  - Configured with `packetSize_ = 500 bytes` and `interval_ = 0.005 seconds`.
  - Rate = $\frac{500 \times 8 \text{ bits}}{0.005 \text{ s}} = 800 \text{ Kbps}$.
- **Bottleneck Analysis:**
  - At 1 Mbps bandwidth, link capacity (1000 Kbps) exceeds CBR traffic (800 Kbps), so 0 drops occur.
  - When link `n1-n2` bandwidth is reduced to 0.5 Mbps (500 Kbps), incoming traffic rate (800 Kbps) exceeds outgoing rate (500 Kbps). Packets accumulate in node `n1`'s queue; once the 50-packet limit is exceeded, DropTail drops excess packets.

### 2. AWK Trace Analyzer (`exp1.awk`)
- Column 1 (`$1`): Event type (`+` enqueue, `-` dequeue, `r` receive, `d` drop).
- Column 5 (`$5`): Packet type (`cbr`).
- Column 11 (`$11`): Unique packet ID.
- The condition `if ($1 == "d")` increments `count` on every drop and prints the packet type and ID.

---

## 🧪 Expected Output

### Case 1: Standard Bandwidth (1 Mbps on both links)
```text
$ ns exp1.tcl
$ awk -f exp1.awk out.tr
The number of packets dropped =0
```

### Case 2: Bottleneck Bandwidth (0.5 Mbps on link n1-n2)
```text
$ ns exp1.tcl
$ awk -f exp1.awk out.tr
cbr	 131
cbr	 134
cbr	 136
cbr	 139
...
The number of packets dropped =252
```

---

## 💡 Viva Questions & Key Takeaways

1. **What is DropTail queue management?**
   - DropTail is a passive queue management algorithm where incoming packets are enqueued at the tail of the buffer until capacity is reached. When full, any subsequent arriving packet is dropped until space frees up.
2. **Why does packet drop occur when bandwidth is reduced to 0.5 Mbps?**
   - The CBR traffic generator injects 800 Kbps of data into the network at `n0`. Link `n1-n2` can only drain data at 500 Kbps. The excess 300 Kbps overflows the 50-packet queue limit at node `n1`, causing packet drops.
3. **What is the difference between trace file (`out.tr`) and NAM trace file (`out.nam`)?**
   - `out.tr` is a textual event log detailing timestamps, source, destination, protocol, packet sizes, and drop events for performance analysis.
   - `out.nam` is a specialized topology and packet animation descriptor used by the graphical Network Animator (NAM).
4. **Why is `Agent/Null` paired with `Agent/UDP`?**
   - UDP is a connectionless, non-acknowledging protocol. `Agent/Null` acts as a traffic sink that silently accepts and frees UDP packets without transmitting ACK packets back to the source.
