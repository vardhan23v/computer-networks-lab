# Experiment 2: TCP and UDP traffic: packet counts and throughput
# Topology:
#   n0 (TCP) \
#             n2 (Router/Queue) --- n3 (Receiver: TCPSink & Null)
#   n1 (UDP) /

set ns [new Simulator]

# Open a new file for NAMTRACE
set nf [open out.nam w]
$ns namtrace-all $nf

# Open a new file to log TRACE
set tf [open out.tr w]
$ns trace-all $tf

# Body of finish procedure
proc finish {} {
    global ns nf tf
    $ns flush-trace
    close $nf
    close $tf
    exec nam out.nam &
    exit 0
}

# Create 4 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

# Set node labels
$n0 label "TCP"
$n1 label "UDP"
$n2 label "Receiver"

# Create links between nodes
$ns duplex-link $n0 $n2 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 1Mb 10ms DropTail

# Set orientation
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right

# Set the queue limit - default is 50 packets
$ns queue-limit $n0 $n2 50
$ns queue-limit $n1 $n2 50
$ns queue-limit $n2 $n3 50

# Create TCP agent b/w node 0 and node 3
# Sender
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0

# Receiver
set sink0 [new Agent/TCPSink]
$ns attach-agent $n3 $sink0
$ns connect $tcp0 $sink0

# Create FTP Application for TCP Agent
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

# Specify TCP packet size
Agent/TCP set packetSize_ 1000

# Create UDP Agent b/w node1 and node3
# Sender
set udp0 [new Agent/UDP]
$ns attach-agent $n1 $udp0

# Receiver
set null0 [new Agent/Null]
$ns attach-agent $n3 $null0
$ns connect $udp0 $null0

# Create CBR Application for UDP Agent
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

# Start and Stop FTP Traffic
$ns at 0.75 "$ftp0 start"
$ns at 4.75 "$ftp0 stop"

# Start and stop CBR traffic
$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"

# Stop the simulations
$ns at 5.0 "finish"
$ns run
