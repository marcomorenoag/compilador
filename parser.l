%{
/*
***Funcionalidad: Programa que realiza el análisis léxico y sintáctico de un lenguaje propio definido en la documentacion
***Autores: Corella Peréz Elda, Moreno Guerra Marco Antonio
***Fecha creación: 15 de septiembre del 2018
***Última modificación: 21 de octubre del 2018
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/******************************TABLAS DINAMICAS (ESTRUCTURA DE DATOS PARA LISTA)******************************/
/*...............Estructura de listas con clase, valor y tipo...............*/
typedef struct strNode {
    int class;
    char *value;
    char *type;
    struct strNode *next;
} strNode;

typedef struct list {
    struct strNode *head;
    struct strNode *tail;
    int size;
} list;

void initializeList(list *lista) {
    lista -> head = NULL;
    lista -> tail = NULL;
    lista -> size = 0;
    return;
}

/*Inserta nodo al final de la lista*/
void insertNode(list *lista, int class, char *value, char *type) {
    strNode *newNode = (strNode *) malloc(sizeof(strNode));
    newNode -> class = class;
    newNode -> value = strdup(value);
    /*El siguiente campo se agrega a todas las listas; pero se usará unicamente en
        la lista de identificadores, en las demás estará vacío*/
    newNode -> type = strdup(type);

    if(lista -> head == NULL) { //Si la lista esta vacia
        newNode -> next = NULL;
        lista -> head = newNode;
        lista -> tail = newNode;
    } else { //Si no esta vacia
        newNode -> next = NULL; //newNode al final de la lista
        lista -> tail -> next = newNode; //conecta ultimo elemento a newNode
        lista -> tail = newNode; //mueve tail a newNode
    }

    lista -> size ++;
    return;
}

/*Impresion de lista genérica*/
void printList(list *lista) {
    int i;
    strNode *tmp = lista -> head;

    for(i = 0; i < lista -> size; i++) {
        printf("%3d\t%s\n", tmp -> class, tmp -> value);
        tmp = tmp -> next;
    }
    return;
}

/*Impresion de lista de identificador (con campo type)*/
void printListIds(list *lista) {
    int i;
    strNode *tmp = lista -> head;

    for(i = 0; i < lista -> size; i++) {
        printf("%3d\t%s\t%s\n", tmp -> class, tmp -> value, tmp -> type);
        tmp = tmp -> next;
    }
    return;
}

/*Busqueda en la lista; si existe devuelve su indice, sino devuelve -1*/
int searchInList(list *lista, char *value) {
    strNode *currentNode = (strNode *) malloc(sizeof(strNode));
    currentNode = lista -> head;

    while(currentNode != NULL) {
        if(!strcmp(currentNode -> value, value)) {
            return currentNode -> class;
        }
        currentNode = currentNode -> next;
    }
    return -1;
}

/*...............Estructura de lista con id y valor...............*/
typedef struct atom {
    int id;
    char *letter;
    struct atom *next;
} atom;

typedef struct strAtom {
    struct atom *head;
    struct atom *tail;
    int size;
} strAtom;

void initStrAtoms(strAtom *listAtom) {
    listAtom -> head = NULL;
    listAtom -> tail = NULL;
    listAtom -> size = 0;
    return;
}

void insertAtom(strAtom *listAtom, char *character) {
    atom *newNode = (atom *) malloc(sizeof(atom));
    newNode -> id = listAtom -> size;
    newNode -> letter = strdup(character);

    if(listAtom -> head == NULL) { //Si la lista esta vacia
        newNode -> next = NULL;
        listAtom -> head = newNode;
        listAtom -> tail = newNode;
    } else { //Si no esta vacia
        newNode -> next = NULL; //newNode al final de la lista
        listAtom -> tail -> next = newNode; //conecta ultimo elemento a newNode
        listAtom -> tail = newNode; //mueve tail a newNode (nuevo último elemento)
    }

    listAtom -> size ++;
    return;
}

void printStrAtoms(strAtom *listAtom, int start) {
    int i;
    atom *tmp = listAtom -> head;

    printf("\nCADENA DE ATOMOS\n");

    for(i = 0; i < listAtom -> size; i++) {
        if(i >= start) {
            printf("%s", tmp -> letter);
        }
        tmp = tmp -> next;
    }
    printf("\n");
    return;
}


//Variable global índice de la posición del átomo actual en la cadena de atomos
int posAtom = 0;

char* nextAtom(strAtom *listAtom, int index) {
    int j;
    atom *tmp = listAtom -> head;

    if(index != 0) {
        for(j = 0; j < index; j++) {
            if(tmp -> next != NULL) {
                tmp = tmp -> next;
            }
        }
    }

    if(strcmp(tmp -> letter, "&")) {
        printStrAtoms(listAtom, ++posAtom);
    }

    return tmp -> letter;
}


/******************************TABLAS ESTATICAS (ARREGLOS ESTATICOS)******************************/
char *pReservadas[] = {"Bul", "Cadena", "Cierto", "Entero", "Falso", "Haz", "Mientras", "Para", "Real", "Si", "Sino"};
char *opRelacional[] = {".DIF.", ".IGL.", ".MN.", ".MNI.", ".MY.", ".MYI."};

/******************************FUNCIONES******************************/
int findComp(char **array, int lenght, char *key) {
    int i = 0;
    while(i < lenght) {
        if(!strcmp(*(array + i), key)) {
            break;
        }
        i++;
    }

    if(i == lenght) {
        return -1;
    } else {
        return i;
    }
}

void insertComponentLex(char **array, int lenght, char *key, FILE *file, list *componentesLexicos , int numClass) {
    char *buffer;
    int index = findComp(array, lenght, key);

    if(index != -1) {
        sprintf(buffer, "%d", index);
        fprintf(file, "%d %d\n", numClass, index);
        insertNode(componentesLexicos, numClass, buffer, "");
    }
}

void insertId(char *key, int *counter, FILE *idFile, FILE *tokFile, list *ids, list *compLexs) {
    int found = searchInList(ids, key);
    int aux = *counter;
    char *buffer;

    if(found == -1) {
        fprintf(idFile, "%d %s\n", aux, key);
        insertNode(ids, aux, key, "");

        fprintf(tokFile, "%d %d\n", 1, aux);
        sprintf(buffer, "%d", aux);
        insertNode(compLexs, 1, buffer, "");
        *counter = ++aux;
    } else {
        fprintf(tokFile, "%d %d\n", 1, found);
        sprintf(buffer, "%d", found);
        insertNode(compLexs, 1, buffer, "");
    }
}

void insertString(char *key, int *counter, FILE *strFile, FILE *tokFile, list *strs, list *compLexs) {
    int aux = *counter;
    char *buffer;

    fprintf(strFile, "%d %s\n", aux, key);
    insertNode(strs, aux, key, "");

    int found = searchInList(strs, key);
    if(found != -1) {
        fprintf(tokFile, "%d %d\n", 6, found);
        sprintf(buffer, "%d", found);
        insertNode(compLexs, 6, buffer, "");
        *counter = ++aux;
    }
}

void insertLexema(FILE *tokFile, int class, char *key, list *compLexs) {
    fprintf(tokFile, "%d %s\n", class, key);
    insertNode(compLexs, class, key, "");
}

char* knownOpRel(char *key) {
    int i = findComp(opRelacional, 6, key);

    switch(i) {
        case(0): return "!";
            break;
        case(1): return "q";
            break;
        case(2): return "<";
            break;
        case(3): return "l";
            break;
        case(4): return ">";
            break;
        case(5): return "g";
            break;
        default: return "&"; //Se agrega fin de cadena si hubo algun error
            printf("\n\t***Error en la generacion de cadena de atomos****\n");
            break;
    }
}

char* knownPalRes(char *key) {
    int i = findComp(pReservadas, 11, key);

    switch(i) {
        case(0): return "b";
            break;
        case(1): return "c";
            break;
        case(2): return "t";
            break;
        case(3): return "e";
            break;
        case(4): return "f";
            break;
        case(5): return "h";
            break;
        case(6): return "m";
            break;
        case(7): return "p";
            break;
        case(8): return "d";
            break;
        case(9): return "i";
            break;
        case(10): return "o";
            break;
        default: return "&"; //Se agrega fin de cadena si hubo algun error
            printf("\n\t***Error en la generacion de cadena de atomos****\n");
            break;
    }
}

/******************************VARIABLES GLOBALES******************************/
int numLineError = 1; //Contador para Identificar la linea de error lexico
int contId = 0;       //Contador para el indice del identificador detectado
int contString = 0;   //Contador para el indice de las constantes cadenas
int contAtom = 0;     //índice de la posición de los átomos de la cadena
char *c;              //Caracter recorrido de la cadena de atomos
int errorFlag = 0;    //Bandera para especificar que hubo un error (-1) o no hubo (0)

/*Declaracion de variables de las listas*/
list identificadores, strings, componentesLexicos;

/*Arreglo de cadena de átomos*/
strAtom stringAtoms;

/*Apuntadores a los archivos de salida*/
FILE *tokensFile;
FILE *stringsFile;
FILE *idsFile;

%}

palRes      Bul|Cadena|Cierto|Entero|Falso|Haz|Mientras|Para|Real|Si|Sino
ident       [a-z][a-zA-Z]{0,7}
simbEsp     [\(\),;\[\]]
opRel       \.(DIF|IGL|MN|MNI|MY|MYI)\.
opAsig      :=
opArit      [+\-*/%]
constCad    (\").*(\")
constEnt    [0-9][0-9]*(l|L)?
real1       ([0-9]+\.[0-9]*)
real2       (\.[0-9]+)
constReal   ({real1}|{real2}|{constEnt})(((e|E)[+\-]?)?[0-9]{1,2})?
comentario  \$\$.*
espacios    [ \t]
nuevaLinea  [\n]

%%

{palRes}        {
                    insertAtom(&stringAtoms, knownPalRes(yytext));
                    insertComponentLex(pReservadas, 11, yytext, tokensFile, &componentesLexicos, 0);
                }
{ident}         {
                    insertId(yytext, &contId, idsFile, tokensFile, &identificadores, &componentesLexicos);
                    insertAtom(&stringAtoms, "a");
                }
{simbEsp}       {
                    insertLexema(tokensFile, 2, yytext, &componentesLexicos);
                    insertAtom(&stringAtoms, yytext);
                }
{opAsig}        {
                    insertLexema(tokensFile, 3, "=", &componentesLexicos);
                    insertAtom(&stringAtoms, "=");
                }
{opRel}         {
                    insertAtom(&stringAtoms, knownOpRel(yytext));
                    insertComponentLex(opRelacional, 6, yytext, tokensFile, &componentesLexicos, 4);
                }
{opArit}        {
                    insertLexema(tokensFile, 5, yytext, &componentesLexicos);
                    insertAtom(&stringAtoms, yytext);
                }
{constCad}      {
                    insertString(yytext, &contString, stringsFile, tokensFile, &strings, &componentesLexicos);
                    insertAtom(&stringAtoms, "s");
                }
{constEnt}      {
                    insertLexema(tokensFile, 7, yytext, &componentesLexicos);
                    insertAtom(&stringAtoms, "n");
                }
{constReal}     {
                    insertLexema(tokensFile, 8, yytext, &componentesLexicos);
                    insertAtom(&stringAtoms, "r");
                }
{comentario}    {   }
{espacios}      {   }
{nuevaLinea}    {   numLineError++; }
.               {   printf("Error lexico en la linea %d: %s\n", numLineError, yytext); }

%%

/********FUNCIONES DE NO TERMINALES PARA EL PARSER*********/

/*Firmas de las funciones*/
void parser();
void G();
void Z();
void D();
void J();
void V();
void Y();
void X();
void S();
void A();
void H();
void M();
void P();
void I();
void K();
void E();
void T();
void EP();
void F();
void TP();
void R();
void Q();
void O();
void N();

/*Funciones*/
void parser() {
    //Se asigna a "c" el primer átomo de la cadena para iniciar el parser
    c = nextAtom(&stringAtoms, contAtom++);

    //Se llama a G() que es el que desencadena todo el analisis sintactico
    G();

    //Se verifica si hubo o no errores sintacticos
    if(!errorFlag) {
        printf("\n\t***NO HUBO ERRORES SINTACTICOS***\n");
    } else {
        printf("\n\t***HUBO ERRORES SINTACTICOS***\n");
    }
    return;
}

void G() {
    if(!strcmp(c, "[")) {
        c = nextAtom(&stringAtoms, contAtom++);
        Z();
        if(!strcmp(c, "]")) {
            c = nextAtom(&stringAtoms, contAtom++);
        } else {
            printf("\nSyntax Error: expecting \"]\"\n");
            errorFlag = -1;
        }
    } else {
        printf("\nSyntax Error: expecting \"[\"\n");
        errorFlag = -1;
    }
    return;
}

void Z() {
    if(!strcmp(c, "b") || !strcmp(c, "c") || !strcmp(c, "e") || !strcmp(c, "d")) {
        D();
        Z();
    } else if(!strcmp(c, "]")) { //En caso de ser producción anulable
        return;
    } else if(!strcmp(c, "a") || !strcmp(c, "h") || !strcmp(c, "m") || !strcmp(c, "p") || !strcmp(c, "i")) {
        Y();
    } else {
        printf("\nSyntax Error: expecting Data Type or \"]\" or An Assignment/Control Structure\n");
        errorFlag = -1;
    }
    return;
}

void D() {
    if(!strcmp(c, "b") || !strcmp(c, "c") || !strcmp(c, "e") || !strcmp(c, "d")) {
        J();
        if(!strcmp(c, "a")) {
            c = nextAtom(&stringAtoms, contAtom++);
            V();
        } else {
            printf("\nSyntax Error: expecting An Identifier\n");
            errorFlag = -1;
        }
    } else {
        printf("\nSyntax Error: expecting A Data Type\n");
        errorFlag = -1;
    }
    return;
}

void J() {
    if(!strcmp(c, "b")) {
        c = nextAtom(&stringAtoms, contAtom++);
    } else if(!strcmp(c, "c")) {
        c = nextAtom(&stringAtoms, contAtom++);
    } else if(!strcmp(c, "e")) {
        c = nextAtom(&stringAtoms, contAtom++);
    } else if(!strcmp(c, "d")) {
        c = nextAtom(&stringAtoms, contAtom++);
    } else {
        printf("\nSyntax Error: expecting An Bul/Cadena/Entero/Real\n");
        errorFlag = -1;
    }
    return;
}

void V() {
    if(!strcmp(c, ",")) {
        c = nextAtom(&stringAtoms, contAtom++);
        if(!strcmp(c, "a")) {
            c = nextAtom(&stringAtoms, contAtom++);
            V();
        } else {
            printf("\nSyntax Error: expecting Another Identifier\n");
            c = nextAtom(&stringAtoms, contAtom++);
        }
    } else if(!strcmp(c, ";")) {
        c = nextAtom(&stringAtoms, contAtom++);
    } else {
        printf("\nSyntax Error: expecting \";\" or \",\" For More Identifiers\n");
        errorFlag = -1;
    }
    return;
}

void Y() {
    if(!strcmp(c, "a") || !strcmp(c, "h") || !strcmp(c, "m") || !strcmp(c, "p") || !strcmp(c, "i")) {
        S();
        X();
    } else {
        printf("\nSyntax Error: expecting An Assignment or A Control Structure\n");
        errorFlag = -1;
    }
    return;
}

void X() {
    if(!strcmp(c, "a") || !strcmp(c, "h") || !strcmp(c, "m") || !strcmp(c, "p") || !strcmp(c, "i")) {
        Y();
    } else if(!strcmp(c, "]")) { //En caso de ser producción anulable
        return;
    } else {
        printf("\nSyntax Error: expecting Another Control Structure or Another Assignment\n");
        errorFlag = -1;
    }
    return;
}

void S() {
    if(!strcmp(c, "a")) {
        A();
        if(!strcmp(c, ";")) {
            c = nextAtom(&stringAtoms, contAtom++);
        } else {
            printf("\nSyntax Error: expecting \";\"\n");
            errorFlag = -1;
        }
    } else if(!strcmp(c, "h")) {
        H();
    } else if(!strcmp(c, "m")) {
        M();
    } else if(!strcmp(c, "p")) {
        P();
    } else if(!strcmp(c, "i")) {
        I();
    } else {
        printf("\nSyntax Error: expecting A Control Structure or An Assignment\n");
        errorFlag = -1;
    }
    return;
}

void A() {
    if(!strcmp(c, "a")) {
        c = nextAtom(&stringAtoms, contAtom++);
        if(!strcmp(c, "=")) {
            c = nextAtom(&stringAtoms, contAtom++);
            K();
        } else {
            printf("\nSyntax Error: expecting \":=\"\n");
            errorFlag = -1;
        }
    } else {
        printf("\nSyntax Error: expecting An Identifier\n");
        errorFlag = -1;
    }
    return;
}

void K() {
    if(!strcmp(c, "s")) {
        c = nextAtom(&stringAtoms, contAtom++);
    } else if(!strcmp(c, "t")) {
        c = nextAtom(&stringAtoms, contAtom++);
    } else if(!strcmp(c, "f")) {
        c = nextAtom(&stringAtoms, contAtom++);
    } else if(!strcmp(c, "(") || !strcmp(c, "a") || !strcmp(c, "n") || !strcmp(c, "r")) {
        E();
    } else {
        printf("\nSyntax Error: expecting A String/Cierto/Falso or An Expression\n");
        errorFlag = -1;
    }
    return;
}

void E() {
    if(!strcmp(c, "(") || !strcmp(c, "a") || !strcmp(c, "n") || !strcmp(c, "r")) {
        T();
        EP();
    } else {
        printf("\nSyntax Error: expecting An Expression\n");
        errorFlag = -1;
    }
    return;
}

void T() {
    if(!strcmp(c, "(") || !strcmp(c, "a") || !strcmp(c, "n") || !strcmp(c, "r")) {
        F();
        TP();
    } else {
        printf("\nSyntax Error: expecting ')' or Identifier or Integer or Real\n");
        errorFlag = -1;
    }
    return;
}

void F() {
    if(!strcmp(c, "(")) {
        c = nextAtom(&stringAtoms, contAtom++);
        E();
        if(!strcmp(c, ")")) {
            c = nextAtom(&stringAtoms, contAtom++);
        } else {
            printf("\nSyntax Error: expecting ')' \n");
            errorFlag = -1;
        }
    } else if(!strcmp(c, "a")) {
        c = nextAtom(&stringAtoms, contAtom++);
    } else if(!strcmp(c, "n")) {
        c = nextAtom(&stringAtoms, contAtom++);
    } else if(!strcmp(c, "r")) {
        c = nextAtom(&stringAtoms, contAtom++);
    } else {
        printf("\nSyntax Error: expecting '('/Identifier/Integer/Real\n");
        errorFlag = -1;
    }
    return;
}

void TP() {
    if(!strcmp(c, "*")) {
        c = nextAtom(&stringAtoms, contAtom++);
        F();
        TP();
    } else if(!strcmp(c, "/")) {
        c = nextAtom(&stringAtoms, contAtom++);
        F();
        TP();
    } else if(!strcmp(c, "%")) {
        c = nextAtom(&stringAtoms, contAtom++);
        F();
        TP();
    } else if(!strcmp(c, "+") || !strcmp(c, "-") || !strcmp(c, ";") || !strcmp(c, ")") || !strcmp(c, "!") ||
              !strcmp(c, "q") || !strcmp(c, "<") || !strcmp(c, "l") || !strcmp(c, ">") || !strcmp(c, "g") ) { //En caso de ser producción anulable
        return;
    } else {
        printf("\nSyntax Error: expecting + - ; ')' ! q < l > g \n");
        errorFlag = -1;
    }
    return;
}

void EP() {
    if(!strcmp(c, "+")) {
        c = nextAtom(&stringAtoms, contAtom++);
        T();
        EP();
    } else if(!strcmp(c, "-")) {
        c = nextAtom(&stringAtoms, contAtom++);
        T();
        EP();
    } else if(!strcmp(c, ";") || !strcmp(c, ")") || !strcmp(c, "!") || !strcmp(c, "q") || !strcmp(c, "<") ||
              !strcmp(c, "l") || !strcmp(c, ">") || !strcmp(c, "g")) { //En caso de ser producción anulable
        return;
    } else {
        printf("\nSyntax Error: expecting + - ; ')' ! q < l > g \n");
        errorFlag = -1;
    }
    return;
}

void H() {
    if(!strcmp(c, "h")) {
        c = nextAtom(&stringAtoms, contAtom++);
        if(!strcmp(c, "[")) {
            c = nextAtom(&stringAtoms, contAtom++);
            Y();
            if(!strcmp(c, "]")) {
                c = nextAtom(&stringAtoms, contAtom++);
                if(!strcmp(c, "m")) {
                    c = nextAtom(&stringAtoms, contAtom++);
                    if(!strcmp(c, "(")) {
                        c = nextAtom(&stringAtoms, contAtom++);
                        R();
                        if(!strcmp(c, ")")) {
                            c = nextAtom(&stringAtoms, contAtom++);
                            if(!strcmp(c, ";")) {
                                c = nextAtom(&stringAtoms, contAtom++);
                            } else {
                                printf("\nSyntax Error: expecting ; \n");
                                errorFlag = -1;
                            }
                        } else {
                            printf("\nSyntax Error: expecting ')' \n");
                            errorFlag = -1;
                        }
                    } else {
                        printf("\nSyntax Error: expecting '(' \n");
                        errorFlag = -1;
                    }
                } else {
                    printf("\nSyntax Error: expecting Mientras Structure \n");
                    errorFlag = -1;
                }
            } else {
                printf("\nSyntax Error: expecting ']' \n");
                errorFlag = -1;
            }
        } else {
            printf("\nSyntax Error: expecting '[' \n");
            errorFlag = -1;
        }
    } else {
        printf("\nSyntax Error: expecting Haz Structure \n");
        errorFlag = -1;
    }
    return;
}

void R() {
    if(!strcmp(c, "(") || !strcmp(c, "a") || !strcmp(c, "n") || !strcmp(c, "r")) {
        E();
        Q();
    } else {
        printf("\nSyntax Error: expecting '(' or Identifier/Integer/Real/Cierto/Falso \n");
        errorFlag = -1;
    }
    return;
}

void Q() {
    if(!strcmp(c, "!") || !strcmp(c, "q") || !strcmp(c, "<") || !strcmp(c, "l") || !strcmp(c, ">") || !strcmp(c, "g")) {
        O();
        E();
    } else if(!strcmp(c, ")") || !strcmp(c, ";") ) { //En caso de ser producción anulable
        return;
    } else {
        printf("\nSyntax Error: expecting An Relational Symbol or ')' or ; \n");
        errorFlag = -1;
    }
    return;
}

void O() {
    if(!strcmp(c, "!")) {
        c = nextAtom(&stringAtoms, contAtom++);
    } else if(!strcmp(c, "q")) {
        c = nextAtom(&stringAtoms, contAtom++);
    } else if(!strcmp(c, "<")) {
        c = nextAtom(&stringAtoms, contAtom++);
    } else if(!strcmp(c, "l")) {
        c = nextAtom(&stringAtoms, contAtom++);
    } else if(!strcmp(c, ">")) {
        c = nextAtom(&stringAtoms, contAtom++);
    } else if(!strcmp(c, "g")) {
        c = nextAtom(&stringAtoms, contAtom++);
    } else {
        printf("\nSyntax Error: expecting A Relational Symbol\n");
        errorFlag = -1;
    }
    return;
}

void M() {
    if(!strcmp(c, "m")) {
        c = nextAtom(&stringAtoms, contAtom++);
        if(!strcmp(c, "(")) {
            c = nextAtom(&stringAtoms, contAtom++);
            R();
            if(!strcmp(c, ")")) {
                c = nextAtom(&stringAtoms, contAtom++);
                if(!strcmp(c, "[")) {
                    c = nextAtom(&stringAtoms, contAtom++);
                    Y();
                    if(!strcmp(c, "]")) {
                        c = nextAtom(&stringAtoms, contAtom++);
                    } else {
                        printf("\nSyntax Error: expecting ']' \n");
                        errorFlag = -1;
                    }
                } else {
                    printf("\nSyntax Error: expecting '[' \n");
                    errorFlag = -1;
                }
            } else {
                printf("\nSyntax Error: expecting ')' \n");
                errorFlag = -1;
            }
        } else {
            printf("\nSyntax Error: expecting '(' \n");
            errorFlag = -1;
        }
    } else {
        printf("\nSyntax Error: expecting Mientras Structure \n");
        errorFlag = -1;
    }
    return;
}

void P() {
    if(!strcmp(c, "p")) {
        c = nextAtom(&stringAtoms, contAtom++);
        if(!strcmp(c, "(")) {
            c = nextAtom(&stringAtoms, contAtom++);
            A();
            if(!strcmp(c, ";")) {
                c = nextAtom(&stringAtoms, contAtom++);
                R();
                if(!strcmp(c, ";")) {
                    c = nextAtom(&stringAtoms, contAtom++);
                    A();
                    if(!strcmp(c, ")")) {
                        c = nextAtom(&stringAtoms, contAtom++);
                        if(!strcmp(c, "[")) {
                            c = nextAtom(&stringAtoms, contAtom++);
                            Y();
                            if(!strcmp(c, "]")) {
                                c = nextAtom(&stringAtoms, contAtom++);
                            } else {
                                printf("\nSyntax Error: expecting ']' \n");
                                errorFlag = -1;
                            }
                        } else {
                            printf("\nSyntax Error: expecting '[' \n");
                            errorFlag = -1;
                        }
                    } else {
                        printf("\nSyntax Error: expecting ')' \n");
                        errorFlag = -1;
                    }
                } else {
                    printf("\nSyntax Error: expecting \";\" \n");
                    errorFlag = -1;
                }
            } else {
                printf("\nSyntax Error: expecting \";\" \n");
                errorFlag = -1;
            }
        } else {
            printf("\nSyntax Error: expecting '(' \n");
            errorFlag = -1;
        }
    } else {
        printf("\nSyntax Error: expecting Para Structure \n");
        errorFlag = -1;
    }
    return;
}

void I() {
    if(!strcmp(c, "i")) {
        c = nextAtom(&stringAtoms, contAtom++);
        if(!strcmp(c, "(")) {
            c = nextAtom(&stringAtoms, contAtom++);
            R();
            if(!strcmp(c, ")")) {
                c = nextAtom(&stringAtoms, contAtom++);
                if(!strcmp(c, "[")) {
                    c = nextAtom(&stringAtoms, contAtom++);
                    Y();
                    if(!strcmp(c, "]")) {
                        c = nextAtom(&stringAtoms, contAtom++);
                        N();
                    } else {
                        printf("\nSyntax Error: expecting ']' \n");
                        errorFlag = -1;
                    }
                } else {
                    printf("\nSyntax Error: expecting '[' \n");
                    errorFlag = -1;
                }
            } else {
                printf("\nSyntax Error: expecting ')' \n");
                errorFlag = -1;
            }
        } else {
            printf("\nSyntax Error: expecting '(' \n");
            errorFlag = -1;
        }
    } else {
        printf("\nSyntax Error: expecting \"Si\" \n");
        errorFlag = -1;
    }
    return;
}

void N() {
    if(!strcmp(c, "a") || !strcmp(c, "h") || !strcmp(c, "m") || !strcmp(c, "p") || !strcmp(c, "i") || !strcmp(c, "]")) { //En caso de ser producción anulable
        return;
    } else if(!strcmp(c, "o")) {
        c = nextAtom(&stringAtoms, contAtom++);
        if(!strcmp(c, "[")) {
            c = nextAtom(&stringAtoms, contAtom++);
            Y();
            if(!strcmp(c, "]")) {
                c = nextAtom(&stringAtoms, contAtom++);
            } else {
                printf("\nSyntax Error: expecting ']'\n");
                errorFlag = -1;
            }
        } else {
            printf("\nSyntax Error: expecting '['\n");
            errorFlag = -1;
        }
    } else {
        printf("\nSyntax Error: expecting Identifier or ']' or Control Structure \n");
        errorFlag = -1;
    }
    return;
}


/*******FUNCIÓN PRICIPAL DEL PROGRAMA********/
int main(int argc, char *argv[]) {
    yyin = fopen(argv[1], "r");
    if(yyin == NULL) {
        printf( "Error de apertura de archivo fuente\n"
                "Verificar que exista el archivo e ingresar su nombre como parametro\n\n");
    } else {
        /*Apertura de archivos de solo escritura para almacenar las tablas "tokens", "strings" y "simbolos"*/
        tokensFile = fopen("tokens.txt", "w");
        stringsFile = fopen("strings.txt", "w");
        idsFile = fopen("identifiers.txt", "w");

        /*Inicializacion de los apuntadores de las listas*/
        initializeList(&identificadores);
        initializeList(&strings);
        initializeList(&componentesLexicos);

        /*Inicialización de apuntador de la lista de cadena de átomos*/
        initStrAtoms(&stringAtoms);

        /*Invocacion del metodo yylex() para el reconocimiento de componentes lexicos*/
        yylex();

        /*Impresion en pantalla de las tablas y sus contenidos*/
        printf("\n***Tabla de Tokens***\nCLASE   ID\n");
        printList(&componentesLexicos);

        printf("\n***Identificadores (Clase 1)***\n ID \tVALOR\t\tTIPO\n");
        printListIds(&identificadores);

        printf("\n***Constantes Cadenas (Clase 6)***\n ID  \tVALOR\n");
        printList(&strings);

        /*Insersión de símbolo de fin de cadena de átomos*/
        insertAtom(&stringAtoms, "&");

        /*Impresión de la cadena de átomos*/
        printStrAtoms(&stringAtoms, 0);

        /*Realización del análisis sintáctico*/
        parser();

        /*Cierre del flujo de escritura de los archivos*/
        fclose(tokensFile);
        fclose(stringsFile);
        fclose(idsFile);
    }
    return 0;
}
