-- File: HDL_Coding_Techniques/rams/rams_02a.vhd
-- Single-Port Block RAM Write-First Mode (recommended template)
--
--
library ieee;
 use ieee.std_logic_1164.all;
 use ieee.std_logic_unsigned.all;
 
 entity ram_mod is
     
     port (clk : in std_logic;
         write_e : in std_logic;
         en : in std_logic;
         addr : in std_logic_vector(7 downto 0); --(9 downto 0);
         din : in std_logic_vector(15 downto 0);
         dout : out std_logic_vector(15 downto 0));
 
 end ram_mod;
     
 architecture syn of ram_mod is
     type ram_type is array (19 downto 0) of std_logic_vector(15 downto 0);--(1023 downto 0) of std_logic_vector (15 downto 0);
     signal RAM : ram_type := (others =>  (others => '0'));
     
     begin
     process (clk)
        begin
            if clk'event and clk = '1' then
                if en = '1' then
                    if write_e = '1' then
                        RAM(conv_integer(addr)) <= din;
                        dout <= din;
                    else
                        dout <= RAM( conv_integer(addr));
                    end if;
                end if;
            end if;
        end process;
 end syn;
