/*Mini proyecto Equipo: Jose Enrique Angeles Avalos Juan Frias Carrillo Miguel Angel Rubi Rico*/
%{ 
#include <ctype.h>
#include <stdio.h>
#include <string.h>

/*Enumeracion para los valores de las clases*/
enum class { reserv, identifier, constant, operator, specialChar, string, directive };

/*Representa un token, aunque permite el comportamiento como un nodo de lista doblemente ligada*/
typedef struct token
{
	int type; /*Clase*/
	int idx; /*Indice*/
	char *data; /*Dato a guardar*/
	struct token *next; /*Apuntadores de la lista*/
	struct token *prev;
}Token;

/*Representa los metadatos de la lista de tokens*/
typedef struct tokenTable
{
	int size;
	Token *begin;
	Token *end;
}TokenTable;

/*Representa un simbolo de la tabla de simbolos*/
typedef struct symbol
{
	int idx;
	char *data;
	struct symbol *next;
	struct symbol *prev;
}Symbol;

/*Reṕresenta la tabla de simbolos*/
typedef struct symbolTable
{
	int size;
	Symbol *begin;
	Symbol *end;
}SymbolTable;

/*Variable singleton de la tabla de tokens y de simbolos*/
static TokenTable *tokenTable = NULL;
static SymbolTable *symbolTable = NULL;

TokenTable *createTable();
SymbolTable *createSymbolTable();
void destroyTable();
void destroySymbolTable();
void add(char *, int);
char *delete();
void listTable();
void addSymbol(char *);
char *deleteSymbol();
void listSymbols();
int findInTable(char *); 
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
{id} { add(yytext, identifier); addSymbol(yytext); }
{cte} { add(yytext, constant); }
{op} { add(yytext, operator); }
{cs} { add(yytext, specialChar); }
{str} { add(yytext, string); }
{dir} { add(yytext, directive); }
{ign} {}
%%
/*Se llena la tabla conforme las entradas coinciden con los diferentes clasificadores
add() agrega a la tabla de tokens y addSymbolos a la de simbolos*/
int yywrap(void)
{
	return 1;
}

int main(int argc, char *argv[])
{
    if (argc == 2)
	{
		yyin = fopen(argv[1], "r"); //Se setea al archivo a leer
		tokenTable = createTable();
		symbolTable = createSymbolTable();

		yylex(); //Se ejecuta a lex
		printf("\n\nTabla de simbolos: \n");
		listSymbols();
		printf("\n\nTabla de tokens: \n");
		listTable();
		destroyTable(); //Se libera la memoria
		return 0;
	}
    
    else
        return -1;
}

/*Se crean las instancias*/
TokenTable *createTable()
{
	return (TokenTable*)calloc(1, sizeof(TokenTable));
}

SymbolTable *createSymbolTable()
{
	return (SymbolTable*)calloc(1, sizeof(SymbolTable));
}

/*Libera los nodos como si fuera una cola y regresa los valores como retorno*/
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

void destroySymbolTable()
{
	while (symbolTable -> size > 0)
	{
		char *str = deleteSymbol();
		free(str);
		str = NULL;
	}

	free(symbolTable);
	symbolTable = NULL;
}

void add(char *data, int type)
{
	int size = strlen(data) + 21; //Se obtiene el tamaño de la cadena
	Token *new = (Token*)calloc(1, sizeof(Token)); //Se crea nuevo nodo/token
	
	new -> data = (char*)calloc(size, sizeof(char));
	new -> type = type; //Se agrega la informacion al token que se agregara
	new -> idx = tokenTable -> size;

	switch(type) //Se clasifica el texto mostrado segun la clase
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

	strcat(new -> data, data); /*Se contacatena la informacion y un salto de linea*/
	strcat(new -> data, "\n");

	/*Se agrega el nodo siguiendo la regla de insercion basica para nodos intermedios*/
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

	tokenTable -> size++; //Se aumenta el tamaño de la tabla/lista
}

int findInTable(char *data) //Busca una cadena dentro de la lista/tabla
{	
	if (symbolTable -> begin)
	{
		Symbol *tmp = symbolTable -> begin;

		while (tmp -> next) //Busca hasta encontrar el dato o llegar al final de la lista
		{
			if (!strncmp(tmp -> data, data, strlen(data)))
				return -1;

			tmp = tmp -> next;
		}
	}

	return 0;
}

/*Funciona igual que la tabla de tokens, con la salveldad que esta asegura que el dato no exista
dentro de la tabla antes de agregarlo*/
void addSymbol(char *data)
{
	if (!findInTable(data)) //Si es cero permite agregar el dato
	{
		int size = strlen(data) + 1;
		Symbol *new = (Symbol*)calloc(1, sizeof(Symbol));

		new -> data = (char*)calloc(size, sizeof(char));
		new -> idx = symbolTable -> size;

		strcpy(new -> data, data);
		strcat(new -> data, "\n");

		if (!symbolTable -> end)
		{
			symbolTable -> end = new;
			symbolTable -> begin = symbolTable -> end;
		}
	
		else
		{
			new -> prev = symbolTable -> end;
			symbolTable -> end -> next = new;
			symbolTable -> end = symbolTable -> end -> next;
		}

		symbolTable -> size++;
	}
}

/*Funciones list que permiten mostrar el contenido de la lista sin alterar los nodos*/
void listTable()
{
	Token *tmp = tokenTable -> begin;

	while (tmp -> next)
	{
		printf("%d %s", tmp -> idx, tmp -> data);
		tmp = tmp -> next;
	}
}

void listSymbols()
{
	Symbol *tmp = symbolTable -> begin;

	while (tmp -> next)
	{
		printf("%d %s", tmp -> idx, tmp -> data);
		tmp = tmp -> next;
	}
}

/*Las funciones delete obtienen una copia del valor del nodo, se libera el nodo y se manda
la informacion del nodo como returno de la funcion*/
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

char *deleteSymbol()
{
	int size = strlen(symbolTable -> begin -> data) + 1;
	char *data = (char*)calloc(size, sizeof(char));
	Symbol *tmp = symbolTable -> begin;

	strncpy(data, symbolTable -> begin -> data, size);
	symbolTable -> begin = symbolTable -> begin -> next;
	symbolTable -> size--;
	free(tmp);

	return data;
}