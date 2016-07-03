
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sqrt is
    Port (
        en : in std_logic;
        clk : in std_logic;
        reset : in std_logic;
        A : in std_logic_vector(15 downto 0);
        C : out std_logic_vector(15 downto 0)
        );
end sqrt;

architecture Behavioral of sqrt is


-- Functionality
--  Ignore negative signs
--  Take one value off stack not two
begin
    -- Square root
    -- _/A [ 8.8 ] =  C [ 8.8 ]
    
    process (clk, reset)
    variable ahigh : unsigned(7 downto 0);
    variable nextbit : unsigned(7 downto 0);
    variable root : unsigned(15 downto 0);
    variable p : unsigned(15 downto 0);
    variable temp : unsigned(31 downto 0);
    begin
        if reset = '1' then
            C <= (others => '0');
        elsif clk'event and clk = '1' then
            if en = '1' then
                ahigh := unsigned(A(15 downto 8));
                
                -- range sort to get integer part and to
                -- check for weird bits near the top of the range
                if (ahigh >= 64) then    --bigger than 64?
                
                    if (A > 32399) then --0x7e8f)    -- >=126.562 = 11.25^2
                        root := "0000101101000000"; --2880; -- 11
                        nextbit := "00010000";--16;
                        
                    elsif (ahigh >= 121) then
                        root := "0000101100000000";--2816;
                        nextbit := "01000000";--64;
                    
                    elsif (ahigh >= 100) then
                        root := "0000101000000000";--2560;
                        nextbit := "10000000";--128;
                        
                    elsif (ahigh >= 81) then
                        root := "0000100100000000";-- 2304;
                        nextbit := "10000000"; --128;
                    
                    else -- 16
                        root := "0000100000000000"; --2048;
                        nextbit := "10000000"; --128;
                    end if;
                
                elsif (ahigh >= 16) then-- smaller than 64 and bigger then 16
                    
                    if (ahigh >= 49) then
                        root := "0000011100000000"; --1792;
                        nextbit := "10000000"; --128;
                    
                    elsif (ahigh >= 36) then
                        root := "0000011000000000"; --1536;
                        nextbit := "10000000"; --128;
                        
                    elsif (ahigh >= 25) then
                        root := "0000010100000000"; --1280;
                        nextbit := "10000000"; --128;
                        
                    else
                        root := "0000010000000000"; --1024;
                        nextbit := "10000000"; --128;
                    end if;
                    
                else -- smaller than 16
                    if (ahigh >= 9) then
                        root := "0000001100000000"; --768;
                        nextbit := "10000000"; --128;
                    
                    elsif (ahigh >= 4) then
                        root := "0000001000000000"; --512;
                        nextbit := "10000000"; --128;
                        
                    elsif (ahigh >= 1) then
                        root := "0000000100000000"; --256;
                        nextbit := "10000000"; --128;
                        
                    else -- less than 1
                        root := "0000000000000000"; --0;
                        nextbit := "10000000"; --128;
                    end if;
                end if;
                
                for I in 1 to 8 loop -- 8
                    root := nextbit + root;
                    temp := root * root;
                    p := temp(23 downto 8);
                    if (p >= unsigned(A)) then
                        root := root - nextbit;
                    end if;
                    nextbit := '0' & nextbit(7 downto 1);
                end loop;
                
                C <= std_logic_vector(root);
            end if;
        end if;
    end process;

end Behavioral;
