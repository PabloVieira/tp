library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MRstd.all;

entity bidi is port(  ck, rst  : in std_logic;
                npcBI: in std_logic_vector(31 downto 0);
                instruction: in std_logic_vector(31 downto 0);
                npcDI: out std_logic_vector(31 downto 0);
                IR: out std_logic_vector(31 downto 0)
               );
end bidi;

architecture bidi of bidi is 
begin

  process(ck, rst)
  begin
    if rst='1' then
      npcDI <= x"00400000";
      IR 	<= x"00000000";
    elsif ck'event and ck = '1' then
          --if ce = '1' then
            npcDI <= npcBI;
            IR <= instruction;
          --end if;
    end if;
  end process;
        
end bidi;