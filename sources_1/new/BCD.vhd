library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BCD is
    Port ( clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           digit_in : in STD_LOGIC_VECTOR(15 downto 0);
           digit_out : out STD_LOGIC_VECTOR(15 downto 0)
           );
end BCD;

architecture Behavioral of BCD is

begin
    process(reset, clock)
    variable temp : std_logic_vector(11 downto 0);
    variable bcd_var : unsigned(15 downto 0);
    variable frac_one : unsigned(3 downto 0);  -- max is .99999999
    variable frac_two : unsigned(3 downto 0);
    variable temp2 : unsigned(11 downto 0);
    begin 
        if (reset = '1') then
           digit_out <= (others => '0');
        elsif (clock'event and clock = '1') then
          -- zero the bcd variable
          bcd_var := (others => '0');
          temp2 := (others => '0');
          
          -- read input into temp variable
          temp(11 downto 0) := "00000" & digit_in(14 downto 8);
          
          -- cycle 12 times as we have 12 input bits
          -- this could be optimized, we dont need to check and add 3 for the 
          -- first 3 iterations as the number can never be >4
          for i in 0 to 11 loop
          
            if bcd_var(3 downto 0) > 4 then 
              bcd_var(3 downto 0) := bcd_var(3 downto 0) + 3;
            end if;
            
            if bcd_var(7 downto 4) > 4 then 
              bcd_var(7 downto 4) := bcd_var(7 downto 4) + 3;
            end if;
          
            if bcd_var(11 downto 8) > 4 then  
              bcd_var(11 downto 8) := bcd_var(11 downto 8) + 3;
            end if;
          
            -- thousands can't be >4 for a 12-bit input number
            -- so don't need to do anything to upper 4 bits of bcd
          
            -- shift bcd left by 1 bit, copy MSB of temp into LSB of bcd
            bcd_var := bcd_var(14 downto 0) & temp(11);
          
            -- shift temp left by 1 bit
            temp := temp(10 downto 0) & '0';
          
          end loop;
       
          -- set outputs
          digit_out(11 downto 8) <= STD_LOGIC_VECTOR(bcd_var(3 downto 0)); -- ones
          if (digit_in(15) = '1') then
            digit_out(15 downto 12) <= "1101"; -- 'D' -> '-'
          else 
            digit_out(15 downto 12) <= STD_LOGIC_VECTOR(bcd_var(7 downto 4)); -- tens
          end if;
          --hundreds <= STD_LOGIC_VECTOR(bcd(11 downto 8));
          --thousands <= STD_LOGIC_VECTOR(bcd(15 downto 12));
          
          -- FRACTIONAL PART
          -- Multiply by 10
          -- [ 12 ] <= [ 4 ] * [ 8 ]
          temp2 := "1010" * unsigned(digit_in(7 downto 0));
          frac_one := temp2(11 downto 8);
          temp2 := "1010" * unsigned(temp2(7 downto 0));
          frac_two := temp2(11 downto 8);
          
          digit_out(7 downto 4) <= STD_LOGIC_VECTOR(frac_one);-- Frac high
          digit_out(3 downto 0)<= STD_LOGIC_VECTOR(frac_two); -- Frac low
       end if;
    end process;

end Behavioral;
