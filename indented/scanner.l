
%{
#include <stack>
#include <iostream>

/* Don't mangle yylex please! */
#define YY_DECL extern "C" int yylex()
#define YYDEBUG 1
#define YYSTYPE Node*

#include "node.h"
#include "parser.tab.h"

%}


 /* %option 8bit reentrant bison-bridge */
%option warn
%option nodefault
%option yylineno
%option noyywrap


 /*%option debug*/
%%
1INDENT1 {yylval = new Node("INDENT"); std::cout<<"INDENT"<<std::endl; return INDENT;}
1DEDENT1 {yylval = new Node("DEDENT"); std::cout<<"DEDENT"<<std::endl; return DEDENT;}
\n    { yylval = new Node("NEWLINE"); std::cout<<"NEWLINE"<<std::endl; return NEWLINE;}
import { yylval = new Node(yytext); return IMPORT; }
None { yylval = new Node(yytext);return NONE; }
True { yylval = new Node(yytext);return TRUE; }
False { yylval = new Node(yytext);return FALSE; }
def { yylval = new Node(yytext);return DEF; }
-> { yylval = new Node(yytext);return MINUS_GREATER; }
\( { yylval = new Node(yytext);return L_PAREN; }
\) { yylval = new Node(yytext);return R_PAREN; }
\+= { yylval = new Node(yytext);return PLUS_EQUAL; }
-= { yylval = new Node(yytext);return MINUS_EQUAL; }
\*= { yylval = new Node(yytext);return STAR_EQUAL; }
@= { yylval = new Node(yytext);return AT_EQUAL; }
\/= { yylval = new Node(yytext);return R_SLASH_EQUAL; }
%= { yylval = new Node(yytext);return PERCENT_EQUAL; }
&= { yylval = new Node(yytext);return AND_EQUAL; }
\|= { yylval = new Node(yytext);return BAR_EQUAL; }
\^= { yylval = new Node(yytext);return XOR_EQUAL; }
\<\<= { yylval = new Node(yytext);return LESS_LESS_EQUAL; }
\>\>= { yylval = new Node(yytext);return GREATER_GREATER_EQUAL; }
\*\*= { yylval = new Node(yytext);return STAR_STAR_EQUAL ; }
\/\/= { yylval = new Node(yytext);return SLASH_SLASH_EQUAL; }
pass { yylval = new Node(yytext);return T_PASS; }
break { yylval = new Node(yytext);return T_BREAK ; }
class { yylval = new Node(yytext);return CLASS;}
continue { yylval = new Node(yytext);return T_CONTINUE  ; }
return { yylval = new Node(yytext);return T_RETURN ; }
from { yylval = new Node(yytext);return FROM; }
\. { yylval = new Node(yytext);return T_DOT ; }
\.\.\. { yylval = new Node(yytext);return T_DOT_DOT_DOT; }
as { yylval = new Node(yytext);return T_AS; }
if { yylval = new Node(yytext);return T_IF ; }
elif { yylval = new Node(yytext);return T_ELIF ; }
else { yylval = new Node(yytext);return T_ELSE; }
while { yylval = new Node(yytext);return T_WHILE ; }
for { yylval = new Node(yytext);return T_FOR; }
in { yylval = new Node(yytext);return T_IN; }
or { yylval = new Node(yytext);return LIT_OR; }
and { yylval = new Node(yytext);return LIT_AND; }
not { yylval = new Node(yytext);return LIT_NOT; }
== { yylval = new Node(yytext);return EQUAL_EQUAL; }
>= { yylval = new Node(yytext);return GREATER_EQUAL; }
\<= { yylval = new Node(yytext);return LESS_EQUAL; }
\<> { yylval = new Node(yytext);return LESS_GREATER; }
!= { yylval = new Node(yytext);return EXCL_EQUAL; }
\*\* { yylval = new Node(yytext);return STAR_STAR;}
\* { yylval = new Node(yytext);return MULTIPLY;}
= { yylval = new Node(yytext);return EQUAL; }
: { yylval = new Node(yytext);return COLON; }
; { yylval = new Node(yytext);return SEMICOLON; }
\^ { yylval = new Node(yytext);return XOR;}
\+ { yylval = new Node(yytext);return PLUS;}
- { yylval = new Node(yytext);return MINUS;}
\| { yylval = new Node(yytext);return OR;}
~ { yylval = new Node(yytext);return TILDA; }
\<\< { yylval = new Node(yytext);return LESS_LESS;}
>> { yylval = new Node(yytext);return GREATER_GREATER;}
\/\/ { yylval = new Node(yytext);return R_SLASH_SLASH;}
\/ { yylval = new Node(yytext);return R_SLASH;}
\< { yylval = new Node(yytext);return LESS; }
> { yylval = new Node(yytext);return GREATER; }
@ { yylval = new Node(yytext);return T_AT;}
% { yylval = new Node(yytext);return PERCENT;}
& { yylval = new Node(yytext);return AND;}
not\sin { yylval = new Node(yytext);return NOT_IN; }
, { yylval = new Node(yytext);return COMMA; }
is { yylval = new Node(yytext);return T_IS; }
is\snot { yylval = new Node(yytext);return IS_NOT; }
[0-9]*[l|L] { yylval = new Node(yytext); return T_NUMBER; }
[a-zA-Z]+[_]?[a-zA-Z0-9]*  { yylval = new Node(yytext);return T_NAME; }
[0-9]+([.][0-9]+)?(("e"|"E")[+|-]?[0-9]+)?([+|-][0-9]*("j"|"J"))? { yylval = new Node(yytext); return T_NUMBER;}
["][0-9A-Za-z#$%=@!{},`~&*()<>?.:;_|^/+\t\r\n\[\]'-]*["] { yylval = new Node(yytext); return T_STRING; }
\'[ 0-9A-Za-z#$%=@!{},`~&*()<>?.:;_|^/+\t\r\n\[\]"-]*\' { yylval = new Node(yytext); return T_STRING; }
[ ]
<<EOF>> { yylval = new Node(yytext); std::cout<<"END"<<std::endl;return END; }
(.|\n)  { std::cerr << "Unexpected symbol."<<yytext << std::endl; exit(1); }

%%
