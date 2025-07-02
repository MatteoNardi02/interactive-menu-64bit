.section .data
    # per il terminale
    clear_screen: .ascii "\x1B[H\x1B[J"
    colore_reset: .ascii "\x1B[0m"
    verde: .ascii "\x1B[32m"
    giallo: .ascii "\x1B[33m"
    reverse_video: .ascii "\x1B[7m"
    
    # le opzioni del menu
    voce1: .asciz "1. Exit"
    voce2: .asciz "2. Option 2"
    voce3: .asciz "3. Option 3"
    voce4: .asciz "4. Option 4"
    
    # dove metterle
    pos_riga2: .ascii "\x1B[2;2H"
    pos_riga3: .ascii "\x1B[3;2H"
    pos_riga4: .ascii "\x1B[4;2H"
    pos_riga5: .ascii "\x1B[5;2H"
    pos_finale: .ascii "\x1B[7;1H"

    freccia: .ascii "> "
    spazio: .ascii "  "

    intestazione: .asciz " Use UP/DOWN arrows + ENTER to select or press 1-4 "
    pos_intestazione: .ascii "\x1B[1;1H"
    
    # messaggi per opzioni non implementate
    msg_not_implemented: .asciz "This option is not implemented yet. Press ENTER to continue..."
    newline: .ascii "\n"

.section .bss
    .lcomm buffer_input 32
    .lcomm impostazioni_term 60
    .lcomm backup_term 60

.section .text
    .global _start
    .global restore_terminal

_start:
    call prepara_terminale
    xor %r9, %r9      # selezione corrente

menu_loop:
    call disegna_tutto
    
    # leggi quello che ha premuto
    mov $0, %rax      # sys_read
    mov $0, %rdi      # stdin
    lea buffer_input(%rip), %rsi
    mov $3, %rdx
    syscall
    
    movb buffer_input(%rip), %al
    cmp $0x1B, %al    # ESC -> frecce
    je handle_frecce
    cmp $0x0A, %al    # invio
    je handle_invio
    
    # ha premuto direttamente 1-4
    cmp $'1', %al
    je vai_opzione1
    cmp $'2', %al
    je vai_opzione2
    cmp $'3', %al
    je vai_opzione3
    cmp $'4', %al
    je vai_opzione4
    
    jmp menu_loop

vai_opzione1:
    mov $0, %r9
    jmp handle_invio
vai_opzione2:
    mov $1, %r9
    jmp handle_invio
vai_opzione3:
    mov $2, %r9
    jmp handle_invio
vai_opzione4:
    mov $3, %r9
    jmp handle_invio

handle_frecce:
    movb buffer_input+1(%rip), %al
    cmp $0x5B, %al
    jne menu_loop
    movb buffer_input+2(%rip), %al
    cmp $0x41, %al    # su
    je freccia_su
    cmp $0x42, %al    # giu
    je freccia_giu
    jmp menu_loop

freccia_su:
    dec %r9
    cmp $-1, %r9
    jne menu_loop
    mov $3, %r9       # wrap around
    jmp menu_loop

freccia_giu:
    inc %r9
    cmp $4, %r9
    jne menu_loop
    xor %r9, %r9      # torna a 0
    jmp menu_loop

handle_invio:
    test %r9, %r9
    jz esci_programma
    
    cmp $1, %r9
    je chiamata_vedilib
    cmp $2, %r9
    je chiamata_vedies
    cmp $3, %r9
    je chiamata_vedigrad
    
    jmp menu_loop

chiamata_vedilib:
    call restore_terminal
    call mostra_non_implementato
    call prepara_terminale
    jmp menu_loop

chiamata_vedies:
    call restore_terminal
    call mostra_non_implementato
    call prepara_terminale
    jmp menu_loop

chiamata_vedigrad:
    call restore_terminal
    call mostra_non_implementato
    call prepara_terminale
    jmp menu_loop

disegna_tutto:
    # pulisci schermo
    mov $1, %rax      # sys_write
    mov $1, %rdi      # stdout
    lea clear_screen(%rip), %rsi
    mov $6, %rdx
    syscall
    
    # intestazione
    mov $1, %rax
    mov $1, %rdi
    lea pos_intestazione(%rip), %rsi
    mov $6, %rdx
    syscall
    
    # metti colori per intestazione
    mov $1, %rax
    mov $1, %rdi
    lea reverse_video(%rip), %rsi
    mov $4, %rdx
    syscall
    
    mov $1, %rax
    mov $1, %rdi
    lea giallo(%rip), %rsi
    mov $5, %rdx
    syscall
    
    mov $1, %rax
    mov $1, %rdi
    lea intestazione(%rip), %rsi
    mov $50, %rdx
    syscall
    
    # resetta colori
    mov $1, %rax
    mov $1, %rdi
    lea colore_reset(%rip), %rsi
    mov $4, %rdx
    syscall
    
    xor %r8, %r8      # uso r8 invece di esi per il contatore

loop_opzioni:
    # posiziona cursore
    test %r8, %r8
    jz pos_opt1
    cmp $1, %r8
    je pos_opt2
    cmp $2, %r8
    je pos_opt3
    # deve essere 3
    lea pos_riga5(%rip), %rsi
    jmp stampa_pos

pos_opt1:
    lea pos_riga2(%rip), %rsi
    jmp stampa_pos
pos_opt2:
    lea pos_riga3(%rip), %rsi
    jmp stampa_pos
pos_opt3:
    lea pos_riga4(%rip), %rsi

stampa_pos:
    mov $1, %rax
    mov $1, %rdi
    mov $6, %rdx
    syscall
    
    # se è selezionata, evidenziala
    cmp %r8, %r9      # confronta contatore con selezione corrente
    jne non_selezionata
    
    # evidenziata
    mov $1, %rax
    mov $1, %rdi
    lea reverse_video(%rip), %rsi
    mov $4, %rdx
    syscall
    
    mov $1, %rax
    mov $1, %rdi
    lea verde(%rip), %rsi
    mov $5, %rdx
    syscall
    
    mov $1, %rax
    mov $1, %rdi
    lea freccia(%rip), %rsi
    mov $2, %rdx
    syscall
    
    jmp stampa_testo

non_selezionata:
    mov $1, %rax
    mov $1, %rdi
    lea spazio(%rip), %rsi
    mov $2, %rdx
    syscall

stampa_testo:
    # che testo stampare
    test %r8, %r8
    jz testo_opt1
    cmp $1, %r8
    je testo_opt2
    cmp $2, %r8
    je testo_opt3
    # deve essere 3
    lea voce4(%rip), %rsi
    mov $11, %rdx
    jmp stampa_il_testo

testo_opt1:
    lea voce1(%rip), %rsi
    mov $8, %rdx
    jmp stampa_il_testo
testo_opt2:
    lea voce2(%rip), %rsi
    mov $11, %rdx
    jmp stampa_il_testo
testo_opt3:
    lea voce3(%rip), %rsi
    mov $11, %rdx

stampa_il_testo:
    mov $1, %rax
    mov $1, %rdi
    syscall
    
    # reset colori
    mov $1, %rax
    mov $1, %rdi
    lea colore_reset(%rip), %rsi
    mov $4, %rdx
    syscall
    
    inc %r8
    cmp $4, %r8
    jne loop_opzioni
    
    # cursore finale
    mov $1, %rax
    mov $1, %rdi
    lea pos_finale(%rip), %rsi
    mov $6, %rdx
    syscall
    
    ret

prepara_terminale:
    # salva terminale originale
    mov $16, %rax     # sys_ioctl
    mov $0, %rdi      # stdin
    mov $0x5401, %rsi # TCGETS
    lea backup_term(%rip), %rdx
    syscall
    
    # copia per modificare
    lea impostazioni_term(%rip), %rdi
    lea backup_term(%rip), %rsi
    mov $60, %rcx
    rep movsb
    
    # modalità raw
    lea impostazioni_term(%rip), %rbx
    andl $0xFFFFF7FF, 12(%rbx)  # no ICANON
    andl $0xFFFFFDFD, 12(%rbx)  # no ECHO
    movb $1, 17(%rbx)           # VMIN=1 (posizione diversa in 64-bit)
    movb $0, 18(%rbx)           # VTIME=0
    
    # applica
    mov $16, %rax     # sys_ioctl
    mov $0, %rdi      # stdin
    mov $0x5402, %rsi # TCSETS
    lea impostazioni_term(%rip), %rdx
    syscall
    ret

restore_terminal:
    # rimetti come prima
    mov $16, %rax     # sys_ioctl
    mov $0, %rdi      # stdin
    mov $0x5402, %rsi # TCSETS
    lea backup_term(%rip), %rdx
    syscall

    # pulisci e resetta
    mov $1, %rax
    mov $1, %rdi
    lea clear_screen(%rip), %rsi
    mov $6, %rdx
    syscall
    
    mov $1, %rax
    mov $1, %rdi
    lea colore_reset(%rip), %rsi
    mov $4, %rdx
    syscall
    ret

mostra_non_implementato:
    # stampa messaggio
    mov $1, %rax
    mov $1, %rdi
    lea msg_not_implemented(%rip), %rsi
    mov $60, %rdx
    syscall
    
    # stampa newline
    mov $1, %rax
    mov $1, %rdi
    lea newline(%rip), %rsi
    mov $1, %rdx
    syscall
    
    # aspetta ENTER
wait_enter:
    mov $0, %rax
    mov $0, %rdi
    lea buffer_input(%rip), %rsi
    mov $1, %rdx
    syscall
    
    # controlla se è ENTER (0x0A)
    movb buffer_input(%rip), %al
    cmp $0x0A, %al
    jne wait_enter
    
    ret

esci_programma:
    call restore_terminal
    
    mov $60, %rax     # sys_exit
    xor %rdi, %rdi
    syscall
