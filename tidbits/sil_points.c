
int get_points(int stat)
{
    int points = 20;

    if (stat < 0) {
        for (int i = stat, k = 4; i && k; ++i, --k) {
            points -= k;
        }
        return points;
    }

    for (int i = 0; i < stat; ++i) {
        points += (points + 2) / 5;
    }
    return points;
}

#include <stdio.h>

int main()
{
    for (int i = -5; i < 8; ++i) {
        printf("%+i: %i\n", i, get_points(i));
    }
    return 0;
}
