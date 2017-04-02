/*
YACC FILE FOR A C LIKE LANGUAGE AS MENTIONED IN THE REF.PDF

FILE NAME: 				CLANG.YACC
FUNCTION: 				CONVERT THE GIVEN INPUT FILES (THE OUTPUT OF LEXER) INTO A PARSE TREE
									TO BE PASSED ON TO THE ICG TO GENRATE THE 3 ADDRESS CODE, ETC.
SUBMITTED BY: 		GROUP 10, COMPILERS LAB, IIT PATNA
GROUP MEMBERS: 		TANMAY DAS (1401CS47)
									MAYANK GOYAL (1401CS25)
									AVANISH KUMAR DAS (1401CS05)
*/

/*
CONTRIBUTION BY:
	(1) TANMAY DAS:						(i)   Defining all the necessary function to implement detection of a function,
																  function name, adding it to the temp. symbol table, checking variable, etc;
														(ii)  Implementing the grammar of the language; (ln 91-220)
														(iii) Commenting in the .yacc file;

	(2) MAYANK GOYAL:					(i)   Initial declaration, and include statements which include special variables
														      for the genration of the symbol table like data structure;
														(ii)  Implementing the grammar of the language; (ln 220-370)
														(iii) Commenting in the .yacc file;

	(3) AVANISH KUMAR DAS:		(i)   Included the required token - returned from the lexer and defining unions and
														      new data-types for the in-grammar genaration of translator;
														(ii)  Implementing the grammar of the language; (ln 370 - 526)
														(iii) Commenting in the .yacc file;
*/

%{
	#include <math.h>
	#include <stdlib.h>
	#include <stddef.h>
	#include <alloca.h>
	#include <string.h>
	#include <ctype.h>
	#include <stdio.h>
	#include <ctype.h>
	char *progname;
	int error_count = 0, func_count = 0;
	int var_define = 0;
	int add_check = 0;
	int function_check = 1;

	//func_name[] array is used to store all the function names.
	char func_name[1000][50];
	//line_error[] array is used to store all the errors in input file .
	char line_error[1000][200];
  // local_var[][] 2-d array is used for storing local variables in a given scope.
	char local_var[1000][100][100];		/* Contains all variables which are defined at
																		   particular line from top to bottom pasing of lines */
  //funcName is used to store function name globally.
	char funcName[1000];

	extern char yyprev[100];
	extern int is_brace_start;
	// open_brace is used to check the level of nesting in the current function
	extern int open_brace;
	//func_par_define is used to indicate parameters need to be stored at the next scope.
	extern int func_par_define;
	//no_of_local_var array is used to number of local variables at the given scope.
	extern int no_of_local_var[1000];	/* Contains number of local variables at particular line */
	//yyin is used to read the input file.
	extern FILE *yyin;
	//yylineno is used to store line number.
	extern int yylineno;
%}

// %union is used to store any variable from lex file in yacc file.
%union{
    char val[1000];
    int line_no;
}

/*
The ordering of operators is handled using strictly BNF grammar.
The operators having higher precedence are placed below the ones' with lesser precedence.
The operators having same precedence are present at the same level.
*/

%token<val> IDENTIFIER CONSTANT STRING_LITERAL SIZEOF
%token<val> DEFINE LINE INCLUDE ERROR PRAGMA UNDEF PRE MACRO
%token<val> PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token<val> AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token<val> SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token<val> XOR_ASSIGN OR_ASSIGN TYPE_NAME

%token<val> TYPEDEF EXTERN STATIC AUTO REGISTER
%token<val> CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token<val> STRUCT UNION ENUM ELLIPSIS
%token<val> CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%type<val> primary_expression postfix_expression argument_expression_list unary_expression
unary_operator cast_expression multiplicative_expression additive_expression shift_expression
relational_expression equality_expression and_expression exclusive_or_expression
inclusive_or_expression logical_and_expression logical_or_expression conditional_expression
assignment_expression assignment_operator expression constant_expression declaration declaration_specifiers
init_declarator_list init_declarator storage_class_specifier type_specifier struct_or_union_specifier
struct_or_union struct_declaration_list struct_declaration specifier_qualifier_list struct_declarator_list struct_declarator
enum_specifier enumerator_list enumerator type_qualifier declarator direct_declarator pointer
type_qualifier_list parameter_type_list parameter_list parameter_declaration identifier_list type_name
abstract_declarator direct_abstract_declarator initializer initializer_list statement labeled_statement
compound_statement declaration_list statement_list expression_statement selection_statement iteration_statement
jump_statement translation_unit external_declaration function_definition control_line

%start translation_unit

/*
Few comments for the grammar section:

translation_unit: external_declaration | translation_declaration external_declaration;
external_declaration : function_definition | declaration | control_line;

>These rules are used for reading input line by line.
>Each statement can further be either a Declaration stmt or Function
 Definition or Assignment stmt which can be further classified into If- Else
 stmt, While stmt or switch stmt.
>Similarly, depending on the structure of the other language constructs,
 remaining rules are defined and the corresponding functions are
 executed after parsing of that corresponding rule on the stack.
*/

%%

primary_expression
	: IDENTIFIER
{
	if(functionCheck($1)) {

	} else if(checkVariable($1)) {

	} else {
		addIdentifierError($1);
	}
}
	| CONSTANT
	| STRING_LITERAL
	| '(' expression ')'
	;

postfix_expression
	: primary_expression
	| postfix_expression '[' expression ']'
	| postfix_expression '(' ')'
	| postfix_expression '(' argument_expression_list ')'
	| postfix_expression '.' IDENTIFIER
	| postfix_expression PTR_OP IDENTIFIER
	| postfix_expression INC_OP
	| postfix_expression DEC_OP
	;

argument_expression_list
	: assignment_expression
	| argument_expression_list ',' assignment_expression
	;

unary_expression
	: postfix_expression
	| INC_OP unary_expression
	| DEC_OP unary_expression
	| unary_operator cast_expression
	| SIZEOF unary_expression
	| SIZEOF '(' type_name ')'
	;

unary_operator
	: '&'
	| '*'
	| '+'
	| '-'
	| '~'
	| '!'
	;

cast_expression
	: unary_expression
	| '(' type_name ')' cast_expression
	;

multiplicative_expression
	: cast_expression
	| multiplicative_expression '*' cast_expression
	| multiplicative_expression '/' cast_expression
	| multiplicative_expression '%' cast_expression
	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' multiplicative_expression
	| additive_expression '-' multiplicative_expression
	;

shift_expression
	: additive_expression
	| shift_expression LEFT_OP additive_expression
	| shift_expression RIGHT_OP additive_expression
	;

relational_expression
	: shift_expression
	| relational_expression '<' shift_expression
	| relational_expression '>' shift_expression
	| relational_expression LE_OP shift_expression
	| relational_expression GE_OP shift_expression
	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP relational_expression
	| equality_expression NE_OP relational_expression
	;

and_expression
	: equality_expression
	| and_expression '&' equality_expression
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' and_expression
	;
inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression '|' exclusive_or_expression
	;

logical_and_expression
	: inclusive_or_expression
	| logical_and_expression AND_OP inclusive_or_expression
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression
	;

conditional_expression

	: logical_or_expression
	| logical_or_expression '?' expression ':' conditional_expression
	;

assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression
	;

assignment_operator
	: '='
	| MUL_ASSIGN
	| DIV_ASSIGN
	| MOD_ASSIGN
	| ADD_ASSIGN
	| SUB_ASSIGN
	| LEFT_ASSIGN
	| RIGHT_ASSIGN
	| AND_ASSIGN
	| XOR_ASSIGN
	| OR_ASSIGN
	;

expression
	: assignment_expression
	| expression ',' assignment_expression
	;

constant_expression
	: conditional_expression
	;

declaration
	: declaration_specifiers ';'
	| declaration_specifiers init_declarator_list ';' {var_define = 0;}
	;

declaration_specifiers
	: storage_class_specifier
	| storage_class_specifier declaration_specifiers
	| type_specifier
	| type_specifier declaration_specifiers
	| type_qualifier
	| type_qualifier declaration_specifiers
	;

init_declarator_list
	: init_declarator
	| init_declarator_list ',' init_declarator
	;

init_declarator
	: declarator
	| declarator '=' initializer
	;

storage_class_specifier
	: TYPEDEF
	| EXTERN
	| STATIC
	| AUTO
	| REGISTER
	;

type_specifier
	: VOID
	| CHAR
	| SHORT
	| INT
	| LONG
	| FLOAT
	| DOUBLE
	| SIGNED
	| UNSIGNED
	| struct_or_union_specifier
	| enum_specifier
	| TYPE_NAME
	;

struct_or_union_specifier
	: struct_or_union IDENTIFIER '{' struct_declaration_list '}'
	| struct_or_union '{' struct_declaration_list '}'
	| struct_or_union IDENTIFIER
	;

struct_or_union
	: STRUCT
	| UNION
	;

struct_declaration_list
	: struct_declaration
	| struct_declaration_list struct_declaration
	;

struct_declaration
	: specifier_qualifier_list struct_declarator_list ';'
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list
	| type_specifier
	| type_qualifier specifier_qualifier_list
	| type_qualifier
	;

struct_declarator_list
	: struct_declarator
	| struct_declarator_list ',' struct_declarator
	;

struct_declarator
	: declarator
	| ':' constant_expression
	| declarator ':' constant_expression
	;

enum_specifier
	: ENUM '{' enumerator_list '}'
	| ENUM IDENTIFIER '{' enumerator_list '}'
	| ENUM IDENTIFIER
	;

enumerator_list
	: enumerator
	| enumerator_list ',' enumerator
	;

enumerator
	: IDENTIFIER
	| IDENTIFIER '=' constant_expression
	;

type_qualifier
	: CONST
	| VOLATILE
	;

declarator
	: pointer direct_declarator
	| direct_declarator
	;

direct_declarator
	: IDENTIFIER
{
	if(func_par_define) {
		strcpy(local_var[open_brace+1][no_of_local_var[open_brace+1]], $1);
		no_of_local_var[open_brace+1]++;
	} else if(is_brace_start) {
		strcpy(local_var[open_brace][no_of_local_var[open_brace]], $1);
		no_of_local_var[open_brace]++;
	}
}
	| '(' declarator ')'
	| direct_declarator '[' constant_expression ']'
	| direct_declarator '[' ']'
	| direct_declarator '(' parameter_type_list ')' 		{sprintf(funcName, "%s", $2); addFunc();}
	| direct_declarator '(' identifier_list ')'
	| direct_declarator '(' ')' 						{sprintf(funcName, "%s", $2); addFunc();}
	;

pointer
	: '*'
	| '*' type_qualifier_list
	| '*' pointer
	| '*' type_qualifier_list pointer
	;

type_qualifier_list
	: type_qualifier
	| type_qualifier_list type_qualifier
	;

parameter_type_list
	: parameter_list
	| parameter_list ',' ELLIPSIS
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
	;

identifier_list
	: IDENTIFIER
	| identifier_list ',' IDENTIFIER
	;

type_name
	: specifier_qualifier_list
	| specifier_qualifier_list abstract_declarator
	;

abstract_declarator
	: pointer
	| direct_abstract_declarator
	| pointer direct_abstract_declarator
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'
	| '[' ']'
	| '[' constant_expression ']'
	| direct_abstract_declarator '[' ']'
	| direct_abstract_declarator '[' constant_expression ']'
	| '(' ')'
	| '(' parameter_type_list ')'
	| direct_abstract_declarator '(' ')'
	| direct_abstract_declarator '(' parameter_type_list ')'
	;

initializer
	: assignment_expression
	| '{' initializer_list '}'
	| '{' initializer_list ',' '}'
	;

initializer_list
	: initializer
	| initializer_list ',' initializer
	;

statement
	: labeled_statement
	| expression_statement
	| compound_statement
	| selection_statement
	| iteration_statement
	| jump_statement
	;

labeled_statement
	: IDENTIFIER ':' statement
	| CASE constant_expression ':' statement
	| DEFAULT ':' statement
	;

compound_statement
	: '{' '}'
	| '{' statement_list '}'
	| '{' declaration_list '}'
	| '{' declaration_list statement_list '}'
	;

declaration_list
	: declaration
	| declaration_list declaration
	;

statement_list
	: statement
	| statement_list statement
	;

expression_statement
	: ';'
	| expression ';'
	| error
{
}
	;

selection_statement
	: IF '(' expression ')' statement
	| IF '(' expression ')' statement ELSE statement
	| SWITCH '(' expression ')' statement
	;

iteration_statement
	: WHILE '(' expression ')' statement
	| DO statement WHILE '(' expression ')' ';'
	| FOR '(' expression_statement expression_statement ')' statement
	| FOR '(' expression_statement expression_statement expression ')' statement
	;

jump_statement
	: GOTO IDENTIFIER ';'
	| CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expression ';'
	;

translation_unit
	: external_declaration
	| translation_unit external_declaration
	;

external_declaration
	: function_definition
	| declaration
	| control_line
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement 	{sprintf(funcName, "%s", $2); addFunc();}
	| declaration_specifiers declarator compound_statement						{ sprintf(funcName, "%s", $2); addFunc();}
	| declarator declaration_list compound_statement							{ sprintf(funcName, "%s", $2); addFunc();}
	| declarator compound_statement	 											{sprintf(funcName, "%s", $2); addFunc();}
	;

control_line: '#' INCLUDE '"' IDENTIFIER PRE '"'
	| '#' INCLUDE '<' IDENTIFIER PRE '>'
	| '#' LINE CONSTANT
	| '#' LINE CONSTANT '"' IDENTIFIER PRE '"'
	| '#' ERROR
	| '#' ERROR MACRO
	| '#' PRAGMA
	| '#' PRAGMA MACRO
	| '#' DEFINE IDENTIFIER CONSTANT
	| '#' DEFINE IDENTIFIER MACRO
	;

%%

extern char yytext[];
extern int column;


main(int argc, char** argv){
	if (argc > 1){
		FILE *file;
		file = fopen(argv[1], "r");
		if (!file)
		{
			fprintf(stderr, "Could not open %s\n", argv[1]);
			exit(1);
		}
		yyin = file;
	}
	do {
		yyparse();
	} while (!feof(yyin));

		if(error_count > 0) {
			printf("FAIL\n");
			printErrors();
		}
		else {
			printf("PASS\n");
		}
}
/*
: used for priting parsing error.
*/
yyerror(){
	char abc[1000], abc1[1000];
	strcpy(abc, "Line Number: ");
	sprintf(abc1, "%d", yylineno);
	strcat(abc, abc1);
	strcat(abc, " '");
	strcat(abc, yyprev);
	strcat(abc, "' ");
	strcat(abc, "Unexpected Token");
	strcpy(line_error[error_count], abc);
	error_count++;
}
/*
used for adding functions in the symbol table.
*/
addFunc() {
	int i, len = strlen(funcName), a = 1;
	for(i = 0; i < func_count; i++) {
		if(!strcmp(func_name[i], funcName)) {
			a = 0;
			break;
		}
	}
	if(a) {
		char *str1 = malloc(sizeof(char)*len);
		for(i = 0; i < len && funcName[i] != '('; i++) {
			str1[i] = funcName[i];
		}
		strcpy(func_name[func_count], str1);
		free(str1);
		func_count++;
	}
	add_check = 0;
}

/*
used for checking function name is valid or not.
*/
int functionCheck(char str[]) {
	int i, a = 1;
	for(i = 0; i < func_count; i++) {
		if(!strcmp(func_name[i], str)) {
			a = 0;
			break;
		}
	}
	if(a) {
		return 0;
	}
	function_check = 1;
	return 1;
}

/*
used for cheking variable is defined or not
*/
int checkVariable(char str[]) {
	int i, j, a = 1;
	for(i = 1;i <= open_brace; i++) {
		for(j = 0; j <= no_of_local_var[i]; j++) {
			if(!strcmp(str, local_var[i][j])) {
				a = 0;
				break;
			}
		}
	}
	if(a) {
		return 0;
	}
	return 1;
}

/*
used for printing all the function names.
*/
printFuncNames() {
	int i;
	for(i = 0;i < func_count; i++) {
		// DO NOTHING
	}
}

/*
used for printing all the errors in thr input file.
*/
printErrors() {
	int i;
	printf("Total Errors : %d\n",error_count);
	for(i = 0; i < error_count; i++)
		printf("%s\n",line_error[i]);
}

addIdentifierError(char str[]) {
	char str1[1000] = "Line Number: ";
	char abc[10];
	sprintf(abc, "%d", yylineno);
	strcat(str1, abc);
	strcat(str1, " Identifier ");
	strcat(str1, str);
	strcat(str1, " not defined");
	strcpy(line_error[error_count], str1);
	error_count++;
}

addError(char c) {
	char abc[10];
	sprintf(abc, "%c", c);
	strcpy(line_error[error_count], abc);
	error_count++;
}
