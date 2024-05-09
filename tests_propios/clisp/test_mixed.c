#include <stdio.h>

// Función para verificar si un número es par o impar
esPar(int num) {
    if (num % 2 == 0) {
        return 1; // es par
    } else {
        return 0; // es impar
    }
}

main() {
    int numeros[5];
    numeros[0] = 3;
    numeros[1] = 4;
    numeros[1+1] = 5;
    numeros[numeros[0]] = 6;
    numeros[4] = 7;
    int longitud = 5;

    // Imprimir los números pares del vector
    printf("Numeros pares ingresados:");
    int i;
    for (i = 0; i < longitud; i = i + 1) {
        if (esPar(numeros[i]) == 1) {
            printf("%d %s", numeros[i], " ");
        }
    }

    return 0;
}
//@ (main)
