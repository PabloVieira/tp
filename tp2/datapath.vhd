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
    signal inst_branch2e, inst_branch3e, inst_branch5e, inst_grupo1e3, inst_grupo1e5: std_logic;   
    signal salta : std_logic := '0';
    signal controlSignals2e, controlSignals3e, controlSignals4e, controlSignals5e: sinalDeControle;
begin

   -- auxiliary signals 
   inst_branch2e  <= '1' when controlSignals2e.ULAOp=BEQ or controlSignals2e.ULAOp=BGEZ or
                             controlSignals2e.ULAOp=BLEZ or controlSignals2e.ULAOp=BNE
                        else '0';
   inst_branch3e  <= '1' when controlSignals3e.ULAOp=BEQ or controlSignals3e.ULAOp=BGEZ or
                             controlSignals3e.ULAOp=BLEZ or controlSignals3e.ULAOp=BNE
                        else '0';
   inst_branch5e  <= '1' when controlSignals4e.ULAOp=BEQ or controlSignals4e.ULAOp=BGEZ or
                             controlSignals4e.ULAOp=BLEZ or controlSignals4e.ULAOp=BNE
                        else '0';
                  
   inst_grupo1e3  <= '1' when controlSignals3e.ULAOp=ADDU or controlSignals3e.ULAOp=NOP or controlSignals3e.ULAOp=SUBU or
                              controlSignals3e.ULAOp=AAND or controlSignals3e.ULAOp=OOR or controlSignals3e.ULAOp=XXOR or
                              controlSignals3e.ULAOp=NNOR
                         else '0';
   inst_grupo1e5  <= '1' when controlSignals5e.ULAOp=ADDU or controlSignals5e.ULAOp=NOP or controlSignals5e.ULAOp=SUBU or
                              controlSignals5e.ULAOp=AAND or controlSignals5e.ULAOp=OOR or controlSignals5e.ULAOp=XXOR or
                              controlSignals5e.ULAOp=NNOR
                        else '0';                

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
   ct: entity work.control_unit  port map(ir=>IR, sinaisDeControle=>controlSignals2e);
                
   -- The then clause is only used for logic shifts with shamt field       
   adS <= IR(20 downto 16) when controlSignals2e.ULAOp=SSLL or controlSignals2e.ULAOp=SSRA or controlSignals2e.ULAOp=SSRL
                           else IR(25 downto 21);
          
   REGS: entity work.reg_bank(reg_bank) port map
        (ck=>ck, rst=>rst, wreg=>uins.wreg, AdRs=>adS, AdRt=>ir(20 downto 16), adRD=>adD,  
         Rd=>RIN, R1=>R1, R2=>R2);
    
   -- sign extension 
   ext16 <=  x"FFFF" & IR(15 downto 0) when IR(15)='1'
                                       else x"0000" & IR(15 downto 0);
    
   -- Immediate constant
   cte_im <= ext16(29 downto 0)  & "00"     when inst_branch2e='1'     else
                -- branch address adjustment for word frontier
             "0000" & IR(25 downto 0) & "00" when controlSignals2e.ULAOp=J or controlSignals2e.ULAOp=JAL else
                -- J/JAL are word addressed. MSB four bits are defined at the ALU, not here!
             x"0000" & IR(15 downto 0) when controlSignals2e.ULAOp=ANDI or controlSignals2e.ULAOp=ORI  or controlSignals2e.ULAOp=XORI else
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
      controlSignalsIN => controlSignals2e,
      controlSignalsOUT => controlSignals3e
   );
 
  --==============================================================================
   -- third stage
   --==============================================================================
                      
   -- select the first ALU operand                           
   op1 <= npc  when inst_branch3e='1' else 
          RA; 
     
   -- select the second ALU operand
   op2 <= RB when inst_grupo1='1' or controlSignals3e.ULAOp=SLTU or controlSignals3e.ULAOp=SLT or controlSignals3e.ULAOp=JR 
                  or controlSignals3e.ULAOp=SLLV or controlSignals3e.ULAOp=SRAV or controlSignals3e.ULAOp=SRLV
                  else IMED; 
                 
   -- ALU instantiation
   inst_alu: entity work.alu port map (op1=>op1, op2=>op2, outalu=>outalu, op_alu=>controlSignals3e.ULAOp);
 
   -- evaluation of conditions to take the branch instructions
   salta <=  '1' when ( (RA=RB  and controlSignals3e.ULAOp=BEQ)  or (RA>=0  and controlSignals3e.ULAOp=BGEZ) or
                        (RA<=0  and controlSignals3e.ULAOp=BLEZ) or (RA/=RB and controlSignals3e.ULAOp=BNE) )  else
             '0';
                 
   EXMEM: entity work.exmem port map (
      ck => ck,
      outalu => outalu,
      RALU => RALU,
      controlSignalsIN => controlSignals3e,
      controlSignalsOUT => controlSignals4e
   );
             
   --==============================================================================
   -- fourth stage
   --==============================================================================
     
   d_address <= RALU;
    
   -- tristate to control memory write    
   data <= RB when (uins.ce='1' and uins.rw='0') else (others=>'Z');  

   -- single byte reading from memory  -- SUPONDO LITTLE ENDIAN
   mdr_int <= data when controlSignals4e.ULAOp=LW  else x"000000" & data(7 downto 0);
       
   --RMDR: entity work.regnbit  port map(ck=>ck, rst=>rst, ce=>uins.wmdr, D=>mdr_int, Q=>MDR);                 
  
   result <= MDR when controlSignals4e.ULAOp=LW  or controlSignals4e.ULAOp=LBU else RALU;

   MEMER: entity work.memer port map (
      ck => ck,
      mdr_int => mdr_int,
      MDR => MDR,
      controlSignalsIN => controlSignals4e,
      controlSignalsOUT => controlSignals5e
   );  

   --==============================================================================
   -- fifth stage
   --==============================================================================

   -- signal to be written into the register bank
   RIN <= npc when (controlSignals5e.ULAOp=JALR or controlSignals5e.ULAOp=JAL) else result;
   
   -- register bank write address selection
   adD <= "11111"               when controlSignals5e.ULAOp=JAL else -- JAL writes in register $31
         IR(15 downto 11)       when inst_grupo1='1' or controlSignals5e.ULAOp=SLTU or controlSignals5e.ULAOp=SLT
                                                     or controlSignals5e.ULAOp=JALR  
						     or controlSignals5e.ULAOp=SSLL or controlSignals5e.ULAOp=SLLV
						     or controlSignals5e.ULAOp=SSRA or controlSignals5e.ULAOp=SRAV
						     or controlSignals5e.ULAOp=SSRL or controlSignals5e.ULAOp=SRLV
                                                     else
         IR(20 downto 16) -- inst_grupoI='1' or uins.ULAOp=SLTIU or uins.ULAOp=SLTI 
        ;                 -- or uins.ULAOp=LW or  uins.ULAOp=LBU  or uins.ULAOp=LUI, or default
    
   dtpc <= result when (inst_branch5e='1' and salta='1') or controlSignals5e.ULAOp=J    or controlSignals5e.ULAOp=JAL or controlSignals5e.ULAOp=JALR or controlSignals5e.ULAOp=JR  
           else npc;
   
   -- Code memory starting address: beware of the OFFSET! 
   -- The one below (x"00400000") serves for code generated 
   -- by the MARS simulator

   ERBI: entity work.erbi port map (
      ck => ck,
      dtpc => dtpc,
      pc => pc
   );

end datapath;