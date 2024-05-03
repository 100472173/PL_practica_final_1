#include <stdio.h>

// Declaración de una variable global
int global_variable = 10;

main()
{
    // Declaración de variables locales
    int x = 5;
    int y = 10;

    // Imprimir el valor de las variables locales y globales
    printf("Valor de x (local): %d\n", x);
    printf("Valor de y (local): %d\n", y);
    printf("Valor de global_variable (global): %d\n", global_variable);

    // Realizar una operación con las variables locales y globales
    int suma = x + y + global_variable;
    printf("La suma de x, y y global_variable es: %d\n", suma);

    return 0;
}
