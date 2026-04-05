; ============================================
; Bootloader for CorteXOS (CXOS)
; ============================================

[org 0x7c00]
[bits 16]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    mov ax, 0x0003
    int 0x10

    mov si, msg_boot
    call print_string


    mov ax, 0x1000
    mov es, ax
    xor bx, bx

    mov ah, 0x02
    mov al, 32
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0x80

    int 0x13
    jc disk_error

    mov si, msg_ok
    call print_string

    call enable_protected_mode

    jmp 0x1000:0x0000

disk_error:
    mov si, msg_error
    call print_string
    jmp halt

enable_protected_mode:
    cli

    lgdt [gdt_desc]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp 0x08:protected_mode_entry

[bits 32]
protected_mode_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    ret

print_string:
    pusha
    mov ah, 0x0e
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

halt:
    cli
    hlt
    jmp halt

; ============================================
; GDT
; ============================================
gdt_start:

    dd 0x0
    dd 0x0

    dw 0xffff
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00

    dw 0xffff
    dw 0x0000
    db 0x00 
    db 10010010b
    db 11001111b 
    db 0x00
gdt_end:

gdt_desc:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; ============================================
msg_boot  db 'CorteXOS bootloader... ', 0
msg_ok    db 'OK!', 13, 10, 0
msg_error db 'ERROR!', 13, 10, 0

; я инвалид

times 510 - ($ - $$) db 0
dw 0xaa55
