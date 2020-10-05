extern free
extern malloc
extern intClone
extern intDelete
extern getCloneFunction
extern getCompareFunction
extern getPrintFunction
extern listNew
extern listPrint
extern fprintf
extern fopen


global floatCmp
global floatClone
global floatDelete
global floatPrint

global strClone
global strLen
global strCmp
global strDelete
global strPrint

global docClone
global docDelete

global listAdd

global treeInsert
global treePrint


section .data
    msg_string_type: DB '%s', 0
    msg_NULL: DB 'NULL', 0
    msg_parentesis: DB '(', 0
    msg_flecha: DB ')->', 0

section .text

; list struct
%define off_list_type 0
%define off_list_size 4
%define off_list_elem_first 8
%define off_list_elem_last 16

; list elem struct
%define off_list_elem_data 0
%define off_list_elem_next 8
%define off_list_elem_prev 16

; tree struct
%define off_tree_first_node 0
%define off_tree_size 8
%define off_tree_typeKey 12
%define off_tree_duplicate 16
%define off_tree_typeData 20

; tree node struct
%define off_tree_node_key 0
%define off_tree_node_values 8
%define off_tree_node_left 16
%define off_tree_node_right 24

%define NULL 0



;*** Float ***

floatCmp:
    push rbp        ;Stack Frame
    mov rbp, rsp               
 
    ; ebx -> xmm0
    ; ecx -> xmm1

    movss xmm0, dword [rdi]  ;EDI -> float* a 
    movss xmm1, dword [rsi]  ;ESI -> float* b
    comiss xmm0, xmm1        ;comparo dos float
 
    je .aIgualB ;a = b => 0
    
    ja .aMayorB ;a > b => -1
    jb .aMenorB ;a < b => 1
    
    .aIgualB: 
    mov eax, 0; 
    jmp .end

    .aMayorB: 
    mov eax, -1
    jmp .end

    .aMenorB: 
    mov eax, 1
    jmp .end
    
    .end: 
    pop rbp
ret
floatClone:
    push rbp        ;Stack Frame
    mov rbp, rsp    
    push rbx             
    push r12        ;para mantener alineada la pila, 
                    ;¿se puede pushear un registor que no vamos a usar para mantener la pila?

    ;En rdi viene el puntero al float

    mov rbx, rdi              ;Guardamos el puntero en un registro que este limpio  rbx <-rdi
    mov edi, 4                ;Reservamos 4 bytes para clonar el float
    call malloc               ;Reserva memoria y devuelve el puntero en rax

    ;mov rax, rcx ; pos de memiria 0x007777...  o .... 0x00000646..
    
    movss xmm0, dword [rbx]   ;Guardamos el numero(float)
    movss dword [rax], xmm0   ;Copiamos el valor del float de entrada

    .end:   
    pop r12     ;-----------
    pop rbx     ;-----------
    pop rbp     ;Fin Stack Frame
ret

floatDelete:
    push rbp
    mov rbp,rsp

    call free

    pop rbp
ret

;*** String ***

strClone:

push rbp
mov rbp, rsp
push r15   ;8
push r12   ;16
push r13   ;24
push r14   ;32  pila alineada a 16 bits 

;El puntero viene en rdi

mov r12,rdi   ;conservamos el puntero inicial
call strLen
mov  r13d, eax;guardamos el largo del string 
inc r13d      ;agregamos uno por el 0 al final del string
mov edi, r13d ;reservamos el largo del string en bytes mas el costo mas el 0
call malloc    
mov r14, rax  ;guardamos el puntero a la posicion de destino
mov r15, r14  ;guardamos el puntero al principio del string
mov ecx, 0    ;guardamos un 0 como comparador
              ;conservamos en rax el puntero ya para el final
dec r13d      ;le sacamos uno al largo, luego se usará para colocar el 0 al final
.ciclo: 

    cmp ecx, r13d 
    je .fin
    mov dl,byte [r12]  ;efectuamos un guardado auxiliar 
    mov byte [r14], dl ;metemos en las nuevas posiciones de memoria el string viejo
    inc r14
    inc r12 
    dec r13d
    jmp .ciclo

.fin:
mov r8, 0
mov r8b,byte 0
mov byte [r14], r8b 
mov rax, r15
pop r14
pop r13
pop r12
pop r15
pop rbp
ret

strLen:

    push rbp        
    mov rbp, rsp    
    push r13             
    push r12        
    push r14
    push r15

    mov r14, rdi ;guardamos en r14 el puntero al primer char    
    mov r12, 0   ;guardamos un 0 en nuestro contador   
    mov r13, 0   ;guardamos un 0 para usar como comparador     

    .ciclo:

        cmp r13b, byte [r14]  
        je .fin
        inc r12d       ;incrementamos el contador    
        inc r14        ;pasamos a la proxima posicion de memoria un byte mas arriba
        jmp .ciclo

    .fin:

    mov eax, r12d 

    pop r15
    pop r14
    pop r12           
    pop r13
    pop rbp 
ret




strCmp:
;RDI<-*a
;RSI<-*b
push rbp
mov rbp, rsp
push r10   
push r11
push r12
push r13

mov r10, rdi  ;r10 <- *a
mov r11, rsi  ;r11 <- *b

call strLen   ;calculo longitud de a
mov r12d, eax ;r12d <- longitud(a)

mov rdi, rsi 
call strLen   ;calculo longitud de b
mov r13d, eax ;r13d<-longitud(b)

;mientras no se haya llegado al fin de ninguno de los dos 
;seguimos mirando elemento a elemento, si alguno llego al fin decimos que el mas grande
;es el que no llego 

mov ecx, 0            ;usaremos ecx como comparador, para analizar el largo de los strings

.ciclo:

    cmp r13d, ecx         ;me fijo si el string b llego a su fin
    je .elMayorPodriaSerA

    cmp r12d, ecx         ;me fijo si el string a llego a su fin
    je .elMayorPodriaSerB ;si a llego a su fin me fijo si b llego a su fin, 

    mov r8b, byte [r10]  ;r8w<-stringA[i]
    mov r9b, byte [r11]  ;r9w<-stringB[i]
    cmp r8b, r9b 
    ja .elMayorEsA
    jb .elMayorEsB
    dec r13d
    dec r12d
    inc r10
    inc r11
    jmp .ciclo

jmp .noHayMayor

.elMayorPodriaSerA:
    cmp r12d, ecx
    jne .elMayorEsA
    jmp .noHayMayor


.elMayorPodriaSerB:
    cmp r13d, ecx
    jne .elMayorEsB
    jmp .noHayMayor

.elMayorEsA:
    mov rax, -1
    jmp .fin

.elMayorEsB:
    mov rax, 1
    jmp .fin

.noHayMayor: 
    mov rax, 0

.fin:
pop r13
pop r12
pop r11 
pop r10
pop rbp
ret




strDelete:
    push rbp
    mov rbp, rsp

    call free
    
    pop rbp
ret


strPrint:
    push rbp
    mov rbp, rsp 
    pushf
    push rbx
    push r12
    push r13

    ;rdi tenemos el puntero al string
    ;rsi tenemos el puntero al stream
    mov rbx, rdi              ;guardamos el puntero al string 
    mov r12, rsi              ;guardamos el puntero al stream

    mov rsi, rbx
    call strLen
    cmp rax, 0
    je .string_null
    ;else 
    mov rdi, r12
    mov rsi, msg_string_type
    mov rdx, rbx
    call fprintf
    jmp .fin

    .string_null:
    mov rdi, r12
    mov rsi, msg_string_type
    mov rdx, msg_NULL
    call fprintf
    jmp .fin
        
    .fin: 
    pop r13 
    pop r12
    pop rbx
    popf
    pop rbp

ret

;*** Document ***
docClone:

;typedef struct s_docElem {
    ;type_t type;
    ;void* data;
;} docElem_t;

;typedef struct s_document {
    ;int count;
    ;struct s_docElem* values;
;} document_t;

;recibimos el puntero al documento a en RDI, RDI <- *a

push rbp
mov rbp, rsp
push rbx     ;8
push r12     ;16
push r13     ;24
push r14     ;32
push r15     ;40 
push rcx     ;48

;--------------------------------------------------------------------------

mov r12, 0
mov r12d, dword [rdi]    ;guardo el count del document inicial en r12
mov rbx, qword [rdi + 8] ;guardo el puntero a values del document inicial en rbx



;-----------CREACION DEL DOCUMENTO Y DE LA ESTRUCTURA VECTOR----------------

mov rdi, 16                         ;metemos en rdi el valor del count del document pasado por parametro
call malloc                         ;reservamos 16 bytes para crear el encabezado del clonado del document 
mov r14, rax                        ;en r14 guardamos el puntero al principio del nuevo document(o sea al document) 
mov dword[r14], r12d                ;guardamos en los primeros 4 bytes el count del document inicial

mov rcx, r12                        ;guardamos la cantidad de elementos que tenia el document pasado por parametro aca
imul rcx, 16                        ;multiplicamos la cantidad de doc_elem que tenia el documento original por 16, que es su tamaño
mov rdi, rcx                       
call malloc                         ;reservamos los bytes necesarios para el cuerpo del vector que seran 16*cantDeValores

mov r15, rax                        ;guardamos en r15 el puntero al primer doc_elem 
mov [r14 + 8], r15                  ;metemos en values* del nuevo documento el puntero al primer doc_elem de nuestro document

.ciclo:

    cmp r12, 0               ;si se llego a 0 no hay mas doc_elem por agregar y terminamos
    je .fin
    ;Si no hay que agregar un nuevo doc_elem con su correspondiente contenido

    mov r13d, dword [rbx]    ;guardamos en r13d el tipo del doc_elem del antiguo document
    mov dword [r15], r13d    ;metemos en el doc_elem del nuevo document el tipo 
                             ;correspondiente proporcionado por el antiguo doc_elem

    ;------------------------------------------------------------------------
    
    ;TESTEADO 

    ;-------------------------CREAR DATA DEL DOC_ELEM-------------------------

    mov rdi,qword [rbx + 8]   ;meto en rdi el puntero a la data original 
    
    cmp r13d, 0
    je .clonarPuntero  
    cmp r13d, 1          ;depende el tipo va a clonar el dato en el nuevo doc_elem
    je .clonarInt           
    cmp r13d, 2
    je .clonarFloat
    cmp r13d, 3
    je .clonarString
    cmp r13d, 4
    je .clonarDocument

    .clonarPuntero:
    mov rax, rdi
    jmp .finCiclo
    .clonarInt:
    call intClone           
    jmp .finCiclo
    .clonarFloat:
    call floatClone
    jmp .finCiclo
    .clonarString:
    call strClone
    jmp .finCiclo
    .clonarDocument:
    call docClone
    
    ;Al terminar el clonado tenemos en rax un puntero a la data nueva por ejemplo un puntero a int.       
    

    .finCiclo:

    add r15, 8                   ;nos movemos 8 bytes dentro del nuevo doc_elem, 
                                 ;para poder respetar la alineacion, ya que se requieren 4 bytes para el type
                                 ;y otros 4 para alinear       
    mov r10, rax                 ;guardamos en r10 el puntero a la data devuelto por la funcion clone     
    mov qword [r15], r10         ;metemos el puntero en la data* de nuestro nuevo doc_Elem a la posicion de memoria apuntada por r15
    add rbx, 16                  ;movemos el rbx al proximo doc_elem del document viejo
    add r15, 8                   ;nos movemos por el document 16 bytes mas arriba, o sea al proximo doc_elem  
    dec r12                      ;decrementamos el r12 avisando que se acaba de agregar un doc_elem mas
    jmp .ciclo
.fin:
mov rax, r14
pop rcx
pop r15
pop r14
pop r13
pop r12
pop rbx
pop rbp
ret

docDelete:
push rbp
mov rbp, rsp
push rbx     ;8
push r12     ;16
push r13     ;24
push r14     ;32
push r15     ;40
push rdi     ;48

;hay que borrar todos los doc_Elem, de eso se encarga la seccion delete doc_elem
;y al final hay que usar free para borrar toda la memoria reservada

                            ;el puntero al document a borrar viene en rdi
mov r14, rdi                ;me guardo el puntero al inicio del document
mov r12d, dword [rdi]        ;guardo el valor del count en r12
mov rbx, qword [rdi + 8]     ;tendre en rbx el puntero al docElem siguiente
                            ;una vez con el puntero a values empiezo a borrar cada docElem
mov r15, rbx

.ciclo:
    mov rsi, 0
    cmp r12d, esi            ;si no se llego al final
    je .fin
    mov r13d, dword[rbx]    ;guardo el tipo en r13d
                            ;dependiendo el tipo voy a llamar a la funcion delete de cada uno de ellos
                            ;esto solo es para borrar el dato almacenado en la memoria, luego abrá que liberar la memoria pasandole a la funcion
                            ;free el puntero al document
    
    mov rdi, qword[rbx + 8] ;muevo a rdi el puntero al dato, para hacerle delete
    cmp r13d ,0
    je .borrarPuntero  
    cmp r13d ,1             
    je .borrarInt           
    cmp r13d, 2
    je .borrarFloat
    cmp r13d, 3
    je .borrarString
    cmp r13d, 4
    je .borrarDocument

    .borrarPuntero:
    call free
    .borrarInt:
    call intDelete   
    jmp .finCiclo
    .borrarFloat:
    call floatDelete
    jmp .finCiclo
    .borrarString:
    call strDelete
    jmp .finCiclo
    .borrarDocument:
    call docDelete

.finCiclo:
    add rbx, 16         ;me muevo al siguiente doc_Elem   
    dec r12d             ;decremento el count, es decir digo que borre uno de los doc elem
    jmp .ciclo          ;vuelvo al ciclo 

.fin:
mov rdi, r15            ;borramos el vector de datos
call free
mov rdi, r14
call free    
pop rdi
pop r15
pop r14
pop r13
pop r12
pop rbx
pop rbp
ret

;*** List ***

    ; typedef struct s_list {
    ;     type_t   type;                -> off 0 (4 B)
    ;     uint32_t size;                -> off 4 (4 B)
    ;     struct s_listElem *first;     -> off 8 (8 B)
    ;     struct s_listElem *last;      -> off 16 (8 B)
    ; } list_t;                         -> size: 24 B

    ; typedef struct s_listElem {
    ;     void *data;                   -> off 0 (8 B)
    ;     struct s_listElem *next;      -> off 8 (8 B)
    ;     struct s_listElem *prev;      -> off 16 (8 B)
    ; } listElem_t;                     -> size: 24 B


    ; if (lista.size == 0) {
    ;     AGREGAR PRIMER NODO
    ; } else {
    ;     NODO = lista.first
    ;     loop{
    ;         comparar = cmp(NODO.data, new_data)
    ;         if (comparar =< 0) {
    ;             AGREGAR izquierda
    ;             if (NODO.prev == 0) {
    ;                 ACTUALIZAR LIST FIRST
    ;             }
    ;         } else {
    ;             if (NODO.next == 0) {
    ;                 AGREGAR DERECHA
    ;                 ACTUALIZAR LIST LAST
    ;             } else {
    ;                 NODO = NODO.next
    ;             }
    ;         }
    ;     }
    ; }

listAdd:
    push rbp 
    mov rbp, rsp
    pushf      
    push rbx    ; 8 B
    push r12    ; 8 B
    push r13    ; 8 B
    push r14    ; 8 B
    push r15    ; 8 B

    mov rbx, rdi ; RBX : puntero a Lista
    mov r12, rsi ; R12 : puntero de data
    ; R13 : NUEVO NODO
    ; R14 : NODO

    ; Reservo memoria para el nuevo nodo
    mov rdi, 24
    call malloc
    mov r13, rax
    ; agrego la data al nodo
    mov [rax + off_list_elem_data], r12

    ; if (lista.size == 0)
    cmp dword [rbx + off_list_size], 0
    je .agregar_primer_nodo
    ; else
    mov r14, qword [rbx + off_list_elem_first]

    .ciclo:
    mov edi, dword [rbx + off_list_type]
    call getCompareFunction
    mov rdi, qword [r14 + off_list_elem_data]
    mov rsi, r12
    call rax
    ; comparar datas
    cmp eax, 1
    je .agregar_derecha
    jmp .agregar_izquierda

    .agregar_derecha:
    cmp qword [r14 + off_list_elem_next], NULL
    je .agregar_ultimo

    mov r14, qword [r14 + off_list_elem_next]
    jmp .ciclo

    .agregar_ultimo:
    mov qword [r14 + off_list_elem_next], r13
    mov qword [r13 + off_list_elem_prev], R14
    mov qword [r13 + off_list_elem_next], NULL

    mov qword [rbx + off_list_elem_last], r13
    jmp .fin

    .agregar_izquierda:
    mov rcx, qword [r14 + off_list_elem_prev]
    mov [r13 + off_list_elem_prev], rcx
    mov qword [r14 + off_list_elem_prev], r13
    mov qword [r13 + off_list_elem_next], R14

    cmp qword [r13 + off_list_elem_prev], NULL
    je .actualizar_first

    mov rcx, [r13 + off_list_elem_prev]
    mov [rcx + off_list_elem_next], r13 
    jmp .fin

    .actualizar_first:
    mov [rbx + off_list_elem_first], r13
    jmp .fin

    .agregar_primer_nodo:
    mov qword [r13 + off_list_elem_prev], NULL
    mov qword [r13 + off_list_elem_next], NULL
    ; nuevo nodo es el primero de la lista
    mov [rbx + off_list_elem_first], r13 
    ; nuevo nodo es el ultimo de la lista
    mov [rbx + off_list_elem_last], r13
    jmp .fin

    .fin:
    ;incremento la cantidad de elementos en la lista
    inc dword [rbx + off_list_size] 

    pop r15
    pop r14
    pop r13 
    pop r12
    pop rbx
    popf
    pop rbp
ret

;*** Tree ***

    ; typedef struct s_tree {
	;     struct s_treeNode* first;         -> off 0 (8 B)
	;     uint32_t size;                    -> off 8 (4 B)
	;     type_t typeKey;                   -> off 12 (4 B)
	;     int    duplicate;                 -> off 16 (4 B)
	;     type_t typeData;                  -> off 20 (4 B)
	; } tree_t;                             -> size: 24 B
    ;
	; typedef struct s_treeNode {
	;     void* key;                        -> off 0 (8 B)
	;     list_t* values;                   -> off 8 (8 B)
	;     struct s_treeNode* left;          -> off 16 (8 B)
	;     struct s_treeNode* right;         -> off 24 (8 B)
	; } treeNode_t;                         -> size: 32 B
    ; ------------------------------------------------------------------
    ; pseudocodigo (treeInsert) :
    ;
    ; if (tree.size == 0) {
    ;     CREAR PRIMER NODO
    ; } else {
    ;        nodo_padre = tree.first_node
    ;     loop {
    ;         if (nodo== 0){ // cuando el tree.size = 1 no entra 
    ;             CREAR NODO
    ;             CREAR LISTA 
    ;             AGREGAR DATA A LISTA
    ;         } else {
    ;             if ( nodo.key == key) { // nodo ya existe
    ;                 // una vez creada una lista, puede eliminarse y quedar el
    ;                 // puntero de la lista sin elementos
    ;                 if (nodo.valores == 0) {
    ;                     CREAR LISTA 
    ;                     AGREGAR DATA A LISTA
    ;                 } else {    // ya esta creada la lista
    ;                     if (duplicate == 0) {
    ;                         if (nodo.valores.size > 0) {
    ;                             NO SE PUEDE AGREGAR DATA A LISTA
    ;                         } else {
    ;                             AGREGAR DATA A LISTA
    ;                         }
    ;                     } else {
    ;                         AGREGAR DATA A LISTA
    ;                     }
    ;                 }
    ;             } else if (nodo.key > key) {
    ;                 izquierda (nodo = nodo.izquierda)
    ;             } else {    // nodo.key < key
    ;                 derecha (nodo = nodo.derecha)
    ;             }
    ;         }
    ;     }
    ; }
    ; ------------------------------------------------------------------
    ; rdi -> tree
    ; rsi -> key
    ; rdx -> data
    ; ------------------------------------------------------------------


treeInsert:
    ; Stack Frame
    push rbp 
    mov rbp, rsp
    pushf
    push rbx    ; 8 B
    push r12    ; 8 B
    push r13    ; 8 B
    push r14    ; 8 B
    push r15    ; 8 B

    ; guardo los inputs en registros preservados
    mov rbx, rdi  ; -> tree *
    mov r12, rsi  ; -> key *
    mov r13, rdx  ; -> data *
    ; r14 = nodo
    ; r15 = nodo_padre

    ; veo si tree no tiene nodos
    cmp dword [rbx + off_tree_size], 0
    je .crear_primer_nodo
    ; r14 = nodo
    mov r14, qword [rbx + off_tree_first_node]
    .ciclo: 
    cmp r14, NULL 
    ; entra en este caso cuando tree.size es > 0
    je .agregar_nodo_lista_data
    ; Comparar para cualquier tipo de key:
    mov rdi, qword [rbx + off_tree_typeKey]
    call getCompareFunction
    mov rdi, qword [r14 + off_tree_node_key]
    mov rsi, r12
    ; comparo las dos key
    call rax
    cmp eax, 0
    je .existe_nodo
    ; else if (nodo.key > key)
    jl .izquierda           ;INVERTI EL JG A JL ///////////
    ; else if (nodo.key < key)
    jg .derecha             ;INVERTI EL JL A JG ///////////

    .existe_nodo:
    
    ; if (nodo.valores == 0) // si no tiene lista
    cmp qword [r14 + off_tree_node_values], NULL
    je .nodo_sin_lista
    ; else // ya esta creada la lista
    ; if (duplicate == 0)
    cmp dword [rbx + off_tree_duplicate], 0             ; TODO TEST
    je .not_tree_duplicate                              ; TODO TEST
    ; else // es duplicable 
    call clonar_data                  
    call insertar_data_a_lista                          ; TODO TEST
    jmp .data_insertada                                 ; TODO TEST

    .not_tree_duplicate:
    ; if (nodo.valores.size > 0)
    mov rcx, qword [r14 + off_tree_node_values]
    cmp dword [rcx + off_list_size], 0
    jg .data_no_insertada
    call insertar_data_a_lista
    jmp .data_insertada

    .izquierda:
    ; actualizo el nodo padre
    mov r15, r14
    ; (nodo = nodo.izquierda)
    mov r14, qword [r14 + off_tree_node_left]
    jmp .ciclo

    .derecha:
    ; actualizo el nodo padre
    mov r15, r14
    ; (nodo = nodo.izquierda)
    mov r14, qword [r14 + off_tree_node_right]
    jmp .ciclo

    .nodo_sin_lista:
    call clonar_data
    call crear_lista
    call insertar_data_a_lista
    jmp .data_insertada

    ; Agregar nodo, lista y data a tree
    .agregar_nodo_lista_data: 
    call clonar_key
    call clonar_data

    call crear_nodo
    ; guardo el puntero del nuevo nodo
    mov r14, rax

    ; Comparar para cualquier tipo de key:
    mov rdi, qword [rbx + off_tree_typeKey]
    call getCompareFunction
    mov rdi, qword [r15 + off_tree_node_key]
    mov rsi, r12
    ; comparo las dos key
    call rax
    cmp eax, 0
    jl .hijo_izquierda              ; INVERTI JG A JL //////////
    jg .hijo_derecha                ; INVERTI JL A JG //////////

    .hijo_derecha:
    mov qword [r15 + off_tree_node_right], r14
    call crear_lista
    call insertar_data_a_lista
    jmp .data_insertada

    .hijo_izquierda:
    mov qword [r15 + off_tree_node_left], r14
    call crear_lista
    call insertar_data_a_lista
    jmp .data_insertada

    .crear_primer_nodo:
    call clonar_key
    call clonar_data

    mov rdi, 32
    call malloc
    ; agrego la key
    mov qword [rax + off_tree_node_key], r12
    ; setteo nodo izq y der son null
    mov qword [rax + off_tree_node_left], NULL
    mov qword [rax + off_tree_node_right], NULL

    ; agrego el puntero del primer nodo al arbol
    mov qword [rbx + off_tree_first_node], rax
    ; r14 = nodo
    mov r14, qword [rbx + off_tree_first_node]
    call crear_lista
    call insertar_data_a_lista
    jmp .data_insertada

    .data_insertada:
    ; incremento la cantidad de nodos del arbol
    inc dword [rbx + off_tree_size]
    mov eax, 1
    jmp .fin

    .data_no_insertada:
    mov eax, 0
    jmp .fin

    .fin:
    pop r15
    pop r14 
    pop r13
    pop r12
    pop rbx
    popf
    pop rbp
ret

clonar_key:
    mov edi, dword [rbx + off_tree_typeKey]
    call getCloneFunction
    mov rdi, r12
    call rax
    mov r12, rax
ret

clonar_data:
    mov edi, dword [rbx + off_tree_typeData]
    call getCloneFunction
    mov rdi, r13
    call rax
    mov r13, rax
ret

crear_nodo:
    mov rdi, 32
    call malloc
    ; agrego la key
    mov qword [rax + off_tree_node_key], r12
    ; setteo nodo izq y der son null
    mov qword [rax + off_tree_node_left], NULL
    mov qword [rax + off_tree_node_right], NULL
ret

crear_lista:
    mov edi, dword [rbx + off_tree_typeData]
    call listNew
    mov [r14 + off_tree_node_values], rax
ret

insertar_data_a_lista:  
    mov rdi, qword [r14 + off_tree_node_values]
    mov rsi, r13
    call listAdd
ret


;*** TreePrint ***************************
; treePrint(tree_t* tree, FILE* pFile){
; 	recursion(tree.first, pFile)
; }

; void recursion(nodo, pFile) {
; 	if (nodo.izquierda != NULL){
; 		recursion(nodo.izquierda)
; 	}
; 	print (nodo, pFile)
; 	if (nodo.derecha != NULL) {
; 		recursion(nodo.derecha)
; 	}
; }

; print(nodo, pFile){
; 	printf("(");
; 	// imprimir nodo key
; 	fPrint1 = getPrintFunction(tree.typeKey)
; 	fPrint1(nodo.key, pFile)
; 	printf(")->[");
; 	// imprimir nodo list
; 	listPrint(nodo.values, pFile)
; 	printf("]");
; }

; // print(nodo.izquierda)
; // print(nodo)
; // print(nodo.derecha)

treePrint:
    ; Stack Frame
    push rbp 
    mov rbp, rsp
    pushf       
    push rbx    
    push r12   
    push r13

    ; rdi -> tree_t*
    ; rsi -> FILE*
    mov rbx, rdi ; rdi -> tree_t*
    mov r12, rsi ; rsi -> FILE*

    cmp dword [rdi + off_tree_size], 0
    jz .tree_vacio

    mov rdi, qword [rbx + off_tree_first_node]
    mov rsi, r12
    mov rdx, rbx
    call imprimir_de_menor_a_mayor
    jmp .fin

    .tree_vacio:


    .fin:
    pop r13
    pop r12
    pop rbx
    popf
    pop rbp
ret

imprimir_de_menor_a_mayor:
    ; Stack Frame
    push rbp 
    mov rbp, rsp
    pushf
    push rbx    ; 8 B
    push r12    ; 8 B
    push r13    ; 8 B
    push r14    ; 8 B
    push r15    ; 8 B

    ; rdi -> tree_node*
    ; rsi -> FILE*
    mov rbx, rdi ; rdi -> tree_node*
    mov r12, rsi ; rsi -> FILE*
    mov r13, rdx ; rdi -> tree_t*

    ; void recursion(nodo, pFile) {
    ; 	if (nodo.izquierda != NULL){
    ; 		recursion(nodo.izquierda)
    ; 	}
    ; 	print (nodo, pFile)
    ; 	if (nodo.derecha != NULL) {
    ; 		recursion(nodo.derecha)
    ; 	}
    ; }

    cmp qword [rbx + off_tree_node_left], 0
    jne .recorrer_hijos_izquierda
    
    
    .imprimir_nodo:
    mov rdi, r12
    mov rsi, msg_string_type
    mov rdx, msg_parentesis
    call fprintf

    mov edi, dword [r13 + off_tree_typeKey]
    call getPrintFunction
    mov rdi, qword [rbx + off_tree_node_key]
    mov rsi, r12
    call rax

    mov rdi, r12
    mov rsi, msg_string_type
    mov rdx, msg_flecha
    call fprintf

    mov rdi, qword [rbx + off_tree_node_values]
    mov rsi, r12
    call listPrint

    cmp qword [rbx + off_tree_node_right], 0
    jne .recorrer_hijos_derecha

    jmp .fin

    .recorrer_hijos_izquierda:
    mov rdi, qword [rbx + off_tree_node_left]
    mov rsi, r12
    mov rdx, r13
    call imprimir_de_menor_a_mayor
    jmp .imprimir_nodo

    .recorrer_hijos_derecha:
    mov rdi, qword [rbx + off_tree_node_right]
    mov rsi, r12
    mov rdx, r13
    call imprimir_de_menor_a_mayor

    .fin:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    popf
    pop rbp
ret