library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MRstd.all;

entity memer is
           port(  ck : in std_logic;
                mdr_int: in std_logic_vector(31 downto 0);
                MDR: out std_logic_vector(31 downto 0);

                controlSignalsIN: in sinalDeControle;
                controlSignalsOUT: out sinalDeControle
               );
end memer;

architecture memer of memer is 
begin

  process(ck)
  begin
        if ck'event and ck = '1' then
          --if ce = '1' then
            MDR <= mdr_int;
            controlSignalsOUT <= controlSignalsIN;
          --end if;
        end if;
  end process;
        
end memer;