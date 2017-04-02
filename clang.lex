/*
LEX FILE FOR A C LIKE LANGUAGE AS MENTIONED IN THE REF.PDF

FILE NAME: 				CLANG.LEX
FUNCTION: 				CONVERT THE GIVEN INPUT FILES-CODE INTO A SET OF TOKENS (DIRECTELY),
									TO BE PASSED ON TO THE PARSER TO GENRATE THE PARSE TREE.
SUBMITTED BY: 		GROUP 10, COMPILERS LAB, IIT PATNA
GROUP MEMBERS: 		TANMAY DAS (1401CS47)
									MAYANK GOYAL (1401CS25)
									AWANISH KUMAR DAS (1401CS05)
*/

/*
CONTRIBUTION BY:
	(1) TANMAY DAS:   			Creating the regex for required input types, constants, etc.;
													Creating the function to recognize comment of type / * * / and //;
													Creating the function for detection of printf() {specifically because the above
													mentioned declaration would not be included in the code as it implicit};
													Including the function count() to avoid/skip empty-space/tabs, etc along with
												  counting the column number at each line;
													Commenting the clang.lex file;

	(2) MAYANK GOYAL:				Mentioning all the operators required as per the c-like language and
													passing it to the output file.
													Including the yylineno variable at every newline detection to increment line number;
													Commenting the clang.lex file;

	(3) AVANISH KUMAR DAS:  Mentioning the restricted names of identifiers and passing it as token
	 												in the output file, lex.yy.c
													Commenting the clang.lex file;
*/

D			[0-9]
L			[a-zA-Z_]
H			[a-fA-F0-9]
E			[Ee][+-]?{D}+
FS			(f|F|l|L)
IS			(u|U|l|L)*

%{
	#include <stdio.h>
	#include "y.tab.h"
	extern YYSTYPE yylval;
	char yyprev[100];
	int open_brace = 1;
	int is_brace_start = 0;
	int func_par_define = 0;
	int no_of_local_var[1000] = {0};
	extern int yylineno;
	void count();
%}

%option yylineno

/*
	Defining all the restricted keywords.
	Defining all the constants/ numbers, etc and passing its value
	Defining all the operators used in the c-like language
*/

%%

"/*"			{ comment(); }
"//"       {comment2();}
"printf"		{comment1();}
"auto"			{ strcpy(yyprev,yytext);count(); return(AUTO); }
"break"			{ strcpy(yyprev,yytext);count(); return(BREAK); }
"case"			{ strcpy(yyprev,yytext);count(); return(CASE); }
"char"			{ strcpy(yyprev,yytext);count(); return(CHAR); }
"const"			{ strcpy(yyprev,yytext);count(); return(CONST); }
"continue"		{ strcpy(yyprev,yytext);count(); return(CONTINUE); }
"default"		{ strcpy(yyprev,yytext);count(); return(DEFAULT); }
"do"			{ strcpy(yyprev,yytext);count(); return(DO); }
"double"		{ strcpy(yyprev,yytext);count(); return(DOUBLE); }
"else"			{ strcpy(yyprev,yytext);count(); return(ELSE); }
"enum"			{ strcpy(yyprev,yytext);count(); return(ENUM); }
"extern"		{ strcpy(yyprev,yytext); count(); return(EXTERN); }
"float"			{ strcpy(yyprev,yytext);count(); return(FLOAT); }
"for"			{ strcpy(yyprev,yytext);count(); return(FOR); }
"goto"			{ strcpy(yyprev,yytext);count(); return(GOTO); }
"if"				{ strcpy(yyprev,yytext);count(); return(IF); }
"int"			{ strcpy(yyprev,yytext);count(); return(INT); }
"long"			{ strcpy(yyprev,yytext);count(); return(LONG); }
"register"		{ strcpy(yyprev,yytext);count(); return(REGISTER); }
"return"		{ strcpy(yyprev,yytext);count(); return(RETURN); }
"short"			{ strcpy(yyprev,yytext);count(); return(SHORT); }
"signed"		{ strcpy(yyprev,yytext);count(); return(SIGNED); }
"sizeof"			{ strcpy(yyprev,yytext);count(); return(SIZEOF); }
"static"			{ strcpy(yyprev,yytext);count(); return(STATIC); }
"struct"			{ strcpy(yyprev,yytext);count(); return(STRUCT); }
"switch"		{ strcpy(yyprev,yytext);count(); return(SWITCH); }
"typedef"		{ strcpy(yyprev,yytext);count(); return(TYPEDEF); }
"union"			{ strcpy(yyprev,yytext);count(); return(UNION); }
"unsigned"		{ strcpy(yyprev,yytext);count(); return(UNSIGNED); }
"void"			{ strcpy(yyprev,yytext);count(); return(VOID); }
"volatile"		{ strcpy(yyprev,yytext);count(); return(VOLATILE); }
"while"			{ strcpy(yyprev,yytext);count(); return(WHILE); }
"define"		{ strcpy(yyprev,yytext);count(); return(DEFINE); }
"line"			{ strcpy(yyprev,yytext);count(); return(LINE); }
"include"		{ strcpy(yyprev,yytext);count(); return(INCLUDE); }
"error"			{ strcpy(yyprev,yytext);count(); return(ERROR); }
"pragma"		{ strcpy(yyprev,yytext);count(); return(PRAGMA); }
"undef"			{ strcpy(yyprev,yytext);count(); return(UNDEF); }
".h"			{strcpy(yyprev,yytext);count(); return(PRE); }



{L}({L}|{D})*		{ strcpy(yyprev,yytext);count(); strcpy(yylval.val, yytext); return(check_type()); }

0[xX]{H}+{IS}?		{ strcpy(yyprev,yytext);count(); strcpy(yylval.val, yytext); return(CONSTANT); }
0{D}+{IS}?		{ strcpy(yyprev,yytext);count(); strcpy(yylval.val, yytext); return(CONSTANT); }
{D}+{IS}?		{ strcpy(yyprev,yytext);count(); strcpy(yylval.val, yytext); return(CONSTANT); }
L?'(\\.|[^\\\'])+'	{ strcpy(yyprev,yytext);count(); strcpy(yylval.val, yytext); return(CONSTANT); }

{D}+{E}{FS}?		{ strcpy(yyprev,yytext);count(); strcpy(yylval.val, yytext); return(CONSTANT); }
{D}*"."{D}+({E})?{FS}?	{ strcpy(yyprev,yytext);count(); strcpy(yylval.val, yytext); return(CONSTANT); }
{D}+"."{D}*({E})?{FS}?	{ strcpy(yyprev,yytext);count(); strcpy(yylval.val, yytext); return(CONSTANT); }

L?\"(\\.|[^\\"])*\"	{ strcpy(yyprev,yytext);count(); strcpy(yylval.val, yytext); return(STRING_LITERAL); }



"..."			{ strcpy(yyprev,yytext);count(); return(ELLIPSIS); }
">>="			{ strcpy(yyprev,yytext);count(); return(RIGHT_ASSIGN); }
"<<="			{ strcpy(yyprev,yytext);count(); return(LEFT_ASSIGN); }
"+="			{ strcpy(yyprev,yytext);count(); return(ADD_ASSIGN); }
"-="			{ strcpy(yyprev,yytext);count(); return(SUB_ASSIGN); }
"*="			{ strcpy(yyprev,yytext);count(); return(MUL_ASSIGN); }
"/="			{ strcpy(yyprev,yytext);count(); return(DIV_ASSIGN); }
"%="			{ strcpy(yyprev,yytext);count(); return(MOD_ASSIGN); }
"&="			{ strcpy(yyprev,yytext);count(); return(AND_ASSIGN); }
"^="			{ strcpy(yyprev,yytext);count(); return(XOR_ASSIGN); }
"|="			{ strcpy(yyprev,yytext);count(); return(OR_ASSIGN); }
">>"			{ strcpy(yyprev,yytext);count(); return(RIGHT_OP); }
"<<"			{ strcpy(yyprev,yytext);count(); return(LEFT_OP); }
"++"			{ strcpy(yyprev,yytext);count(); return(INC_OP); }
"--"			{ strcpy(yyprev,yytext);count(); return(DEC_OP); }
"->"			{ strcpy(yyprev,yytext);count(); return(PTR_OP); }
"&&"			{ strcpy(yyprev,yytext);count(); return(AND_OP); }
"||"			{ strcpy(yyprev,yytext);count(); return(OR_OP); }
"<="			{ strcpy(yyprev,yytext);count(); return(LE_OP); }
">="			{ strcpy(yyprev,yytext);count(); return(GE_OP); }
"=="			{ strcpy(yyprev,yytext);count(); return(EQ_OP); }
"!="			{ strcpy(yyprev,yytext);count(); return(NE_OP); }
";"			{ strcpy(yyprev,yytext);count(); return(';'); }
("{"|"<%")		{ open_brace++; is_brace_start = 1; strcpy(yyprev,yytext);count(); return('{'); }
("}"|"%>")		{ no_of_local_var[open_brace] = 0; open_brace--; is_brace_start = 0; strcpy(yyprev,yytext);count(); return('}'); }
","			{ strcpy(yyprev,yytext);count(); return(','); }
":"			{ strcpy(yyprev,yytext);count(); return(':'); }
"="			{ strcpy(yyprev,yytext);count(); return('='); }
"("			{ func_par_define = 1; strcpy(yyprev,yytext);count(); return('('); }
")"			{ func_par_define = 0; strcpy(yyprev,yytext);count(); return(')'); }
("["|"<:")		{ strcpy(yyprev,yytext);count(); return('['); }
("]"|":>")		{ strcpy(yyprev,yytext);count(); return(']'); }
"."			{ strcpy(yyprev,yytext);count(); return('.'); }
"&"			{ strcpy(yyprev,yytext);count(); return('&'); }
"!"			{ strcpy(yyprev,yytext);count(); return('!'); }
"~"			{ strcpy(yyprev,yytext);count(); return('~'); }
"-"			{ strcpy(yyprev,yytext);count(); return('-'); }
"+"			{ strcpy(yyprev,yytext);count(); return('+'); }
"*"			{ strcpy(yyprev,yytext);count(); return('*'); }
"/"			{ strcpy(yyprev,yytext);count(); return('/'); }
"%"			{ strcpy(yyprev,yytext);count(); return('%'); }
"<"			{ strcpy(yyprev,yytext);count(); return('<'); }
">"			{ strcpy(yyprev,yytext);count(); return('>'); }
"^"			{ strcpy(yyprev,yytext);count(); return('^'); }
"|"			{ strcpy(yyprev,yytext);count(); return('|'); }
"?"			{ strcpy(yyprev,yytext);count(); return('?'); }
"#"|"\""			{ strcpy(yyprev,yytext);count(); return yytext[0]; }
[ \n ]		{ strcpy(yyprev,yytext);count();}
[ \t\v\f]		{ strcpy(yyprev,yytext);count(); }
.			{ strcpy(yyprev,yytext);count(); return MACRO; }

%%

yywrap(){
	return(1);
}

/*
	Function to find multiline comment
*/

comment(){
	char c, c1;

loop:
	while ((c = input()) != '*' && c != 0);
		c += 1;

	if ((c1 = input()) != '/' && c != 0){
		unput(c1);
		goto loop;
	}

	if (c != 0)
		c1 += 1;
}

/*
	Function to find single line comment
*/

comment2(){
	char c, c1;
	while ((c = input()) != '\n' && c != 0);//line chnges comment ends
		c += 1;
}

/*
	Function to find printf
*/
comment1(){
	char c, c1;

loop:
	while ((c = input()) != ')' && c != 0);
		c += 1;

	if ((c1 = input()) != ';' && c != 0)
	{
		unput(c1);
		goto loop;
	}

	if (c != 0)
		c1 += 1;
}

/*
	Function to count the number of column
*/
int column = 0;
void count(){
	int i;

	for (i = 0; yytext[i] != '\0'; i++)
		if (yytext[i] == '\n') //row changes
			column = 0;
		else if (yytext[i] == '\t')
			column += 4;
		else
			column++;
}

int check_type(){
	return(IDENTIFIER);
}
