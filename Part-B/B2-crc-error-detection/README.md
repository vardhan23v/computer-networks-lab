# Experiment 6: Error Detection using CRC (Cyclic Redundancy Check)

## 🎯 Aim & Objective
Write a Python program to implement error-detecting code using Cyclic Redundancy Check (CRC). The program computes the CRC remainder using modulo-2 polynomial division, appends it to create the transmitted codeword, simulates channel bit corruption, and verifies the integrity at the receiver side.

---

## 📦 Required Tools & Mathematical Specifications

| Component | Specification |
|---|---|
| **Language** | Python 3 |
| **Generator Polynomial ($G(x)$)** | `div = [1, 0, 1, 1]` representing $x^3 + x + 1$ (degree $m - 1 = 3$) |
| **Arithmetic Type** | Modulo-2 polynomial division using bitwise XOR (`^`) |
| **Standard References** | CRC-12, CRC-16, CRC-CCITT ($x^{16} + x^{12} + x^5 + 1$), CRC-32 (Ethernet) |
| **Zero Padding** | $(m - 1)$ zeros appended to data polynomial before division |
| **Codeword Structure** | $\text{Codeword} = \text{Data} \,\|\, \text{Remainder}$ |

---

## 📂 Files in this Experiment

- [`exp6.py`](./exp6.py) - Complete CRC encoding, transmission, error injection, and decoding script.

---

## 🛠 Execution Instructions

```bash
# Run the script
python3 exp6.py

# Run Case 1 (Without Error):
# Enter 4 bits: 1, 0, 0, 1
# Introduce Error: N

# Run Case 2 (With Error Injected):
# Enter 4 bits: 1, 0, 0, 1
# Introduce Error: Y -> Position: 1
```

---

## 🔍 Code Walkthrough

### 1. Mathematical Principle of CRC
Given data word $D(x)$ of degree $k$ and generator polynomial $G(x)$ of degree $r = m - 1$:
1. Multiply data by $x^r$ (append $r$ zeros to data): $D(x) \cdot x^r$.
2. Divide $D(x) \cdot x^r$ by $G(x)$ using modulo-2 arithmetic (XOR without borrow/carry):
   $$\frac{D(x) \cdot x^r}{G(x)} = Q(x) + \frac{R(x)}{G(x)}$$
3. Form transmitted codeword $T(x)$:
   $$T(x) = D(x) \cdot x^r \oplus R(x)$$
4. The receiver divides received message $T'(x)$ by $G(x)$:
   - If remainder $R'(x) = 0$, no detectable error occurred.
   - If remainder $R'(x) \neq 0$, error detected.

### 2. Transmitter Division
```python
for i in range(n):
    if cdata[i] == 1:
        for j in range(m):
            cdata[i + j] ^= div[j]
```
- Iterates over each bit of the original message.
- If current bit is `1`, XORs with generator polynomial `div` across $m$ bits.
- Leaves remainder in slice `cdata[n : n + m - 1]`.

### 3. Receiver Verification
- Codeword $T$ is divided by `div` using identical modulo-2 loop.
- The `flag` scans all bits; any remaining `1` indicates transmission error.

---

## 🧪 Expected Output

### Run 1: No Error
```text
$ python3 exp6.py
Enter the number of bits :4
Enter bit 1: 1
Enter bit 2: 0
Enter bit 3: 0
Enter bit 4: 1
Initial Codeword : [1, 0, 0, 1, 0, 0, 0]
Codeword to be transmitted is: [1, 0, 0, 1, 1, 1, 0]
Introduce Error - Y -> YES N->NO:N
The message received is: [1, 0, 0, 1, 1, 1, 0]
No Error 
Successfully Transferred
```

### Run 2: Error Introduced
```text
$ python3 exp6.py
Enter the number of bits :4
Enter bit 1: 1
Enter bit 2: 0
Enter bit 3: 0
Enter bit 4: 1
Initial Codeword : [1, 0, 0, 1, 0, 0, 0]
Codeword to be transmitted is: [1, 0, 0, 1, 1, 1, 0]
Introduce Error - Y -> YES N->NO:Y
Enter the position to change bit :1
The message received is: [0, 0, 0, 1, 1, 1, 0]
Error !
```

---

## 💡 Viva Questions & Key Takeaways

1. **Why is XOR used for polynomial division instead of standard binary subtraction?**
   - Polynomial coefficients over Galois Field $GF(2)$ are binary ($0$ or $1$). In $GF(2)$, addition and subtraction are identical and equivalent to bitwise XOR:
     $$0 \oplus 0 = 0, \quad 0 \oplus 1 = 1, \quad 1 \oplus 0 = 1, \quad 1 \oplus 1 = 0$$
     There is no carrying or borrowing across columns.
2. **How many check bits does CRC append to the original data?**
   - Exactly $r = m - 1$ bits, where $m$ is the length of the generator polynomial (degree of $G(x)$).
3. **What error types does CRC detect?**
   - All single-bit errors (if $G(x)$ has more than one term).
   - All double-bit errors (if $G(x)$ is not divisible by $x^k + 1$).
   - Any odd number of errors (if $G(x)$ has factor $x + 1$).
   - All burst errors of length $\le r$.
4. **What is the generator polynomial used in IEEE 802.3 Ethernet?**
   - CRC-32: $x^{32} + x^{26} + x^{23} + x^{22} + x^{16} + x^{12} + x^{11} + x^{10} + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1$.
