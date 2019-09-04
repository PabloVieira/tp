library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MRstd.all;

entity bidi is
           port(  ck : in std_logic;
                incpc: in std_logic_vector(31 downto 0);
                instruction: in std_logic_vector(31 downto 0);
                npc: out std_logic_vector(31 downto 0);
                IR: out std_logic_vector(31 downto 0)
               );
end bidi;

architecture bidi of bidi is 
begin

  process(ck)
  begin
        if ck'event and ck = '0' then
          --if ce = '1' then
            npc <= incpc;
            IR <= instruction;
          --end if;
        end if;
  end process;
        
end bidi;