library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MRstd.all;

entity erbi is
           port(  ck : in std_logic;
                dtpc: in std_logic_vector(31 downto 0);
                pc: out std_logic_vector(31 downto 0)
               );
end erbi;

architecture erbi of erbi is 
begin

  process(ck)
  begin
        if ck'event and ck = '0' then
          --if ce = '1' then
            pc <= dtpc;
          --end if;
        end if;
  end process;
        
end erbi;