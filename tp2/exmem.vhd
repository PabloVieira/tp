library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MRstd.all;

entity exmem is
           port(  ck, rst : in std_logic;
                outalu: in std_logic_vector(31 downto 0);
                RALU: out std_logic_vector(31 downto 0);
                  uinsEX: in microinstruction;
                  uinsMEM: out microinstruction
               );
end exmem;

architecture exmem of exmem is 
begin

  process(ck, rst)
  begin
    if rst = '1' then
      RALU <= x"00000000";
      uinsMEM.i <= NOP;
        elsif ck'event and ck = '1' then
          --if ce = '1' then
            RALU <= outalu;
            uinsMEM <= uinsEX;
          --end if;
        end if;
  end process;
        
end exmem;