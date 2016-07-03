
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity mul is
    Port (
        en : in std_logic;
        clk : in std_logic;
        reset: in std_logic;
        A : in std_logic_vector(15 downto 0);
        B : in std_logic_vector(15 downto 0);
        C : out std_logic_vector(15 downto 0);
        overflow : out std_logic
        );
end mul;

architecture Behavioral of mul is

begin
    -- Multiplication
    -- A [ 8.8] times B [ 8.8 ] = C [ 16.16 ]
    -- truncate C to [ 8 + (8.8) + 8 ]
    -- if upper 16 is >99 then overflow 
    process(clk,reset)
        variable temp_a : unsigned(15 downto 0);
        variable temp_b : unsigned(15 downto 0);
        variable temp_c : unsigned(31 downto 0);
        variable neg : std_logic;
        begin
            if reset='1' then
                overflow <= '0';
                C <= (others => '0');
            elsif clk'event and clk='1' then
                if en='1' then
                    temp_a(15 downto 0)  := unsigned(A);
                    temp_b(15 downto 0)  := unsigned(B);
                    temp_c(31 downto 0)  := (others => '0');
                    neg := '0';
                    -- Check if negative
                    if (temp_a(15) = '1') then
                        neg := '1';
                        temp_a(15) := '0';
                    end if;
                    if (temp_b(15) = '1') then
                        neg := (neg xor '1');
                        temp_b(15) := '0';
                    end if;                
                    
                    temp_c := temp_a * temp_b; -- Perform multiplication
                    if ( temp_c(31 downto 16) > 99 ) then
                        overflow <= '1';
                    else 
                        overflow <= '0';
                    end if;
                    -- Fix for negative
                    if (neg = '1') then
                        if (temp_c(31 downto 16) > 9) then -- past -9.99
                            overflow <= '1';
                        end if;
                        temp_c(23) := '1';
                    end if;
                    
                    C <= std_logic_vector(temp_c(23 downto 8)); -- Middle 16 bits
                end if;
            end if;
    end process;

end Behavioral;
