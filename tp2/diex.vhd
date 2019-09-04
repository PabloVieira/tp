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
                  IMED: out std_logic_vector(31 downto 0)
               );
end diex;

architecture diex of diex is 
begin

  process(ck)
  begin
        if ck'event and ck = '0' then
            --if ce = '1' then
                RA <= R1;
                RB <= R2;
                IMED <= cte_im;
            --end if;
        end if;
  end process;
        
end diex;