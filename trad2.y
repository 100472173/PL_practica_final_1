/* Grupo de trabajo 03. Alejandro Díaz Cuéllar y Tomás Mendizábal*/
/* 100472173@alumnos.uc3m.es 100461170@alumos.uc3m.es */

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
void replace_substring (char *string, char *sub_string)  ;

char temp [2048] ;

// Definitions for explicit attributes

typedef struct s_attr {
        int value ;
        char *code ;
} t_attr ;

#define YYSTYPE t_attr

%}
// TODO: mirar lo de los parentesis de cierre y las tabulaciones. Tal vez lisp se las trague.
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

%right '='                    // es la ultima operacion que se debe realizar
%left '+' '-'                 // menor orden de precedencia
%left '*' '/'                 // orden de precedencia intermedio
%left UNARY_SIGN              // mayor orden de precedencia

%%                            // Seccion 3 Gramatica - Semantico

axioma:       decl_variables def_funciones             { printf ("\n%s%s\n(main) ;\n\n", $1.code, $2.code) ; }
              r_expr                                   { ; }
            ;

r_expr:        axioma                 { ; }
            |                         { ; }

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

lista_decl_var: ',' IDENTIF '=' NUMBER lista_decl_var            { sprintf (temp, "(setq %s %d) %s", $2.code, $4.value, $5.code) ;
                                                                   $$.code = gen_code (temp) ; }
           |                                                     { strcpy(temp, "") ;
                                                                   $$.code = gen_code (temp) ; }
           ;

def_funciones:  MAIN '(' ')' '{' cuerpo_funcion '}'     { replace_substring($5.code, "main");
                                                        sprintf (temp, "(defun main ()\n%s)", $5.code) ;
                                                          $$.code = gen_code (temp) ; }
               | sentencia_funcion def_funciones        {sprintf (temp, "%s\n%s", $1.code, $2.code) ;
                                                          $$.code = gen_code (temp) ;}
               ;

sentencia_funcion: IDENTIF '(' ')' '{' cuerpo_funcion '}'    {replace_substring($5.code, $1.code);
                                                            sprintf (temp, "(defun %s ()\n%s)", $1.code, $5.code) ;
                                                              $$.code = gen_code (temp) ; }

cuerpo_funcion:     sentencia  cuerpo_funcion        { sprintf (temp, "%s\n%s", $1.code, $2.code) ;
                                                          $$.code = gen_code (temp) ; }
                    |                                   { strcpy(temp, "") ;
                                                         $$.code = gen_code (temp) ; }
                 ;

sentencia:  var_local                                           {$$ = $1;}
            | PRINTF '(' STRING ',' lista_expresiones ')' ';' {$$ = $5;}
            | PUTS '(' STRING ')' ';'                          { sprintf (temp, "(print \"%s\")", $3.code) ;
                                                              $$.code = gen_code (temp) ; }
            | WHILE '(' expresion ')' '{' sentencias_mult '}'     {sprintf (temp, "(loop while %s do (%s))", $3.code, $6.code) ;
                                                              $$.code = gen_code (temp) ;}
            | IF '(' expresion ')' '{' sentencias_if '}'        {sprintf (temp, "(if %s %s)", $3.code, $6.code) ;
                                                              $$.code = gen_code (temp) ;}
            | IF '(' expresion ')' '{' sentencias_if '}' ELSE '{' sentencias_if '}'       {sprintf (temp, "(if %s %s %s)", $3.code, $6.code, $10.code) ;
                                                                                $$.code = gen_code (temp) ;}        
            | FOR '(' var_local  expresion ';' incr_descenso ')' '{' sentencias_mult '}'   {sprintf (temp, "(loop while %s do (%s))", $4.code, $9.code);
                                                                                $$.code = gen_code (temp) ;}   
            ;
var_local: IDENTIF '=' expresion ';'                       { sprintf (temp, "(setf FUNC-%s %s)", $1.code, $3.code) ;
                                                             $$.code = gen_code (temp) ; }
            |  INTEGER IDENTIF ';'                             { sprintf (temp, "(setq FUNC-%s 0)", $2.code) ;
                                                                      $$.code = gen_code (temp) ; }
            | INTEGER IDENTIF '=' NUMBER lista_decl_var_local ';'   { sprintf (temp, "(setq FUNC-%s %d) %s", $2.code, $4.value, $5.code) ;
                                                                      $$.code = gen_code (temp) ; }

lista_decl_var_local: ',' IDENTIF '=' NUMBER lista_decl_var_local            { sprintf (temp, "(setq FUNC-%s %d) %s", $2.code, $4.value, $5.code) ;
                                                                   $$.code = gen_code (temp) ; }
           |                                                     { strcpy(temp, "") ;
                                                                   $$.code = gen_code (temp) ; }
           ;          

sentencias_if:    sentencia sentencias_if           {sprintf (temp, "\nprogn %s\n\t%s\n", $1.code, $2.code);
                                                               $$.code = gen_code (temp);}
                |   sentencia                         {$$ = $1;}
                ;
sentencias_mult:   sentencia sentencias_mult           {sprintf (temp, "%s\n%s\n", $1.code, $2.code);
                                                               $$.code = gen_code (temp);}
                |   sentencia                         {$$ = $1;}
                ;
incr_descenso:  IDENTIF '=' NUMBER lista_decl_var_local            { ; }
                ;


lista_expresiones:     expresion ',' lista_expresiones        {sprintf (temp, "(prin1 %s) %s", $1.code, $3.code);
                                                               $$.code = gen_code (temp);}
                    |  expresion                              {sprintf (temp, "(prin1 %s)", $1.code) ;
                                                               $$.code = gen_code(temp) ;}
                    |  STRING                                 {sprintf (temp, "(prin1 \"%s\")", $1.code) ;
                                                               $$.code = gen_code(temp) ;}

                    |  STRING ',' lista_expresiones           {sprintf (temp, "(prin1 \"%s\") %s", $1.code, $3.code);
                                                               $$.code = gen_code (temp);}
            ;

expresion:      termino                  { $$ = $1 ; }
            |   expresion '+' expresion  { sprintf (temp, "(+ %s %s)", $1.code, $3.code) ;
                                           $$.code = gen_code (temp) ; }
            |   expresion '-' expresion  { sprintf (temp, "(- %s %s)", $1.code, $3.code) ;
                                           $$.code = gen_code (temp) ; }
            |   expresion '*' expresion  { sprintf (temp, "(* %s %s)", $1.code, $3.code) ;
                                           $$.code = gen_code (temp) ; }
            |   expresion '/' expresion  { sprintf (temp, "(/ %s %s)", $1.code, $3.code) ;
                                           $$.code = gen_code (temp) ; }
            ;

termino:        operando                           { $$ = $1 ; }                          
            |   '+' operando %prec UNARY_SIGN      { sprintf (temp, "(+ %s)", $2.code) ;
                                                     $$.code = gen_code (temp) ; }
            |   '-' operando %prec UNARY_SIGN      { sprintf (temp, "(- %s)", $2.code) ;
                                                     $$.code = gen_code (temp) ; }    
            ;

operando:       IDENTIF                  { sprintf (temp, "%s", $1.code) ;
                                           $$.code = gen_code (temp) ; }
            |   NUMBER                   { sprintf (temp, "%d", $1.value) ;
                                           $$.code = gen_code (temp) ; }
            |   '(' expresion ')'        { $$ = $2 ; }
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
