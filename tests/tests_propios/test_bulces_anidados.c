#include <stdio.h>

// Función personalizada sin parámetros y sin retorno
test_custom_function()
{
    // Imprimir un encabezado
    printf("Imprimiendo patrón con bucles anidados\n");

    // Utilizando bucles anidados para imprimir un patrón
    for (int i = 1; i <= 3; i++)
    {
        for (int j = 1; j <= i; j++)
        {
            printf("%d ", j);
        }
        printf("\n");
    }

    // Utilizando un bucle while para imprimir un mensaje tres veces
    int count = 0;
    while (count < 3)
    {
        puts("¡Hola!");
        count++;
    }
}

main()
{
    // Llamando a la función personalizada
    test_custom_function();

}
