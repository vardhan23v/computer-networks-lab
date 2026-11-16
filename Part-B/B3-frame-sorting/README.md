# Experiment 7: Frame Sorting Technique Used in Buffers

## 🎯 Aim & Objective
Write a Python program to demonstrate the **Frame Sorting Technique** utilized in receiver buffers of the Data Link and Transport Layers (e.g., TCP reassembly queue). The program partitions a continuous message into fixed-size chunks, assigns sequence numbers, randomly shuffles the frames to simulate out-of-order transmission across an IP network, and sorts the buffer to reconstruct the original stream.

---

## 📦 Required Tools & Specifications

| Component | Specification |
|---|---|
| **Language** | Python 3 |
| **Chunk Size (`DATA_SZ`)** | 3 characters per frame |
| **Sequencing Mechanism** | 1-based sequential integers paired as tuples: `(seq_num, payload)` |
| **Disorder Simulation** | Random in-place index permutation via `random.randint()` |
| **Sorting Algorithm** | Bubble Sort (`bubb_sort()`) ordering frames by sequence number |
| **Reassembly** | String concatenation (`"".join(...)`) over ordered buffer payloads |

---

## 📂 Files in this Experiment

- [`exp7.py`](./exp7.py) - Complete Python implementation of message fragmentation, shuffling, buffer sorting, and reassembly.

---

## 🛠 Execution Instructions

```bash
# Run the Python script
python3 exp7.py

# When prompted, enter a message:
Enter the message:NMAMIT NITTE
```

---

## 🔍 Code Walkthrough

### 1. Fragmentation & Sequencing
```python
msg_chunks = [msg[i:i + DATA_SZ] for i in range(0, len(msg), DATA_SZ)]
frames = list(enumerate(msg_chunks, start=1))
```
- Divides input string into fixed chunks of length 3 (`DATA_SZ`).
- Pairs each chunk with a sequence number starting from 1 using `enumerate(..., start=1)`.
- For `NMAMIT NITTE`:
  - `(1, 'NMA')`, `(2, 'MIT')`, `(3, ' NI')`, `(4, 'TTE')`.

### 2. Simulating Out-of-Order Channel Delivery
```python
for i in range(len(frames)):
    j = random.randint(0, len(frames) - 1)
    frames[i], frames[j] = frames[j], frames[i]
```
- In packet-switched networks (such as IP networks), packets may take divergent paths with variable delays, causing out-of-order arrivals.
- Random index swapping simulates this non-deterministic packet arrival at the receiver.

### 3. Buffer Sorting & Stream Reconstruction
```python
def bubb_sort(arr):
    n = len(arr)
    for i in range(n):
        for j in range(n - i - 1):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
```
- Compares tuple `arr[j]` with `arr[j + 1]`. In Python, tuples compare element-by-element starting with the sequence number.
- Once sorted, `"".join(x[1] for x in frames)` concatenates payloads in guaranteed monotonic order.

---

## 🧪 Expected Output

```text
$ python3 exp7.py
Enter the message:NMAMIT NITTE
Fragmented frames: [(1, 'NMA'), (2, 'MIT'), (3, ' NI'), (4, 'TTE')]
Shuffled frames: [(2, 'MIT'), (3, ' NI'), (1, 'NMA'), (4, 'TTE')]
Sorted frames: [(1, 'NMA'), (2, 'MIT'), (3, ' NI'), (4, 'TTE')]
Sorted message:NMAMIT NITTE
```

---

## 💡 Viva Questions & Key Takeaways

1. **Why do packets arrive out of order in computer networks?**
   - In datagram networks (like IP), packets between the same source and destination are routed independently over dynamically varying paths with different routing hops, link loads, and propagation delays.
2. **At what OSI layer does frame/packet reordering happen?**
   - Transport Layer (e.g., TCP using 32-bit byte sequence numbers) and Data Link Layer (in sliding window protocols like Selective Repeat ARQ).
3. **What is the consequence of missing frames during reassembly?**
   - In Go-Back-N or TCP without SACK, receiver discards out-of-order frames beyond a missing sequence number or holds them in an out-of-order queue until the missing segment is retransmitted.
4. **Why is tuple comparison convenient in this Python implementation?**
   - Python compares tuples lexicographically: `(seq_a, payload_a) < (seq_b, payload_b)` compares `seq_a` against `seq_b` first, directly sorting by sequence number without custom comparator keys.
