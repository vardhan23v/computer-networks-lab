BEGIN {
    count = 0;
}
{
    # Field $1 represents event type ('d' for packet drop)
    # Field $5 is packet type (cbr, tcp, ack, etc.)
    # Field $11 is packet unique identifier
    if ($1 == "d") {
        count++;
        printf("%s\t %s\n", $5, $11);
    }
}
END {
    printf("The number of packets dropped =%d \n", count);
}
