; Calculadora Assembly para Windows 32 bits
; Adaptado do código Linux 64 bits original

; Declarações de funções externas da API Win32
extern _atof
extern _printf
extern _scanf
extern _system
extern _ExitProcess@4

section .data
    erro_msg db "Erro: Divisao por zero!", 13, 10, 0 
    menu_msg db "Escolha a operacao:", 13, 10
             db "1 - Soma", 13, 10
             db "2 - Subtracao", 13, 10
             db "3 - Multiplicacao", 13, 10
             db "4 - Divisao", 13, 10
             db "5 - sair", 13, 10
             db "Opcao: ", 0
    num1_msg db "Digite o primeiro numero: ", 0
    num2_msg db "Digite o segundo numero: ", 0
    result_msg db "Resultado: ", 0
    format_str db "%s", 0
    format_char db "%c", 0
    format_float_in db "%f", 0
    format_float_out db "%+.2f", 13, 10, 0
    clear_cmd db "cls", 0
    float_tmp dd 0.0
    numt1 dd 0.0
    numt2 dd 0.0
    ;numtt1 times 2 dd 4.232
   ; numtt2 dd 2.5345

    
section .bss
    opt resb 2       ; Armazena a opção do usuário
    num1 resb 16     ; Armazena o primeiro número (string)
    num2 resb 16     ; Armazena o segundo número (string)
    
section .text
global _main

; --------------------------------------------------------
; Função print_string (Exibe uma string usando printf)
; --------------------------------------------------------
print_string:
    push ebp
    mov ebp, esp
    push esi        ; String a ser impressa
    push format_str
    call _printf
    add esp, 8      ; Limpa a pilha (2 parâmetros * 4 bytes)
    mov esp, ebp
    pop ebp
    ret

; --------------------------------------------------------
; Função read_float (Lê um número float usando scanf)
; --------------------------------------------------------
read_float:
    push ebp
    mov ebp, esp
    push edi        ; Endereço onde o float será armazenado
    push format_float_in
    call _scanf
    add esp, 8      ; Limpa a pilha (2 parâmetros * 4 bytes)
    mov esp, ebp
    pop ebp
    ret

; --------------------------------------------------------
; Função read_char (Lê um caractere usando scanf)
; --------------------------------------------------------
read_char:
    push ebp
    mov ebp, esp
    push edi        ; Endereço onde o caractere será armazenado
    push format_char
    call _scanf
    add esp, 8      ; Limpa a pilha (2 parâmetros * 4 bytes)
    mov esp, ebp
    pop ebp
    ret

; --------------------------------------------------------
; Função clear_screen (Limpa a tela usando system("cls"))
; --------------------------------------------------------
clear_screen:
    push ebp
    mov ebp, esp
    push clear_cmd
    call _system
    add esp, 4      ; Limpa a pilha (1 parâmetro * 4 bytes)
    mov esp, ebp
    pop ebp
    ret

; --------------------------------------------------------
; Função exit (Finaliza o programa)
; --------------------------------------------------------
exit:
    call clear_screen
    push 0          ; Código de saída 0
    call _ExitProcess@4
    ; Não retorna

; --------------------------------------------------------
; Início do programa
; --------------------------------------------------------
_main:
    ; Configuração inicial da pilha
    push ebp
    mov ebp, esp

menu:     

    ; Exibe o menu
    mov esi, menu_msg
    call print_string

    ; Lê a opção do usuário
    mov edi, opt
    call read_char
    
    ; Limpa o buffer de entrada
   ; mov edi, opt
    ;call read_char
    
    ; Verifica a opção escolhida
    mov al, byte[opt]
    cmp al, '1'
    je soma
    cmp al, '2'
    je subtracao
    cmp al, '3'
    je multiplicacao
    cmp al, '4'
    je divisao
    cmp al, '5'
    je exit_program

    ; Se a opção for inválida, volta ao menu
    jmp menu

; --------------------------------------------------------
; Função para ler os dois números
; --------------------------------------------------------
ler_numeros:
    ; Exibe a mensagem para o primeiro número
    mov esi, num1_msg
    call print_string

    ; Lê o primeiro número
    mov edi, numt1
    call read_float

    ; Exibe a mensagem para o segundo número
    mov esi, num2_msg
    call print_string

    ; Lê o segundo número
    mov edi, numt2
    call read_float
    ret

; --------------------------------------------------------
; Operações aritméticas
; --------------------------------------------------------
soma:
 
    call ler_numeros
    fld dword [numt1]
    fadd dword [numt2]
    fstp dword [float_tmp]
    jmp resultado

subtracao:
    call ler_numeros
    fld dword [numt1]
    fsub dword [numt2]
    fstp dword [float_tmp]
    jmp resultado

multiplicacao:
    call ler_numeros
    fld dword [numt1]
    fmul dword [numt2]
    fstp dword [float_tmp]
    jmp resultado

divisao:
    call ler_numeros
    
    ; Verifica divisão por zero
    fld dword [numt2]
    ftst                ; Compara ST(0) com 0.0
    fstsw ax            ; Armazena o status word em AX
    sahf                ; Transfere AH para o registro de flags
    jz erro_divisao     ; Se for zero, vai para erro
    
    ; Realiza a divisão
    fld dword [numt1]
    fdiv dword [numt2]
    fstp dword [float_tmp]
    jmp resultado

erro_divisao:
    ; Limpa a pilha FPU
    ffree st0
    fincstp
    
    ; Exibe mensagem de erro
    mov esi, erro_msg
    call print_string
    
    ; Espera por um caractere antes de voltar ao menu
    mov edi, opt
    call read_char
    
    ; Volta ao menu
    jmp menu

resultado:
    ; Exibe a mensagem de resultado
    mov esi, result_msg
    call print_string
    
    ; Exibe o resultado formatado
         fld dword [float_tmp]
         sub esp, 8
         fstp qword [esp]
         push dword format_float_out
         call _printf
         add esp, 12      ; Limpa a pilha (2 parâmetros * 4 bytes)
    
    ; Espera por um caractere antes de limpar a tela
    mov edi, opt
    call read_char
    
    ; Limpa a tela
    ;call clear_screen
    
    ; Volta ao menu
    jmp menu

exit_program:
    call exit
