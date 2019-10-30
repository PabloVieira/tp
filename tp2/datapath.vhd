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
             uinsMEMout :     out microinstruction
          );
end datapath;

architecture datapath of datapath is
    signal incpc, pc, npcBI, npcDI, npcEX, npcMEM, npcER, IRdi, IRex,  result, R1, R2, RA, RtEX, RtMEM, RIN, ext16, cte_im, IMED, op1, op2, 
           outalu, RALUmem, RALUer, MDR, mdr_int, dtpc : std_logic_vector(31 downto 0) := (others=> '0');
    signal ir2016, adDex, adDmem, adDer, adS : std_logic_vector(4 downto 0) := (others=> '0');    
    signal inst_branchDI, inst_branchEX, inst_branchMEM, inst_grupo1DI, inst_grupo1EX: std_logic;   
    signal salta : std_logic := '0';
    signal uinsDI, uinsEX, uinsMEM, uinsER : microinstruction;
begin

   -- auxiliary signals 
   inst_branchDI  <= '1' when uinsDI.i=BEQ or uinsDI.i=BGEZ or uinsDI.i=BLEZ or uinsDI.i=BNE else 
   '0';
   inst_branchEX  <= '1' when uinsEX.i=BEQ or uinsEX.i=BGEZ or uinsEX.i=BLEZ or uinsEX.i=BNE else 
                  '0';
   inst_branchMEM  <= '1' when uinsMEM.i=BEQ or uinsMEM.i=BGEZ or uinsMEM.i=BLEZ or uinsMEM.i=BNE else 
                  '0';
   inst_grupo1DI  <= '1' when uinsDI.i=ADDU or uinsDI.i=NOP or uinsDI.i=SUBU or uinsDI.i=AAND
                  or uinsDI.i=OOR or uinsDI.i=XXOR or uinsDI.i=NNOR else
            '0';
   inst_grupo1EX  <= '1' when uinsEX.i=ADDU or uinsEX.i=SUBU or uinsEX.i=AAND
                         or uinsEX.i=OOR or uinsEX.i=XXOR or uinsEX.i=NNOR else
                   '0';

   --==============================================================================
   -- BI_stage
   --==============================================================================

   dtpc <= result when (inst_branchMEM='1' and salta='1') or uinsMEM.i=J    or uinsMEM.i=JAL or uinsMEM.i=JALR or
                        uinsMEM.i=JR  
                  else npcBI;
  
   npcBI <= pc + 4;
  
   --RNPC: entity work.regnbit port map(ck=>ck, rst=>rst, ce=>uins.CY1, D=>incpc,       Q=>npc);     
           
   --RIR: entity work.regnbit  port map(ck=>ck, rst=>rst, ce=>uins.CY1, D=>instruction, Q=>IR);
             
   i_address <= pc;  -- connects PC output to the instruction memory address bus
   
   
   --==============================================================================
   -- DI stage
   --==============================================================================
   ct: entity work.control_unit port map( ck=>ck, rst=>rst, ir=>IRdi, uins=>uinsDI);

   BIDI: entity work.bidi port map (
    ck => ck,
    rst=>rst,
    npcBI => npcBI,
    instruction => instruction,
    npcDI => npcDI,
    IR => IRdi
 );
                
   -- The then clause is only used for logic shifts with shamt field       
   adS <= IRdi(20 downto 16) when uinsER.i=SSLL or uinsER.i=SSRA or uinsER.i=SSRL else 
          IRdi(25 downto 21);
          
   REGS: entity work.reg_bank(reg_bank) port map
        (ck=>ck, rst=>rst, wreg=>uinsER.wreg, AdRs=>adS, AdRt=>IRdi(20 downto 16), adRD=>adDer,  
         Rd=>RIN, R1=>R1, R2=>R2);
    
   -- sign extension 
   ext16 <=  x"FFFF" & IRdi(15 downto 0) when IRdi(15)='1' else
             x"0000" & IRdi(15 downto 0);
    
   -- Immediate constant
   cte_im <= ext16(29 downto 0)  & "00"     when inst_branchDI='1'     else
                -- branch address adjustment for word frontier
             "0000" & IRdi(25 downto 0) & "00" when uinsDI.i=J or uinsDI.i=JAL else
                -- J/JAL are word addressed. MSB four bits are defined at the ALU, not here!
             x"0000" & IRdi(15 downto 0) when uinsDI.i=ANDI or uinsDI.i=ORI  or uinsDI.i=XORI else
                -- logic instructions with immediate operand are zero extended
             ext16;
                -- The default case is used by addiu, lbu, lw, sbu and sw instructions
             
   -- second stage registers
   --REG_S:  entity work.regnbit port map(ck=>ck, rst=>rst, ce=>uins.CY2, D=>R1,     Q=>RA);

   --REG_T:  entity work.regnbit port map(ck=>ck, rst=>rst, ce=>uins.CY2, D=>R2,     Q=>RB);
  
   --REG_IM: entity work.regnbit port map(ck=>ck, rst=>rst, ce=>uins.CY2, D=>cte_im, Q=>IMED);
 
 
  --==============================================================================
   -- EX stage
   --==============================================================================
   DIEX: entity work.diex port map (
      ck => ck,
      rst => rst,
      R1 => R1,
      R2 => R2,
      cte_im => cte_im,
      RA => RA,
      RB => RtEX,
      IMED => IMED,
      npcDI => npcDI,
      npcEX => npcEX,
      irDI => IRdi,
      irEX => IRex,
      uinsDI => uinsDI,
      uinsEX => uinsEX
   );

      -- register bank write address selection
      adDex <= "11111"               when uinsEX.i=JAL else -- JAL writes in register $31
      IRex(15 downto 11)       when inst_grupo1EX='1' or uinsEX.i=SLTU or uinsEX.i=SLT or uinsEX.i=JALR or
      uinsEX.i=SSLL or uinsEX.i=SLLV or uinsEX.i=SSRA or uinsEX.i=SRAV or
      uinsEX.i=SSRL or uinsEX.i=SRLV
                             else
      IRex(20 downto 16) -- inst_grupoI='1' or uins.i=SLTIU or uins.i=SLTI 
     ;                 -- or uins.i=LW or  uins.i=LBU  or uins.i=LUI, or default

                      
   -- select the first ALU operand                           
   op1 <= npcEX  when inst_branchEX='1' else RA; 
     
   -- select the second ALU operand
   op2 <= RtEX when inst_grupo1EX='1' or uinsEX.i=SLTU or uinsEX.i=SLT or uinsEX.i=JR 
                  or uinsEX.i=SLLV or uinsEX.i=SRAV or uinsEX.i=SRLV
                  else  IMED; 
                 
   -- ALU instantiation
   inst_alu: entity work.alu port map (op1=>op1, op2=>op2, outalu=>outalu, op_alu=>uinsEX.i);
                                   
   -- ALU register
   --REG_alu: entity work.regnbit  port map(ck=>ck, rst=>rst, ce=>uins.walu, D=>outalu, Q=>RALU);               
 
   -- evaluation of conditions to take the branch instructions
   salta <=  '1' when ( (RA=RtEX  and uinsEX.i=BEQ)  or (RA>=0  and uinsEX.i=BGEZ) or
                        (RA<=0  and uinsEX.i=BLEZ) or (RA/=RtEX and uinsEX.i=BNE) )  else
             '0';
                  
             
   --==============================================================================
   -- MEM stage
   --==============================================================================
   EXMEM: entity work.exmem port map (
      ck => ck,
      rst => rst,
      outalu => outalu,
      RALU => RALUmem,      
      npcEX => npcEX,
      npcMEM => npcMEM,
      RtIN => RtEX,
      RtOUT => RtMEM,
      adDex => adDex,
      adDmem => adDmem,
      uinsEX => uinsEX,
      uinsMEM => uinsMEM
   );

   uinsMEMout <= uinsMEM;
     
   d_address <= RALUmem;
    
   -- tristate to control memory write    
   data <= RtMEM when ( uinsMEM.rw='0' and uinsMEM.ce='1' ) else (others=>'Z');  

   -- single byte reading from memory  -- SUPONDO LITTLE ENDIAN
   mdr_int <= data when uinsMEM.i=LW  else
              x"000000" & data(7 downto 0);
       

   --==============================================================================
   -- ER stage
   --==============================================================================
   
   MEMER: entity work.memer port map (
      ck => ck,
      rst => rst,
      mdr_int => mdr_int,
      MDR => MDR,
      npcMEM => npcMEM,
      npcER => npcER,
      RALUin => RALUmem,
      RALUout => RALUer,
      adDmem => adDmem,
      adDer => adDer,
      uinsMEM => uinsMEM,
      uinsER => uinsER
   );

      --RMDR: entity work.regnbit  port map(ck=>ck, rst=>rst, ce=>uins.wmdr, D=>mdr_int, Q=>MDR);                 
  
      result <=    MDR when uinsER.i=LW  or uinsER.i=LBU else
      RALUer;

   -- signal to be written into the register bank
   RIN <= npcER when (uinsER.i=JALR or uinsER.i=JAL) else result;    
   
   -- Code memory starting address: beware of the OFFSET! 
   -- The one below (x"00400000") serves for code generated 
   -- by the MARS simulator
   rpc: entity work.regnbit generic map(INIT_VALUE=>x"00400000")   
                            port map(ck=>ck, rst=>rst, ce=>uinsER.wpc, D=>dtpc, Q=>pc);


end datapath;