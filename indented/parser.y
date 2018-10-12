
%{
#include <cstdio>
#include <iostream>
#include <string>

// stuff from flex that bison needs to know about:
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

void yyerror(const char *s);

#define YYSTYPE std::string
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

%locations
%start start

%%

start: expr NEWLINE {}
		| star_expr NEWLINE {}
		;

star_expr: MULTIPLY expr {}
			;

expr: xor_expr {}
	  | expr OR xor_expr {}
	  ;
xor_expr: and_expr {}
			| xor_expr XOR and_expr {}
		 ;
and_expr: shift_expr {}
			| and_expr AND shift_expr {}
			;
shift_expr: arith_expr {}
			| shift_expr LESS_LESS arith_expr {}
			| shift_expr GREATER_GREATER arith_expr {}
			;
arith_expr: term {}
			| arith_expr PLUS term {}
			| arith_expr MINUS term {}
			;
term: factor {}
		| term MULTIPLY factor {}
		| term T_AT factor {}
		| term R_SLASH factor {}
		| term PERCENT factor {}
		| term R_SLASH_SLASH factor {}
		;
factor: PLUS factor {}
		| MINUS factor {}
		| TILDA factor {}
		| power {}
		;
power: atom {}
		| atom STAR_STAR factor {}
		;
atom : T_NAME {}
		| T_NUMBER {} 
		| T_STRING {}
		| "..." {}
		| "None" {}
		| "True" {}
		| "False" {}
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