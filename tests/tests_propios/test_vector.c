#include <stdio.h>

// Función personalizada sin parámetros y sin retorno
test_custom_function()
{
    // Declarando un vector de enteros
    int vector[5];

    // Asignando valor a cada posición del vector
    vector[0] = 10;
    vector[1] = 20;
    vector[2] = 30;
    vector[3] = 40;
    vector[4] = 50;

    // Imprimiendo cada elemento del vector
    printf("Elementos del vector: ");
    for (int i = 0; i < 5; i++)
    {
        printf("%d ", vector[i]);
    }
    printf("\n");
}

main()
{
    // Prueba de función personalizada sin parámetros y sin retorno
    test_custom_function();

}
