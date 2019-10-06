library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MRstd.all;

entity erbi is
              generic( INIT_VALUE : STD_LOGIC_VECTOR(31 downto 0) := (others=>'0') );
              port( ck, rst : in std_logic;
                    dtpc: in std_logic_vector(31 downto 0);
                    pc: out std_logic_vector(31 downto 0)
               );
end erbi;

architecture erbi of erbi is 
begin

  process(ck, rst)
  begin
       if rst = '1' then
        pc <= INIT_VALUE(31 downto 0);
        elsif ck'event and ck = '0' then
          --if ce = '1' then
            pc <= dtpc;
          --end if;
        end if;
  end process;
        
end erbi;