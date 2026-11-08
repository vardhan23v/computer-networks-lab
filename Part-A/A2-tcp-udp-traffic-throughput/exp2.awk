BEGIN {
    tcp_count = 0;
    udp_count = 0;
}
{
    if ($5 == "cbr")
        udp_count++;
    else if ($5 == "tcp")
        tcp_count++;
}
END {
    printf("The number of packets by TCP =%d\n", tcp_count);
    printf("The number of packets by UDP =%d\n", udp_count);
}
