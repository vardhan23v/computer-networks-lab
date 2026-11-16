# Experiment 4: Ethernet LAN: Congestion Window of TCP Vegas and Reno

## 🎯 Aim & Objective
Simulate an Ethernet LAN using $N$ nodes (9 nodes: `n0` to `n8`) with multiple traffic sources. Determine collisions across different nodes, trace the evolution of the congestion window (`cwnd_`) for TCP Vegas and TCP Reno, and compare their delay-based vs loss-based congestion control dynamics using Xgraph.

---

## 📦 Required Tools & Simulation Parameters

| Component | Specification |
|---|---|
| **Simulator** | NS-2 (`ns` v2.35) |
| **Trace Analysis** | AWK (`exp4.awk` for parsing `cwnd_` trace files) |
| **Graphing Tool** | Xgraph (`xgraph tcp1`, `xgraph tcp2`) |
| **Topology** | 9 Nodes: Sender `n1` (Vegas), Sender `n2` (Reno), Concentrator `n0`, LAN Interface `n3`, LAN Members `n4`..`n8` (`n7` Vegas Sink, `n8` Reno Sink) |
| **Access Links** | `n1-n0`: 2 Mbps, 10ms; `n2-n0`: 2 Mbps, 10ms |
| **Bottleneck Link** | `n0-n3`: 1 Mbps, 20ms, Queue limit: 20 |
| **LAN Bus** | Multi-access `Mac/802_3`, 512 Kbps, 40ms delay |
| **TCP Variants** | `Agent/TCP/Vegas` (delay-based) vs `Agent/TCP/Reno` (loss-based AIMD) |
| **Packet Size** | 55 bytes |
| **Trace Targets** | `cwnd1.tr` (TCP Vegas) and `cwnd2.tr` (TCP Reno) |

---

## 📂 Files in this Experiment

- [`exp4.tcl`](./exp4.tcl) - Simulation script setting up dual TCP Vegas & Reno flows into a shared Ethernet LAN.
- [`exp4.awk`](./exp4.awk) - AWK script filtering timestamp and congestion window values (`cwnd_`).

---

## 🛠 Execution Instructions

```bash
# 1. Run NS-2 simulation (generates exp4.nam, cwnd1.tr, cwnd2.tr and invokes exp4.awk to create tcp1 and tcp2)
ns exp4.tcl

# 2. Plot congestion window for TCP Vegas
xgraph tcp1

# 3. Plot congestion window for TCP Reno
xgraph tcp2

# 4. View sample cwnd values
head -4 tcp1; tail -2 tcp1
head -4 tcp2; tail -2 tcp2
```

---

## 🔍 Code Walkthrough

### 1. TCP Vegas vs TCP Reno Congestion Control Mechanisms
- **TCP Reno (Loss-Based AIMD):**
  - **Additive Increase:** In congestion avoidance, increases $cwnd$ by $1 \text{ MSS}$ per RTT.
  - **Multiplicative Decrease:** Continues increasing until packet drop occurs (buffer overflow). On packet drop (detected by 3 duplicate ACKs), halves $cwnd$ ($cwnd = cwnd / 2$).
  - Results in classic "sawtooth" curve.
- **TCP Vegas (Delay-Based Predictive):**
  - Measures Round Trip Time ($RTT$) and compares actual throughput with expected throughput:
    $$\text{Expected} = \frac{cwnd}{RTT_{\min}}, \quad \text{Actual} = \frac{cwnd}{RTT}$$
    $$\text{Diff} = \text{Expected} - \text{Actual} = cwnd \times \left(1 - \frac{RTT_{\min}}{RTT}\right)$$
  - Adjusts $cwnd$ linearly before packet drops happen to keep queue occupancy between thresholds $\alpha$ and $\beta$.
  - Generates smoother, proactive window adjustments.

### 2. Tracing the Congestion Window in NS-2
```tcl
set tfile1 [open cwnd1.tr w]
$tcp1 attach $tfile1
$tcp1 trace cwnd_
```
- Informs the TCP C++ agent to record every change in the `cwnd_` variable into the designated trace file.

### 3. AWK Filtering Logic (`exp4.awk`)
- Parses records looking for `$6 == "cwnd_"`.
- Extracts timestamp `$1` and new congestion window value `$7`.

---

## 🧪 Expected Output

```text
$ ns exp4.tcl
$ xgraph tcp1
$ xgraph tcp2
$ head -4 tcp1; tail -2 tcp1
0.000000	 1.000000
0.946450	 2.000000
0.946450	 3.000000
1.392900	 4.000000
...
5.483430	 1.000000
5.483430	 2.000000
```

---

## 💡 Viva Questions & Key Takeaways

1. **What is the fundamental difference between TCP Reno and TCP Vegas?**
   - TCP Reno is **reactive** and **loss-based**: it drives the network into packet loss/queue overflow before reacting and halving its window.
   - TCP Vegas is **proactive** and **delay-based**: it measures RTT increases to anticipate congestion and adjusts the window before buffers overflow and packets drop.
2. **What is `cwnd_` in NS-2?**
   - `cwnd_` is the internal state variable representing the Congestion Window (in terms of segments/MSS) that dictates how many unacknowledged packets the TCP sender may transmit.
3. **Why does TCP Vegas get lower bandwidth when competing with TCP Reno?**
   - TCP Vegas backs off early upon detecting queuing delay, whereas aggressive TCP Reno continues expanding its window until packets are dropped, thereby monopolizing shared buffer capacity.
4. **What is the role of `Agent/TCPSink` in this experiment?**
   - Node `n7` runs the TCPSink for Vegas, and node `n8` runs the TCPSink for Reno. They generate cumulative ACKs and trigger RTT calculation.
