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

    ----------------------------------------------------------------------------------------
    -- BLOCK (2/3) - DATAPATH REGISTERS load control signals generation.
    ----------------------------------------------------------------------------------------
    uins.CY1   <= '1' when PS=Sfetch         else '0';
            
    uins.CY2   <= '1' when PS=Sreg           else '0';
  
    uins.walu  <= '1' when PS=Salu           else '0';
                
    uins.wmdr  <= '1' when PS=Sld            else '0';
  
    uins.wreg   <= '1' when PS=Swbk or (PS=Ssalta and (i=JAL or i=JALR)) else   '0';
   
    uins.rw    <= '0' when PS=Sst            else  '1';
                  
    uins.ce    <= '1' when PS=Sld or PS=Sst  else '0';
    
    uins.bw    <= '0' when PS=Sst and i=SB   else '1';
      
    uins.wpc   <= '1' when PS=Swbk or PS=Sst or PS=Ssalta  else  '0';
  
    ---------------------------------------------------------------------------------------------
    -- BLOCK (3/3) - Sequential part of the control unit - two processes implementing the
    -- Control Unit state register and the next-state (combinational) function
    --------------------------------------------------------------------------------------------- 
    process(rst, ck)
    begin
       if rst='1' then
            PS <= Sidle;          -- Sidle is the state the machine stays while processor is being reset
       elsif ck'event and ck='1' then
       
            if PS=Sidle then
                  PS <= Sfetch;
            else
                  PS <= NS;
            end if;
                
       end if;
    end process;
     
     
    process(PS, i)
    begin
       case PS is         
      
            when Sidle=>NS <= Sidle; -- reset being active, the processor do nothing!       

            -- first stage:  read the current instruction 
            --
            when Sfetch=>NS <= Sreg;  
     
            -- second stage: read the register banck and store the mask (when i=stmsk)
            --
            when Sreg=>NS <= Salu;  
             
            -- third stage: alu operation 
            --
            when Salu =>if i=LBU  or i=LW then 
                                NS <= Sld;  
                          elsif i=SB or i=SW then 
                                NS <= Sst;
                          elsif i=J or i=JAL or i=JALR or i=JR or i=BEQ
                                    or i=BGEZ or i=BLEZ  or i=BNE then 
                                NS <= Ssalta;  
                          else 
                                NS <= Swbk; 
                          end if;
                         
            -- fourth stage: data memory operation  
            --
            when Sld=>  NS <= Swbk; 
            
            -- fifth clock cycle of most instructions  - GO BACK TO FETCH
            -- 
            when Sst | Ssalta | Swbk=>NS <= Sfetch;
  
       end case;

    end process;
    
end control_unit;