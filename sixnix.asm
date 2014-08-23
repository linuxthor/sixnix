BITS 64
osabi 0x09               ; FreeBSD 

global _start
_start:

    mov  rax,6           ; BSD: sys_close / Linux: sys_lstat
    mov  rdi,arky
    mov  rsi,statz 
    syscall    
 
    cmp  rax,0
    je   linux

    ;  
    ; SunOS code 
    ;
    mov rdi,sunz
    mov rax,12
    syscall

    cmp rax,0
    jne bsd

    mov rdi,1
    mov rsi,suno
    mov rdx,sunob
    mov rax,4
    syscall

    jmp bexit

    ;   
    ; BSD code
    ;
bsd:
    mov rdi,1
    mov rsi,obsd
    mov rdx,obyte
    mov rax,4            ; sys_write
    syscall

bexit:
    mov rdi,69
    mov rax,1            ; sys_exit
    syscall      
 
linux:
    ;
    ; Linux code
    ;
    mov rdi,1
    mov rsi,linz
    mov rdx,lbyte
    mov rax,1            ; sys_write
    syscall

    mov rax,60           ; sys_exit 
    mov rdi,42        
    syscall

section .data
    sunz db '/system',0
    arky db '/proc/self/stat',0 
    abyte equ $-arky
    suno db 'SunOS',0x0a
    sunob equ $-suno
    obsd db 'BSD',0x0a
    obyte equ $-obsd
    linz db 'Linux',0x0a
    lbyte equ $-linz
    statz db 144 ; sizeof(struct stat)

section .note.openbsd.ident 
    align   2 
    dd      8 
    dd      4 
    dd      1 
    db      'OpenBSD',0 
    dd      0 
    align   2

section .note.netbsd.ident
    dd      7,4,1
    db      'NetBSD',0
    db      0
    dd      200000000      

