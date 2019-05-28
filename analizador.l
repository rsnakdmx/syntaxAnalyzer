/*Mini proyecto Equipo: Jose Enrique Angeles Avalos Juan Frias Carrillo Miguel Angel Rubi Rico*/
%{ 
#include <stdio.h>
#include <string.h>

enum class { reserv, identifier, constant, operator, specialChar, string, directive };

typedef struct token
{
	int type;
	char *data;
	struct token *next;
	struct token *prev;
}Token;

typedef struct tokenTable
{
	int size;
	Token *begin;
	Token *end;
}TokenTable;

static TokenTable *tokenTable = NULL;

TokenTable *createTable();
void destroyTable();
void add(char *, int);
char *delete();
void listTable();
%} 

pr (auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|int|long|register|return|short|signed|sizeof|static|struct|typedef|union|unsigned|void|volatile|while)
id [a-zA-Z_][a-zA-Z0-9_]*
cte ([0-9]+|[A-Z]+\ [0-9]+)
op (\+(\+|=)?|\-(\-|=)?|\/\=?|\*\=?|\%\=?|\=\=?|\!\=?|\>(\>\=|\=|\>)?|\<(\<\=|\=|\<)?|\&(\&|\=)?|\^\=?|\|\=?|\?|\:|\.|\-\>)
cs (\#\#?|\\|\,|\(|\)|\{|\}|\'|\.\.\.|\;)
str (\"([^\"\\]|\\.)*\")
dir (\#define\ |\#ifdef|\#ifndef|\#include\ ?|\#pragma\ once)
ign (\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/)|(\/\/.*)|(\ |\t|\n)

%%
{pr} { add(yytext, reserv); }
{id} { add(yytext, identifier); }
{cte} { add(yytext, constant); }
{op} { add(yytext, operator); }
{cs} { add(yytext, specialChar); }
{str} { add(yytext, string); }
{dir} { add(yytext, directive); }
{ign} {}
%%

int yywrap(void)
{
	return 1;
}

int main(int argc, char *argv[])
{
    if (argc == 2)
	{
		yyin = fopen(argv[1], "r");
		tokenTable = createTable();

		yylex();
		listTable();
		destroyTable();
		return 0;
	}
    
    else
        return -1;
}

TokenTable *createTable()
{
	return (TokenTable*)calloc(1, sizeof(TokenTable));
}

void destroyTable()
{
	while (tokenTable -> size > 0)
	{
		char *str = delete();
		free(str);
		str = NULL;
	}

	free(tokenTable);
	tokenTable = NULL;
}

void add(char *data, int type)
{
	int size = tokenTable -> size + 20;
	Token *new = (Token*)calloc(1, sizeof(Token));
	
	new -> data = (char*)calloc(size, sizeof(char));
	new -> type = type;

	switch(type)
	{
		case reserv:
			strcpy(new -> data, "Palabra reservada: ");
			break;
		case identifier:
			strcpy(new -> data, "Identificador: ");
			break;
		case constant:
			strcpy(new -> data, "Constante: ");
			break;
		case operator:
			strcpy(new -> data, "Operador: ");
			break;
		case specialChar:
			strcpy(new -> data, "Caracter especial: ");
			break;
		case string:
			strcpy(new -> data, "Cadena: ");
			break;
		default:
			strcpy(new -> data, "Directiva: ");
	}

	strcat(new -> data, data);
	strcat(new -> data, "\n");

	if (!tokenTable -> end)
	{
		tokenTable -> end = new;
		tokenTable -> begin = tokenTable -> end;
	}
	
	else
	{
		new -> prev = tokenTable -> end;
		tokenTable -> end -> next = new;
		tokenTable -> end = tokenTable -> end -> next;
	}

	tokenTable -> size++;
}

void listTable()
{
	Token *tmp = tokenTable -> begin;

	while (tmp -> next)
	{
		printf("%s", tmp -> data);
		tmp = tmp -> next;
	}
}

char *delete()
{
	int size = strlen(tokenTable -> begin -> data) + 1;
	char *data = (char*)calloc(size, sizeof(char));
	Token *tmp = tokenTable -> begin;

	strncpy(data, tokenTable -> begin -> data, size);
	tokenTable -> begin = tokenTable -> begin -> next;
	tokenTable -> size--;
	free(tmp);

	return data;
}