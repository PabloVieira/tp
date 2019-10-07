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
                  IMED: out std_logic_vector(31 downto 0);
                  --npcIN: in std_logic_vector(31 downto 0);
                  --npcOUT: out std_logic_vector(31 downto 0);
                  --controlSignalsIN: in sinalDeControle;
                  --controlSignalsOUT: out sinalDeControle
                  controlSignalsIN: in microinstruction;
                  controlSignalsOUT: out microinstruction
               );
end diex;

architecture diex of diex is 
begin

  process(ck)
  begin
    if ck'event and ck = '0' then
          RA <= R1;
          RB <= R2;
         -- npcOUT <= npcIN;
          IMED <= cte_im;
          controlSignalsOUT <= controlSignalsIN;
        end if;
  end process;
        
end diex;