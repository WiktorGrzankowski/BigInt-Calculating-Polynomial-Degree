# BigInt-Calculating-Polynomial-Degree

This program is written in x86 assembly for 64-bit linux.
polynomial_degree is a function called from a program in C language 
with the declaration as "int polynomial_degree(const int *y, size_t n)"
and calculates the minimal degree of a polynomial that satisfies the 
given array. Algorithm used to find the answer subtracts adjacent
elements in the array until all elements are equal to 0, or there are
no more elements to subtract. This may result in an overflow, so
I created a structure similar to a BigInt/InfInt, so each int
is actually represented as a series of ints on which calculations
can be perfmored no matter the length of the resulting number.
polynomial. An example of usage is provided in test.c
To run the program type:

nasm -f elf64 -w+all -w+error -o polynomial_degree.o polynomial_degree.asm

gcc -c -Wall -Wextra -std=c17 -O2 -o test.o test.c

gcc -o test test.o polynomial_degree.o

./test
