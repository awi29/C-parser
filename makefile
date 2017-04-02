clang: lex.yy.c y.tab.c
	gcc y.tab.c lex.yy.c -o clang
lex.yy.c:
	lex clang.lex
y.tab.c y.tab.h:
	yacc -d clang.yacc
clean:
	rm -f y.tab.c lex.yy.c y.tab.h clang
