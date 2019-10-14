# Programa para o c�lculo da s�rie de fibonacci at� a 20� posi��o
.text
      #la   $t0, fibs        # carrega endere�o do array
      lui $at,0x00001001
      nop
      nop
      ori $t0,$1,0x00000000
      #la   $t5, size        # carrega endere�o do total de n�meros a serem calculados
      lui $at,0x00001001
      nop
      nop
      ori $t5,$at,0x00000050
nop
nop
      lw   $t5, 0($t5)      # busca quantidade de numeros a serem calculados     
      li   $t2, 1           # valor inicial da s�rie => 1
nop
nop
      sw   $t2, 0($t0)      # F[0] = 1
      nop
      nop
      sw   $t2, 4($t0)      # F[1] = F[0] = 1
      addiu $t1, $t5, -2     # contador
      nop
loop: lw   $t3, 0($t0)      # busca �ltimos dois valores da s�rie
nop
nop
      lw   $t4, 4($t0)
      nop
      nop
      addu  $t2, $t3, $t4    # Soma n-2 e n-1
      nop
      nop
      sw   $t2, 8($t0)      # Salva na pr�xima posi��o vazia
      nop
      nop
      addiu $t0, $t0, 4      # incrementa endere�o
      addiu $t1, $t1, -1
      nop
      nop
      slti $t9, $t1, 1
      nop
      nop
      beqz $t9, loop        # repete enquanto n�o chegou ao fim
nop
nop
nop
end:    jr       $ra				# Agora volta para o programa monitor

.data
fibs:.word   0 : 20         # "array" para armazenar resultados do fibonacci
size: .word  20             # n�mero de valores do fibonacci a serem calculados
