/* Grupo de trabajo 03. Alejandro Díaz Cuéllar y Tomás Mendizábal*/
/* 100472173@alumnos.uc3m.es 100461170@alumos.uc3m.es */

%{                          // SECCION 1 Declaraciones de C-Yacc

#include <stdio.h>
#include <ctype.h>            // declaraciones para tolower
#include <string.h>           // declaraciones para cadenas
#include <stdlib.h>           // declaraciones para exit ()
#include <stdbool.h>

#define FF fflush(stdout);    // para forzar la impresion inmediata

typedef struct Symbol {
    char name[50];
    char type[50];
    bool active; // Indica si el símbolo está activo
    bool global; // Indica si el símbolo es global
    struct Symbol *next;
} Symbol;
void removeNonGlobalSymbols(Symbol **table);
void hideSymbol(Symbol *table, char *name);
Symbol* findSymbol(Symbol *table, char *name);
void insertSymbol(Symbol **table, char *name, char *type, bool global);
char temp_function[50];
Symbol *symbolTable = NULL;


int yylex () ;
int yyerror () ;
char *mi_malloc (int) ;
char *gen_code (char *) ;
char *int_to_string (int) ;
char *char_to_string (char) ;
char * replace_substring (char *string, char *sub_string)  ;
int is_expression(const char *cadena) ;
int search_string(char *elemento);
void add_string(char *nuevaCadena);
void clear_array();

char temp [2048] ;
char locales [256][256];
int tamaño_locales = 0;

// Definitions for explicit attributes

typedef struct s_attr {
        int value ;
        char *code ;
} t_attr ;

#define YYSTYPE t_attr

%}
// Definitions for explicit attributes

%token NUMBER
%token IDENTIF       // Identificador=variable
%token INTEGER       // identifica el tipo entero
%token STRING
%token MAIN          // identifica el comienzo del proc. main
%token WHILE         // identifica el bucle main
%token PUTS
%token PRINTF
%token IF
%token ELSE
%token FOR
%token RETURN
%token AND            // Identifica el operador lógico AND
%token OR             // Identifica el operador lógico OR
%token NEQ            // Identifica el operador de desigualdad !=
%token EQ             // Identifica el operador de igualdad ==
%token LTE            // Identifica el operador menor o igual que <=
%token GTE            // Identifica el operador mayor o igual que >=

%right '='                    // es la ultima operacion que se debe realizar
%left OR
%left AND
%left EQ NEQ
%left '<' '>' GTE LTE
%left '+' '-'                 // menor orden de precedencia
%left '*' '/' '%'                // orden de precedencia intermedio
%left UNARY_SIGN              // mayor orden de precedencia

%%                            // Seccion 3 Gramatica - Semantico

axioma:       decl_variables def_funciones             { printf ("\n%s%s\n", $1.code, $2.code) ; }
              r_expr                                   { ; }
            ;

r_expr:        axioma                 { ; }
            |                                { ; }

            ;

decl_variables:      sentencia_variable ';' decl_variables    { sprintf (temp, "%s\n%s", $1.code, $3.code) ;
                                                                $$.code = gen_code (temp) ; }
                  |                                           { strcpy(temp, "") ;
                                                                $$.code = gen_code (temp) ;}
                  ;

sentencia_variable:    INTEGER IDENTIF                              { sprintf (temp, "(setq %s 0)", $2.code) ;
                                                                      $$.code = gen_code (temp) ; }
                     | INTEGER IDENTIF '=' NUMBER lista_decl_var    { sprintf (temp, "(setq %s %d) %s", $2.code, $4.value, $5.code) ;
                                                                      $$.code = gen_code (temp) ; }
                     | INTEGER IDENTIF '[' NUMBER ']'               { sprintf (temp, "(setq %s (make-array %d))", $2.code, $4.value) ;
                                                                      $$.code = gen_code (temp) ; }
                     ;

lista_decl_var:     ',' IDENTIF '=' NUMBER lista_decl_var            { sprintf (temp, "(setq %s %d) %s", $2.code, $4.value, $5.code) ;
                                                                       $$.code = gen_code (temp) ; }
                  |                                                  { strcpy(temp, "") ;
                                                                       $$.code = gen_code (temp) ; }
                  ;

def_funciones:      MAIN '(' argumentos ')' '{' cuerpo_funcion '}'     { char * new_code = replace_substring($6.code, "main") ;
                                                                         clear_array() ;
                                                                         sprintf (temp, "(defun main (%s)\n%s)", $3.code, new_code) ;
                                                                         $$.code = gen_code (temp) ; }
                  | sentencia_funcion def_funciones                    { sprintf (temp, "%s\n%s", $1.code, $2.code) ;
                                                                         $$.code = gen_code (temp) ;}
                  ;

sentencia_funcion:   IDENTIF '(' argumentos ')' '{' cuerpo_funcion '}'    { char * new_code = replace_substring($6.code, $1.code) ;
                                                                            clear_array() ;
                                                                            sprintf (temp, "(defun %s (%s)\n%s)", $1.code, $3.code, new_code) ;
                                                                            $$.code = gen_code (temp) ; }
                   ;

argumentos:     tipo_argumento resto_argumentos    { sprintf(temp, "%s %s", $1.code, $2.code);
                                                     $$.code = gen_code(temp);}
              |                                    { strcpy(temp, "") ;
                                                     $$.code = gen_code (temp) ; }
              ;

tipo_argumento:       INTEGER IDENTIF                   { $$ = $2 ; }
                    | INTEGER IDENTIF '[' NUMBER ']'    { $$ = $2 ; }
                    ;

resto_argumentos:     ',' tipo_argumento resto_argumentos     { sprintf(temp, "%s %s", $2.code, $3.code);
                                                                 $$.code = gen_code(temp);}
                    |                                         { strcpy(temp, "") ;
                                                                $$.code = gen_code (temp) ; }
                    ;

cuerpo_funcion:     sentencia cuerpo_funcion         { sprintf (temp, "%s\n%s", $1.code, $2.code) ;
                                                       $$.code = gen_code (temp) ; }
                 |  funcion_return cuerpo_funcion    { if (strcmp($2.code, "") == 0) {
                                                            sprintf(temp, "%s", $1.code) ;
                                                       }
                                                       else {
                                                            sprintf(temp, "(return-from FUNC %s)\n%s", $1.code, $2.code) ;
                                                       }
                                                       $$.code = gen_code (temp) ; }
                 |                                   { strcpy(temp, "") ;
                                                       $$.code = gen_code (temp) ; }
                 ;

funcion_return:     RETURN expresion ';'        { sprintf(temp, "%s", $2.code) ;
                                                     $$.code = gen_code (temp) ; }

sentencia:        var_local                                                                                 { $$ = $1 ; }
                | PRINTF '(' STRING ',' lista_expresiones ')' ';'                                                  { $$ = $5 ; }
                | PUTS '(' STRING ')' ';'                                                                      { sprintf (temp, "(print \"%s\")", $3.code) ;
                                                                                                                    $$.code = gen_code (temp) ; }
                | WHILE '(' expr_logica ')' '{' sentencias_mult '}'                                           { sprintf (temp, "(loop while %s do\n%s)", $3.code, $6.code) ;
                                                                                                              $$.code = gen_code (temp) ; }
                | IF '(' expr_logica ')' '{' sentencias_if '}'                                              { sprintf (temp, "(if %s %s)", $3.code, $6.code) ;
                                                                                                                  $$.code = gen_code (temp) ; }
                | IF '(' expr_logica ')' '{' sentencias_if '}' ELSE '{' sentencias_if '}'                        { sprintf (temp, "(if %s\n%s\n%s)", $3.code, $6.code, $10.code) ;
                                                                                                                    $$.code = gen_code (temp) ; }
                | FOR '(' IDENTIF '=' expresion ';'  expr_logica ';' incr  ')' '{' sentencias_mult '}'          { sprintf (temp, "(loop while %s do\n%s\n%s)", $7.code, $12.code, $9.code) ;
                                                                                                                            $$.code = gen_code (temp) ; }
                | IDENTIF '(' expresion lista_argumentos ')' ';'                                                 { sprintf (temp, "(%s %s %s)", $1.code, $3.code, $4.code) ;
                                                                                                  $$.code = gen_code (temp) ; }
                ;

lista_argumentos:   ',' expresion lista_argumentos      { sprintf (temp, "%s %s", $2.code, $3.code) ;
                                                            $$.code = gen_code (temp) ; }
                   |                                       { strcpy(temp, "") ;
                                                              $$.code = gen_code (temp) ; }


incr:  IDENTIF '=' expresion                              { if (search_string($1.code) == 1) {
                                                                               sprintf (temp, "(setf FUNC_%s %s)", $1.code, $3.code) ;
                                                                             }
                                                                             else {
                                                                               sprintf (temp, "(setf %s %s)", $1.code, $3.code) ;
                                                                             }
                                                                             $$.code = gen_code (temp) ; }

var_local:    IDENTIF '=' expresion ';'                             { if (search_string($1.code) == 1) {
                                                                        sprintf (temp, "(setf FUNC_%s %s)", $1.code, $3.code) ;
                                                                      }
                                                                      else {
                                                                        sprintf (temp, "(setf %s %s)", $1.code, $3.code) ;
                                                                      }
                                                                      $$.code = gen_code (temp) ; }
            | IDENTIF '[' NUMBER ']' '=' expresion ';'              { if (search_string($1.code) == 1) {
                                                                        sprintf (temp, "(setf (aref FUNC_%s %d) %s)", $1.code, $3.value, $6.code) ;
                                                                      }
                                                                      else {
                                                                        sprintf (temp, "(setf (aref %s %d) %s)", $1.code, $3.value, $6.code) ;
                                                                      }
                                                                      $$.code = gen_code (temp) ; }
            |  INTEGER IDENTIF ';'                                  { add_string($2.code);
                                                                      sprintf (temp, "(setq FUNC_%s 0)", $2.code) ;
                                                                      $$.code = gen_code (temp) ; }
            | INTEGER IDENTIF '=' NUMBER lista_decl_var_local ';'   { add_string($2.code);
                                                                      sprintf (temp, "(setq FUNC_%s %d) %s", $2.code, $4.value, $5.code) ;
                                                                      $$.code = gen_code (temp) ; }
            | INTEGER IDENTIF '[' NUMBER ']' ';'                    { add_string($2.code);
                                                                      sprintf (temp, "(setq FUNC_%s (make-array %d))", $2.code, $4.value) ;
                                                                      $$.code = gen_code (temp) ; }
            ;

lista_decl_var_local: ',' IDENTIF '=' NUMBER lista_decl_var_local   { add_string($2.code) ;
                                                                      sprintf (temp, "(setq FUNC_%s %d) %s", $2.code, $4.value, $5.code) ;
                                                                      $$.code = gen_code (temp) ; }
           |                                                        { strcpy(temp, "") ;
                                                                      $$.code = gen_code (temp) ; }
           ;

expr_logica:     expr_logica AND expr_logica          { sprintf (temp, "(and %s %s)", $1.code, $3.code) ;
                                                        $$.code = gen_code (temp) ; }
               | expr_logica OR expr_logica           { sprintf (temp, "(or %s %s)", $1.code, $3.code) ;
                                                        $$.code = gen_code (temp) ; }
               | expr_logica NEQ expr_logica           { sprintf (temp, "(/= %s %s)", $1.code, $3.code) ;
                                                         $$.code = gen_code (temp) ; }
               | expr_logica EQ expr_logica           { sprintf (temp, "(= %s %s)", $1.code, $3.code) ;
                                                        $$.code = gen_code (temp) ; }
               | expr_logica '<' expr_logica           { sprintf (temp, "(< %s %s)", $1.code, $3.code) ;
                                                         $$.code = gen_code (temp) ; }
               | expr_logica '>' expr_logica           { sprintf (temp, "(> %s %s)", $1.code, $3.code) ;
                                                        $$.code = gen_code (temp) ; }
               | expr_logica GTE expr_logica           { sprintf (temp, "(>= %s %s)", $1.code, $3.code) ;
                                                        $$.code = gen_code (temp) ; }
               | expr_logica LTE expr_logica           { sprintf (temp, "(<= %s %s)", $1.code, $3.code) ;
                                                        $$.code = gen_code (temp) ; }
               | expr_logica '%' expr_logica           { sprintf (temp, "(mod %s %s)", $1.code, $3.code) ;
                                                        $$.code = gen_code (temp) ; }
               | expr_logica '+' expr_logica           { sprintf (temp, "(+ %s %s)", $1.code, $3.code) ;
                                                        $$.code = gen_code (temp) ; }
               | expr_logica '-' expr_logica           { sprintf (temp, "(- %s %s)", $1.code, $3.code) ;
                                                        $$.code = gen_code (temp) ; }
               | expr_logica '/' expr_logica           { sprintf (temp, "(/ %s %s)", $1.code, $3.code) ;
                                                        $$.code = gen_code (temp) ; }
               | expr_logica '*' expr_logica           { sprintf (temp, "(* %s %s)", $1.code, $3.code) ;
                                                        $$.code = gen_code (temp) ; }
               | termino_logico                                     { $$ = $1 ; }
               ;

termino_logico:     operando_logico                           { $$ = $1 ; }
                 |   '+' operando_logico %prec UNARY_SIGN      { sprintf (temp, "(+ %s)", $2.code) ;
                                                                     $$.code = gen_code (temp) ; }
                 |   '-' operando_logico %prec UNARY_SIGN      { sprintf (temp, "(- %s)", $2.code) ;
                                                                     $$.code = gen_code (temp) ; }
                 |   '!' operando_logico %prec UNARY_SIGN      { sprintf (temp, "(not %s)", $2.code) ;
                                                                  $$.code = gen_code (temp) ; }
                 ;

operando_logico:   NUMBER                       { sprintf (temp, "%d", $1.value) ;
                                                  $$.code = gen_code (temp) ; }
                 | IDENTIF                      { if (search_string($1.code) == 1) {
                                                    sprintf (temp, "FUNC_%s", $1.code) ;
                                                  }
                                                  else {
                                                    sprintf (temp, "%s", $1.code) ;
                                                  }
                                                  $$.code = gen_code (temp) ; }
                 |  IDENTIF '[' NUMBER ']'      { if (search_string($1.code) == 1) {
                                                    sprintf(temp, "(aref FUNC_%s %d)", $1.code, $3.value) ;
                                                  }
                                                  else {
                                                    sprintf(temp, "(aref %s %d)", $1.code, $3.value) ;
                                                  }
                                                  $$.code = gen_code (temp) ; }
                 ;

sentencias_if:    sentencia resto_sentencias_if           { if (strcmp($2.code, "") == 0) {
                                                                sprintf (temp, "\t%s", $1.code) ;
                                                            }
                                                            else {
                                                                sprintf (temp, "(progn %s\t%s)", $1.code, $2.code) ;
                                                            }
                                                            $$.code = gen_code (temp) ; }
               |  funcion_return resto_sentencias_if      { if (strcmp($2.code, "") == 0) {
                                                                sprintf(temp, "%s", $1.code) ;
                                                            }
                                                            else {
                                                                sprintf(temp, "(progn (return-from FUNC %s)\t%s)", $1.code, $2.code) ;
                                                            }
                                                            $$.code = gen_code (temp) ; }
                |                                         { strcpy(temp, "") ;
                                                            $$.code = gen_code (temp) ; }
                ;

resto_sentencias_if:    sentencia resto_sentencias_if        { sprintf (temp, "\n\t%s", $1.code) ;
                                                               $$.code = gen_code (temp) ; }
                   |  funcion_return resto_sentencias_if     { if (strcmp($2.code, "") == 0) {
                                                                  sprintf(temp, "%s", $1.code) ;
                                                               }
                                                               else {
                                                                  sprintf(temp, "\n(return-from FUNC %s)\n\t%s", $1.code, $2.code) ;
                                                               }
                                                               $$.code = gen_code (temp) ; }
                    |                                        { strcpy(temp, "") ;
                                                               $$.code = gen_code (temp) ; }
                    ;

sentencias_mult:   sentencia sentencias_mult           { sprintf (temp, "%s\n%s\n", $1.code, $2.code);
                                                         $$.code = gen_code (temp);}
                |   sentencia                           { $$ = $1 ; }
                ;


lista_expresiones:     expresion ',' lista_expresiones        { sprintf (temp, "(prin1 %s) %s", $1.code, $3.code) ;
                                                                $$.code = gen_code (temp) ; }
                    |  expresion                              { sprintf (temp, "(prin1 %s)", $1.code) ;
                                                                $$.code = gen_code(temp) ; }
                    |  STRING                                 { sprintf (temp, "(prin1 \"%s\")", $1.code) ;
                                                                $$.code = gen_code(temp) ; }
                    |  STRING ',' lista_expresiones           { sprintf (temp, "(prin1 \"%s\") %s", $1.code, $3.code) ;
                                                                $$.code = gen_code (temp) ; }
            ;

expresion:      termino                    { $$ = $1 ; }
            |   expresion '+' expresion    { sprintf (temp, "(+ %s %s)", $1.code, $3.code) ;
                                             $$.code = gen_code (temp) ; }
            |   expresion '-' expresion    { sprintf (temp, "(- %s %s)", $1.code, $3.code) ;
                                             $$.code = gen_code (temp) ; }
            |   expresion '*' expresion    { sprintf (temp, "(* %s %s)", $1.code, $3.code) ;
                                             $$.code = gen_code (temp) ; }
            |   expresion '/' expresion    { sprintf (temp, "(/ %s %s)", $1.code, $3.code) ;
                                             $$.code = gen_code (temp) ; }
            ;

termino:        operando                           { $$ = $1 ; }
            |   '+' operando %prec UNARY_SIGN      { sprintf (temp, "(+ %s)", $2.code) ;
                                                     $$.code = gen_code (temp) ; }
            |   '-' operando %prec UNARY_SIGN      { sprintf (temp, "(- %s)", $2.code) ;
                                                     $$.code = gen_code (temp) ; }
            ;

operando:       IDENTIF                   { if (search_string($1.code) == 1) {
                                                sprintf (temp, "FUNC_%s", $1.code) ;
                                            }
                                            else {
                                                sprintf (temp, "%s", $1.code) ;
                                            }
                                            $$.code = gen_code (temp) ; }
            |   NUMBER                    { sprintf (temp, "%d", $1.value) ;
                                            $$.code = gen_code (temp) ; }
            |  IDENTIF '[' NUMBER ']'     { if (search_string($1.code) == 1) {
                                               sprintf(temp, "(aref FUNC_%s %d)", $1.code, $3.value);
                                            }
                                            else {
                                               sprintf(temp, "(aref %s %d)", $1.code, $3.value);
                                            }
                                            $$.code = gen_code (temp) ; }
            | IDENTIF '(' expresion lista_argumentos ')'   { sprintf (temp, "(%s %s %s)", $1.code, $3.code, $4.code) ;
                                                            $$.code = gen_code (temp) ; }
            |   '(' expresion ')'         { $$ = $2 ; }
            ;


%%                            // SECCION 4    Codigo en C

int n_line = 1 ;

int yyerror (mensaje)
char *mensaje ;
{
    fprintf (stderr, "%s en la linea %d\n", mensaje, n_line) ;
    printf ( "\n") ;	// bye
}

char *int_to_string (int n)
{
    sprintf (temp, "%d", n) ;
    return gen_code (temp) ;
}

char *char_to_string (char c)
{
    sprintf (temp, "%c", c) ;
    return gen_code (temp) ;
}

char *my_malloc (int nbytes)       // reserva n bytes de memoria dinamica
{
    char *p ;
    static long int nb = 0;        // sirven para contabilizar la memoria
    static int nv = 0 ;            // solicitada en total

    p = malloc (nbytes) ;
    if (p == NULL) {
        fprintf (stderr, "No queda memoria para %d bytes mas\n", nbytes) ;
        fprintf (stderr, "Reservados %ld bytes en %d llamadas\n", nb, nv) ;
        exit (0) ;
    }
    nb += (long) nbytes ;
    nv++ ;

    return p ;
}
/*
void replace_substring (char *string, char *sub_string){
    char *p;
    char s1[] = "FUNC";
    do {
    p = strstr(string, s1);
    if (p != NULL) {
        size_t len1 = strlen(s1);
        size_t len2 = strlen(sub_string);
        if (len1 != len2)
            memmove(p + len2, p + len1, strlen(p + len1) + 1);
        memcpy(p, sub_string, len2);
    }
    } while (p != NULL);
} */

/*
void replace_substring(char *string,  char *new_substring) {
    // Longitud de la subcadena original y la nueva subcadena
    size_t old_len = strlen("FUNC");
    size_t new_len = strlen(new_substring);

    // Puntero para iterar sobre la cadena
    char *pos = string;

    // Busca ocurrencias de la subcadena original en la cadena
    while ((pos = strstr(pos, "FUNC")) != NULL) {
        // Copia la parte de la cadena antes de la ocurrencia
        memmove(pos + new_len, pos + old_len, strlen(pos + old_len) + 1);

        // Copia la nueva subcadena en lugar de la antigua
        memcpy(pos, new_substring, new_len);

        // Mueve el puntero de búsqueda a la siguiente posición después de la ocurrencia
        pos += new_len;
    }
} */

char* replace_substring(char *string, char *sub_string) {
    const char *p = string;
    const char *s1 = "FUNC";
    size_t len1 = strlen(s1);
    size_t len2 = strlen(sub_string);

    // Contar la cantidad de ocurrencias de s1 en string
    size_t count = 0;
    while ((p = strstr(p, s1)) != NULL) {
        count++;
        p += len1;
    }

    // Calcular el tamaño del nuevo string
    size_t new_len = strlen(string) + (len2 - len1) * count;
    char *new_string = (char *)malloc(new_len + 1);
    if (new_string == NULL) {
        // Manejar error de asignación de memoria
        return NULL;
    }

    // Hacer la copia y los cambios pertinentes
    const char *src = string;
    char *dest = new_string;
    while ((p = strstr(src, s1)) != NULL) {
        size_t n = p - src; // Copiar caracteres antes de la ocurrencia
        memcpy(dest, src, n);
        dest += n;
        memcpy(dest, sub_string, len2); // Reemplazar la subcadena
        dest += len2;
        src = p + len1; // Avanzar a la siguiente ocurrencia
    }
    strcpy(dest, src); // Copiar los caracteres restantes

    return new_string;
}

int is_expression(const char *cadena) {
    int i;
    int longitud = strlen(cadena);

    for (i = 0; i < longitud; i++) {
        if (isdigit(cadena[i])) {
            // Si encuentra un dígito, devuelve 1 (verdadero)
            return 1;
        } else if (cadena[i] == '+' || cadena[i] == '-' || cadena[i] == '*' || cadena[i] == '/') {
            // Si encuentra uno de los operadores, devuelve 1 (verdadero)
            return 1;
        }
    }

    // Si no encuentra ninguno, devuelve 0 (falso)
    return 0;
}

int search_string(char *elemento) {
    for (int i = 0; i < tamaño_locales; i++) {
        if (strcmp(locales[i], elemento) == 0) {
            return 1; // Se encontró el elemento en el array
        }
    }
    return 0; // No se encontró el elemento en el array
}

void add_string(char *nuevaCadena) {
    strcpy(locales[tamaño_locales], nuevaCadena);
    tamaño_locales++; // Incrementa el número de filas
}

void clear_array() {
    for (int i = 0; i < tamaño_locales; i++) {
        locales[i][0] = '\0'; // Asigna una cadena vacía a cada elemento del array
    }
    tamaño_locales = 0;
}

// Función para insertar un símbolo en la tabla
void insertSymbol(Symbol **table, char *name, char *type, bool global) {
    Symbol *newSymbol = (Symbol *)malloc(sizeof(Symbol));
    strcpy(newSymbol->name, name);
    strcpy(newSymbol->type, type);
    newSymbol->active = true; // El símbolo se inserta como activo
    newSymbol->global = global; // Se establece el campo global
    newSymbol->next = *table;
    *table = newSymbol;
}

// Función para buscar un símbolo en la tabla
Symbol* findSymbol(Symbol *table, char *name) {
    while (table != NULL) {
        if (strcmp(table->name, name) == 0 && table->active) {
            return table;
        }
        table = table->next;
    }
    return NULL;
}

// Función para ocultar un símbolo en la tabla
void hideSymbol(Symbol *table, char *name) {
    Symbol *symbol = findSymbol(table, name);
    if (symbol != NULL) {
        symbol->active = false; // Marcar el símbolo como inactivo
    }
}

void removeNonGlobalSymbols(Symbol **table) {
    Symbol *currentSymbol = *table;
    Symbol *prevSymbol = NULL;

    while (currentSymbol != NULL) {
        if (!currentSymbol->global) {
            if (prevSymbol != NULL) {
                // Si no es el primer elemento, conectar el anterior con el siguiente
                prevSymbol->next = currentSymbol->next;
                free(currentSymbol);
                currentSymbol = prevSymbol->next;
            } else {
                // Si es el primer elemento, actualizar la cabeza de la lista
                *table = currentSymbol->next;
                free(currentSymbol);
                currentSymbol = *table;
            }
        } else {
            // Avanzar al siguiente símbolo
            prevSymbol = currentSymbol;
            currentSymbol = currentSymbol->next;
        }
    }
}


/***************************************************************************/
/********************** Seccion de Palabras Reservadas *********************/
/***************************************************************************/

typedef struct s_keyword { // para las palabras reservadas de C
    char *name ;
    int token ;
} t_keyword ;

t_keyword keywords [] = { // define las palabras reservadas y los
    "main",        MAIN,           // y los token asociados
    "int",         INTEGER,
    "puts",        PUTS,
    "printf",      PRINTF,
    "while",       WHILE,
    "if",          IF,
    "else",        ELSE,
    "for",         FOR,
    "return",      RETURN,
    "&&",          AND,
    "||",          OR,
    "!=",          NEQ,
    "==",          EQ,
    "<=",          LTE,
    ">=",          GTE,
    NULL,          0               // para marcar el fin de la tabla
} ;

t_keyword *search_keyword (char *symbol_name)
{                                  // Busca n_s en la tabla de pal. res.
                                   // y devuelve puntero a registro (simbolo)
    int i ;
    t_keyword *sim ;

    i = 0 ;
    sim = keywords ;
    while (sim [i].name != NULL) {
	    if (strcmp (sim [i].name, symbol_name) == 0) {
		                             // strcmp(a, b) devuelve == 0 si a==b
            return &(sim [i]) ;
        }
        i++ ;
    }

    return NULL ;
}


/***************************************************************************/
/******************* Seccion del Analizador Lexicografico ******************/
/***************************************************************************/

char *gen_code (char *name)     // copia el argumento a un
{                                      // string en memoria dinamica
    char *p ;
    int l ;

    l = strlen (name)+1 ;
    p = (char *) my_malloc (l) ;
    strcpy (p, name) ;

    return p ;
}


int yylex ()
{
    int i ;
    unsigned char c ;
    unsigned char cc ;
    char ops_expandibles [] = "!<=>|%/&+-*" ;
    char temp_str [256] ;
    t_keyword *symbol ;

    do {
        c = getchar () ;

        if (c == '#') {	// Ignora las lineas que empiezan por #  (#define, #include)
            do {		//	OJO que puede funcionar mal si una linea contiene #
                c = getchar () ;
            } while (c != '\n') ;
        }

        if (c == '/') {	// Si la linea contiene un / puede ser inicio de comentario
            cc = getchar () ;
            if (cc != '/') {   // Si el siguiente char es /  es un comentario, pero...
                ungetc (cc, stdin) ;
            } else {
                c = getchar () ;	// ...
                if (c == '@') {	// Si es la secuencia //@  ==> transcribimos la linea
                    do {		// Se trata de codigo inline (Codigo embebido en C)
                        c = getchar () ;
                        putchar (c) ;
                    } while (c != '\n') ;
                } else {		// ==> comentario, ignorar la linea
                    while (c != '\n') {
                        c = getchar () ;
                    }
                }
            }
        } else if (c == '\\') c = getchar () ;

        if (c == '\n')
            n_line++ ;

    } while (c == ' ' || c == '\n' || c == 10 || c == 13 || c == '\t') ;

    if (c == '\"') {
        i = 0 ;
        do {
            c = getchar () ;
            temp_str [i++] = c ;
        } while (c != '\"' && i < 255) ;
        if (i == 256) {
            printf ("AVISO: string con mas de 255 caracteres en linea %d\n", n_line) ;
        }		 	// habria que leer hasta el siguiente " , pero, y si falta?
        temp_str [--i] = '\0' ;
        yylval.code = gen_code (temp_str) ;
        return (STRING) ;
    }

    if (c == '.' || (c >= '0' && c <= '9')) {
        ungetc (c, stdin) ;
        scanf ("%d", &yylval.value) ;
//         printf ("\nDEV: NUMBER %d\n", yylval.value) ;        // PARA DEPURAR
        return NUMBER ;
    }

    if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')) {
        i = 0 ;
        while (((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') ||
            (c >= '0' && c <= '9') || c == '_') && i < 255) {
            temp_str [i++] = tolower (c) ;
            c = getchar () ;
        }
        temp_str [i] = '\0' ;
        ungetc (c, stdin) ;

        yylval.code = gen_code (temp_str) ;
        symbol = search_keyword (yylval.code) ;
        if (symbol == NULL) {    // no es palabra reservada -> identificador antes vrariabre
//               printf ("\nDEV: IDENTIF %s\n", yylval.code) ;    // PARA DEPURAR
            return (IDENTIF) ;
        } else {
//               printf ("\nDEV: OTRO %s\n", yylval.code) ;       // PARA DEPURAR
            return (symbol->token) ;
        }
    }

    if (strchr (ops_expandibles, c) != NULL) { // busca c en ops_expandibles
        cc = getchar () ;
        sprintf (temp_str, "%c%c", (char) c, (char) cc) ;
        symbol = search_keyword (temp_str) ;
        if (symbol == NULL) {
            ungetc (cc, stdin) ;
            yylval.code = NULL ;
            return (c) ;
        } else {
            yylval.code = gen_code (temp_str) ; // aunque no se use
            return (symbol->token) ;
        }
    }

//    printf ("\nDEV: LITERAL %d #%c#\n", (int) c, c) ;      // PARA DEPURAR
    if (c == EOF || c == 255 || c == 26) {
//         printf ("tEOF ") ;                                // PARA DEPURAR
        return (0) ;
    }

    return c ;
}


int main ()
{
    yyparse () ;
}

/*
int a = 1 ;
main () {
a = 0 ;
while (a != 10) {
printf ("%d", a) ;
a = a + 1 ;
}
}
*/