%{                          // SECCION 1 Declaraciones de C-Yacc

#include <stdio.h>
#include <ctype.h>            // declaraciones para tolower
#include <string.h>           // declaraciones para cadenas
#include <stdlib.h>           // declaraciones para exit ()

#define FF fflush(stdout);    // para forzar la impresion inmediata

int yylex () ;
int yyerror () ;
char *mi_malloc (int) ;
char *gen_code (char *) ;
char *int_to_string (int) ;
char *char_to_string (char) ;
int is_expression(const char *cadena) ;

char temp [2048] ;

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
%token SETQ
%token SETF
%token DEFUN
%token PRINT
%token PRIN1
%token LOOP
%token DO
%token IF
%token PROGN
%token AND            // Identifica el operador lógico AND
%token OR             // Identifica el operador lógico OR
%token NEQ            // Identifica el operador de desigualdad !=
%token LTE            // Identifica el operador menor o igual que <=
%token GTE            // Identifica el operador mayor o igual que >=
%token MOD
%token NOT

%right '='                    // es la ultima operacion que se debe realizar
%left '+' '-'                 // menor orden de precedencia
%left '*' '/'                 // orden de precedencia intermedio
%left UNARY_SIGN              // mayor orden de precedencia

%%                            // Seccion 3 Gramatica - Semantico

axioma:       programa '(' MAIN ')'           { printf ("\n%smain\n\n", $1.code) ; }
                r_expr                                { ; }
            ;

r_expr:                                  { ; }
            |   axioma                   { ; }
            ;

programa:   '(' linea ')' programa                          {sprintf (temp, "%s\n%s", $2.code, $4.code);
                                                           $$.code = gen_code(temp);}
          | '(' DEFUN MAIN '(' ')' cuerpo_funcion ')'     {sprintf (temp, ": main %s ;\n", $6.code) ;
                                                                            $$.code = gen_code (temp) ; }

linea:   sentencia_variable     {$$ = $1;}
       | sentencia_funcion      {$$ = $1;}

sentencia_variable:      SETQ IDENTIF expresion      { if (strcmp($3.code, "0") == 0) {
                                                                sprintf (temp, "variable %s\n", $2.code) ;
                                                            }
                                                            else {
                                                                sprintf (temp, "variable %s\n%s %s !\n", $2.code, $3.code, $2.code) ;
                                                            }
                                                            $$.code = gen_code (temp) ; }
                    |   SETF IDENTIF expresion      { sprintf (temp, "%s %s !\n", $3.code, $2.code) ;
                                                            $$.code = gen_code (temp) ; }

                ;

sentencia_funcion: DEFUN IDENTIF '('  ')' cuerpo_funcion      {sprintf (temp, ": %s %s ;\n", $2.code, $5.code) ;
                                                                    $$.code = gen_code (temp) ; }

cuerpo_funcion: sentencia cuerpo_funcion            {sprintf(temp, "%s\n%s", $1.code, $2.code);
                                                    $$.code = gen_code(temp); }
                |                                   { strcpy(temp, "") ;
                                                    $$.code = gen_code (temp) ; }
                ;

sentencia:
             '(' SETF IDENTIF expresion ')'                                   {sprintf (temp, "%s %s !", $4.code, $3.code) ;
                                                                                    $$.code = gen_code (temp) ; }
            |  '(' PRINT STRING ')'                                          {sprintf(temp, ".\" %s\"cr", $3.code);
                                                                             $$.code = gen_code(temp);}
            |   '(' PRIN1 expresion_print ')'                                     { sprintf(temp, "%s", $3.code);
                                                                            $$.code = gen_code(temp);}
            | '(' LOOP WHILE expresion_logica DO cuerpo_funcion ')'     {sprintf(temp, "BEGIN\n\t%s\nWHILE\n\t%s\nREPEAT", $4.code, $6.code);
                                                                              $$.code = gen_code(temp);}
            | '(' IF expresion_logica cuerpo_if ')'                     {sprintf(temp, "%s IF\n\t%s", $3.code, $4.code);
                                                                         $$.code = gen_code(temp);}
            | '(' IDENTIF ')'                                           {$$ = $2;}
            ;

expresion_print:    expresion {sprintf(temp, "%s .", $1.code);
                               $$.code = gen_code(temp);}
                  | STRING    {sprintf(temp, ".\" %s\"cr", $1.code);
                               $$.code = gen_code(temp);}
                  ;

cuerpo_if:  '(' PROGN cuerpo_funcion ')' sentencia                              {sprintf(temp, "%s\nELSE\n\t%s\nTHEN", $3.code, $5.code);
                                                                                 $$.code = gen_code(temp); }
           | sentencia sentencia                                                 {sprintf(temp, "%s\nELSE\n\t%s\nTHEN", $1.code, $2.code);
                                                                                 $$.code = gen_code(temp); }
           | sentencia '(' PROGN cuerpo_funcion ')'                                  {sprintf(temp, "%s\nELSE\n\t%s\nTHEN", $1.code, $4.code);
                                                                                     $$.code = gen_code(temp); }
           | '(' PROGN cuerpo_funcion ')' '(' PROGN cuerpo_funcion ')'           {sprintf(temp, "%s\nELSE\n\t%s\nTHEN", $3.code, $7.code);
                                                                                 $$.code = gen_code(temp); }
           | '(' PROGN cuerpo_funcion ')'                                       {sprintf(temp, "%s\nTHEN", $3.code);
                                                                                  $$.code = gen_code(temp); }
           | sentencia                                                          {sprintf(temp, "%s\nTHEN", $1.code);
                                                                                   $$.code = gen_code(temp); }
           ;

expresion_logica:        termino_logico                             { $$ = $1 ; }
                      |  '(' '+' expresion_logica expresion_logica ')'      { sprintf (temp, "%s %s +", $3.code, $4.code) ;
                                                                             $$.code = gen_code (temp) ; }
                      |   '(' '-' expresion_logica expresion_logica ')'     { sprintf (temp, "%s %s -", $3.code, $4.code) ;
                                                                             $$.code = gen_code (temp) ; }
                      |   '(' '*' expresion_logica expresion_logica ')'     { sprintf (temp, "%s %s *", $3.code, $4.code) ;
                                                                             $$.code = gen_code (temp) ; }
                      |   '(' '/' expresion_logica expresion_logica ')'     { sprintf (temp, "%s %s /", $3.code, $4.code) ;
                                                                            $$.code = gen_code (temp) ; }
                      |  '(' AND expresion_logica expresion_logica ')'      { sprintf (temp, "%s %s and", $3.code, $4.code) ;
                                                                              $$.code = gen_code (temp) ; }
                      |   '(' OR expresion_logica expresion_logica ')'     { sprintf (temp, "%s %s or", $3.code, $4.code) ;
                                                                             $$.code = gen_code (temp) ; }
                      |   '(' NEQ expresion_logica expresion_logica ')'     { sprintf (temp, "%s %s = 0=", $3.code, $4.code) ;
                                                                              $$.code = gen_code (temp) ; }
                      |   '(' '=' expresion_logica expresion_logica ')'     { sprintf (temp, "%s %s =", $3.code, $4.code) ;
                                                                             $$.code = gen_code (temp) ; }
                      |  '(' '<' expresion_logica expresion_logica ')'      { sprintf (temp, "%s %s <", $3.code, $4.code) ;
                                                                                 $$.code = gen_code (temp) ; }
                      |   '(' '>' expresion_logica expresion_logica ')'     { sprintf (temp, "%s %s >", $3.code, $4.code) ;
                                                                                 $$.code = gen_code (temp) ; }
                      |   '(' LTE expresion_logica expresion_logica ')'     { sprintf (temp, "%s %s <=", $3.code, $4.code) ;
                                                                                $$.code = gen_code (temp) ; }
                      |   '(' GTE expresion_logica expresion_logica ')'     { sprintf (temp, "%s %s >=", $3.code, $4.code) ;
                                                                                 $$.code = gen_code (temp) ; }
                      |   '(' MOD expresion_logica expresion_logica ')'     { sprintf (temp, "%s %s mod", $3.code, $4.code) ;
                                                                             $$.code = gen_code (temp) ; }
    ;

termino_logico:        operando                            { $$ = $1 ; }
            |   '-' operando %prec UNARY_SIGN       { sprintf (temp, "negate %s", $2.code) ;
                                                    $$.code = gen_code (temp) ; }
            | NOT operando %prec UNARY_SIGN         { sprintf (temp, "0= %s", $2.code) ;
                                                      $$.code = gen_code (temp) ; }
            ;


expresion:      termino                             { $$ = $1 ; }
            |  '(' '+' expresion expresion ')'      { sprintf (temp, "%s %s +", $3.code, $4.code) ;
                                                    $$.code = gen_code (temp) ; }
            |   '(' '-' expresion expresion ')'     { sprintf (temp, "%s %s -", $3.code, $4.code) ;
                                                    $$.code = gen_code (temp) ; }
            |   '(' '*' expresion expresion ')'     { sprintf (temp, "%s %s *", $3.code, $4.code) ;
                                                    $$.code = gen_code (temp) ; }
            |   '(' '/' expresion expresion ')'     { sprintf (temp, "%s %s /", $3.code, $4.code) ;
                                                    $$.code = gen_code (temp) ; }
            ;

termino:        operando                            { $$ = $1 ; }
            |   '-' operando %prec UNARY_SIGN       { sprintf (temp, "negate %s", $2.code) ;
                                                    $$.code = gen_code (temp) ; }
            ;

operando:       IDENTIF                 { sprintf (temp, "%s @", $1.code) ;
                                        $$.code = gen_code (temp) ; }
            |   NUMBER                  { sprintf (temp, "%d", $1.value) ;
                                        $$.code = gen_code (temp) ; }
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
    "setq",        SETQ,
    "setf",        SETF,
    "defun",       DEFUN,
    "print",       PRINT,
    "prin1",       PRIN1,
    "loop",        LOOP,
    "while",       WHILE,
    "do",          DO,
    "if",           IF,
    "progn",        PROGN,
    "and",          AND,
    "or",          OR,
    "/=",          NEQ,
    "mod",         MOD,
    "<=",          LTE,
    ">=",          GTE,
    "not",         NOT,
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
