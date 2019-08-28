library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MRstd.all;

entity bidi is
           port(  ck, ce : in std_logic;
                  npcIN: in std_logic_vector(31 downto 0);
                  IRIN: in std_logic_vector(31 downto 0);
                  npcOUT: out std_logic_vector(31 downto 0);
                  IROUT: out std_logic_vector(31 downto 0)
               );
end bidi;

architecture bidi of bidi is 
begin

  process(ck)
  begin
        if ck'event and ck = '0' then
            npcOUT <= npcIN;
            IROUT <= IRIN;
        end if;
  end process;
        
end bidi;