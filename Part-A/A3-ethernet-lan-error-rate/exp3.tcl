# Experiment 3: Ethernet LAN: throughput versus data rate and error rate
# Topology: Node n0 connected via duplex link to LAN consisting of nodes n1..n6

set ns [new Simulator]
set namfile [open exp3.nam w]
$ns namtrace-all $namfile
set tracefile [open exp3.tr w]
$ns trace-all $tracefile

proc finish {} {
    global ns namfile tracefile
    $ns flush-trace
    close $namfile
    close $tracefile
    exec nam exp3.nam &
    exec awk -f exp3.awk exp3.tr > exp3.graph &
    exit 0
}

# Create 6 nodes (n0 as sender, n1..n6 as members of Ethernet LAN)
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]

# Label source and sink nodes
$n0 label "TCPSource"
$n6 label "TCPSink"

# Assign color to flow and nodes
$ns color 1 red
$n0 color blue
$n6 color orange

# Connect n0 to n1 via point-to-point link
$ns duplex-link $n0 $n1 3Mb 20ms DropTail

# Create Ethernet 802.3 CSMA/CD Local Area Network connecting n1 through n6
$ns make-lan "$n1 $n2 $n3 $n4 $n5 $n6" 2Mb 40ms LL Queue/DropTail Mac/802_3

$ns duplex-link-op $n0 $n1 orient right

# Create TCP Agent on n0
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
$tcp set class_ 1

# Create TCPSink Agent on n6
set tcpsink [new Agent/TCPSink]
$ns attach-agent $n6 $tcpsink
$ns connect $tcp $tcpsink

# Attach FTP Application to TCP Agent
set ftp [new Application/FTP]
$ftp attach-agent $tcp

# Error model on the link n0 -> n1 (simulate channel packet losses)
set em [new ErrorModel]
$em unit pkt
$em set rate_ 0.01
$em ranvar [new RandomVariable/Uniform]
$em drop-target [new Agent/Null]
$ns lossmodel $em $n0 $n1

# Schedule simulation events
$ns at 1.0 "$ftp start"
$ns at 5.0 "$ftp stop"
$ns at 5.5 "finish"
$ns run
