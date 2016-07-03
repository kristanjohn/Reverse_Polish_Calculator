
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu_sim is
--  Port ( );
end alu_sim;

architecture Behavioral of alu_sim is

component alu
  Port ( switches : in std_logic_vector(15 downto 0);
         temp_reg : out std_logic_vector(15 downto 0);
         top_reg : out std_logic_vector(15 downto 0);
         clock : in std_logic;
         reset : in std_logic;
         exec : in std_logic;
         load : in std_logic;
         overflow : out std_logic;
         max : out std_logic
         );
end component;

    -- Inputs
    signal switches_sig : std_logic_vector(15 downto 0) := (others => '0');
    signal clock_sig : std_logic := '0';
    signal reset_sig : std_logic := '0';
    signal exec_sig : std_logic := '0';
    signal load_sig : std_logic := '0';
    
    -- Outpus
    signal temp_reg_sig : std_logic_vector(15 downto 0);
    signal top_reg_sig : std_logic_vector(15 downto 0);
    signal overflow_sig : std_logic;
    signal max_sig : std_logic; 
    
begin
    uut1 : alu port map (
        switches => switches_sig,
        temp_reg => temp_reg_sig,
        top_reg => top_reg_sig,
        clock => clock_sig,
        reset => reset_sig,
        exec => exec_sig,
        load => load_sig,
        overflow => overflow_sig,
        max => max_sig);
        
    clock_sig <= not clock_sig after 100ns;
    
    input_gen : process
        begin
            reset_sig <= '1';
            wait for 50us;
            reset_sig <= '0';            
            wait for 50us;
            -- Set switch, click button
            -- (12*0.5) - 0.25*(3 + 29) = -2
            -- 12; ENTER; 0.5; ENTER; MUL; 29; ENTER; 3; ENTER; ADD; 0.25; ENTER; MUL; SUB;
            switches_sig(15 downto 8) <= "00001100"; -- 12
            load_sig <= '1'; -- load
            wait for 50us;
            switches_sig(7 downto 0) <= "00000100"; -- enter 4
            exec_sig <= '1'; -- exec
            load_sig <= '0';
            wait for 50us;
            switches_sig(15 downto 8) <= "00000000"; -- 0
            exec_sig <= '0';
            load_sig <= '1';
            wait for 50us;
            load_sig <= '0';
            wait for 50us;
            switches_sig(15 downto 8) <= "10000000"; -- 1/2
            load_sig <= '1';
            wait for 50us; -- load
            load_sig <= '0';
            exec_sig <= '1';
            wait for 50us; -- exec
            exec_sig <= '0';
            wait for 50us; 
            switches_sig(7 downto 0) <= "00000011"; -- MUL 3
            exec_sig <= '1';
            wait for 50us;
            exec_sig <= '0';
            wait for 50us; 
            switches_sig(15 downto 8) <= "00011101"; -- 29
            load_sig <= '1';
            wait for 50us;
            load_sig <= '0';
            wait for 50us;
            switches_sig(7 downto 0) <= "00000100"; -- enter 4
            exec_sig <= '1';
            wait for 50us;
            exec_sig <= '0';
            wait for 50us;
            switches_sig(15 downto 8) <= "00000011"; -- 3
            load_sig <= '1';
            wait for 50us;
            load_sig <= '0';
            wait for 50us;
            switches_sig(7 downto 0) <= "00000100"; -- enter 4
            exec_sig <= '1';
            wait for 50us;
            exec_sig <= '0';
            wait for 50us; 
            switches_sig(7 downto 0) <= "00000001"; -- add 1
            exec_sig <= '1';
            wait for 50us;
            exec_sig <= '0';
            wait for 50us;
            switches_sig(15 downto 8) <= "00000000"; -- 0
            exec_sig <= '0';
            load_sig <= '1';
            wait for 50us;
            load_sig <= '0';
            wait for 50us;
            switches_sig(15 downto 8) <= "01000000"; -- 1/4
            load_sig <= '1';
            wait for 50us; -- load
            load_sig <= '0';
            wait for 50us;
            switches_sig(7 downto 0) <= "00000100"; -- enter 4
            exec_sig <= '1';
            wait for 50us; -- exec
            exec_sig <= '0';
            wait for 50us; 
            switches_sig(7 downto 0) <= "00000011"; -- MUL 3
            exec_sig <= '1';
            wait for 50us;
            exec_sig <= '0';
            wait for 50us; 
            switches_sig(7 downto 0) <= "00000010"; -- SUB 2
            exec_sig <= '1';
            wait for 50us;
            exec_sig <= '0';
            wait for 50us; 
            wait;
            
     end process;

end Behavioral;
