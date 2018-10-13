
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
%token TOK_STUFF TOK_REST
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
%token IMPORT
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
%start start

%%

start: expr NEWLINE { $$ = $1; $$->print(); }
		| star_expr NEWLINE{$$ = $1; $$->print(); }
		| expr { $$ = $1; $$->print(); }
		| star_expr{$$ = $1; $$->print(); }
		| END {$$ = $1; $$->print();}
		;

star_expr: MULTIPLY expr {$$ = new Node("star expr",$2); }
			;

expr: expr OR xor_expr { $$ = new Node("expr OR",$1,$3);}
	  | xor_expr {$$ = $1;}
	  ;
xor_expr: xor_expr XOR and_expr {$$ = new Node("xor_expr XOR",$1,$3);}
			| and_expr {$$ = $1;}
		 ;
and_expr: and_expr AND shift_expr {$$ = new Node("and_expr AND",$1,$3);}
			| shift_expr {$$ = $1;}
			;
shift_expr: shift_expr LESS_LESS arith_expr {$$ = new Node("shit_expr <<",$1,$3);}
			| shift_expr GREATER_GREATER arith_expr {$$ = new Node("shit_expr >>",$1,$3);}
			| arith_expr {$$ = $1;}
			;
arith_expr: arith_expr PLUS term {$$ = new Node("arith_expr +",$1,$3);}
			| arith_expr MINUS term {$$ = new Node("arith_expr -",$1,$3);}
			| term {$$ = $1;}
			;
term: term R_SLASH_SLASH factor {$$ = new Node("term //",$1,$3);}
		| term MULTIPLY factor {$$ = new Node("term *",$1,$3);}
		| term T_AT factor {$$ = new Node("term @",$1,$3);}
		| term R_SLASH factor {$$ = new Node("term /",$1,$3);}
		| term PERCENT factor {$$ = new Node("term %",$1,$3);}
		| factor {$$ = $1;}
		;
factor: PLUS factor {$$ = new Node("factor +", $2);}
		| MINUS factor {$$ = new Node("factor -", $2);}
		| TILDA factor {$$ = new Node("factor ~", $2);}
		| power {$$ = $1;}
		;
power: atom STAR_STAR factor {$$ = new Node("power ** ", $1,$3);}
		| atom {$$ = $1; }
		;
atom : T_NAME {$$ = $1;}
		| T_NUMBER {$$ = $1;} 
		| T_STRING {$$ = $1;}
		| "..." {$$ = $1;}
		| "None" {$$ = $1;}
		| "True" {$$ = $1;}
		| "False" {$$ = $1;}
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