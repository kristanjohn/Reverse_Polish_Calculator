

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
--USE IEEE.NUMERIC_STD.ALL;

entity div is
    Port (
        clk : in std_logic;
        en : in std_logic;
        reset : in std_logic;
        A : in std_logic_vector(15 downto 0);
        B : in std_logic_vector(15 downto 0);
        C : out std_logic_vector(15 downto 0);
        overflow : out std_logic
        );
end div;

architecture Behavioral of div is

begin

    process(clk, reset)
    variable temp_a : ufixed(7 downto -8);
    variable temp_b : ufixed(7 downto -8);
    variable temp_c : ufixed(15 downto -16);  
    variable neg : std_logic;
    begin
        if reset = '1' then
            C <= (others =>'0');
            overflow <= '0';
        elsif clk'event and clk='1' then
            if en='1' then
                temp_a := to_ufixed(A, 7, -8);
                temp_b := to_ufixed(B, 7, -8);
               
                neg := '0';
--                    -- Check if negative
                if (A(15) = '1') then
                    neg := '1';
                    temp_a(7) := '0';
                end if;
                if (B(15) = '1') then
                    neg := (neg xor '1');
                    temp_b(7) := '0';
                end if;
                
                temp_c := temp_b / temp_a;
                
                if ( temp_c(15 downto 0) > 99 ) then
                    overflow <= '1';
                else 
                    overflow <= '0';
                end if;
                -- Fix for negative
                if (neg = '1') then
                    if (temp_c(15 downto 0) > 9) then -- past -9.99
                        overflow <= '1';
                    end if;
                    temp_c(7) := '1';
                end if;
                
                 C <= std_logic_vector(temp_c(7 downto -8)); -- Middle 16 bits
            end if;        
        end if;
    end process;
    -- Division
    -- A [ (8<<8).8 ] divide B [ 8.8 ] = C [ 8.16 ]
    -- truncate C to [ 8.8 (+8) ]
    -- No overflow
--    process (clk , reset)
--        variable x : unsigned(15 downto 0);
--        variable d : unsigned(15 downto 0);
--        variable n : unsigned(15 downto 0);
--        variable temp : unsigned(15 downto 0);
--        variable temp2 : unsigned(31 downto 0);
--        variable count : signed(7 downto 0);
--        variable neg : std_logic;
--        begin 
--            if (reset = '1') then
--                C <= (others => '0');
                
--            elsif (clk'event and clk='1') then
--                if (en = '1') then
--                    d := unsigned(A);
--                    n := unsigned(B);
--                    count := "00000000";
--                    neg := '0';
--                    -- Check if negative
--                    if (A(15) = '1') then
--                        neg := '1';
--                        d(15) := '0';
--                    end if;
--                    if (B(15) = '1') then
--                        neg := (neg xor '1');
--                        n(15) := '0';
--                    end if;
                    
--                    -- Perform Division
--                    --temp_c := signed(temp_a) / signed(temp_b);
--                    -- A is dividend , B is divisor
--                    --    _____
--                    -- B / A
                    
--                    -- Range reduction
--                    for I in 1 to 16 loop
--                        if (d > 256) then-- 0x0100
--                            count := count - 1;
--                            d := '0' & d(15 downto 1);
--                        end if;
--                    end loop;
                    
--                    for I in 1 to 16 loop
--                        if (d < 128) then
--                            count := count + 1;
--                            d := d(14 downto 0) & '0';
--                        end if;
--                    end loop;
                    
--                    -- Newton interation
--                    x := "0000001011101010"; --746
--                    x := x - unsigned( d(14 downto 0) & '0'); -- e.g. 512
                    
--                    temp2 := d * x; -- d * x -- e.g 2.0
--                    temp := "0000001000000000" - temp2(23 downto 8);-- 0x0200 - temp2 -- e.g. 
--                    temp2 := x * temp; -- x * temp
--                    x := temp2(23 downto 8); -- e.g. 3.0
                    
--                    temp2 := d * x; -- d * x
--                    temp := "0000001000000000" - temp2(23 downto 8); -- 0x200 - temp2
--                    temp2 := x * temp; -- x * temp
--                    x := temp2(23 downto 8);
                    
--                    -- Range expansion
--                    if (count > 0) then
--                        for I in 0 to 16 loop
--                            if I < count then
--                                x := x(14 downto 0) & '0';
--                            end if;
--                        end loop;
--                    else
--                        count := '0' & count(6 downto 0); -- Make positive
--                        for I in 0 to 16 loop
--                            if I < count then
--                                x := '0' & x(15 downto 1);
--                            end if;
--                        end loop;
--                    end if;
                    
--                    -- Form ratio
--                    temp2 := x * n;
--                    x := temp2(23 downto 8);
                    
--                    if (neg = '1') then
--                        x(15) := '1';
--                    end if;
                    
--                    C <= std_logic_vector(x); -- Top 16 bits
--                end if;
--            end if;
--        end process;
end Behavioral;
