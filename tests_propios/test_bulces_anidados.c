#include <stdio.h>
int i = 0, j = 0;
int count = 0;
// Función personalizada sin parámetros y sin retorno
test_custom_function()
{
    // Imprimir un encabezado
    puts("Imprimiendo patrón con bucles anidados\n");

    // Utilizando bucles anidados para imprimir un patrón
    
    for (i = 1; i <= 3; i= i + 1)
    {
        for (j = 1; j <= i; j = j + 1)
        {
            
        }
        
    }
    puts("bucle anidado terminado");

    // Utilizando un bucle while para imprimir un mensaje tres veces
    
    while (count < 3)
    {
        puts("¡Hola!");
        count = count + 1;
    }
}

main()
{
    // Llamando a la función personalizada
    test_custom_function();
    

}

//@ (main)
