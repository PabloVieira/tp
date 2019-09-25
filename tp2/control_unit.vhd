--------------------------------------------------------------------------
--------------------------------------------------------------------------
--  Control Unit behavioral description 
--------------------------------------------------------------------------
--------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use work.p_MRstd.all;

entity control_unit is
        port(   ck, rst : in std_logic;     
                ir : in std_logic_vector(31 downto 0);
                sinaisDeControle: out sinalDeControle
             );
end control_unit;
                   
architecture control_unit of control_unit is
   signal i : inst_type;      
begin
      
    ----------------------------------------------------------------------------------------
    -- BLOCK (1/3) - INSTRUCTION DECODING and ALU operation definition.
    -- This block generates 1 Output Function of the Control Unit
    ----------------------------------------------------------------------------------------
    i <=   ADDU   when ir(31 downto 26)="000000" and ir(10 downto 0)="00000100001" else
           NOP    when ir(31 downto 26)="000000" and ir(10 downto 0)="00000000000" else
           SUBU   when ir(31 downto 26)="000000" and ir(10 downto 0)="00000100011" else
           AAND   when ir(31 downto 26)="000000" and ir(10 downto 0)="00000100100" else
           OOR    when ir(31 downto 26)="000000" and ir(10 downto 0)="00000100101" else
           XXOR   when ir(31 downto 26)="000000" and ir(10 downto 0)="00000100110" else
           NNOR   when ir(31 downto 26)="000000" and ir(10 downto 0)="00000100111" else
           SSLL   when ir(31 downto 21)="00000000000" and ir(5 downto 0)="000000" else
           SLLV   when ir(31 downto 26)="000000" and ir(10 downto 0)="00000000100" else
           SSRA   when ir(31 downto 21)="00000000000" and ir(5 downto 0)="000011" else
           SRAV   when ir(31 downto 26)="000000" and ir(10 downto 0)="00000000111" else
           SSRL   when ir(31 downto 21)="00000000000" and ir(5 downto 0)="000010" else
           SRLV   when ir(31 downto 26)="000000" and ir(10 downto 0)="00000000110" else
           ADDIU  when ir(31 downto 26)="001001" else
           ANDI   when ir(31 downto 26)="001100" else
           ORI    when ir(31 downto 26)="001101" else
           XORI   when ir(31 downto 26)="001110" else
           LUI    when ir(31 downto 26)="001111" else
           LW     when ir(31 downto 26)="100011" else
           LBU    when ir(31 downto 26)="100100" else
           SW     when ir(31 downto 26)="101011" else
           SB     when ir(31 downto 26)="101000" else
           SLTU   when ir(31 downto 26)="000000" and ir(5 downto 0)="101011" else
           SLT    when ir(31 downto 26)="000000" and ir(5 downto 0)="101010" else
           SLTIU  when ir(31 downto 26)="001011"                             else
           SLTI   when ir(31 downto 26)="001010"                             else
           BEQ    when ir(31 downto 26)="000100" else
           BGEZ   when ir(31 downto 26)="000001" and ir(20 downto 16)="00001" else
           BLEZ   when ir(31 downto 26)="000110" and ir(20 downto 16)="00000" else
           BNE    when ir(31 downto 26)="000101" else
           J      when ir(31 downto 26)="000010" else
           JAL    when ir(31 downto 26)="000011" else
           JALR   when ir(31 downto 26)="000000"  and ir(20 downto 16)="00000"
                                           and ir(10 downto 0) = "00000001001" else
           JR     when ir(31 downto 26)="000000" and ir(20 downto 0)="000000000000000001000" else
           invalid_instruction ; -- IMPORTANT: default condition is invalid instruction;
        
    assert i /= invalid_instruction
          report "******************* INVALID INSTRUCTION *************"
          severity error;
                   
    
        sinaisDeControle.RegDst  <= '1' when i=ADDU or
                                             i=SUBU or
                                             i=AAND or
                                             
                                        else '0';

        sinaisDeControle.ULAOp <=  i;                                   

        sinaisDeControle.ULAFonte <= '1' when i=ADDIU or
                                              i=ANDI or
                                              i=BEQ or
                                              i=BNE or
                                              i=LBU or
                                              i=LUI or
                                              i=LW or
                                              i=ORI or
                                              i=SB or
                                              i=SLTI or
                                              i=SLTIU or
                                              i=SW
                                         else '0';

        sinaisDeControle.EscReg <= '0' when i=SW or
                                            i=SB or
                                            i=BEQ or
                                            i=BGEZ or 
                                            i=BLEZ or
                                            i=BNE
                                        else '1';

        sinaisDeControle.DvC <= '1' when i=BEQ or
                                         i=BGEZ or
                                         i=BLEZ or
                                         i=BNE or
                                         i=J else '0';
   
        sinaisDeControle.EscMem    	<= '1' when i=SB or i=SW else '0';
      
      
    
  
    
  
    
  
    sinaisDeControle.LerMem		<= '1' when i=LW or i=LBU else '0';
  
    sinaisDeControle.MemParaReg  <= '1' when i=LW or i=LBU else '0';
    
end control_unit;