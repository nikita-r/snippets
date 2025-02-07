
int get_points(int stat)
{
	int points = 20, i = stat < -4 ? -4 : stat;

	if (i < 0) for (; i; ++i) points += i;
	else for (; i; --i) points += (points + 2) / 5;

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
