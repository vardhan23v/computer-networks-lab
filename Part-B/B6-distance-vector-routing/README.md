# Experiment 10: Distance Vector Routing Algorithm

## 🎯 Aim & Objective
Write a C program to implement the **Distance Vector Routing Algorithm** (based on the distributed Bellman-Ford algorithm) used in interior gateway protocols like RIP (Routing Information Protocol). The program takes a cost adjacency matrix of a network topology, iteratively updates distances via neighboring nodes, and prints the converged distance table and next-hop for every router.

---

## 📦 Required Tools & Algorithm Specifications

| Component | Specification |
|---|---|
| **Language** | C (C99 / C11) |
| **Compiler** | GCC / Clang (`gcc -Wall -Wextra -O2`) |
| **Routing Algorithm**| Bellman-Ford equation: $D_x(y) = \min_v \{ c(x, v) + D_v(y) \}$ |
| **Data Structures** | 2D Cost matrix `dmat[20][20]`, routing table array of structs `rt[10]` with `dist[]` and `from[]` |
| **Infinity Representation** | High integer value (e.g., `999`) representing disconnected links |
| **Iterations** | $n - 1$ relaxation iterations guarantees shortest-path convergence across $n$ nodes |

---

## 📂 Files in this Experiment

- [`exp10.c`](./exp10.c) - Complete C program implementing the Distance Vector Routing algorithm.

---

## 🛠 Compilation & Execution Instructions

```bash
# 1. Compile C program
gcc -Wall -Wextra exp10.c -o exp10

# 2. Run with 3-router topology
./exp10
# Enter nodes: 3
# Enter cost matrix:
# 1 0 1
# 2 5 3
# 3 1 0

# 3. Run with 4-router topology (with disconnected links entered as 999)
./exp10
# Enter nodes: 4
# Enter cost matrix:
# 0 2 999 1
# 2 0 3 7
# 999 3 0 11
# 1 7 11 0
```

---

## 🔍 Code Walkthrough

### 1. The Bellman-Ford Distance Vector Equation
For any source router $i$ seeking to reach destination $j$ through intermediate neighbor $k$:
$$D_i(j) = \min_k \left( \text{cost}(i, k) + D_k(j) \right)$$

### 2. Initialization
```c
for(int i=1; i<=n; i++) {
    for(int j=1; j<=n; j++) {
        scanf("%d", &dmat[i][j]);
        dmat[i][i] = 0;
        rt[i].dist[j] = dmat[i][j];
        rt[i].from[j] = j;
    }
}
```
- Each router initially assumes direct transmission to neighbor $j$ with immediate hop `from[j] = j` and direct link distance `dmat[i][j]`.

### 3. Iterative Relaxation Loop
```c
do {
    for(i=1; i<=n; i++)
        for(j=1; j<=n; j++)
            for(k=1; k<=n; k++)
                if(rt[i].dist[j] > dmat[i][k] + rt[k].dist[j]) {
                    rt[i].dist[j] = rt[i].dist[k] + rt[k].dist[j];
                    rt[i].from[j] = k;
                }
    c++;
} while(c < n);
```
- For $n - 1$ rounds, every router checks if routing traffic through neighbor $k$ yields a shorter path to destination $j$ than its current recorded distance.
- If so, it updates distance `rt[i].dist[j]` and redirects the next-hop `rt[i].from[j] = k`.

---

## 🧪 Expected Output

### Run 1: Three Routers (Lab Manual Sample)
```text
$ gcc exp10.c -o exp10
$ ./exp10
Enter the number of nodes: 
3
Enter the cost matrix: 1 0 1
2 5 3
3 1 0

Distance Table for router A is in 
	Node 1 Via 1. Distance: 0.
	Node 2 Via 2. Distance: 0.
	Node 3 Via 3. Distance: 1.

Distance Table for router B is in 
	Node 1 Via 1. Distance: 2.
	Node 2 Via 2. Distance: 0.
	Node 3 Via 3. Distance: 3.

Distance Table for router C is in 
	Node 1 Via 1. Distance: 3.
	Node 2 Via 2. Distance: 1.
	Node 3 Via 3. Distance: 0.
```

### Run 2: Four Routers (No direct link A–C, entered as 999)
```text
$ ./exp10
Enter the number of nodes: 
4
Enter the cost matrix: 0 2 999 1
2 0 3 7
999 3 0 11
1 7 11 0

Distance Table for router A is in 
	Node 1 Via 1. Distance: 0.
	Node 2 Via 2. Distance: 2.
	Node 3 Via 2. Distance: 5.
	Node 4 Via 4. Distance: 1.

Distance Table for router B is in 
	Node 1 Via 1. Distance: 2.
	Node 2 Via 2. Distance: 0.
	Node 3 Via 3. Distance: 3.
	Node 4 Via 1. Distance: 3.

Distance Table for router C is in 
	Node 1 Via 2. Distance: 5.
	Node 2 Via 2. Distance: 3.
	Node 3 Via 3. Distance: 0.
	Node 4 Via 2. Distance: 6.

Distance Table for router D is in 
	Node 1 Via 1. Distance: 1.
	Node 2 Via 1. Distance: 3.
	Node 3 Via 1. Distance: 6.
	Node 4 Via 4. Distance: 0.
```

---

## 💡 Viva Questions & Key Takeaways

1. **What is Distance Vector Routing and which real-world protocol uses it?**
   - Distance Vector Routing is a distributed dynamic routing algorithm where each router maintains a table (vector) of minimum distances to all reachable destinations and periodically exchanges it with directly connected neighbors. RIP (Routing Information Protocol) is the most prominent protocol based on it.
2. **What is the difference between Distance Vector Routing and Link State Routing?**
   - **Distance Vector (Bellman-Ford):** Each router tells its neighbors about the whole world (shares distance vector only with adjacent neighbors). Computation is distributed.
   - **Link State (Dijkstra):** Each router tells the whole world about its direct neighbors (floods link-state packets across the entire autonomous system). Every router independently computes the shortest path tree.
3. **What is the Count-to-Infinity problem?**
   - When a link breaks, routers exchange outdated distance vectors and increment the hop count iteratively toward infinity before detecting destination unreachability.
4. **How can the Count-to-Infinity problem be mitigated?**
   - **Split Horizon:** Do not advertise a route back to the neighbor from which it was learned.
   - **Poison Reverse:** Explicitly advertise the route back to the neighbor with an infinite metric ($\infty = 16$ in RIP).
   - **Hold-down Timers:** Delay accepting worse route updates for a fixed duration following a link failure.
