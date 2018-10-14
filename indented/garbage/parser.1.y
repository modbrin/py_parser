
%{
#include <cstdio>
#include <iostream>
#include <string>
#include "string.h"

using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char *s);


#include "node.h"

// Node* top = new Node("root");
#define YYDEBUG 1
#define YYSTYPE Node*
%}

%token NONE
%token TRUE
%token FALSE
%token IMPORT
%token NEWLINE
%token INDENT
%token DEDENT
%token END
%token T_NUMBER 
%token T_STRING
%token T_NAME
%token PLUS
%token MULTIPLY
%token MINUS
%token OR
%token TILDA
%token LESS_LESS
%token GREATER_GREATER
%token STAR_STAR
%token R_SLASH
%token R_SLASH_SLASH
%token T_AT
%token PERCENT
%token AND
%token XOR
%token DEF 
%token MINUS_GREATER
%token L_PAREN
%token R_PAREN
%token EQUAL
%token COMMA
%token COLON
%token SEMICOLON
%token PLUS_EQUAL
%token MINUS_EQUAL
%token STAR_EQUAL
%token AT_EQUAL
%token R_SLASH_EQUAL
%token PERCENT_EQUAL
%token AND_EQUAL
%token BAR_EQUAL
%token XOR_EQUAL
%token LESS_LESS_EQUAL
%token GREATER_GREATER_EQUAL
%token STAR_STAR_EQUAL 
%token SLASH_SLASH_EQUAL
%token T_PASS
%token T_BREAK 
%token T_CONTINUE  
%token T_RETURN 
%token FROM
%token T_DOT 
%token T_DOT_DOT_DOT
%token T_AS
%token T_IF 
%token T_ELIF 
%token T_ELSE
%token T_WHILE 
%token T_FOR
%token T_IN
%token LIT_OR 
%token LIT_AND
%token LIT_NOT
%token LESS
%token GREATER
%token EQUAL_EQUAL
%token GREATER_EQUAL
%token LESS_EQUAL
%token LESS_GREATER
%token EXCL_EQUAL
%token NOT_IN
%token T_IS
%token IS_NOT


%locations

%%
root:
root stuff | stuff ;

stuff: 
	NONE {$1->print("");}
	|
	TRUE {$1->print("");}
	|
	FALSE {$1->print("");}
	|
	IMPORT {$1->print("");}
	|
	NEWLINE {$1->print("");}
	|
	INDENT {$1->print("");}
	|
	DEDENT {$1->print("");}
	|
	END {$1->print("");}
	|
	T_NUMBER {$1->print("");}
	|
	T_STRING {$1->print("");}
	|
	T_NAME {$1->print("");}
	|
	PLUS {$1->print("");}
	|
	MULTIPLY {$1->print("");}
	|
	MINUS {$1->print("");}
	|
	OR {$1->print("");}
	|
	TILDA {$1->print("");}
	|
	LESS_LESS {$1->print("");}
	|
	GREATER_GREATER {$1->print("");}
	|
	STAR_STAR {$1->print("");}
	|
	R_SLASH	{$1->print("");}
	|
	R_SLASH_SLASH {$1->print("");}
	|
	T_AT {$1->print("");}
	|
	PERCENT {$1->print("");}
	|
	AND	{$1->print("");}
	|
	XOR {$1->print("");}
	|
	DEF {$1->print("");}
	|
	MINUS_GREATER {$1->print("");}
	|
	L_PAREN {$1->print("");}
	|
	R_PAREN {$1->print("");}
	|
	EQUAL {$1->print("");}
	|
	COMMA {$1->print("");}
	|
	COLON {$1->print("");}
	|
	SEMICOLON {$1->print("");}
	|
	PLUS_EQUAL {$1->print("");}
	|
	MINUS_EQUAL {$1->print("");}
	|
	STAR_EQUAL {$1->print("");}
	|
	AT_EQUAL {$1->print("");}
	|
	R_SLASH_EQUAL {$1->print("");}
	|
	PERCENT_EQUAL {$1->print("");}
	|
	AND_EQUAL {$1->print("");}
	|
	BAR_EQUAL {$1->print("");}
	|
	XOR_EQUAL {$1->print("");}
	|
	LESS_LESS_EQUAL {$1->print("");}
	|
	GREATER_GREATER_EQUAL {$1->print("");}
	|
	STAR_STAR_EQUAL {$1->print("");}
	|
	SLASH_SLASH_EQUAL {$1->print("");}
	|
	T_PASS {$1->print("");}
	|
	T_BREAK {$1->print("");}
	|
	T_CONTINUE {$1->print("");}
	|
	T_RETURN {$1->print("");}
	|
	FROM {$1->print("");}
	|
	T_DOT {$1->print("");}       
	|
	T_DOT_DOT_DOT {$1->print("");}       
	|
	T_AS {$1->print("");}       
	|
	T_IF {$1->print("");}        
	|
	T_ELIF {$1->print("");}       
	|
	T_ELSE {$1->print("");}       
	|
	T_WHILE {$1->print("");}       
	|
	T_FOR {$1->print("");}        
	|
	T_IN {$1->print("");}                 
	|
	LIT_OR {$1->print("");}              
	|
	LIT_AND {$1->print("");}           
	|
	LIT_NOT {$1->print("");}	             
	|
	LESS {$1->print("");}            
	|
	GREATER {$1->print("");}
	|
	EQUAL_EQUAL {$1->print("");}
	|
	GREATER_EQUAL {$1->print("");}	 
	|
	LESS_EQUAL {$1->print("");}
	|
	LESS_GREATER {$1->print("");}
	|
	EXCL_EQUAL {$1->print("");}
	|
	NOT_IN {$1->print("");} 
	|
	T_IS {$1->print("");}    
	|
	IS_NOT {$1->print("");}
	;
%%

const char* g_current_filename = "stdin";

int main(int argc, char* argv[]) {
    yyin = stdin;
#if YYDEBUG
    yydebug = 1;
#endif

    if(argc == 2) {
        yyin = fopen(argv[1], "r");
        g_current_filename = argv[1];
        if(!yyin) {
            perror(argv[1]);
            return 1;
        }
    }

    // parse through the input until there is no more:
    do {
        yyparse();
    } while (!feof(yyin));

    // Only in newer versions, apparently.
    // yylex_destroy();
}

void yyerror(const char *s) {
    std::cerr << g_current_filename << ":" << yylloc.first_line << ":" << yylloc.first_column << "-" << yylloc.last_column << ": Parse error: " << s << std::endl;
    exit(-1);  // Might as well halt now.
}