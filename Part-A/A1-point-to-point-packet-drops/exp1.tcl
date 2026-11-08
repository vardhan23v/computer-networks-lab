# Experiment 1: Point-to-Point Network & Packet Drop Analysis
# Topology: n0 --- n1 --- n2

set ns [new Simulator]

# Open files for NAM and TRACE logging
set nf [open out.nam w]
$ns namtrace-all $nf

set tf [open out.tr w]
$ns trace-all $tf

# Finish procedure to flush trace and open NAM animator
proc finish {} {
    global ns nf tf
    $ns flush-trace
    close $nf
    close $tf
    exec nam out.nam &
    exit 0
}

# Create 3 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

# Create duplex links between nodes (1Mb bandwidth, 10ms delay, DropTail queue)
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail

# Set orientation for visualization in NAM
$ns duplex-link-op $n0 $n1 orient right-up
$ns duplex-link-op $n1 $n2 orient right-down

# Set queue limit (default is 50 packets)
$ns queue-limit $n0 $n1 50
$ns queue-limit $n1 $n2 50

# Create transport agent: UDP on sender n0, Null on receiver n2
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0

set null0 [new Agent/Null]
$ns attach-agent $n2 $null0
$ns connect $udp0 $null0

# Create Application to generate traffic: CBR (Constant Bit Rate)
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

# Schedule traffic generation events
$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"

# Schedule simulation end
$ns at 5.0 "finish"

# Run simulation
$ns run
