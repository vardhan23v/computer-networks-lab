/*
 * Experiment 10: Distance Vector Routing Algorithm
 * Implementation of distributed Bellman-Ford equation in C:
 *   D_x(y) = min_v { c(x, v) + D_v(y) }
 */

#include <stdio.h>
#include <stdlib.h>

struct node
{
    int dist[20];
    int from[20];
} rt[10];

int main()
{
    int dmat[20][20];
    int n, i, j, k, c = 1;

    printf("Enter the number of nodes: \n");
    if (scanf("%d", &n) != 1) {
        fprintf(stderr, "Invalid input for number of nodes\n");
        return 1;
    }

    printf("Enter the cost matrix: ");
    for (i = 1; i <= n; i++)
    {
        for (j = 1; j <= n; j++)
        {
            if (scanf("%d", &dmat[i][j]) != 1) {
                fprintf(stderr, "Invalid input for cost matrix\n");
                return 1;
            }
            dmat[i][i] = 0;
            rt[i].dist[j] = dmat[i][j];
            rt[i].from[j] = j;
        }
    }

    /* Bellman-Ford relaxation loop */
    do
    {
        for (i = 1; i <= n; i++)
        {
            for (j = 1; j <= n; j++)
            {
                for (k = 1; k <= n; k++)
                {
                    if (rt[i].dist[j] > dmat[i][k] + rt[k].dist[j])
                    {
                        rt[i].dist[j] = rt[i].dist[k] + rt[k].dist[j];
                        rt[i].from[j] = k;
                    }
                }
            }
        }
        c++;
    } while (c < n);

    /* Print Distance Table for each router */
    for (i = 1; i <= n; i++)
    {
        printf("\nDistance Table for router %c is in \n", i + 64);
        for (j = 1; j <= n; j++)
        {
            printf("\tNode %d Via %d. Distance: %d.\n", j, rt[i].from[j], rt[i].dist[j]);
        }
    }

    return 0;
}
