library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MRstd.all;

entity memer is
           port(  ck : in std_logic;
                mdr_int: in std_logic_vector(31 downto 0);
                MDR: out std_logic_vector(31 downto 0);
                --controle
                MemParaRegIN: in std_logic;
                EscRegIN: in std_logic;

                MemParaRegOUT: out std_logic;
                EscRegOUT: out std_logic
               );
end memer;

architecture memer of memer is 
begin

  process(ck)
  begin
        if ck'event and ck = '0' then
          --if ce = '1' then
            MDR <= mdr_int;
            --controle
            MemParaRegOUT <= MemParaRegIN;
            EscRegOUT <= EscRegIN;
          --end if;
        end if;
  end process;
        
end memer;