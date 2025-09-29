%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>  // For strdup
#include "yacc.tab.h"

extern int yylineno;
%}

%option yylineno

digit      [0-9]
letter     [a-zA-Z]
id         {letter}({letter}|{digit}){0,15}

%%
"="                { return '='; }
"("                { return '('; }
")"                { return ')'; }
"+"                { return '+'; }
"-"                { return '-'; }
"*"                { return '*'; }
"/"                { return '/'; }
"^"                { return '^'; }
"%"                { return '%'; }
"++"               { return INCREMENT; }
"--"               { return DECREMENT; }
"neg"              { return NEG; }
"abs"              { return ABS; }
"cos"              { return COS; }
"sin"              { return SIN; }
"log"              { return LOG; }
{digit}+(\.{digit}+)? { yylval.dval = atof(yytext); return NUMBER; }
{id}               { yylval.sval = strdup(yytext); return IDENTIFIER; }
[\n]               { return ';'; }
[ \t]              ;
.                  { 
                      fprintf(stderr, "Line %d: unexpected token '%s'\n", yylineno, yytext);
                      return yytext[0];
                  }
%%

int yywrap() {
    return 1;
}
