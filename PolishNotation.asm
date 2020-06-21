%include "includes/io.inc"

extern getAST
extern freeAST

section .data
    operand1 dq 0
    operand2 dd 0
    operator dd 0
    sign dd 0 
    tokens: times 400 dd 0
    size dd 0
        

section .bss
    nodes resd 100
    ; La aceasta adresa, scheletul stocheaza radacina arborelui
    root: resd 1
    
section .text
global main
main:
    ; NU MODIFICATI
    push ebp
    mov ebp, esp
    
    ; Se citeste arborele si se scrie la adresa indicata mai sus
    call getAST
   
    xor ecx, ecx

    mov [root], eax
    ; parcurgere arbore
    sub esp, 4
    push eax
    call traverseTree
    add esp, 4
    ; parcurgere array de operatii
    call traverseArray
    
    ; NU MODIFICATI
    ; Se elibereaza memoria alocata pentru arbore
    push dword [root]
    call freeAST
    
    xor eax, eax
    leave
    ret

traverseArray:
    push ebp
    mov ebp, esp
    xor ecx, ecx
    dec dword[size]
    mov ecx, dword[size]
while:
    cmp dword[tokens + ecx * 4], "mul"
    je multiply
    
    cmp dword[tokens + ecx * 4], "add"
    je add

    cmp dword[tokens + ecx * 4], "sub"
    je subtraction
    
    cmp dword[tokens + ecx * 4], "div"
    je divide

    push dword[tokens + ecx * 4] ; introduce operandul in stiva

continueWhile:
    dec ecx
    cmp ecx, -1
    jne while
    xor eax, eax
    pop eax
    PRINT_DEC 4, eax

    leave
    ret

multiply:
    pop dword[operand1] ; scoate 2 operanzi de pe stiva
    pop dword[operand2]
    xor eax, eax
    xor esi, esi
    mov eax, dword[operand1]
    mov esi, dword[operand2]
    cdq
    imul esi
    push eax
    jmp continueWhile
add:
    pop dword[operand1]
    pop dword[operand2]
    xor eax, eax
    mov eax, dword[operand1]
    add eax, dword[operand2]
    push eax
    jmp continueWhile
subtraction:
    pop dword[operand1]
    pop dword[operand2]
    xor eax, eax
    mov eax, dword[operand1]
    sub eax, dword[operand2]
    push eax
    jmp continueWhile
divide:
    pop dword[operand1]
    pop dword[operand2]
    xor eax, eax
    xor ebx, ebx
    xor edx, edx
    mov edx, 0
    mov edx, dword[operand1 + 4]
    mov eax, dword[operand1]
    mov ebx, dword[operand2]
    cdq
    idiv ebx
    push eax
    jmp continueWhile

    leave
    ret

traverseTree:
    push ebp
    mov ebp, esp
    mov esi, [ebp + 8]
    mov esi, [esi]
    push esi
    call atoi
    add esp, 4
    call changeSign ;verifica daca numarul e negativ
    
    xor ecx, ecx
    mov ecx, dword[size]
    mov dword[tokens + ecx * 4], eax
    inc dword[size]

moveLeft:
    xor esi, esi
    mov esi, [ebp + 8]
    cmp dword [esi + 4], 0
    je moveRight
    push dword[esi + 4]
    call traverseTree
moveRight:
    mov esi, [ebp + 8]
    cmp dword [esi + 8], 0
    je endTraverseTree
    push dword [esi + 8]
    call traverseTree
endTraverseTree:
    mov esp, ebp
    pop ebp
    ret



changeSign:
    cmp byte[sign], 1
    je negate
    ret
negate:
    imul eax, -1
    ret

atoi:
    push ebp
    mov ebp, esp
    xor ecx, ecx
    cmp byte[esi + 0], 45 ; verific daca numarul e negativ
    je negative
    jmp pozitive
negative:
    cmp byte[esi + 1], 0
    je convert
    mov ecx, 1 ; pornesc conversia de la urmatorul caracter
    mov dword[sign],1 ; marchez numarul ca negativ 
    xor edx, edx
    xor eax, eax
    jmp convert
pozitive:   
    mov ecx, 0
    mov dword[sign], 0 ; marchez numarul ca pozitiv
    xor edx, edx
    xor eax, eax 
convert:
   
    cmp byte[esi + ecx] , 43
    je encryptAdd

    cmp byte[esi + ecx], 42
    je encryptMul

    cmp byte[esi + ecx] , 47
    je encryptDiv

    cmp byte[esi + ecx] , 45
    je encryptSub

    jmp continueAtoi
encryptAdd:
    xor eax, eax
    mov eax, "add"
    jmp endAtoi
encryptSub:
    xor eax, eax
    mov eax, "sub"
    jmp endAtoi
encryptMul:
    xor eax, eax
    mov eax, "mul"
    jmp endAtoi
encryptDiv:
    xor eax, eax
    mov eax, "div"
    jmp endAtoi

continueAtoi:
    mov dl, byte[esi + ecx] ; retin caracterul
    sub edx, 48 ; transform caracteul in int
    add eax, edx ; construiesc numarul convertit in eax
    cmp byte[esi + ecx + 1], 0  
    je continue
    mov ebx, 10
    cdq
    imul ebx
continue:
    inc ecx
    jmp for
for:
    cmp byte[esi + ecx], 0
    jne convert
endAtoi:    
    leave
    ret
