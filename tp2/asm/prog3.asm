# Programa para o cálculo da série de fibonacci até a 20º posição
.text
      #la   $t0, fibs        # carrega endereço do array
      lui $at,0x00001001
      nop
      nop
      ori $t0,$1,0x00000000
      #la   $t5, size        # carrega endereço do total de números a serem calculados
      lui $at,0x00001001
      nop
      nop
      ori $t5,$at,0x00000050
nop
nop
      lw   $t5, 0($t5)      # busca quantidade de numeros a serem calculados     
      li   $t2, 1           # valor inicial da série => 1
nop
nop
      sw   $t2, 0($t0)      # F[0] = 1
      nop
      nop
      sw   $t2, 4($t0)      # F[1] = F[0] = 1
      addiu $t1, $t5, -2     # contador
      nop
loop: lw   $t3, 0($t0)      # busca últimos dois valores da série
nop
nop
      lw   $t4, 4($t0)
      nop
      nop
      addu  $t2, $t3, $t4    # Soma n-2 e n-1
      nop
      nop
      sw   $t2, 8($t0)      # Salva na próxima posição vazia
      nop
      nop
      addiu $t0, $t0, 4      # incrementa endereço
      addiu $t1, $t1, -1
      nop
      nop
      slti $t9, $t1, 1
      nop
      nop
      beqz $t9, loop        # repete enquanto não chegou ao fim
nop
nop
nop
end:    jr       $ra				# Agora volta para o programa monitor

.data
fibs:.word   0 : 20         # "array" para armazenar resultados do fibonacci
size: .word  20             # número de valores do fibonacci a serem calculados
