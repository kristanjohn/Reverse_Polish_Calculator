--generated by V2 synthesiser
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ssegDriver is port (
    en : in std_logic;
	clk : in std_logic;
	rst : in std_logic;
	cathode_p : out std_logic_vector(7 downto 0);
	digit1_p : in std_logic_vector(3 downto 0);
	anode_p : out std_logic_vector(7 downto 0);
	digit2_p : in std_logic_vector(3 downto 0);
	digit3_p : in std_logic_vector(3 downto 0);
	digit4_p : in std_logic_vector(3 downto 0);
	digit5_p : in std_logic_vector(3 downto 0);
	digit6_p : in std_logic_vector(3 downto 0);
	digit7_p : in std_logic_vector(3 downto 0);
	digit8_p : in std_logic_vector(3 downto 0)
); end ssegDriver;

------------------------------------------------

architecture behavioural of ssegDriver is

	signal digit_reg : std_logic_vector(31 downto 0);
	signal anode_reg : std_logic_vector(7 downto 0);
	signal digitout_reg : std_logic_vector(3 downto 0);
	signal digit_sel : std_logic_vector(2 downto 0);
	signal next_sel : std_logic_vector(2 downto 0);
	
	begin
		
		--Clock and set state machine
		process (clk, rst) 
			begin
				if (rst = '1') then
					digit_reg <= "00000000000000000000000000000000";
					digit_sel <= "000";
					next_sel <= "000";
					digitout_reg <= "0000";
					anode_reg <= "11111111";

				elsif (clk'event and clk = '1') then
					
					--latch digits into register on clock edge
					digit_reg(3 downto 0) <= digit1_p;
					digit_reg(7 downto 4) <= digit2_p;
					digit_reg(11 downto 8) <= digit3_p;
					digit_reg(15 downto 12) <= digit4_p;
					digit_reg(19 downto 16) <= digit5_p;
					digit_reg(23 downto 20) <= digit6_p;
					digit_reg(27 downto 24) <= digit7_p;
					digit_reg(31 downto 28) <= digit8_p;
					
					digit_sel <= next_sel;
			
					case digit_sel is
					
						when "000" =>
							anode_reg <= "11111110";	
							digitout_reg <= digit_reg(3 downto 0);
							next_sel <= "001";
							
						when "001" =>
							anode_reg <= "11111101";	
							digitout_reg <= digit_reg(7 downto 4);
							digit_sel <= "010";
							
						when "010" =>
							anode_reg <= "11111011";	
							digitout_reg <= digit_reg(11 downto 8);
							next_sel <= "011";
							
						when "011" =>
							anode_reg <= "11110111";	
							digitout_reg <= digit_reg(15 downto 12);
							next_sel <= "100";
							
						when "100" =>
							anode_reg <= "11101111";	
							digitout_reg <= digit_reg(19 downto 16);
							next_sel <= "101";
							
						when "101" =>
							anode_reg <= "11011111";	
							digitout_reg <= digit_reg(23 downto 20);
							next_sel <= "110";
							
						when "110" =>
							anode_reg <= "10111111";	
							digitout_reg <= digit_reg(27 downto 24);
							next_sel <= "111";
							
						when "111" =>
							anode_reg <= "01111111";	
							digitout_reg <= digit_reg(31 downto 28);
							next_sel <= "000";
							
						when others =>
							anode_reg <= "11111111";	
							digitout_reg <= "0000";
							next_sel <= "000";
					end case;
					
					-- Add fixed point decimal
					if (digit_sel = "110" or digit_sel = "010") then
					   cathode_p(7) <= '0';
					else
					   cathode_p(7) <= '1';
				    end if;
				end if;
			end process;
				
			--Connect the Cathode values
			with digitout_reg select
			cathode_p(6 downto 0) <= "1000000"when "0000", 	-- 0 
							"1111001" when "0001",	-- 1
							"0100100" when "0010",		-- 2
							"0110000" when "0011",		-- 3
							"0011001" when "0100",		-- 4
							"0010010" when "0101",		-- 5
							"0000010" when "0110",		-- 6
							"1111000" when "0111",		-- 7
							"0000000" when "1000",		-- 8
							"0011000" when "1001",		-- 9
							"1000000" when "1010",		-- A -> O
							"1000111" when "1011",		-- B -> L
							"0101111" when "1100",		-- C -> r
							"0111111" when "1101",		-- D -> -
							"0000110" when "1110",		-- E 
							"0001110" when "1111";		-- F
		 -- Add fixed point decimal
		 --cathode_p(7) <= '0' when digit_sel = "110" or digit_sel = "010"  else '1';
		 
		 --Connect the Anode values
		 anode_p <= anode_reg;

end behavioural;