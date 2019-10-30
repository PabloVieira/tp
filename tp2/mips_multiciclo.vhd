--------------------------------------------------------------------------
-- Top-level instantiation of the MRstd Datapath and Control Unit
--------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use work.p_MRstd.all;

entity MRstd is
    port( clock, reset: in std_logic;
          ce, rw, bw: out std_logic;
          i_address, d_address: out std_logic_vector(31 downto 0);
          instruction: in std_logic_vector(31 downto 0);
          data: inout std_logic_vector(31 downto 0));
end MRstd;

architecture MRstd of MRstd is
      signal uinsMEM: microinstruction;
 begin

     dp: entity work.datapath   
         port map( ck=>clock, rst=>reset, uinsMEMout=>uinsMEM, i_address=>i_address, 
                   instruction=>instruction, d_address=>d_address,  data=>data);
         
     ce <= uinsMEM.ce;
     rw <= uinsMEM.rw; 
     bw <= uinsMEM.bw;
     
end MRstd;