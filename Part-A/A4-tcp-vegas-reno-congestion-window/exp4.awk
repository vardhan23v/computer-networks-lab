BEGIN {
}
{
    # Field $6 contains variable name ("cwnd_")
    # Field $1 contains simulation timestamp
    # Field $7 contains congestion window value
    if ($6 == "cwnd_") {
        printf("%f\t %f\n", $1, $7);
    }
}
END {
}
