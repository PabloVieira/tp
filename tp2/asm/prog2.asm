###############################################################################################
# Autor: Lucas Ribeiro
# Programa baseado na solução disponibilizada pelo professor Ney Calazans
#
# Simulação deste programa é de aproximadamente 7,220 ns
###############################################################################################
        
    .text                   # Diretiva para o montador - adiciona o que vem abaixo
    # 	� mem�ria de programa do processador
    .globl  main            # Declare o r�tulo main Como sendo global
    # � o ponto a partir de onde se inicia a execu��o
main:
    	lui     $t2, 0x00001001
        nop
        lui     $t1, 0x00001001
        nop
        lui     $t3, 0x00001001
        nop
        lui     $t0, 0x00001001
        nop
        
        ori     $s2, $t2, 0x00000058
        nop
        ori     $s3, $t3, 0x0000005c
        nop
        ori     $s0, $t0, 0x00000000
        nop       
        ori     $s1, $t1, 0x0000002c

    	lw      $s2,0($s2)      # o registrador $21 cont�m o tamanho do vetor
    	nop
    	nop
    	lw      $s3,0($s3)      # o registrador $s3 contem a constante a somar
        
loop:   
        
    	blez    $s2, end         # se o tamanho chega a 0, fim do processamento
    	lw      $s4, 0($s0)      # obtem um elemento do vetor
    	nop
    	nop        
    	addu    $s4, $s4,$s3     # soma a constante
    	nop
    	nop
    	sw      $s4, 0($s1)      # atualiza o vetor
    	addiu   $s0, $s0, 4       # atualiza o apontador do vetor
    	addiu   $s1, $s1, 4       # atualiza o apontador do vetor
    	# lembrar que 1 palavra no MIPS ocupa 4 enderecos consecutivos de memoria
    	addiu   $s2, $s2, -1      # decrementa o contador de tamanho do vetor
    	j       loop            # continua a execucao
	nop
	nop
	nop
        # Agora volta para o programa monitor
end:    
	j	end		# fim do programa
	nop
	nop
    	nop
    .data                   # Diretiva para o montador - adiciona o que vem abaixo
    # 	a memoria de dados do processador
src:    .word   0x12 0xff 0x3 0x14 0x878 0x31  0x62 0x10 0x5 0x16 0x20
dst:    .word   0x00 0x00 0x0 0x00 0X000 0X00  0X00 0X00 0X0 0X00 0X00    
size:   .word   11              # Variavel que armazena o tamanho do vetor
const:  .word   0x100           # Constante a somar a cada elemento do vetor
