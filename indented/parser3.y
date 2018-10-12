/*
Copyright (C) 2013 Lucas Beyer (http://lucasb.eyer.be)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to
deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
IN THE SOFTWARE.
*/

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



%token T_NAME
%token T_NUMBER
%token T_STRING
%token NONE
%token TRUE
%token FALSE
%token IMPORT
%token NEWLINE
%token INDENT
%token DEDENT
%token END

%token TOK_STUFF TOK_REST

%locations

 /* %debug */

%%
root:
    root stuff | stuff ;

stuff:
    T_NAME {std::cout << "NAME STRING" << std::endl;}
    | T_STRING {std::cout << "STRING: "<< $1 << std::endl; }
    | T_NUMBER {std::cout << "NUMBER" << std::endl;}
    | NONE {std::cout << "NONE" << std::endl;}
    | TRUE {std::cout << "TRUE" << std::endl;}
    | FALSE {std::cout << "FALSE" << std::endl;}
    | IMPORT {std::cout << "IMPORT" << std::endl;}
    | NEWLINE {std::cout << "NEWLINE" << std::endl;}
    | INDENT {std::cout << "INDENT" << std::endl;}
    | DEDENT {std::cout << "DEDENT" << std::endl;}
    | END {std::cout << "END" << std::endl;}
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

