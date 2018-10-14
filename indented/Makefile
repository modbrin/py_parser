all: link clean makepre

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y --verbose

lex.yy.c: scanner.l
	flex scanner.l

compile:  lex.yy.c parser.tab.c parser.tab.h node.h
	g++ -c lex.yy.c parser.tab.c

link: compile
	g++ -o parser lex.yy.o parser.tab.o

clean:
	del lex.yy.* parser.tab.*

makepre: preprocessor.cpp
	g++ -std=c++11 -o prepr preprocessor.cpp
