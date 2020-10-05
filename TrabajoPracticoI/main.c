#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

void test_list(FILE *pfile){
    // Crear una lista vacı́a de tipo string
    list_t*  l1 = listNew(3);
    // Agregar exactamente 10 strings cualquiera.
    listAdd(l1, strClone("texto 1"));
    listAdd(l1, strClone("texto 2"));
    listAdd(l1, strClone("texto 3"));
    listAdd(l1, strClone("texto 4"));
    listAdd(l1, strClone("texto 5"));
    listAdd(l1, strClone("texto 6"));
    listAdd(l1, strClone("texto 7"));
    listAdd(l1, strClone("texto 8"));
    listAdd(l1, strClone("texto 9"));
    listAdd(l1, strClone("texto 0"));
    // Crear una lista vacı́a de tipo float
    list_t*  l2 = listNew(2);
    // Agregar exactamente 5 valores en punto flotante cualquiera.
    float f1 = 3.14f;
    float f2 = 10202.03f;
    float f3 = 1001.13f;
    float f4 = 10.12f;
    float f5 = 13.33f;
    listAdd(l2, floatClone(&f1));
    listAdd(l2, floatClone(&f2));
    listAdd(l2, floatClone(&f3));
    listAdd(l2, floatClone(&f4));
    listAdd(l2, floatClone(&f5));
    // Clonar ambas listas.
    list_t* l1Clone = listClone(l1);
    list_t* l2Clone = listClone(l2);
    // Imprimir ambas listas.
    listPrint(l1, pfile);
    listPrint(l2, pfile);
    listPrint(l1Clone, pfile);
    listPrint(l2Clone, pfile);
    // Borrar todas las listas creadas.
    listDelete(l1);
    listDelete(l2);
    listDelete(l1Clone);
    listDelete(l2Clone);
    
}

void test_tree(FILE *pfile){
    // Crear un tree que permita duplicados con claves de tipo Int y datos de tipo String.
    tree_t * nTree = treeNew(1,3,1);
    
    // Agregar los siguientes datos respetando el orden:
    // INSERT 1
    int key_1 = 24;
    int nTree_insertado_1 = treeInsert(nTree, &key_1, "papanatas");
    printf("Insertado : %d \n", nTree_insertado_1);
    // INSERT 2
    int key_2 = 34;
    int nTree_insertado_2 = treeInsert(nTree, &key_2, "rima" );
    printf("Insertado : %d \n", nTree_insertado_2);
    // INSERT 3
    int key_3 = 24;
    int nTree_insertado_3 = treeInsert(nTree, &key_3, "buscabullas");
    printf("Insertado : %d \n", nTree_insertado_3);
    // INSERT 4
    int key_4 = 11;
    int nTree_insertado_4 = treeInsert(nTree, &key_4, "musica");
    printf("Insertado : %d \n", nTree_insertado_4);
    // INSERT 5
    int key_5 = 31;
    int nTree_insertado_5 = treeInsert(nTree, &key_5, "Pikachu");
    printf("Insertado : %d \n", nTree_insertado_5);
    // INSERT 6
    int key_6 = 11;
    int nTree_insertado_6 = treeInsert(nTree, &key_6, "Bulbasaur");
    printf("Insertado : %d \n", nTree_insertado_6);
    // INSERT 7
    int key_7 = -2;
    int nTree_insertado_7 = treeInsert(nTree, &key_7, "Charmander" );
    printf("Insertado : %d \n", nTree_insertado_7);
    
    // Crear un tree que permita duplicados con claves de tipo Int y datos de tipo String.
    tree_t * nTree2 = treeNew(1,3,1);
    int nTree2_insertado_7 = treeInsert(nTree, &key_7, "Charmander");
    printf("Insertado : %d \n", nTree2_insertado_7);
    int nTree2_insertado_6 = treeInsert(nTree, &key_6, "Bulbasaur");
    printf("Insertado : %d \n", nTree2_insertado_6);
    int nTree2_insertado_5 = treeInsert(nTree, &key_5, "Pikachu");
    printf("Insertado : %d \n", nTree2_insertado_5);
    int nTree2_insertado_4 = treeInsert(nTree, &key_4, "musica");
    printf("Insertado : %d \n", nTree2_insertado_4);
    int nTree2_insertado_3 = treeInsert(nTree, &key_3, "buscabullas");
    printf("Insertado : %d \n", nTree2_insertado_3);
    int nTree2_insertado_2 = treeInsert(nTree, &key_2, "rima");
    printf("Insertado : %d \n", nTree2_insertado_2);
    int nTree2_insertado_1 = treeInsert(nTree, &key_1, "papanatas");
    printf("Insertado : %d \n", nTree2_insertado_1);

    // Imprimir ambos tree.
    treePrint(nTree, pfile);
    treePrint(nTree2, pfile);

    // Borrar los tree creados.
    treeDelete(nTree);
    treeDelete(nTree2);
}

void test_document(FILE *pfile){
    int32_t p = 40;
    int32_t q = -35;
    float_t f1 = 3.14f;
    float_t f2 = -2.71212f;
    char* s1 = "Hello World Wide Web";
    char* s2 = "HardCoding is fun!";
    document_t* d1 = docNew(6,TypeInt, &p ,TypeInt, &q, TypeFloat, &f1, TypeFloat, &f2, TypeString, s1, TypeString, s2);
    document_t* dClone = docClone(d1);
    docPrint(d1, pfile);
    docPrint(dClone, pfile);
    docDelete(d1);
    docDelete(dClone);
}


int main (void){
    FILE *pfile = fopen("salida.caso.propios.txt","w");
    test_list(pfile);
    test_tree(pfile);
    test_document(pfile);
    fclose(pfile);
    return 0;
}


