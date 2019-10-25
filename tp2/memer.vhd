library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MRstd.all;

entity memer is
           port(  ck, rst : in std_logic;
                mdr_int: in std_logic_vector(31 downto 0);
                MDR: out std_logic_vector(31 downto 0);
                RALUin: in std_logic_vector(31 downto 0);
                RALUout: out std_logic_vector(31 downto 0);
                  uinsMEM: in microinstruction;
                  uinsER: out microinstruction
               );
end memer;

architecture memer of memer is 
begin

  process(ck, rst)
  begin
    if rst = '1' then
      MDR <= x"00000000";
      uinsER.i <= NOP;
      RALUout <= x"00000000";
    elsif ck'event and ck = '1' then
      --if ce = '1' then
        MDR <= mdr_int;
        RALUout <= RALUin;
        uinsER <= uinsMEM;
      --end if;
    end if;
  end process;
        
end memer;