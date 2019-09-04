library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MRstd.all;

entity exmem is
           port(  ck : in std_logic;
                outalu: in std_logic_vector(31 downto 0);
                RALU: out std_logic_vector(31 downto 0);

                controlSignalsIN: in sinalDeControle;
                controlSignalsOUT: out sinalDeControle
--                --controle
--                DvCIN: in std_logic;
--                LerMemIN: in std_logic;
--                EscMemIN: in std_logic;
--                MemParaRegIN: in std_logic;
--                EscRegIN: in std_logic;
--
--                DvCOUT: out std_logic;
--                LerMemOUT: out std_logic;
--                EscMemOUT: out std_logic;
--                MemParaRegOUT: out std_logic;
--                EscRegOUT: out std_logic
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
            --controle
--            DvCOUT <= DvCIN;
--            LerMemOUT <= LerMemIN;
--            EscMemOUT <= EscMemIN;
--            MemParaRegOUT <= MemParaRegIN;
--            EscRegOUT <= EscRegIN;
          --end if;
        end if;
  end process;
        
end exmem;