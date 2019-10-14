--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- package with basic types
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.Std_Logic_1164.all;

package p_MRstd is  
    
    -- inst_type defines the instructions decodeable by the control unit
    type inst_type is  
            ( ADDU, NOP, SUBU, AAND, OOR, XXOR, NNOR, SSLL, SLLV, SSRA, SRAV, SSRL, SRLV,
            ADDIU, ANDI, ORI, XORI, LUI, LBU, LW, SB, SW, SLT, SLTU, SLTI,
            SLTIU, BEQ, BGEZ, BLEZ, BNE, J, JAL, JALR, JR, invalid_instruction);
 
    type microinstruction is record
            CY1:   std_logic;       -- command of the first stage
            CY2:   std_logic;       --    "    of the second stage
            walu:  std_logic;       --    "    of the third stage
            wmdr:  std_logic;       --    "    of the fourth stage
            wpc:   std_logic;       -- PC write enable
            wreg:  std_logic;       -- register bank write enable
            ce:    std_logic;       -- Chip enable and R_W controls
            rw:    std_logic;
            bw:    std_logic;       -- Byte-word control (mem write only)
            i:     inst_type;       -- operation specification
    end record;
         
end p_MRstd;

library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MRstd.all;

entity erbi is
              port( ck, rst : in std_logic;
                    dtpc: in std_logic_vector(31 downto 0);
                    pc: out std_logic_vector(31 downto 0)
               );
end erbi;

architecture erbi of erbi is 
signal dtpcInit: std_logic;
begin

  process(ck, rst)
  begin
       if rst = '1' then
          pc <= x"00400000";
       elsif ck'event and ck = '0' then
          --if ce = '1' then
           pc <= dtpc;
          --end if;
       end if;
  end process;
        
end erbi;

library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MRstd.all;

entity bidi is port(  ck, rst  : in std_logic;
                incpc: in std_logic_vector(31 downto 0);
                instruction: in std_logic_vector(31 downto 0);
                npc: out std_logic_vector(31 downto 0);
                IR: out std_logic_vector(31 downto 0)
               );
end bidi;

architecture bidi of bidi is 
begin

  process(ck, rst)
  begin
    if rst = '1' then
      npc <= x"00400000";
    elsif ck'event and ck = '0' then
          --if ce = '1' then
            npc <= incpc;
            IR <= instruction;
          --end if;
        end if;
  end process;
        
end bidi;

library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MRstd.all;

entity diex is
           port(  ck : in std_logic;
                  R1: in std_logic_vector(31 downto 0);
                  R2: in std_logic_vector(31 downto 0);
                  cte_im: in std_logic_vector(31 downto 0);
                  RA: out std_logic_vector(31 downto 0);
                  RB: out std_logic_vector(31 downto 0);
                  IMED: out std_logic_vector(31 downto 0);
                  npcIN: in std_logic_vector(31 downto 0);
                  npcOUT: out std_logic_vector(31 downto 0);
                  --controlSignalsIN: in sinalDeControle;
                  --controlSignalsOUT: out sinalDeControle
                  controlSignalsIN: in microinstruction;
                  controlSignalsOUT: out microinstruction
               );
end diex;

architecture diex of diex is 
begin

  process(ck)
  begin
    if ck'event and ck = '0' then
          RA <= R1;
          RB <= R2;
          npcOUT <= npcIN;
          IMED <= cte_im;
          controlSignalsOUT <= controlSignalsIN;
        end if;
  end process;
        
end diex;

library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MRstd.all;

entity exmem is
           port(  ck : in std_logic;
                outalu: in std_logic_vector(31 downto 0);
                RALU: out std_logic_vector(31 downto 0);
                  controlSignalsIN: in microinstruction;
                  controlSignalsOUT: out microinstruction
               );
end exmem;

architecture exmem of exmem is 
begin

  process(ck)
  begin
        if ck'event and ck = '0' then
          --if ce = '1' then
            RALU <= outalu;
            controlSignalsOUT <= controlSignalsIN;
          --end if;
        end if;
  end process;
        
end exmem;

library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MRstd.all;

entity memer is
           port(  ck : in std_logic;
                mdr_int: in std_logic_vector(31 downto 0);
                MDR: out std_logic_vector(31 downto 0);
                  --controlSignalsIN: in sinalDeControle;
                  --controlSignalsOUT: out sinalDeControle
                  controlSignalsIN: in microinstruction;
                  controlSignalsOUT: out microinstruction
               );
end memer;
architecture memer of memer is 
begin

  process(ck)
  begin
        if ck'event and ck = '0' then
          --if ce = '1' then
            MDR <= mdr_int;
            controlSignalsOUT <= controlSignalsIN;
          --end if;
        end if;
  end process;
        
end memer;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Generic register  
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;

entity regnbit is
           generic( INIT_VALUE : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0') );
           port(  ck, rst, ce : in std_logic;
                  D : in  STD_LOGIC_VECTOR (31 downto 0);
                  Q : out STD_LOGIC_VECTOR (31 downto 0)
               );
end regnbit;

architecture regn of regnbit is 
begin

  process(ck, rst)
  begin
       if rst = '1' then
              Q <= INIT_VALUE(31 downto 0);
       elsif ck'event and ck = '0' then
           if ce = '1' then
              Q <= D; 
           end if;
       end if;
  end process;
        
end regn;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Register Bank (R0..R31) - 31 GENERAL PURPOSE 16-bit REGISTERS
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.Std_Logic_1164.all;
use ieee.STD_LOGIC_UNSIGNED.all;   
use work.p_MRstd.all;

entity reg_bank is
       port( ck, rst, wreg :    in std_logic;
             AdRs, AdRt, adRd : in std_logic_vector( 4 downto 0);
             RD : in std_logic_vector(31 downto 0);
             R1, R2: out std_logic_vector(31 downto 0) 
           );
end reg_bank;

architecture reg_bank of reg_bank is
   type bank is array(0 to 31) of std_logic_vector(31 downto 0);
   signal reg : bank ;                            
   signal wen : std_logic_vector(31 downto 0) ;
begin            

    g1: for i in 0 to 31 generate        

        -- Remember register $0 is the constant 0, not a register.
        -- This is implemented by never enabling writes to register $0
        wen(i) <= '1' when i/=0 and adRD=i and wreg='1' else '0';
         
        -- Remember register $29, the stack pointer, points to some place
        -- near the bottom of the data memory, not the usual place 
		-- assigned by the MIPS simulator!!
        g2: if i=29 generate -- SP ---  x10010000 + x800 -- top of stack
           r29: entity work.regnbit generic map(INIT_VALUE=>x"10010800")    
                                  port map(ck=>ck, rst=>rst, ce=>wen(i), D=>RD, Q=>reg(i));
        end generate;  
                
        g3: if i/=29 generate 
           rx: entity work.regnbit port map(ck=>ck, rst=>rst, ce=>wen(i), D=>RD, Q=>reg(i));                    
        end generate;
                   
   end generate g1;   
    

    R1 <= reg(CONV_INTEGER(AdRs));    -- source1 selection 

    R2 <= reg(CONV_INTEGER(AdRt));    -- source2 selection 
   
end reg_bank;

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- ALU - operation depends only on the current instruction 
--       (decoded in the control unit)
--
-- 22/11/2004 - subtle error correctionwas done for J!
-- Part of the work for J has been done before, by shifting IR(15 downto 0)
-- left by two bits before writing data to the IMED register 
--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.p_MRstd.all;

entity alu is
       port( op1, op2 : in std_logic_vector(31 downto 0);
             outalu :   out std_logic_vector(31 downto 0);   
             op_alu : in inst_type   
           );
end alu;

architecture alu of alu is 
   signal menorU, menorS : std_logic ;
begin
  
    menorU <=  '1' when op1 < op2 else '0';
    menorS <=  '1' when ieee.Std_Logic_signed."<"(op1,  op2) else '0' ; -- signed
    
    outalu <=  
        op1 - op2                                when  op_alu=SUBU                     else
        op1 and op2                              when  op_alu=AAND  or op_alu=ANDI     else 
        op1 or  op2                              when  op_alu=OOR   or op_alu=ORI      else 
        op1 xor op2                              when  op_alu=XXOR  or op_alu=XORI     else 
        op1 nor op2                              when  op_alu=NNOR                     else 
        op2(15 downto 0) & x"0000"               when  op_alu=LUI                      else
        (0=>menorU, others=>'0')                 when  op_alu=SLTU  or op_alu=SLTIU    else   -- signed
        (0=>menorS, others=>'0')                 when  op_alu=SLT   or op_alu=SLTI     else   -- unsigned
        op1(31 downto 28) & op2(27 downto 0)     when  op_alu=J     or op_alu=JAL      else 
        op1                                      when  op_alu=JR    or op_alu=JALR     else 
        to_StdLogicVector(to_bitvector(op1) sll  CONV_INTEGER(op2(10 downto 6)))   when  op_alu=SSLL   else 
        to_StdLogicVector(to_bitvector(op2) sll  CONV_INTEGER(op1(5 downto 0)))    when  op_alu=SLLV   else 
        to_StdLogicVector(to_bitvector(op1) sra  CONV_INTEGER(op2(10 downto 6)))   when  op_alu=SSRA   else 
        to_StdLogicVector(to_bitvector(op2) sra  CONV_INTEGER(op1(5 downto 0)))    when  op_alu=SRAV   else 
        to_StdLogicVector(to_bitvector(op1) srl  CONV_INTEGER(op2(10 downto 6)))   when  op_alu=SSRL   else 
        to_StdLogicVector(to_bitvector(op2) srl  CONV_INTEGER(op1(5 downto 0)))    when  op_alu=SRLV   else 
        op1 + op2;    -- default for ADDU, NOP,ADDIU,LBU,LW,SW,SB,BEQ,BGEZ,BLEZ,BNE    

end alu;

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
   ERBI: entity work.erbi port map (
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
    rst=>rst,
    incpc => incpc,
    instruction => instruction,
    npc => npc2,
    IR => IR
 );
                
   -- The then clause is only used for logic shifts with shamt field       
   adS <= IR(20 downto 16) when uins5.i=SSLL or uins5.i=SSRA or uins5.i=SSRL else 
          IR(25 downto 21);
          
   REGS: entity work.reg_bank(reg_bank) port map
        (ck=>ck, rst=>rst, wreg=>uins5.wreg, AdRs=>adS, AdRt=>IR(20 downto 16), adRD=>adD,  
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
   op1 <= npc3  when inst_branch3='1' else RA; 
     
   -- select the second ALU operand
   op2 <= RB when inst_grupo1e3='1' or uins3.i=SLTU or uins3.i=SLT or uins3.i=JR 
                  or uins3.i=SLLV or uins3.i=SRAV or uins3.i=SRLV
                  else  IMED; 
                 
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
         IR(15 downto 11)       when inst_grupo1e2='1' or uins2.i=SLTU or uins2.i=SLT or uins2.i=JALR or
                                     uins2.i=SSLL or uins2.i=SLLV or uins2.i=SSRA or uins2.i=SRAV or
						                   uins2.i=SSRL or uins2.i=SRLV
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

--------------------------------------------------------------------------
--  Control Unit behavioral description 
--------------------------------------------------------------------------
--------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use work.p_MRstd.all;

entity control_unit is
        port(   ck, rst : in std_logic;          
                uins : out microinstruction;
                ir : in std_logic_vector(31 downto 0)
             );
end control_unit;
                   
architecture control_unit of control_unit is
   type type_state is (Sidle, Sfetch, Sreg, Salu, Swbk, Sld, Sst, Ssalta);
   signal PS, NS : type_state;
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
                   
    uins.i <= i;    -- this instructs the alu to execute its expected operation, if any
  
    uins.wreg <= '0' when  i=SW or
                           i=SB or
                           i=SLT or
                           i=SLTU or
                           i=SLTI or
                           i=SLTIU or
                           i=BEQ or
                           i=BGEZ or
                           i=BLEZ or
                           i=BNE or
                           i=J or
                           i=JAL or
                           i=JALR or
                           i=JR       else '1'; 
   
    uins.rw	<= '1' when i=LUI or
                        i=LBU or
                        i=LW    else '0';
                  
    uins.ce <= '1' when i=LUI or
                        i=LBU or
                        i=LW or
                        i=SB or
                        i=SW     else '0';
    
    uins.bw    <= '0' when i=SB   else '1';
    
end control_unit;

--------------------------------------------------------------------------
-- Top-level instantiation of the MRstd Datapath and Control Unit
--------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use work.p_MRstd.all;

entity MRstd is
    port( clock, reset: in std_logic;
          ce, rw, bw: out std_logic;
          i_address, d_address: out std_logic_vector(31 downto 0);
          instruction: in std_logic_vector(31 downto 0);
          data: inout std_logic_vector(31 downto 0));
end MRstd;

architecture MRstd of MRstd is
      signal IR: std_logic_vector(31 downto 0);
      signal uinsMEM: microinstruction;
 begin

     dp: entity work.datapath   
         port map( ck=>clock, rst=>reset, uinsMEMout=>uinsMEM, i_address=>i_address, 
                   instruction=>instruction, d_address=>d_address,  data=>data);
         
     ce <= uinsMEM.ce;
     rw <= uinsMEM.rw; 
     bw <= uinsMEM.bw;
     
end MRstd;