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
#include <stack>
#include <iostream>

/* globals to track current indentation */
int g_current_line_indent = 0;   /* indentation of the current line */
std::stack<size_t> g_indent_levels;
int g_is_fake_outdent_symbol = 0;

/* TODO: error-out on tabs/spaces mix? */
static const unsigned int TAB_WIDTH = 2;

extern const char* g_current_filename;

/* Don't mangle yylex please! */
#define YY_DECL extern "C" int yylex()
#define YYSTYPE Node*

#include "node.h"
#include "parser.tab.h"

#define YY_USER_INIT { \
        g_indent_levels.push(0); \
        BEGIN(initial); \
    }

int yycolumn = 1;
void set_yycolumn(int val) {
    yycolumn = val;
    yylloc.first_column = yycolumn;
    yylloc.last_column = yycolumn + yyleng - 1;
}

#define YY_USER_ACTION { \
    yylloc.first_line = yylloc.last_line = yylineno; \
    set_yycolumn(yycolumn); \
    yycolumn += yyleng; \
}

%}

 /* This is a sub-parser (state) for indentation-sensitive scoping */
%x initial
%x indent
%s normal

 /* %option 8bit reentrant bison-bridge */
%option warn
%option nodefault
%option yylineno
%option noyywrap

 /*%option debug*/
%%
    int indent_caller = normal;

 /* This helps to keep track of the column number.
  * Note that it won't work if you have a rule which includes a newline and is
  * longer than one character because in that case that rule will be favored
  * and this one here won't get called.
  * TL;DR: If you have a rule which includes \n and more, you need to reset
  *        yycolumn inside that rule!
  */
<*>\n { set_yycolumn(0); yylineno--; REJECT; }

 /* Everything runs in the <normal> mode and enters the <indent> mode
    when a newline symbol is encountered.
    There is no newline symbol before the first line, so we need to go
    into the <indent> mode by hand there.
 */
<initial>.  { set_yycolumn(yycolumn-1); indent_caller = normal; yyless(0); BEGIN(indent); }
<initial>\n { indent_caller = normal; yyless(0); BEGIN(indent); }

 /* The following are the rules that keep track of indentation. */
<indent>" "     { g_current_line_indent++; }
<indent>\t      { g_current_line_indent = (g_current_line_indent + TAB_WIDTH) & ~(TAB_WIDTH-1); }
<indent>\n      { g_current_line_indent = 0; /* ignoring blank line */ }
<indent><<EOF>> {
                    // When encountering the end of file, we want to emit an
                    // outdent for all indents currently left.
                    if(g_indent_levels.top() != 0) {
                        g_indent_levels.pop();

                        // See the same code below (<indent>.) for a rationale.
                        if(g_current_line_indent != g_indent_levels.top()) {
                            unput('\n');
                            for(size_t i = 0 ; i < g_indent_levels.top() ; ++i) {
                                unput(' ');
                            }
                        } else {
                            BEGIN(indent_caller);
                        }
                        // std::cout<<"DEDENT"<<std::endl;
                        yylval = new Node("DEDENT");
                        return DEDENT;
                    } else {
                        // std::cout<<"EOF"<<std::endl;
                        yylval = new Node("EOF");
                        return EOF;
                        // yyterminate();
                    }
                }

<indent>.       {
                    if(!g_is_fake_outdent_symbol) {
                        unput(*yytext);
                    }
                    set_yycolumn(yycolumn-1);
                    g_is_fake_outdent_symbol = 0;

                    // Indentation level has increased. It can only ever
                    // increase by one level at a time. Remember how many
                    // spaces this level has and emit an indentation token.
                    if(g_current_line_indent > g_indent_levels.top()) {
                        g_indent_levels.push(g_current_line_indent);
                        BEGIN(indent_caller);
                        std::cout<<"INDENT"<<std::endl;
                        yylval = new Node("INDENT");
                        return INDENT;
                    } else if(g_current_line_indent < g_indent_levels.top()) {
                        // Outdenting is the most difficult, as we might need to
                        // outdent multiple times at once, but flex doesn't allow
                        // emitting multiple tokens at once! So we fake this by
                        // 'unput'ting fake lines which will give us the next
                        // outdent.
                        g_indent_levels.pop();

                        if(g_current_line_indent != g_indent_levels.top()) {
                            // Unput the rest of the current line, including the newline.
                            // We want to keep it untouched.
                            for(size_t i = 0 ; i < g_current_line_indent ; ++i) {
                                unput(' ');
                            }
                            unput('\n');
                            // Now, insert a fake character indented just so
                            // that we get a correct outdent the next time.
                            unput('.');
                            // Though we need to remember that it's a fake one
                            // so we can ignore the symbol.
                            g_is_fake_outdent_symbol = 1;
                            for(size_t i = 0 ; i < g_indent_levels.top() ; ++i) {
                                unput(' ');
                            }
                            unput('\n');
                        } else {
                            BEGIN(indent_caller);
                        }
                        // std::cout<<"DEDENT"<<std::endl;
                        yylval = new Node("DEDENT");
                        return DEDENT;
                    } else {
                        // No change in indentation, not much to do here...
                        BEGIN(indent_caller);
                    }
                }

<normal>\n    { g_current_line_indent = 0; indent_caller = YY_START; BEGIN(indent); return NEWLINE;}
<normal>import { yylval = new Node(yytext); return IMPORT; }
<normal>[a-zA-Z]+[_]?[a-zA-Z0-9]*  { yylval = new Node(yytext);return T_NAME; }
<normal>[0-9]+([.][0-9]+)?(("e"|"E")[+|-]?[0-9]+)?([+|-][0-9]*("j"|"J"))? { yylval = new Node(yytext);return T_NUMBER;}
<normal>["][0-9A-Za-z#$%=@!{},`~&*()<>?.:;_|^/+\t\r\n\[\]'-]*["] { yylval = new Node(yytext);return T_STRING; }
<normal>\'[ 0-9A-Za-z#$%=@!{},`~&*()<>?.:;_|^/+\t\r\n\[\]"-]*\' { yylval = new Node(yytext);return T_STRING; }
<normal>[0-9]*[l|L] { yylval = new Node(yytext); return T_NUMBER; }
<normal>None { yylval = new Node(yytext);return NONE; }
<normal>True { yylval = new Node(yytext);return TRUE; }
<normal>\| { yylval = new Node(yytext);return OR;}
<normal>~ { yylval = new Node(yytext);return TILDA; }
<normal><< { yylval = new Node(yytext);return LESS_LESS;}
<normal>>> { yylval = new Node(yytext);return GREATER_GREATER;}
<normal>\*\* { yylval = new Node(yytext);return STAR_STAR;}
<normal>\/\/ { yylval = new Node(yytext);return R_SLASH_SLASH;}
<normal>\/ { yylval = new Node(yytext);return R_SLASH;}
<normal>@ { yylval = new Node(yytext);return T_AT;}
<normal>% { yylval = new Node(yytext);return PERCENT;}
<normal>& { yylval = new Node(yytext);return AND;}
<normal>\^ { yylval = new Node(yytext);return XOR;}
<normal>\* { yylval = new Node(yytext);return MULTIPLY;}
<normal>\+ { yylval = new Node(yytext);return PLUS;}
<normal>- { yylval = new Node(yytext);return MINUS;}
<normal>False { yylval = new Node(yytext);return FALSE; }
<normal>def { yylval = new Node(yytext);return DEF; }
<normal>-> { yylval = new Node(yytext);return MINUS_GREATER; }
<normal>\( { yylval = new Node(yytext);return L_PAREN; }
<normal>\) { yylval = new Node(yytext);return R_PAREN; }
<normal>= { yylval = new Node(yytext);return EQUAL; }
<normal>\. { yylval = new Node(yytext);return COMMA; }
<normal>: { yylval = new Node(yytext);return COLON; }
<normal>; { yylval = new Node(yytext);return SEMICOLON; }
<normal>\+= { yylval = new Node(yytext);return PLUS_EQUAL; }
<normal>-= { yylval = new Node(yytext);return MINUS_EQUAL; }
<normal>\*= { yylval = new Node(yytext);return STAR_EQUAL; }
<normal>@= { yylval = new Node(yytext);return AT_EQUAL; }
<normal>\/= { yylval = new Node(yytext);return R_SLASH_EQUAL; }
<normal>%= { yylval = new Node(yytext);return PERCENT_EQUAL; }
<normal>&= { yylval = new Node(yytext);return AND_EQUAL; }
<normal>\|= { yylval = new Node(yytext);return BAR_EQUAL; }
<normal>\^= { yylval = new Node(yytext);return XOR_EQUAL; }
<normal><<= { yylval = new Node(yytext);return LESS_LESS_EQUAL; }
<normal>>>= { yylval = new Node(yytext);return GREATER_GREATER_EQUAL; }
<normal>\*\*= { yylval = new Node(yytext);return STAR_STAR_EQUAL ; }
<normal>\/\/= { yylval = new Node(yytext);return SLASH_SLASH_EQUAL; }
<normal>pass { yylval = new Node(yytext);return T_PASS; }
<normal>break { yylval = new Node(yytext);return T_BREAK ; }
<normal>continue { yylval = new Node(yytext);return T_CONTINUE  ; }
<normal>return { yylval = new Node(yytext);return T_RETURN ; }
<normal>from { yylval = new Node(yytext);return FROM; }
<normal>\. { yylval = new Node(yytext);return T_DOT ; }
<normal>\.\.\. { yylval = new Node(yytext);return T_DOT_DOT_DOT; }
<normal>as { yylval = new Node(yytext);return T_AS; }
<normal>if { yylval = new Node(yytext);return T_IF ; }
<normal>elif { yylval = new Node(yytext);return T_ELIF ; }
<normal>else { yylval = new Node(yytext);return T_ELSE; }
<normal>while { yylval = new Node(yytext);return T_WHILE ; }
<normal>for { yylval = new Node(yytext);return T_FOR; }
<normal>in { yylval = new Node(yytext);return T_IN; }
<normal>or { yylval = new Node(yytext);return LIT_OR; }
<normal>and { yylval = new Node(yytext);return LIT_AND; }
<normal>not { yylval = new Node(yytext);return LIT_NOT; }
<normal>< { yylval = new Node(yytext);return LESS; }
<normal>> { yylval = new Node(yytext);return GREATER; }
<normal>== { yylval = new Node(yytext);return EQUAL_EQUAL; }
<normal>>= { yylval = new Node(yytext);return GREATER_EQUAL; }
<normal><= { yylval = new Node(yytext);return LESS_EQUAL; }
<normal><> { yylval = new Node(yytext);return LESS_GREATER; }
<normal>!= { yylval = new Node(yytext);return EXCL_EQUAL; }
<normal>not\sin { yylval = new Node(yytext);return NOT_IN; }
<normal>is { yylval = new Node(yytext);return T_IS; }
<normal>is\snot { yylval = new Node(yytext);return IS_NOT; }
<normal>" ".+ { yylval = new Node(yytext);return TOK_REST; }
<normal><<EOF>> { yylval = new Node(yytext);std::cout<<"EOF"<<std::endl; return END; }

(.|\n)  { std::cerr << g_current_filename << ":" << yylineno << ":" << yycolumn << ": Unexpected character: " << yytext << std::endl; exit(1); }

%%
