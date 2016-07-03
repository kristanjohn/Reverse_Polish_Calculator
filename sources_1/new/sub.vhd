

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sub is
    Port (
        en : in std_logic;
        clk : in std_logic;
        reset : in std_logic;
        A : in std_logic_vector(15 downto 0);
        B : in std_logic_vector(15 downto 0);
        C : out std_logic_vector(15 downto 0);
        overflow : out std_logic
    );
end sub;

architecture Behavioral of sub is
begin    
    process(clk,reset)
    variable temp_c : unsigned(15 downto 0);
    variable temp_a : unsigned(15 downto 0);
    variable temp_b : unsigned(15 downto 0);
    variable neg : std_logic;
    begin
        if reset='1' then
            overflow <= '0';
            C <= (others => '0');
        elsif clk'event and clk = '1' then
            if en = '1' then
                temp_b(15 downto 0) := unsigned(A);
                temp_a(15 downto 0) := unsigned(B);
                neg := '0';
                ----       C = A - B
                if (temp_a(15) = '0' and temp_b(15) = '0') then -- A pos, B pos
                    -- A - B
                    if (temp_b > temp_a) then -- result is neg
                        temp_c := temp_b - temp_a;
                        neg := '1';
                    else 
                        temp_c := temp_a - temp_b;
                    end if;
                elsif (temp_a(15) = '1' and temp_b(15) = '0') then -- A neg, B pos
                    --      -A - B
                    temp_a(15) := '0';
                    neg := '1';
                    temp_c := temp_a + temp_b;
                elsif (temp_a(15) = '0' and temp_b(15) = '1') then -- A pos, B neg
                    --      A - -B
                    temp_b(15) := '0';
                    temp_c := temp_a + temp_b;
                else -- A neg, B neg
                    --     -A - -B
                    temp_a(15) := '0';
                    temp_b(15) := '0';
                    if (temp_a > temp_b) then -- neg result
                        neg := '1';
                        temp_c := temp_a - temp_b;
                    else 
                        temp_c := temp_b - temp_a;
                    end if;
                end if;
                
                -- Detect overflow
                if (temp_c(15 downto 8) > 99) then 
                    overflow <= '1';
                else 
                    overflow <= '0';
                end if;
                
                 -- Return negative sign
                if (neg = '1') then
                    if (temp_c(15 downto 8) > 9) then
                        overflow <= '1';
                    end if;
                    temp_c(15) := '1';
                end if;
                
                C <= std_logic_vector(temp_c(15 downto 0));      
            end if;
        end if;
    end process;

end Behavioral;
