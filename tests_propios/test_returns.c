#include <stdio.h>

// Función con múltiples ifs-else y retornos
test_multiple_ifs(int x)
{
    if (x < 0)
    {
        puts("El número es negativo");
        return -1;
    }
    else
    {
        puts("El número es positivo");
        return 1;
    }
}

main()
{
    int num = 5;
    int result = test_multiple_ifs(num);
    printf("Resultado de la prueba: %d", result);
    return 0;
}
//@ (main)
