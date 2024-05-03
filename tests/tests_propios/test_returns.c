#include <stdio.h>

// Función con múltiples ifs-else y retornos
test_multiple_ifs(int x)
{
    if (x < 0)
    {
        printf("El número es negativo\n");
        return -1;
    }
    else if (x == 0)
    {
        printf("El número es cero\n");
        return 0;
    }
    else
    {
        printf("El número es positivo\n");
        return 1;
    }
}

main()
{
    int num = 5;
    int result = test_multiple_ifs(num);
    printf("Resultado de la prueba: %d\n", result);
    return 0;
}
