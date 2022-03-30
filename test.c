#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>

int polynomial_degree(const int *y, size_t n);

void test(const int *y, size_t n, int oczekiwane) {
    int res = polynomial_degree(y, n);
    printf("[%d] ", res);
    if (res == oczekiwane) {
        printf("passed ");
    } else {
        printf("not passed ");
    }
    printf("for {");
    for (size_t i = 0; i < n; ++i) {
        printf(" %3d", y[i]);
    }
    printf("}\n");
}

int main(void) {
    int d[7] = {1,1,1,1,1,1,1};
    test(d, 7, 0);

    int c[2] = {0, 0};
    test(c, 2, -1);

    int a[5] = {1, 4, 9, 16, 25};
    test(a, 5, 2);
   
    int b[5] = {1, 8, 27, 64, 125};
    test(b, 5, 3);

    int ost[5] = {-9, 0, 9, 18, 27};
    test(ost, 5, 1);

    int os[2] = {1, 9};
    test(os, 2, 1);

    int f[3] = {1, 4, 9};
    test(f, 3, 2);

    int pecz[9] = {1, 4, 9, 16, 25, 36, 49, 64, 81};
    test(pecz, 9, 2);

    int zero[1] = {0};
    test(zero, 1, -1);

    int d5[2] = {5, 5};
    test(d5, 2, 0);

    int lon[66] = {
  1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1,
  1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1,
  1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1, 1, -1,
  1, -1, 1, -1, 1, -1};
    test(lon, 66, 65);


    int ss[1] = {777};
    test(ss, 1, 0);

    int tn1[9] = {37, 46, 61, 1, 2, 22, 7, 61, 63};
    test(tn1, 9, 7);
    
    int tn2[6] = {61, 0, 7, 28, 35, 26};
    test(tn2, 6, 4);

    int tn3[10] = {11, 65, 4, 1, 57, 54, 51, 63, 38, 11};
    test(tn3, 10, 9);

    int tn4[4] = {43, 1, 8, 64};
    test(tn4, 4, 2);

    int moj[3] = {1, 8, 27};
    test(moj, 3, 2);
}
