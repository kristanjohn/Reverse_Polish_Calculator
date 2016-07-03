library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity add_sim is
--  Port ( );
end add_sim;

architecture Behavioral of add_sim is
    component ADD
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
    uut1 : ADD port map (
        clk => clk_sig,
        A => A_sig,
        B => B_sig,
        C => C_sig,
        overflow => overflow_sig);
        
    clk_sig <= not clk_sig after 100ns;
    
    input_gen : process
        begin
            wait for 100us;
            A_sig <= "0000000000000001";
            B_sig <= "0000000000000000";
            wait for 100us;
            A_sig <= "1000000000000001";
            B_sig <= "1000000000000001";
            wait for 100us;
            A_sig <= "0000011100000000";
            B_sig <= "1000001100000000";
            wait for 100us;
    end process;
        

end Behavioral;
