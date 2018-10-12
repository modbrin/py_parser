all: link clean

pyparser.tab.c pyparser.tab.h: pyparser.y
	bison -d pyparser.y --verbose

lex.yy.c: lexer.l
	flex lexer.l

compile:  lex.yy.c pyparser.tab.c pyparser.tab.h
	g++ -c lex.yy.c pyparser.tab.c

link: compile
	g++ -o parser lex.yy.o pyparser.tab.o

clean:
	del lex.yy.* pyparser.tab.*
