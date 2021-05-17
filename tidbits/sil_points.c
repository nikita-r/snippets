
int get_points(int stat)
{
    int points = 20;

    if (stat >= 0) {
        for (int i = 0; i < stat; i++) {
            points += (points + 2) / 5;
        }
    } else {
        int k = 4;
        for (int i = 0; i < -(stat) && k; i++) {
            points -= k;
            --k;
        }
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
