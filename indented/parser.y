
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
#define YYDEBUG 1

#include "node.h"

// Node* top = new Node("root");

#define YYSTYPE Node*
%}

%token NONE
%token TRUE
%token FALSE
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

%token CLASS
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


/*
single_input: NEWLINE | simple_stmt | compound_stmt NEWLINE
file_input: (NEWLINE | stmt)* ENDMARKER
eval_input: testlist NEWLINE* ENDMARKER
funcdef: 'def' NAME parameters :' suite
parameters: '(' [NAME (, NAME )* ] ')'
stmt: simple_stmt | compound_stmt
simple_stmt: small_stmt (';' small_stmt)* [';'] NEWLINE
small_stmt: (expr_stmt | "pass" | flow_stmt | import_stmt)
expr_stmt: testlist_star_expr ( (augassign testlist) |
                     ('=' (testlist_star_expr)*) )
augassign: ('+=' | '-=' | '*=' | '@=' | '/=' | '%=' | '&=' | '|=' | '^=' |
            '<<=' | '>>=' | '**=' | '//=')
flow_stmt = 'break' | 'continue'| 'return' [testlist]
/*



compound_stmt: if_stmt | while_stmt | for_stmt | funcdef | classdef
if_stmt: 'if' test ':' suite ('elif' test ':' suite)* [else ':' suite]
while_stmt: 'while' test ':' suite ['else' ':' suite]
for_stmt: 'for' exprlist 'in' testlist ':' suite ['else' ':' suite]
suite: simple_stmt | NEWLINE INDENT stmt+ DEDENT
test: or_test ['if' or_test 'else' test]
or_test: and_test ('or' and_test)*
and_test: not_test ('and' not_test)*
not_test: 'not' not_test | comparison
comparison: expr (comp_op expr)*
comp_op: '<'|'>'|'=='|'>='|'<='|'<>'|'!='|'in'|'not' 'in'|'is'|'is' 'not'
*/

%%

/*
start: expr NEWLINE { $$ = $1; $$->print(); }
		| star_expr NEWLINE{$$ = $1; $$->print(); }
		| expr { $$ = $1; $$->print(); }
		| star_expr{$$ = $1; $$->print(); }
		| END {$$ = $1; $$->print();}
		| compound_stmt {$$ = $1; $$->print();}
		| compound_stmt NEWLINE {$$ = $1; $$->print();}
		;

*/
start: eval_input { $$ = $1;cout <<"eval input"<<endl; $$->print(); return 0; }
		| file_input { $$ = $1; cout <<"file input "<<endl; $$->print(); return 0; }
		;
/*
start: file_input { $$ = $1; $$->print(); }
		;
*/
eval_input: testlist END {$$ = $1; }
			| testlist NEWLINE END {$$ = new Node("eval input ",$1,$2); };
			;

single_input: NEWLINE  {$$ = $1; }
			 | simple_stmt {$$ = $1; }
			 | compound_stmt NEWLINE {$$ = $1; }
			 ;


file_input : file_inp END {$$ = $1; }

file_inp: file_inp NEWLINE{$$ = new Node("file inp ",$1,$2); };
			| file_inp stmt{$$ = new Node("file inp ",$1,$2); };
			| stmt{$$ = $1; }
			| NEWLINE{$$ = $1; }
			;

stmt: simple_stmt 	 {$$ = $1; }
		|  compound_stmt 	 {$$ = $1; }
		;

stmts: stmts stmt {$$ = new Node("stmts ",$1,$2)};
		| stmt {$$ = $1; }
		;


small_stmts: small_stmts SEMICOLON small_stmt {$$ = new Node("small_stmts ",$1,$3);}
			| SEMICOLON small_stmt {$$ = $2; }
			;

simple_stmt: small_stmt small_stmts NEWLINE {$$ = new Node("simple_stmt ",$1,$2);}
			| small_stmt small_stmts SEMICOLON NEWLINE {$$ = new Node("simple_stmt ",$1,$2);}
			| small_stmt NEWLINE {$$ = new Node("simple_stmt ",$1);}
			|  small_stmt SEMICOLON NEWLINE {$$ = new Node("simple_stmt ",$1);}
			;

small_stmt: expr_stmt  {$$ = $1; }
			| T_PASS  {$$ = $1; }
			| flow_stmt {$$ = $1; };
		 	| import_stmt  {$$ = $1; }
		 	| funcall {$$ = $1; }
			;



import_stmt : import_name {$$ = $1; }
			| import_from {$$ = $1; }
			;
import_name : IMPORT dotted_as_name {$$ = $2;}
			;



import_from: FROM dotted_name IMPORT import_as_name {$$ = new Node("import from ",$2,$4);}
			| FROM dotted_name IMPORT MULTIPLY {$$ = new Node("import from ",$2,$4);}
			;

import_as_name: T_NAME T_AS  T_NAME {$$ = new Node("import as names ",$1,$3);}
			| T_NAME {$$ = $1; }
			;


dotted_as_name: dotted_name T_AS T_NAME {$$ = new Node("dotted_as_name",$1,$3);}
				| dotted_name{$$ = $1;}
				;
dotted_name : dotted_name T_DOT T_NAME {$$ = new Node("dotted_name ",$1,$3);}
			| T_NAME {$$ = $1;}
			;


testlist_star_exprs_equal: testlist_star_exprs_equal EQUAL testlist_star_expr {$$ = new Node("testlist_star_exprs_equal ",$1,$3);}
					| EQUAL testlist_star_expr { $$ = $2; }
					| /*empty */ {$$ = 0;}
					;


expr_stmt: testlist_star_expr augassign testlist {$$ = new Node("expr_stmt ",$1,$2,$3);}
			| testlist_star_expr testlist_star_exprs_equal {$$ = new Node("expr_stmt ",$1,$2); }
			;

testlist_star_exprs_comma: testlist_star_exprs_comma COMMA test COMMA {$$ = new Node("testlist_star_exprs_comma ",$1,$3);}
							| testlist_star_exprs_comma COMMA star_expr COMMA {$$ = new Node("testlist_star_exprs_comma ",$1,$3);}
							| testlist_star_exprs_comma COMMA test {$$ = new Node("testlist_star_exprs_comma ",$1,$3);}
							| testlist_star_exprs_comma COMMA star_expr {$$ = new Node("testlist_star_exprs_comma ",$1,$3);}
							| COMMA test COMMA {$$ = new Node("testlist_star_exprs_comma ",$2);}
							| COMMA test {$$ = new Node("testlist_star_exprs_comma ",$2);}
							| COMMA star_expr COMMA {$$ = new Node("testlist_star_exprs_comma ",$2);}
							| COMMA star_expr {$$ = new Node("testlist_star_exprs_comma ",$2);}
							;


testlist_star_expr: test testlist_star_exprs_comma COMMA {$$ = new Node("testlist_star_expr ",$1,$2);}
					| test testlist_star_exprs_comma {$$ = new Node("testlist_star_expr ",$1,$2);}
					| star_expr testlist_star_exprs_comma COMMA {$$ = new Node("testlist_star_expr ",$1,$2);}
					| star_expr testlist_star_exprs_comma {$$ = new Node("testlist_star_expr ",$1,$2);}
					| test COMMA {$$ = $1; }
					| test {$$ = $1; }
					| star_expr COMMA {$$ = $1; }
					| star_expr {$$ = $1; }
					;

augassign: PLUS_EQUAL {$$ = $1; }
		|  MINUS_EQUAL {$$ = $1; }
		|  STAR_EQUAL  {$$ = $1; }
		| AT_EQUAL {$$ = $1; }
		| R_SLASH_EQUAL {$$ = $1; }
		| PERCENT_EQUAL {$$ = $1; }
		| AND_EQUAL {$$ = $1; }
		| BAR_EQUAL {$$ = $1; }
		| XOR_EQUAL {$$ = $1; }
		| LESS_LESS_EQUAL {$$ = $1; }
		| GREATER_GREATER_EQUAL {$$ = $1; }
		| STAR_STAR_EQUAL {$$ = $1; }
		| SLASH_SLASH_EQUAL {$$ = $1; }
		;


flow_stmt: T_BREAK  {$$ = $1; }
	| T_CONTINUE  {$$ = $1; }
	| T_RETURN testlist  {$$ = new Node("return value ",$2); }
	| T_RETURN  {$$ = $1; }
	;


compound_stmt: if_stmt {$$ = $1; }
			| while_stmt {$$ = $1; }
			| for_stmt {$$ = $1; }  //ADD HERE
			| funcdef  {$$ = $1; }
			| classdef  {$$ = $1; }
			;
funcdef : DEF T_NAME L_PAREN parameters R_PAREN COLON suite {$$ = new Node("funcdef ",$2,$4,$7);}
		 | DEF T_NAME L_PAREN R_PAREN COLON suite {$$ = new Node("funcdef ",$2,$6);}
		 ;

funcall : T_NAME L_PAREN parameters R_PAREN{$$ = new Node("func call ",$1,$3);}
		 | T_NAME L_PAREN R_PAREN{$$ = new Node("func call ",$1);}
		 ;


parameters : parameters COMMA T_NAME {$$ = new Node("parameters name",$1,$3)};
					| T_NAME {$$ = $1; }
					;


if_stmt: T_IF test COLON suite elif_else_stmt {$$ = new Node("if ", $2,$4,$5);}

elif_else_stmt: T_ELSE COLON suite {$$ = new Node("else ", $3);}
				| elif_else_stmt T_ELIF COLON suite {$$ = new Node("elif ", $1,$4);}
				| /* empty */  {$$ = 0; }
				;

while_stmt: T_WHILE test COLON suite T_ELSE COLON suite {$$ = new Node("while else ", $2,$4,$7);}
			| T_WHILE test COLON suite{$$ = new Node("while ", $2,$4);}
			;

for_stmt: T_FOR exprlist T_IN testlist COLON suite T_ELSE COLON suite {$$ = new Node("for in else ", $2,$4,$6,$9);}
		| T_FOR exprlist T_IN testlist COLON suite{$$ = new Node("for in ", $2,$4,$6);}
		;


suite: NEWLINE INDENT stmts DEDENT {$$ = new Node("suite ", $3);}
		| simple_stmt {$$ = $1;}
		;


test : or_test T_IF or_test T_ELSE test {$$ = new Node("test with if else", $1,$3,$5);}
		| or_test {$$ = $1;}
		;

or_test: or_test LIT_OR and_test {$$ = new Node("or test ", $1,$3);}
		 | and_test {$$ = $1;}
		 ;

and_test: and_test LIT_AND not_test {$$ = new Node("and test ", $1,$3);}
		 | not_test {$$ = $1;}
		 ;

not_test: LIT_NOT not_test {$$ = new Node("not test ", $2);}
		 | comparison {$$ = $1;}
		 ;

comparison: comparison comp_op expr {$$ = new Node("comparison "+$2->name,$1,$3);}
			| expr {$$ = $1;}
			;


comp_op: GREATER {$$ = $1;}
		| LESS {$$ = $1;}
		| EQUAL_EQUAL {$$ = $1;}
		| GREATER_EQUAL {$$ = $1;}
		| LESS_EQUAL {$$ = $1;}
		| EXCL_EQUAL {$$ = $1;}
		| T_IN { $$ = $1;}
		| NOT_IN {$$ = $1;}
		| T_IS {$$ = $1;}
		| IS_NOT {$$ = $1;}
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
		| L_PAREN test R_PAREN {$$ = new Node("( ) ",$2)};
		| L_PAREN star_expr R_PAREN {$$ = new Node("( ) ",$2)};
		| T_NUMBER {$$ = $1;} 
		| T_STRING {$$ = $1;}
		| T_DOT_DOT_DOT {$$ = $1;}
		| NONE {$$ = $1;}
		| TRUE {$$ = $1;}
		| FALSE {$$ = $1;}
		;


expr_star_exprs: expr_star_exprs COMMA expr COMMA {$$ = new Node("expr_star_exprs ", $1,$3);}
				| expr_star_exprs COMMA expr {$$ = new Node("expr_star_exprs ", $1,$3);}
				| expr_star_exprs COMMA star_expr COMMA {$$ = new Node("expr_star_exprs ", $1,$3);}
				| expr_star_exprs COMMA star_expr {$$ = new Node("expr_star_exprs ", $1,$3);}
				| COMMA expr COMMA {$$ = $2;}
				| COMMA expr {$$ = $2;}
				| COMMA star_expr COMMA {$$ = $2;}
				| COMMA star_expr {$$ = $2;}
				;




exprlist: expr expr_star_exprs {$$ = new Node("exprlist ", $1,$2);}
		| expr {$$ = $1;}
		;

tests : tests COMMA test COMMA {$$ = new Node("tests ", $1,$3);}
		| tests COMMA test {$$ = new Node("tests ", $1,$3);}
		| COMMA test COMMA {$$ = $2;}
		| COMMA test {$$ = $2;}
		;

testlist: test tests {$$ = new Node("testlist ", $1,$2);}
		  |  test {$$ = $1;}
		  ;

classdef: CLASS T_NAME COLON suite {$$ = new Node("class def",$2,$4);}
		| CLASS T_NAME L_PAREN R_PAREN COLON suite {$$ = new Node("class def",$2,$6);}
		| CLASS T_NAME L_PAREN parameters R_PAREN COLON suite {$$ = new Node("class def",$2,$4,$7);}
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
	yyparse();
    
	return 0;

    // Only in newer versions, apparently.
    // yylex_destroy();
}

void yyerror(const char *s) {
    std::cerr << g_current_filename << ":" << yylloc.first_line << ":" << yylloc.first_column << "-" << yylloc.last_column << ": Parse error: " << s << std::endl;
    exit(-1);  // Might as well halt now.
}