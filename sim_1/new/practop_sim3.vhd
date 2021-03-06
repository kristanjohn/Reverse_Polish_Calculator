

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity practop_sim3 is
--  Port ( );
end practop_sim3;

architecture Behavioral of practop_sim3 is
component pracTop is
    Port ( ssegAnode : out  STD_LOGIC_VECTOR (7 downto 0);
       ssegCathode : out  STD_LOGIC_VECTOR (7 downto 0);
       slideSwitches : in  STD_LOGIC_VECTOR (15 downto 0);
       pushButtons : in  STD_LOGIC_VECTOR (4 downto 0);
       LEDs : out  STD_LOGIC_VECTOR (15 downto 0);
       clk100mhz : in STD_LOGIC;
       aclMISO : in STD_LOGIC;
       aclMOSI : out STD_LOGIC;
       aclSCK : out STD_LOGIC;
       aclSS : out STD_LOGIC;
--       RGB1_Red : out STD_LOGIC;
--       RGB1_Green : out STD_LOGIC;
--       RGB1_Blue : out STD_LOGIC;
       logic_analyzer : out STD_LOGIC_VECTOR (7 downto 0));
end component;

    -- Inputs
    signal clock : std_logic := '0';
    signal slideSwitches : std_logic_vector(15 downto 0) := (others => '0');
    signal pushButtons : std_logic_vector(4 downto 0) := (others => '0');
    
    signal reset_sig : std_logic := '0';
    signal load_sig : std_logic := '0';
    signal exec_sig : std_logic := '0';
    signal switches_sig : std_logic_vector(15 downto 0) := (others => '0');
    
    signal aclMISO : STD_LOGIC := '0';
    signal aclMOSI : STD_LOGIC := '0';
    signal aclSCK : STD_LOGIC := '0';
    signal aclSS : STD_LOGIC := '0';
begin
    uut1 : pracTop port map (
        clk100mhz => clock,
        slideSwitches => slideSwitches,
        pushButtons => pushButtons,
        aclMISO => aclMISO,
        aclMOSI => aclMOSI,
        aclSCK => aclSCK,
        aclSS => aclSS);
        
    clock <= not clock after 10ns;
    
    pushButtons(2) <= reset_sig;
    pushButtons(1) <= load_sig;
    pushButtons(4) <= exec_sig;
    
    slideSwitches <= switches_sig;
    input_gen : process
        begin 
            -- 12 / 4  = 3
            reset_sig <= '1';
            wait for 50ms;
            reset_sig <= '0';
            wait for 50ms;
            switches_sig(15 downto 8) <= "00010010"; -- 12
            load_sig <= '1'; -- load
            wait for 50ms;
            switches_sig(7 downto 0) <= "00000100"; -- enter 4
            exec_sig <= '1'; -- exec
            load_sig <= '0';
            wait for 50ms;
            switches_sig(15 downto 8) <= "00000100"; -- 4
            exec_sig <= '0';
            load_sig <= '1';
            wait for 50ms;
            load_sig <= '0';
            exec_sig <= '1'; -- exec
            wait for 50ms;
            exec_sig <= '0';
            wait for 50ms;
            switches_sig(7 downto 0) <= "00000111"; -- div
            exec_sig <= '1';
            wait for 50ms;
            exec_sig <= '0';
            wait for 50ms;
            wait;
            
         end process;

end Behavioral;
