library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity div_sim is
--  Port ( );
end div_sim;

architecture Behavioral of div_sim is
    component DIV
        Port (
            clk : in std_logic;
            A : in std_logic_vector(15 downto 0);
            B : in std_logic_vector(15 downto 0);
            C : out std_logic_vector(15 downto 0);
            overflow : out std_logic
        );
    end component;

    -- Inputs
    signal clk_sig : std_logic := '0';
    signal A_sig : std_logic_vector(15 downto 0) := "0000000000000000";
    signal B_sig : std_logic_vector(15 downto 0) := "0000000000000000";
    
    -- Outputs
    signal C_sig : std_logic_vector(15 downto 0);
    signal overflow_sig : std_logic;
begin
    uut1 : DIV port map (
        clk => clk_sig,
        A => A_sig,
        B => B_sig,
        C => C_sig,
        overflow => overflow_sig);
        
    clk_sig <= not clk_sig after 100ns;
    
    input_gen : process
        begin
            wait for 100us;
            A_sig <= "0000010110000000"; -- 5.5
            B_sig <= "0000001001000000"; -- 2.25
            wait for 100us;
            A_sig <= "1000001000000000";
            B_sig <= "0000000100000000";
            wait for 100us;
            A_sig <= "1000001100000000";
            B_sig <= "1000001100000000";
            wait for 100us;
    end process;
        

end Behavioral;
