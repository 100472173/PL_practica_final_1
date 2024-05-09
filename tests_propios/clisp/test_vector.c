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

    int i;
    for (i = 0; i < 5; i=i+1)
    {
        puts("en bucle");
    }
    return vector[2];
}

main()
{
    // Prueba de función personalizada sin parámetros y sin retorno
    test_custom_function();

}
//@ (main)

