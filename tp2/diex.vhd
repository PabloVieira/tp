library IEEE;
use IEEE.std_logic_1164.all;
use work.p_MRstd.all;

entity diex is
           port(  ck, rst : in std_logic;
                  R1: in std_logic_vector(31 downto 0);
                  R2: in std_logic_vector(31 downto 0);
                  cte_im: in std_logic_vector(31 downto 0);
                  RA: out std_logic_vector(31 downto 0);
                  RB: out std_logic_vector(31 downto 0);
                  IMED: out std_logic_vector(31 downto 0);
                  npcDI: in std_logic_vector(31 downto 0);
                  npcEX: out std_logic_vector(31 downto 0);
                  uinsDI: in microinstruction;
                  uinsEX: out microinstruction
               );
end diex;

architecture diex of diex is 
begin

  process(ck)
  begin
    if rst = '1' then
      RA <= x"00000000";
      RB <= x"00000000";
      IMED <= x"00000000";
      npcEX <= x"00000000";
      uinsEX.i <= NOP;
    elsif ck'event and ck = '1' then
          RA <= R1;
          RB <= R2;
          npcEX <= npcDI;
          IMED <= cte_im;
          uinsEX <= uinsDI;
        end if;
  end process;
        
end diex;