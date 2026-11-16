# Experiment 3: Ethernet LAN: Throughput versus Data Rate and Error Rate

## 🎯 Aim & Objective
Simulate an Ethernet Local Area Network (LAN) using $N$ nodes (6–10 nodes) using IEEE 802.3 CSMA/CD MAC protocol in NS-2. Introduce an error model on the communication link, vary data rates and error rates, and analyze the resulting TCP throughput.

---

## 📦 Required Tools & Simulation Parameters

| Component | Specification |
|---|---|
| **Simulator** | NS-2 (`ns` v2.35) |
| **Trace Analysis** | AWK (`exp3.awk`) |
| **Graphing Tool** | Xgraph (`xgraph exp3.graph`) |
| **Nodes** | 7 Nodes total (`n0` external sender; `n1` to `n6` participating in LAN) |
| **LAN Standard** | IEEE 802.3 Ethernet (`Mac/802_3`, `LL`, `Queue/DropTail`) |
| **LAN Bandwidth & Delay** | 2 Mbps bandwidth, 40ms propagation delay |
| **Access Link** | `n0-n1`: 3 Mbps bandwidth, 20ms delay |
| **Transport / App** | `Agent/TCP` (node `n0`) to `Agent/TCPSink` (node `n6`) with `Application/FTP` |
| **Error Model** | `ErrorModel` on link `n0-n1`, packet unit (`pkt`), uniform random variable, rate = 0.01 (1% loss) |

---

## 📂 Files in this Experiment

- [`exp3.tcl`](./exp3.tcl) - Simulation script creating the hybrid point-to-point and CSMA/CD Ethernet LAN topology with an ErrorModel.
- [`exp3.awk`](./exp3.awk) - AWK script computing the throughput curve over time and saving to `exp3.graph`.

---

## 🛠 Execution Instructions

```bash
# 1. Run the NS-2 simulation (automatically generates exp3.nam and exp3.graph)
ns exp3.tcl

# 2. Plot throughput graph using Xgraph
xgraph exp3.graph

# 3. View the beginning and end throughput entries
head -3 exp3.graph; tail -2 exp3.graph

# 4. Compare effect of error rate:
# Set rate_ to 0.00 (lossless) vs 0.01 vs 0.05 in exp3.tcl to observe TCP throughput degradation.
```

---

## 🔍 Code Walkthrough

### 1. Ethernet LAN Creation (`make-lan`)
```tcl
$ns make-lan "$n1 $n2 $n3 $n4 $n5 $n6" 2Mb 40ms LL Queue/DropTail Mac/802_3
```
- Creates a shared multi-access broadcast bus linking `n1` through `n6`.
- **LL (Link Layer):** Provides link-layer framing and ARP functionality.
- **Mac/802_3:** Emulates standard Ethernet CSMA/CD (Carrier Sense Multiple Access with Collision Detection).
- **Queue/DropTail:** DropTail buffer associated with the LAN channel interface.

### 2. Error Model Injection
```tcl
set em [new ErrorModel]
$em unit pkt
$em set rate_ 0.01
$em ranvar [new RandomVariable/Uniform]
$em drop-target [new Agent/Null]
$ns lossmodel $em $n0 $n1
```
- Injects simulated packet corruption/loss onto the link between `n0` and `n1`.
- `rate_ 0.01`: Drops 1% of traversing packets uniformly at random.
- Packets marked as corrupt are routed to `drop-target` (`Agent/Null`), triggering retransmission timeouts or duplicate ACKs in TCP.

### 3. Impact of Error Rate on TCP
- Unlike UDP, TCP interprets packet loss as an indicator of network congestion.
- Even at a mild random error rate of 1%, TCP Reno/NewReno frequently enters fast retransmit/recovery or drops into slow start ($cwnd \to 1$), significantly pulling down overall throughput.

---

## 🧪 Expected Output

```text
$ ns exp3.tcl
$ xgraph exp3.graph
$ head -3 exp3.graph; tail -2 exp3.graph
1.000000	 -0.00
1.000000	 -0.00
1.020107	 15.91
...
5.202373	 1328.39
5.206637	 1327.12
```

---

## 💡 Viva Questions & Key Takeaways

1. **What command is used to configure an Ethernet LAN in NS-2?**
   - The `$ns make-lan <nodelist> <bw> <delay> <ll> <ifq> <mac>` command creates a local area network abstraction using a shared broadcast channel.
2. **What MAC protocol does `Mac/802_3` represent?**
   - IEEE 802.3 Ethernet CSMA/CD (Carrier Sense Multiple Access with Collision Detection). Nodes listen before transmitting (carrier sense) and detect collisions during transmission to invoke exponential backoff.
3. **How does an `ErrorModel` affect TCP performance?**
   - TCP cannot differentiate between packet losses caused by channel noise/corruption versus buffer overflow congestion. Consequently, random packet loss triggers unnecessary TCP congestion window halving, drastically lowering throughput.
4. **Why is data rate on the LAN link (2Mb) lower than the point-to-point link (3Mb)?**
   - It represents an access network bottleneck feeding into an intranet or switch, demonstrating queue contention and frame delivery delays over shared media.
