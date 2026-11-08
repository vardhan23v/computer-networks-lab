# Makefile for Computer Networks and Communication (CNC) Laboratory
# NMAM Institute of Technology, Nitte (Academic Year 2026-27)

CC = gcc
CFLAGS = -Wall -Wextra -O2
PYTHON = python3

# Part B C binary targets
B6_DIR = Part-B/B6-distance-vector-routing
TARGET_EXP10 = $(B6_DIR)/exp10

# Python script sources
PYTHON_SCRIPTS = Part-B/B1-bit-stuffing/exp5.py \
                 Part-B/B2-crc-error-detection/exp6.py \
                 Part-B/B3-frame-sorting/exp7.py \
                 Part-B/B4-tcp-file-transfer/tcp_server.py \
                 Part-B/B4-tcp-file-transfer/tcp_client.py \
                 Part-B/B5-udp-calculator/udp_server.py \
                 Part-B/B5-udp-calculator/udp_client.py

.PHONY: all build check-python test clean help sim1 sim2 sim3 sim4

all: build check-python

# Build compiled C programs
build: $(TARGET_EXP10)

$(TARGET_EXP10): $(B6_DIR)/exp10.c
	$(CC) $(CFLAGS) $< -o $@

# Syntax-check all Python scripts
check-python:
	@echo "Checking Python scripts syntax..."
	@for script in $(PYTHON_SCRIPTS); do \
		$(PYTHON) -m py_compile $$script && echo "  [OK] $$script" || exit 1; \
	done
	@echo "All Python scripts passed syntax validation."

# Run automated unit tests on Part B algorithms
test: build
	@echo "Running verification test on Experiment 5 (Bit Stuffing)..."
	@$(PYTHON) Part-B/B1-bit-stuffing/exp5.py <<< "1011111101" > /dev/null && echo "  [PASS] Experiment 5"
	@echo "Running verification test on Experiment 6 (CRC)..."
	@printf "4\n1\n0\n0\n1\nN\n" | $(PYTHON) Part-B/B2-crc-error-detection/exp6.py > /dev/null && echo "  [PASS] Experiment 6"
	@echo "Running verification test on Experiment 7 (Frame Sorting)..."
	@$(PYTHON) Part-B/B3-frame-sorting/exp7.py <<< "NMAMIT NITTE" > /dev/null && echo "  [PASS] Experiment 7"
	@echo "Running verification test on Experiment 10 (Distance Vector Routing)..."
	@printf "3\n1 0 1\n2 5 3\n3 1 0\n" | $(TARGET_EXP10) > /dev/null && echo "  [PASS] Experiment 10"
	@echo "All automated tests passed successfully."

# NS-2 Simulation runners (requires ns2 installed)
sim1:
	@cd Part-A/A1-point-to-point-packet-drops && ns exp1.tcl && awk -f exp1.awk out.tr

sim2:
	@cd Part-A/A2-tcp-udp-traffic-throughput && ns exp2.tcl && awk -f exp2.awk out.tr

sim3:
	@cd Part-A/A3-ethernet-lan-error-rate && ns exp3.tcl

sim4:
	@cd Part-A/A4-tcp-vegas-reno-congestion-window && ns exp4.tcl

clean:
	rm -f $(TARGET_EXP10)
	find . -type f \( -name "*.tr" -o -name "*.nam" -o -name "*.graph" -o -name "plot_throughput" -o -name "tcp1" -o -name "tcp2" -o -name "received_*" -o -name "*.o" -o -name "*.out" -o -name "a.out" \) -delete
	find . -type d -name "__pycache__" -exec rm -rf {} +
	@echo "Workspace cleaned."

help:
	@echo "Available commands:"
	@echo "  make all          - Compile C programs and validate Python scripts"
	@echo "  make build        - Compile Experiment 10 (Distance Vector Routing)"
	@echo "  make check-python - Syntax check all Python scripts"
	@echo "  make test         - Run automated test suite across Part B experiments"
	@echo "  make sim1..sim4   - Execute NS-2 simulations (Exp 1 to Exp 4)"
	@echo "  make clean        - Remove all generated trace files, logs, and binaries"
