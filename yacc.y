%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <stdbool.h>

typedef struct symrec {
    char *name;
    double value;
    struct symrec *next;
} symrec;

symrec *sym_table = NULL;

symrec *putsym(char const *, double);
symrec *getsym(char const *);
FILE *yyin;
void yyerror(char *);
int yylex(void);
bool defined = true;
extern int yylineno;
%}

%union {
    double dval;
    char *sval;
}

%token <dval> NUMBER
%token <sval> IDENTIFIER
%token INCREMENT DECREMENT NEG ABS COS SIN LOG

%type <dval> expression

%left '+' '-'
%left '*' '/' '%'
%left '^'
%left NEG ABS COS SIN LOG INCREMENT DECREMENT

%%

program:
    program statement ';' { }
    | statement ';' { }
    ;

statement:
    IDENTIFIER '=' expression 	{ 
									symrec *s = putsym($1, $3);
									if (defined){
										if (floor($3) == $3) {
											printf("%d\n", (int)s->value);
										} else {
											printf("%lf\n", s->value);
										}
									}
									
									defined = true;
								}
    | error '\n' { 
					yyerror("syntax error"); 
					yyerrok; 
				 }
    ;

expression:
    expression '+' expression { $$ = $1 + $3; }
    | expression '-' expression { $$ = $1 - $3; }
    | expression '*' expression { $$ = $1 * $3; }
    | expression '/' expression { if ($3 == 0) { yyerror("division by zero"); $$ = 0; } else { $$ = $1 / $3; } }
    | expression '%' expression { $$ = fmod($1, $3); }
    | expression '^' expression { $$ = pow($1, $3); }
    | NEG '(' expression ')' { $$ = -$3; }
    | ABS '(' expression ')' { $$ = fabs($3); }
    | COS '(' expression ')' { $$ = cos($3); }
    | SIN '(' expression ')' { $$ = sin($3); }
    | LOG '(' expression ')' { $$ = log10($3); }
    | INCREMENT IDENTIFIER { symrec *s = getsym($2); if (s) { s->value++; $$ = s->value; } else { $$ = 0; } }
    | IDENTIFIER INCREMENT { symrec *s = getsym($1); if (s) { $$ = s->value++; } else { $$ = 0; } }
    | DECREMENT IDENTIFIER { symrec *s = getsym($2); if (s) { s->value--; $$ = s->value; } else { $$ = 0; } }
    | IDENTIFIER DECREMENT { symrec *s = getsym($1); if (s) { $$ = s->value--; } else { $$ = 0; } }
    | IDENTIFIER { symrec *s = getsym($1); if (s) { $$ = s->value; } else { $$ = 0; } }
    | NUMBER { $$ = $1; }
    | '(' expression ')' { $$ = $2; }
    ;

%%
symrec *putsym(char const *sym_name, double value) {
    symrec *ptr;
    ptr = (symrec *) malloc(sizeof(symrec));
    ptr->name = strdup(sym_name);
    ptr->value = value;
    ptr->next = sym_table;
    sym_table = ptr;
    return ptr;
}

symrec *getsym(char const *sym_name) {
    symrec *ptr;
    for (ptr = sym_table; ptr != (symrec *) 0; ptr = (symrec *)ptr->next)
        if (strcmp(ptr->name, sym_name) == 0)
            return ptr;
    fprintf(stderr, "Line %d: %s is undefined\n", yylineno, sym_name);
	defined = false;
    return 0;
}

void yyerror(char *s) {
    extern char *yytext;
    fprintf(stderr, "Line %d: %s near token '%s'\n", yylineno, s, yytext);
}



int main(void) {
    char filename[100];
    FILE *file;
    
    printf("Enter the file name: ");
    scanf("%s", filename);

    file = fopen(filename, "r");
    if (file == NULL) {
        printf("Error opening file %s\n", filename);
        return 1;
    }

    yyin = file;

    int result = yyparse();
    fclose(file);
    return result;
}
