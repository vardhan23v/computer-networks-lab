# Experiment 5: Bit Stuffing and Destuffing

## 🎯 Aim & Objective
Write a Python program to implement the **Bit Stuffing** (and Destuffing) framing technique used in the Data Link Layer (such as in HDLC / SDLC protocols) to achieve data transparency and prevent unintended frame delimiters (`01111110`).

---

## 📦 Required Tools & Language Specification

| Component | Specification |
|---|---|
| **Language** | Python 3 (Python 3.8+) |
| **Libraries** | Built-in standard functions (no external packages required) |
| **OS Support** | Linux / macOS / Windows |
| **Framing Standard** | High-Level Data Link Control (HDLC) Flag Sequence `01111110` ($0x7E$) |
| **Stuffing Rule** | Transmitter injects a `0` bit after any sequence of five consecutive `1`s |
| **Destuffing Rule**| Receiver inspects incoming stream; whenever five consecutive `1`s are followed by a `0`, the `0` is discarded |

---

## 📂 Files in this Experiment

- [`exp5.py`](./exp5.py) - Python script containing `bit_stuffing()` and `bit_destuffing()` routines.

---

## 🛠 Execution Instructions

```bash
# Run the Python script
python3 exp5.py

# When prompted, enter binary bit sequence (e.g., 1011111101)
```

---

## 🔍 Code Walkthrough

### 1. The Framing Problem & Data Transparency
- Frame boundaries in synchronous data link protocols are delimited by the 8-bit flag pattern:
  $$\text{Flag} = 01111110_2 \quad (0\text{ followed by six }1\text{s and a }0)$$
- If user data contains six consecutive `1`s, the receiver hardware would misinterpret it as the end-of-frame delimiter, truncating the transmission prematurely.

### 2. Transmitter Stuffing Logic (`bit_stuffing`)
```python
for bit in data:
    stuffed_data += bit
    if bit == '1':
        count += 1
        if count == 5:
            stuffed_data += '0'
            count = 0
    else:
        count = 0
```
- A counter tracks consecutive `1` bits.
- Whenever `count == 5`, a synthetic `0` bit is immediately appended to `stuffed_data`, guaranteeing that six consecutive `1`s can never appear inside the transmitted payload.
- Any `0` bit resets `count = 0`.

### 3. Receiver Destuffing Logic (`bit_destuffing`)
```python
for bit in stuffed_data:
    if skip_next:
        skip_next = False
        continue
    destuffed_data += bit
    if bit == '1':
        count += 1
        if count == 5:
            skip_next = True
            count = 0
    else:
        count = 0
```
- The receiver mirrors transmitter state tracking.
- Upon observing five consecutive `1`s, the subsequent bit (which the transmitter guaranteed to be `0`) is identified as stuffed and dropped (`skip_next = True`).
- Original data stream is restored with 100% fidelity.

---

## 🧪 Expected Output

```text
$ python3 exp5.py
Enter the input data :1011111101
Original data : 1011111101
Bit Stuffed data : 10111110101
Bit Destuffed data : 1011111101
```

---

## 💡 Viva Questions & Key Takeaways

1. **What is bit stuffing and why is it required?**
   - Bit stuffing is the insertion of non-information bits into data to break up sequences that might otherwise be detected as control delimiters (such as flag byte `01111110`). It ensures **data transparency**—the payload can contain any arbitrary bit sequence without disrupting framing.
2. **What happens if the original data naturally ends with five `1`s?**
   - The transmitter still inserts a `0` bit after the five `1`s. The receiver sees five consecutive `1`s and removes the trailing `0`, reconstructing the exact original five `1`s.
3. **What is the difference between bit stuffing and byte stuffing (character stuffing)?**
   - Bit stuffing operates at the bit level on arbitrary bit streams by inserting a `0` after five consecutive `1`s.
   - Byte (character) stuffing operates at the byte/character level by inserting an escape byte (`ESC` or `DLE`) before data bytes that collide with start/end delimiter characters (`FLAG`).
4. **How does the receiver recognize an actual End of Frame (EOF)?**
   - If after five consecutive `1`s the next bit is `0`, it is a stuffed bit (discarded). If the next bit is `1` (yielding `01111110`), it is a true frame delimiter flag!
