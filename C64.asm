;r = 64bit & e = 32bit
;rax/eax define o tipo de syscall
;rdi/edi primeiro parametro da syscall(0 = stdin, 1 = stdout)
;rsi/rsi segundo parametro da syscall 
;rdx/edx terçeiro parametro da syscall
;resb = mallock


section .data
    erro_msg db "Erro: Divisao por zero!", 10, 0 
    menu_msg db "Escolha a operacao:", 10
             db "1 - Soma", 10
             db "2 - Subtracao", 10
             db "3 - Multiplicacao", 10
             db "4 - Divisao", 10
             db "5 - sair", 10
             db "Opcao: ", 0
    num1_msg db "Digite o primeiro numero: ", 0
    num2_msg db "Digite o segundo numero: ", 0
    teste    db "teste", 0
    testep    db "+", 0
    testen    db "-", 0
    result_msg db "Resultado: ", 0
    newline db 10, 0
    ten dq 10  ; Constante usada para divisão por 10
    clear_screen db 27, "[2J", 27, "[H", 0  ; Sequência ANSI para limpar a tela
    float_tmp dq 0

    num_menos2 dd -2.0

    numt1 dq 0.0
    numt2 dq 0.0

      cti:
    dd 1000000000, 100000000, 10000000, 1000000, 100000, 10000, 1000, 100, 10, 1, 0
  
ctf32:
    dd 500000000      ; 2^-1  = 0.5
    dd 250000000      ; 2^-2  = 0.25
    dd 125000000      ; 2^-3  = 0.125
    dd 62500000       ; 2^-4  = 0.0625
    dd 31250000       ; 2^-5  = 0.03125
    dd 15625000       ; 2^-6  = 0.015625
    dd 7812500        ; 2^-7  = 0.0078125
    dd 3906250        ; 2^-8  = 0.00390625
    dd 1953125        ; 2^-9  = 0.001953125
    dd 976563         ; 2^-10 = 0.0009765625
    dd 488281         ; 2^-11 = 0.00048828125
    dd 244141         ; 2^-12 = 0.000244140625
    dd 122070         ; 2^-13 = 0.0001220703125
    dd 61035          ; 2^-14 = 0.00006103515625
    dd 30517          ; 2^-15 = 0.000030517578125
    dd 15258          ; 2^-16 = 0.0000152587890625
    dd 7629           ; 2^-17 = 0.00000762939453125
    dd 3814           ; 2^-18 = 0.000003814697265625
    dd 1907           ; 2^-19 = 0.0000019073486328125
    dd 953            ; 2^-20 = 0.00000095367431640625
    dd 477            ; 2^-21 = 0.000000476837158203125
    dd 238            ; 2^-22 = 0.0000002384185791015625
    dd 119            ; 2^-23 = 0.00000011920928955078125
    dd 59             ; Extra segurança / alinhamento
    dd 29
    dd 14
    dd 7
    dd 3
    dd 1
    dd 0
    dd 0




section .bss
    opt resb 2       ; Armazena a opção do usuário
    num1 resb 16     ; Armazena o primeiro número (string)
    num2 resb 16     ; Armazena o segundo número (string)
    result_str resb 16  ; Buffer para armazenar o número convertido em string
    saida resb 100
section .text
global _start

tes:
    mov rsi, teste
    call print_string

;positivo:
   ; mov rsi, testep
   ; call print_string

;negativo:
   ; mov rsi, testen
    ;call print_string        
; --------------------------------------------------------
; Função print_string (Exibe uma string até encontrar o código 0)
; --------------------------------------------------------
print_string:
    push rsi            ; Salva o ponteiro original da string
    xor rdx, rdx        ; Zera rdx (contador de tamanho)

 .loop:
    mov al, [rsi + rdx] ; Carrega um byte da string
    test al, al         ; Verifica se é '\0' (terminador nulo)
    jz .done            ; Se for '\0', sai do loop
    inc rdx             ; Incrementa o contador
    jmp .loop           ; Continua no loop

 .done:
    mov rax, 1          ; syscall write
    mov rdi, 1          ; stdout
    pop rsi             ; Recupera o endereço original da string
    syscall             ; Chama syscall para exibir a string
    ret

print_string_limit6:
    push rsi
    push rcx
    push rdx
    push rax
    push rdi

    xor rcx, rcx              ; rcx = 0, usado para contar dígitos após o ponto


 .print_sinal:
    mov rdx, 1
    mov rax, 1
    mov rdi, 1
    syscall
 
    

 .come_zero:
    inc rsi
    mov al, [rsi] 
    cmp al, '0'
    je .come_zero


 .print_loop:
    mov al, [rsi]             ; Lê caractere atual
    cmp al, 0
    je .done                  ; Se for fim da string, termina
    
    mov rdx, 1
    mov rax, 1
    mov rdi, 1
    syscall

    mov al, [rsi]
    cmp al, '.'               ; Verifica se é o ponto decimal
    je .decimal1   ; Se for, inicia a contagem de casas decimais

    jmp .next_char             ; Se ainda não, continua

 .next_char:

    inc rsi
    jmp .print_loop


 .decimal1:
    inc rsi

    mov rdx, 1
    mov rax, 1
    mov rdi, 1
    syscall

    jmp .decimal2
    
 .decimal2:
    inc rsi

    mov rdx, 1
    mov rax, 1
    mov rdi, 1
    syscall

    jmp .decimal3

 .decimal3:
    inc rsi

    mov rdx, 1
    mov rax, 1
    mov rdi, 1
    syscall

    jmp .decimal4

 .decimal4:
    inc rsi

    mov rdx, 1
    mov rax, 1
    mov rdi, 1
    syscall

    jmp .decimal5

 .decimal5:
    inc rsi

    mov rdx, 1
    mov rax, 1
    mov rdi, 1
    syscall

    jmp .decimal6

 .decimal6:
    inc rsi

    mov rdx, 1
    mov rax, 1
    mov rdi, 1
    syscall

    jmp .done
 .done:
    pop rdi
    pop rax
    pop rdx
    pop rcx
    pop rsi
    ret

; --------------------------------------------------------
; Função read_string (Lê uma string do usuário)
; --------------------------------------------------------
read_string:
    mov rax, 0          ; syscall read
    mov rdi, 0          ; stdin
    mov rdx, 16         ; Lê até 16 bytes
    syscall
    ret

; --------------------------------------------------------
; Função str_to_float (Converte uma string numérica em um inteiro)
; --------------------------------------------------------
str_to_float:
 push r8
 push rcx
 push rdx
 push r10

 mov r10,0
 mov al,byte [rsi]
 cmp al, '+'
 jz prox_char
 cmp al, '-'
 jnz ler_str
 mov r10,1

 prox_char:
 inc rsi  

 ler_str:

 call str_to_uint
 mov qword [float_tmp],rax
 fild qword [float_tmp]

 mov al, byte [rsi]
 cmp al,'.'
 jnz sf_done

 inc rsi
 mov r8, rsi
 call str_to_uint
 mov rcx, rsi
 sub rcx, r8
 mov qword [float_tmp], rax
 fild qword [float_tmp]

 mov rax ,1
 mov r8, 10

 sf_dec_loop:
 cmp rcx,0
 jz sf_dec_loop_end
 mul r8
 dec rcx
 jmp sf_dec_loop

 sf_dec_loop_end:
 mov qword [float_tmp],rax
 fild qword [float_tmp]
 fdivp
 faddp

 sf_done:
  fstp dword [float_tmp]
  mov eax, dword [float_tmp]

  cmp r10, 1
  jnz sf_done1
  or eax, 80000000h

 sf_done1:
  pop r10
  pop rdx
  pop rcx
  pop r8

  ret

 str_to_uint:
  push rbx
  push rdx
  push r8

  xor rax,rax
  xor rbx,rbx
  mov r8, 10

 uint_loop:
  mov bl,byte [rsi]
  cmp bl, '0'
  jc unit_done
  cmp bl, '9'+1
  jnc unit_done

  sub bl, '0'
  mul r8
  add rax,rbx
  inc rsi
  jmp uint_loop

 unit_done:
  pop r8
  pop rdx
  pop rbx

  ret  
; --------------------------------------------------------
; Função float_to_str (Converte um inteiro em string)
; --------------------------------------------------------
float_to_str:
   
   mov r8, saida
   push rax
   push rbx
   push rcx
   push rsi
   push rdi



 
   test eax,80000000h
   jnz f_neg
   mov byte [r8], '+'
   jmp f_exp

    mov rsi, teste
    call print_string

 f_neg:
  mov byte [r8], '-'
 
 f_exp:
  inc r8
  push rax
  mov cl,23
  shr rax,cl
  and rax, 0FFh
  mov rcx,rax

  pop rax

  and rax, 7FFFFFh
  or rax, 800000h
  shl rax, 9

  cmp rcx,127
  jz f_exp_done
  jc f_exp_neg
  sub rcx,127
  shl rax, cl
  jmp f_exp_done

 f_exp_neg:
  add rcx,128
  neg rcx
  add rcx, 07Fh
  sub rcx, 1
  shr rax, cl
 
 f_exp_done:
  push rax
  xor rbx,rbx
  shld rbx,rax,32
  mov rax,rbx
  call unit_to_str10
  mov byte [r8], '.'
  inc r8
  pop rbx
  xor eax,eax
  mov rsi,ctf32
  mov rcx, 32
  mov rdi, 80000000h

 f_frac:

  test rbx,rdi
  jz f_frac_skip
  add eax, dword[rsi]

 f_frac_skip:

  add rsi, 4
  shr rdi, 1
  loop f_frac

 
  call unit_to_str9

  pop rdi
  pop rsi
  pop rcx
  pop rbx
  pop rax

  ret
 
 unit_to_str:
 unit_to_str10:
  push rsi
  mov rsi, cti
 
  call unit_to_str_intern

  pop rsi
  ret

 unit_to_str9:
  push rsi
  mov rsi , cti 
  add rsi, 4
  
  call unit_to_str_intern

  pop rsi
  ret

 unit_to_str_intern:
  push rax
  push rbx
  push rcx
  push rdx
  push rsi

 unit_to_str_loop:
  xor edx,edx
  mov ecx, dword [rsi]
  cmp ecx, 0
  jz unit_to_str_done
  div ecx
  add al, '0'
  mov byte [r8],al
  inc r8
  mov eax,edx
  add rsi,4
  jmp unit_to_str_loop

 unit_to_str_done:
  pop rsi
  pop rdx
  pop rcx
  pop rbx
  pop rax
 
  ret
 
 


; --------------------------------------------------------
; Função exit (Finaliza o programa)
; --------------------------------------------------------
exit:
    mov rsi, clear_screen
    call print_string
    mov rax, 60  ; syscall exit
    syscall
    ret

; --------------------------------------------------------
; Início do programa
; --------------------------------------------------------
_start:
    mov rsi, menu_msg
    call print_string

    mov rsi, opt
    call read_string
    mov al, byte [opt]  
    cmp al, '1'          
    je soma
    cmp al, '2'           
    je subtracao
    cmp al, '3'         
    je multiplicacao
    cmp al, '4'        
    je divisao
    cmp al, '5'        
    je exit

    call exit  ; Se a opção for inválida, sai do programa

ler_numeros:
    mov rsi, num1_msg
    call print_string

    mov rsi, num1
    call read_string

 
    mov rsi, num1        ; Converte num1 para inteiro

    call str_to_float      


    mov rbx, rax         ; Armazena o valor de num1 em rbx




    mov rsi, num2_msg
    call print_string

    mov rsi, num2
    call read_string
    mov rsi, num2        ; Converte num2 para inteiro
    call str_to_float      
    mov rcx, rax         ; Armazena o valor de num2 em rcx
    ret

soma:
    call ler_numeros    

    mov [numt1], rbx
    mov [numt2], rcx
    fld dword [numt1] 
    fadd  dword [numt2]  ; rbx = num1 + num2

    fstp dword [float_tmp]   ; Salva o resultado da FPU em float32 (descarta ST(0))
    mov eax, dword [float_tmp]

    jmp resultado

subtracao:
    call ler_numeros

    mov [numt1], rbx
    mov [numt2], rcx

    fld dword [numt1] 
    fsub  dword [numt2]   ; rbx = num1 - num2

    fstp dword [float_tmp]   ; Salva o resultado da FPU em float32 (descarta ST(0))

    jmp resultado

multiplicacao:
    call ler_numeros

    mov [numt1], rbx
    mov [numt2], rcx

    fld dword [numt1] 
    fmul  dword [numt2]  ; rbx = num1 * num2

    fstp dword [float_tmp]   ; Salva o resultado da FPU em float32 (descarta ST(0))
    mov eax, dword [float_tmp]

    jmp resultado

divisao:
    call ler_numeros  ; Chama função para ler os dois números
    test rcx, rcx      ; Verifica se o divisor (num2) é zero
    jz erro_divisao    ; Se for zero, vai para o erro de divisão

    xor rdx, rdx       ; Limpa o registrador rdx (necessário para operação de divisão 64 bits)

    mov [numt1], rbx
    mov [numt2], rcx

    fld dword [numt1] 
    fdiv  dword [numt2]           ; Divide rax (dividendo) por rcx (divisor), resultado em rax, resto em rdx
    
    ; O resultado (quociente) agora está em rax
    ; O resto da divisão (em rdx) não está sendo utilizado aqui, mas poderia ser

    fstp dword [float_tmp]   ; Salva o resultado da FPU em float32 (descarta ST(0))
    mov eax, dword [float_tmp]
    
    jmp resultado      ; Vai para a exibição do resultado

erro_divisao:
    mov rsi, erro_msg
    call print_string  ; Exibe a mensagem de erro
    jmp _start         ; Volta ao menu

resultado:

    mov rsi, result_msg
    call print_string

    mov eax,dword [float_tmp]
    call float_to_str
    mov rsi, saida 
    call print_string_limit6

    call read_string
    mov rsi, clear_screen
    call print_string

    jmp _start  ; Reinicia o programa



;Integrantes:
;João Lucas Gomes – 2312130197
;Arthur Brito     - 2312130001
;Raul Finageiv    – 2312130194
;Luan Menezes     - 2312130224
;Lucas Gonçalves  - 2312130198
;Vitor Hugo       - 2312130182
