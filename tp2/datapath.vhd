-- Datapath structural description
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Std_Logic_signed.all; -- needed for comparison instructions SLTxx
use IEEE.Std_Logic_arith.all; -- needed for comparison instructions SLTxx
use work.p_MRstd.all;
   
entity datapath is
      port(  ck, rst :     in std_logic;
             i_address :   out std_logic_vector(31 downto 0);
             instruction : in std_logic_vector(31 downto 0);
             d_address :   out std_logic_vector(31 downto 0);
             data :        inout std_logic_vector(31 downto 0);  
             uins2 :        in microinstruction;
             IR_OUT :      out std_logic_vector(31 downto 0)
          );
end datapath;

architecture datapath of datapath is
    signal incpc, pc, npc2, npc3, IR,  result, R1, R2, RA, RB, RIN, ext16, cte_im, IMED, op1, op2, 
           outalu, RALU, MDR, mdr_int, dtpc : std_logic_vector(31 downto 0) := (others=> '0');
    signal adD, adS : std_logic_vector(4 downto 0) := (others=> '0');    
    signal inst_branch2, inst_branch3, inst_branch5, inst_grupo1e2, inst_grupo1e3, inst_grupoI: std_logic;   
    signal salta : std_logic := '0';
    signal uins3, uins4, uins5 : microinstruction;
begin

   -- auxiliary signals 
   inst_branch2  <= '1' when uins2.i=BEQ or uins2.i=BGEZ or uins2.i=BLEZ or uins2.i=BNE else 
                  '0';
   inst_branch3  <= '1' when uins3.i=BEQ or uins3.i=BGEZ or uins3.i=BLEZ or uins3.i=BNE else 
                  '0';
   inst_branch5  <= '1' when uins5.i=BEQ or uins5.i=BGEZ or uins5.i=BLEZ or uins5.i=BNE else 
                  '0';
   inst_grupo1e2  <= '1' when uins2.i=ADDU or uins2.i=SUBU or uins2.i=AAND
                  or uins2.i=OOR or uins2.i=XXOR or uins2.i=NNOR else
            '0';
   inst_grupo1e3  <= '1' when uins3.i=ADDU or uins3.i=SUBU or uins3.i=AAND
                         or uins3.i=OOR or uins3.i=XXOR or uins3.i=NNOR else
                   '0';

   --==============================================================================
   -- first_stage
   --==============================================================================
   ERBI: entity work.erbi generic map(INIT_VALUE=>x"00400000")   
                  port map (
                      ck => ck,
                      rst=>rst,
                      dtpc => dtpc,
                      pc => pc
                   );
  
   incpc <= pc + 4;
  
   --RNPC: entity work.regnbit port map(ck=>ck, rst=>rst, ce=>uins.CY1, D=>incpc,       Q=>npc);     
           
   --RIR: entity work.regnbit  port map(ck=>ck, rst=>rst, ce=>uins.CY1, D=>instruction, Q=>IR);

   IR_OUT <= IR ;    -- IR is the datapath output signal to carry the instruction
             
   i_address <= pc;  -- connects PC output to the instruction memory address bus
   
   
   --==============================================================================
   -- second stage
   --==============================================================================
   BIDI: entity work.bidi port map (
    ck => ck,
    incpc => incpc,
    instruction => instruction,
    npc => npc2,
    IR => IR
 );
                
   -- The then clause is only used for logic shifts with shamt field       
   adS <= IR(20 downto 16) when uins2.i=SSLL or uins2.i=SSRA or uins2.i=SSRL else 
          IR(25 downto 21);
          
   REGS: entity work.reg_bank(reg_bank) port map
        (ck=>ck, rst=>rst, wreg=>uins2.wreg, AdRs=>adS, AdRt=>IR(20 downto 16), adRD=>adD,  
         Rd=>RIN, R1=>R1, R2=>R2);
    
   -- sign extension 
   ext16 <=  x"FFFF" & IR(15 downto 0) when IR(15)='1' else
             x"0000" & IR(15 downto 0);
    
   -- Immediate constant
   cte_im <= ext16(29 downto 0)  & "00"     when inst_branch2='1'     else
                -- branch address adjustment for word frontier
             "0000" & IR(25 downto 0) & "00" when uins2.i=J or uins2.i=JAL else
                -- J/JAL are word addressed. MSB four bits are defined at the ALU, not here!
             x"0000" & IR(15 downto 0) when uins2.i=ANDI or uins2.i=ORI  or uins2.i=XORI else
                -- logic instructions with immediate operand are zero extended
             ext16;
                -- The default case is used by addiu, lbu, lw, sbu and sw instructions
             
   -- second stage registers
   --REG_S:  entity work.regnbit port map(ck=>ck, rst=>rst, ce=>uins.CY2, D=>R1,     Q=>RA);

   --REG_T:  entity work.regnbit port map(ck=>ck, rst=>rst, ce=>uins.CY2, D=>R2,     Q=>RB);
  
   --REG_IM: entity work.regnbit port map(ck=>ck, rst=>rst, ce=>uins.CY2, D=>cte_im, Q=>IMED);
 
 
  --==============================================================================
   -- third stage
   --==============================================================================
   DIEX: entity work.diex port map (
      ck => ck,
      R1 => R1,
      R2 => R2,
      cte_im => cte_im,
      RA => RA,
      RB => RB,
      IMED => IMED,
      npcIN => npc2,
      npcOUT => npc3,
      controlSignalsIN => uins2,
      controlSignalsOUT => uins3
   );
                      
   -- select the first ALU operand                           
   op1 <= npc3  when inst_branch3='1' else 
          RA; 
     
   -- select the second ALU operand
   op2 <= RB when inst_grupo1e3='1' or uins3.i=SLTU or uins3.i=SLT or uins3.i=JR 
                  or uins3.i=SLLV or uins3.i=SRAV or uins3.i=SRLV else 
          IMED; 
                 
   -- ALU instantiation
   inst_alu: entity work.alu port map (op1=>op1, op2=>op2, outalu=>outalu, op_alu=>uins3.i);
                                   
   -- ALU register
   --REG_alu: entity work.regnbit  port map(ck=>ck, rst=>rst, ce=>uins.walu, D=>outalu, Q=>RALU);               
 
   -- evaluation of conditions to take the branch instructions
   salta <=  '1' when ( (RA=RB  and uins3.i=BEQ)  or (RA>=0  and uins3.i=BGEZ) or
                        (RA<=0  and uins3.i=BLEZ) or (RA/=RB and uins3.i=BNE) )  else
             '0';
                  
             
   --==============================================================================
   -- fourth stage
   --==============================================================================
   EXMEM: entity work.exmem port map (
      ck => ck,
      outalu => outalu,
      RALU => RALU,
      controlSignalsIN => uins3,
      controlSignalsOUT => uins4
   );
     
   d_address <= RALU;
    
   -- tristate to control memory write    
   data <= RB when  uins4.rw='0' else (others=>'Z');  

   -- single byte reading from memory  -- SUPONDO LITTLE ENDIAN
   mdr_int <= data when uins4.i=LW  else
              x"000000" & data(7 downto 0);
       
   --RMDR: entity work.regnbit  port map(ck=>ck, rst=>rst, ce=>uins.wmdr, D=>mdr_int, Q=>MDR);                 
  
   result <=    MDR when uins4.i=LW  or uins4.i=LBU else
                RALU;

   --==============================================================================
   -- fifth stage
   --==============================================================================
   
   MEMER: entity work.memer port map (
      ck => ck,
      mdr_int => mdr_int,
      MDR => MDR,
      controlSignalsIN => uins4,
      controlSignalsOUT => uins5
   );

   -- signal to be written into the register bank
   RIN <= npc2 when (uins2.i=JALR or uins2.i=JAL) else result;
   
   -- register bank write address selection
   adD <= "11111"               when uins2.i=JAL else -- JAL writes in register $31
         IR(15 downto 11)       when inst_grupo1e2='1' or uins2.i=SLTU or uins2.i=SLT
                                                     or uins2.i=JALR  
						     or uins2.i=SSLL or uins2.i=SLLV
						     or uins2.i=SSRA or uins2.i=SRAV
						     or uins2.i=SSRL or uins2.i=SRLV
                                                     else
         IR(20 downto 16) -- inst_grupoI='1' or uins.i=SLTIU or uins.i=SLTI 
        ;                 -- or uins.i=LW or  uins.i=LBU  or uins.i=LUI, or default
    
   dtpc <= result when (inst_branch5='1' and salta='1') or uins3.i=J    or uins3.i=JAL or uins3.i=JALR or uins3.i=JR  
           else npc2;
   
   -- Code memory starting address: beware of the OFFSET! 
   -- The one below (x"00400000") serves for code generated 
   -- by the MARS simulator
   --rpc: entity work.regnbit generic map(INIT_VALUE=>x"00400000")   
     --                       port map(ck=>ck, rst=>rst, ce=>uins.wpc, D=>dtpc, Q=>pc);


end datapath;