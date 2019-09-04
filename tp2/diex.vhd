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
                  --controle
                  RegDestIN: in std_logic;
                  ULAFonteIN: in std_logic;
                  ULAOp0IN: in std_logic;
                  ULAOp1IN: in std_logic;
                  DvCIN: in std_logic;
                  LerMemIN: in std_logic;
                  EscMemIN: in std_logic;
                  MemParaRegIN: in std_logic;
                  EscRegIN: in std_logic;

                  RegDestOUT: out std_logic;
                  ULAFonteOUT: out std_logic;
                  ULAOp0OUT: out std_logic;
                  ULAOp1OUT: out std_logic;
                  DvCOUT: out std_logic;
                  LerMemOUT: out std_logic;
                  EscMemOUT: out std_logic;
                  MemParaRegOUT: out std_logic;
                  EscRegOUT: out std_logic
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
                --controle
                RegDestOUT <= RegDestIN;
                ULAFonteOUT <= ULAFonteIN;
                ULAOp0OUT <= ULAOp0IN;
                ULAOp1OUT <= ULAOp1IN;
                DvCOUT <= DvCIN;
                LerMemOUT <= LerMemIN;
                EscMemOUT <= EscMemIN;
                MemParaRegOUT <= MemParaRegIN;
                EscRegOUT <= EscRegIN;
            --end if;
        end if;
  end process;
        
end diex;