library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MRstd.all;

entity exmem is
           port(  ck : in std_logic;
                outalu: in std_logic_vector(31 downto 0);
                RALU: out std_logic_vector(31 downto 0);

                controlSignalsIN: in sinalDeControle;
                controlSignalsOUT: out sinalDeControle
               );
end exmem;

architecture exmem of exmem is 
begin

  process(ck)
  begin
        if ck'event and ck = '1' then
          --if ce = '1' then
            RALU <= outalu;
            controlSignalsOUT <= controlSignalsIN;
          --end if;
        end if;
  end process;
        
end exmem;