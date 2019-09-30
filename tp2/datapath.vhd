--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Datapath structural description
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
             IR_OUT :      out std_logic_vector(31 downto 0)
          );
end datapath;

architecture datapath of datapath is
    signal incpc, pc, npc1, npc2, IR, result, R1, R2, RA, RB, RIN, ext16, cte_im, IMED, op1, op2, 
           outalu, RALU, MDR, mdr_int, dtpc : std_logic_vector(31 downto 0) := (others=> '0');
    signal adD, adS : std_logic_vector(4 downto 0) := (others=> '0');    
    signal inst_branch, inst_grupo1, inst_grupoI: std_logic;   
    signal salta : std_logic := '0';
    signal controlSignals1, controlSignals2, controlSignals3, controlSignals4: sinalDeControle;
begin

   -- auxiliary signals 
   inst_branch  <= '1' when uins.i=BEQ or uins.i=BGEZ or uins.i=BLEZ or uins.i=BNE else 
                  '0';
                  
   inst_grupo1  <= '1' when uins.i=ADDU or uins.i=NOP or uins.i=SUBU or uins.i=AAND
                         or uins.i=OOR or uins.i=XXOR or uins.i=NNOR else
                   '0';

   inst_grupoI  <= '1' when uins.i=ADDIU or uins.i=ANDI or uins.i=ORI or uins.i=XORI else
                   '0';

   --==============================================================================
   -- first_stage
   --==============================================================================

   BIDI: entity work.bidi port map (
      ck => ck,
      incpc => incpc,
      instruction => instruction,
      npc => npc1,
      IR => IR
   );
   
   --==============================================================================
   -- second stage
   --==============================================================================
   ct: entity work.control_unit
            port map(ir=>IR, sinaisDeControle=>controlSignals1);
                
   -- The then clause is only used for logic shifts with shamt field       
   adS <= IR(20 downto 16) when uins.i=SSLL or uins.i=SSRA or uins.i=SSRL else 
          IR(25 downto 21);
          
   REGS: entity work.reg_bank(reg_bank) port map
        (ck=>ck, rst=>rst, wreg=>uins.wreg, AdRs=>adS, AdRt=>ir(20 downto 16), adRD=>adD,  
         Rd=>RIN, R1=>R1, R2=>R2);
    
   -- sign extension 
   ext16 <=  x"FFFF" & IR(15 downto 0) when IR(15)='1' else
             x"0000" & IR(15 downto 0);
    
   -- Immediate constant
   cte_im <= ext16(29 downto 0)  & "00"     when inst_branch='1'     else
                -- branch address adjustment for word frontier
             "0000" & IR(25 downto 0) & "00" when uins.i=J or uins.i=JAL else
                -- J/JAL are word addressed. MSB four bits are defined at the ALU, not here!
             x"0000" & IR(15 downto 0) when uins.i=ANDI or uins.i=ORI  or uins.i=XORI else
                -- logic instructions with immediate operand are zero extended
             ext16;
                -- The default case is used by addiu, lbu, lw, sbu and sw instructions

   DIEX: entity work.diex port map (
      ck => ck,
      R1 => R1,
      R2 => R2,
      cte_im => cte_im,
      RA => RA,
      RB => RB,
      IMED => IMED,
      npcIN => npc1,
      npcOUT => npc2,
      controlSignalsIN => controlSignals1,
      controlSignalsOUT => controlSignals2
   );
 
  --==============================================================================
   -- third stage
   --==============================================================================
                      
   -- select the first ALU operand                           
   op1 <= npc  when inst_branch='1' else 
          RA; 
     
   -- select the second ALU operand
   op2 <= RB when inst_grupo1='1' or uins.i=SLTU or uins.i=SLT or uins.i=JR 
                  or uins.i=SLLV or uins.i=SRAV or uins.i=SRLV else 
          IMED; 
                 
   -- ALU instantiation
   inst_alu: entity work.alu port map (op1=>op1, op2=>op2, outalu=>outalu, op_alu=>uins.i);
                                   
   -- ALU register
   --REG_alu: entity work.regnbit  port map(ck=>ck, rst=>rst, ce=>uins.walu, D=>outalu, Q=>RALU);               
 
   -- evaluation of conditions to take the branch instructions
   salta <=  '1' when ( (RA=RB  and uins.i=BEQ)  or (RA>=0  and uins.i=BGEZ) or
                        (RA<=0  and uins.i=BLEZ) or (RA/=RB and uins.i=BNE) )  else
             '0';
                 
   EXMEM: entity work.exmem port map (
      ck => ck,
      outalu => outalu,
      RALU => RALU,
      controlSignalsIN => controlSignals2,
      controlSignalsOUT => controlSignals3
   );
             
   --==============================================================================
   -- fourth stage
   --==============================================================================
     
   d_address <= RALU;
    
   -- tristate to control memory write    
   data <= RB when (uins.ce='1' and uins.rw='0') else (others=>'Z');  

   -- single byte reading from memory  -- SUPONDO LITTLE ENDIAN
   mdr_int <= data when uins.i=LW  else
              x"000000" & data(7 downto 0);
       
   --RMDR: entity work.regnbit  port map(ck=>ck, rst=>rst, ce=>uins.wmdr, D=>mdr_int, Q=>MDR);                 
  
   result <=    MDR when uins.i=LW  or uins.i=LBU else
                RALU;

   MEMER: entity work.memer port map (
      ck => ck,
      mdr_int => mdr_int,
      MDR => MDR,
      controlSignalsIN => controlSignals3,
      controlSignalsOUT => controlSignals4
   );  

   --==============================================================================
   -- fifth stage
   --==============================================================================

   -- signal to be written into the register bank
   RIN <= npc when (uins.i=JALR or uins.i=JAL) else result;
   
   -- register bank write address selection
   adD <= "11111"               when uins.i=JAL else -- JAL writes in register $31
         IR(15 downto 11)       when inst_grupo1='1' or uins.i=SLTU or uins.i=SLT
                                                     or uins.i=JALR  
						     or uins.i=SSLL or uins.i=SLLV
						     or uins.i=SSRA or uins.i=SRAV
						     or uins.i=SSRL or uins.i=SRLV
                                                     else
         IR(20 downto 16) -- inst_grupoI='1' or uins.i=SLTIU or uins.i=SLTI 
        ;                 -- or uins.i=LW or  uins.i=LBU  or uins.i=LUI, or default
    
   dtpc <= result when (inst_branch='1' and salta='1') or uins.i=J    or uins.i=JAL or uins.i=JALR or uins.i=JR  
           else npc;
   
   -- Code memory starting address: beware of the OFFSET! 
   -- The one below (x"00400000") serves for code generated 
   -- by the MARS simulator
   --rpc: entity work.regnbit generic map(INIT_VALUE=>x"00400000")   
     --                       port map(ck=>ck, rst=>rst, ce=>uins.wpc, D=>dtpc, Q=>pc);

   ERBI: entity work.erbi port map (
      ck => ck,
      dtpc => dtpc,
      pc => pc
   );

end datapath;