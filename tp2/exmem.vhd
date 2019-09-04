library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MRstd.all;

entity exmem is
           port(  ck : in std_logic;
                outalu: in std_logic_vector(31 downto 0);
                RALU: out std_logic_vector(31 downto 0)
               );
end exmem;

architecture exmem of exmem is 
begin

  process(ck)
  begin
        if ck'event and ck = '0' then
          --if ce = '1' then
            RALU <= outalu;
          --end if;
        end if;
  end process;
        
end exmem;