

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pracTop is
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
end pracTop;

architecture Behavioral of PracTop is
    component ssegDriver port (
      en : in std_logic;
      clk : in std_logic;
      rst : in std_logic;
      cathode_p : out std_logic_vector(7 downto 0);
      anode_p : out std_logic_vector(7 downto 0);
      digit1_p : in std_logic_vector(3 downto 0);
      digit2_p : in std_logic_vector(3 downto 0);
      digit3_p : in std_logic_vector(3 downto 0);
      digit4_p : in std_logic_vector(3 downto 0);
      digit5_p : in std_logic_vector(3 downto 0);
      digit6_p : in std_logic_vector(3 downto 0);
      digit7_p : in std_logic_vector(3 downto 0);
      digit8_p : in std_logic_vector(3 downto 0)
   ); 
end component;

component ssegDriverUpsideDown port (
      en : in std_logic;
      clk : in std_logic;
      rst : in std_logic;
      cathode_p : out std_logic_vector(7 downto 0);
      anode_p : out std_logic_vector(7 downto 0);
      digit1_p : in std_logic_vector(3 downto 0);
      digit2_p : in std_logic_vector(3 downto 0);
      digit3_p : in std_logic_vector(3 downto 0);
      digit4_p : in std_logic_vector(3 downto 0);
      digit5_p : in std_logic_vector(3 downto 0);
      digit6_p : in std_logic_vector(3 downto 0);
      digit7_p : in std_logic_vector(3 downto 0);
      digit8_p : in std_logic_vector(3 downto 0)
   ); 
end component;

component alu2
  Port ( switches : in std_logic_vector(15 downto 0);
         temp_reg : out std_logic_vector(15 downto 0);
         top_reg : out std_logic_vector(15 downto 0);
         clock : in std_logic;
         reset : in std_logic;
         exec : in std_logic;
         load : in std_logic;
         overflow : out std_logic;
         test : out std_logic_vector(7 downto 0);
         max : out std_logic
         );
end component;

component BCD
    Port ( clock : in STD_LOGIC;
           reset : in STD_LOGIC;
           digit_in : in STD_LOGIC_VECTOR(15 downto 0);
           digit_out : out STD_LOGIC_VECTOR(15 downto 0)
           );
end component;

component debounce
    Port ( clk : in STD_LOGIC;
           button : in std_logic;
           result : out std_logic);
end component;

component tilt_FSM1 is 
     Port ( A : in STD_LOGIC;
            MISO : in STD_LOGIC;
            SCLK : in STD_LOGIC;
            reset : in STD_LOGIC;
            test : out std_logic;
            test2 : out std_logic;
            A_DONE : out STD_LOGIC;
            N_CS_0 : out STD_LOGIC;
            MOSI_0 : out STD_LOGIC);
end component;

component tilt_FSM2
     Port ( SCLK : in STD_LOGIC;
            reset : in STD_LOGIC;
            X : in STD_LOGIC;
            Y : in STD_LOGIC;
            Z : in STD_LOGIC;
            MISO : in STD_LOGIC;
            digit_out : out STD_LOGIC_VECTOR(15 downto 0);
            N_CS_1 : out STD_LOGIC;
            MOSI_1 : out STD_LOGIC);
 end component;
 
    -- Inputs
    signal temp_reg_sig : std_logic_vector(15 downto 0);
    signal top_reg_sig : std_logic_vector(15 downto 0);
    signal clock_sig : std_logic;
    signal masterReset : std_logic; -- active high
    signal clockScalers : std_logic_vector (26 downto 0);
    
    signal digit1 : std_logic_vector(3 downto 0);
    signal digit2 : std_logic_vector(3 downto 0);
    signal digit3 : std_logic_vector(3 downto 0);
    signal digit4 : std_logic_vector(3 downto 0);
    signal digit5 : std_logic_vector(3 downto 0);
    signal digit6 : std_logic_vector(3 downto 0);
    signal digit7 : std_logic_vector(3 downto 0);
    signal digit8 : std_logic_vector(3 downto 0);
    
    signal load_button : std_logic;
    signal exec_button : std_logic;
    
    -- Outputs
    signal overflow_sig : std_logic;
    signal max_sig : std_logic;
    signal top_reg_out : std_logic_vector(15 downto 0);
    signal temp_reg_out : std_logic_vector(15 downto 0);
    signal test_sig : std_logic_vector(7 downto 0);
    
    -- Tilt signals
    signal SCLK_signal : std_logic := '0';
    signal MISO_signal : std_logic := '0';
    
    -- outputs
    signal digit_out_signal : std_logic_vector(15 downto 0);
    signal N_CS_1_signal : std_logic;
    signal N_CS_0_signal : std_logic;
    signal MOSI_1_signal : std_logic;
    signal MOSI_0_signal : std_logic;
    signal MOSI_signal : std_logic;
    signal N_CS : std_logic;
    signal A_DONE_Signal : std_logic;
    
    -- 7seg
    signal seg_en : std_logic;
    signal number9 : std_logic;
    signal ssegAnode_1 : STD_LOGIC_VECTOR (7 downto 0);
    signal ssegCathode_1 : STD_LOGIC_VECTOR (7 downto 0);
    signal ssegAnode_2 : STD_LOGIC_VECTOR (7 downto 0);
    signal ssegCathode_2 : STD_LOGIC_VECTOR (7 downto 0);
begin
    u1 : alu2 port map (
        switches => slideSwitches,
        temp_reg => temp_reg_sig,
        top_reg => top_reg_sig,
        clock => clock_sig,
        reset => masterReset,
        exec => exec_button,
        load => load_button,
        overflow => overflow_sig,
        max => max_sig,
        test => test_sig
        );
        
    u2 : BCD port map (
        clock => clock_sig,
        reset => masterReset,
        digit_in => top_reg_sig,
        digit_out => top_reg_out);
    
    u3 : BCD port map (
        clock => clock_sig,
        reset => masterReset,
        digit_in => temp_reg_sig,
        digit_out => temp_reg_out);
    
    u4 : ssegDriver port map (
       en => seg_en,
       clk => clockScalers(11),
       rst => masterReset,
       cathode_p => ssegCathode_1,
       anode_p => ssegAnode_1,
       digit1_p => digit1,
       digit2_p => digit2,
       digit3_p => digit3,
       digit4_p => digit4,
       digit5_p => digit5,
       digit6_p => digit6,
       digit7_p => digit7,
       digit8_p => digit8
    );
    
    u9 : ssegDriverUpsideDown port map (
       en => not seg_en,
       clk => clockScalers(11),
       rst => masterReset,
       cathode_p => ssegCathode_2,
       anode_p => ssegAnode_2,
       digit1_p => digit1,
       digit2_p => digit2,
       digit3_p => digit3,
       digit4_p => digit4,
       digit5_p => digit5,
       digit6_p => digit6,
       digit7_p => digit7,
       digit8_p => digit8
    );
    
    u5 : debounce port map ( -- Exec Button
        clk => clockScalers(1),
        button => pushButtons(4),
        result => exec_button
    );
    
    u6 : debounce port map ( -- Load Button
        clk => clockScalers(1),
        button => pushButtons(1),
        result => load_button
    );
    
    u10 : debounce port map ( -- Load Button
            clk => clockScalers(6),
            button => digit_out_signal(9),
            result => number9
    );
    
    u7 : tilt_FSM1 port map ( -- Initiate Tilt
        A => '0', -- SKIP INITIATE should be '1'
        A_DONE => A_DONE_signal, -- out
        MISO => MISO_signal,
        SCLK => SCLK_signal,
        reset => masterReset,
        test => logic_analyzer(7),
        test2 => logic_analyzer(6),
        N_CS_0 => N_CS_0_signal,
        MOSI_0 => MOSI_0_signal
    );
        
    u8 : tilt_FSM2 port map (
        reset => '1', --A_DONE_signal, -- in
        SCLK => SCLK_signal,
        X => '1', -- Always x-axis
        Y => '0',
        Z => '0',
        MISO => MISO_signal,
        digit_out => digit_out_signal,
        N_CS_1 => N_CS_1_signal,
        MOSI_1 => MOSI_1_signal
    );
        
    -- Control Statements
    masterReset <= pushbuttons(2);
    clock_sig <= clockScalers(5); -- was 3
    --logic_analyzer(7 downto 0) <= test_sig;
    --LEDs <= temp_reg_sig;
    
    SCLK_signal <= clockScalers(5);
    MOSI_signal <= MOSI_0_signal or MOSI_1_signal;
    N_CS <= N_CS_0_signal xnor N_CS_1_signal;    
    
    -- Connect SPI through board
    MISO_signal <= aclMISO;
    aclMOSI <= MOSI_signal;
    aclSCK <= SCLK_signal;
    aclSS <= N_CS;
    -- Logic Analyzer
    logic_analyzer(0) <= MOSI_signal;
    logic_analyzer(1) <= MISO_signal;
    logic_analyzer(2) <= SCLK_signal;
    logic_analyzer(3) <= N_CS;
    
    logic_analyzer(4) <= A_DONE_signal;
    logic_analyzer(5) <= N_CS_0_signal;
    
    -- Tilt 7seg
    ssegAnode   <= ssegAnode_1   when seg_en = '1' else ssegAnode_2;
    ssegCathode <= ssegCathode_1 when seg_en = '1' else ssegCathode_2; 
    
    process(clk100mhz, masterReset)
    begin -- Reset top level states
        if (masterReset = '1') then
            clockScalers <= "000000000000000000000000000";
        elsif(clk100mhz'event and clk100mhz = '1') then
            clockScalers <= clockScalers + '1'; 
        end if;
    end process;
    
    process(clock_sig, masterReset)
    begin
        if (masterReset = '1') then
            digit1 <= (others => '0');
            digit2 <= (others => '0');
            digit3 <= (others => '0');
            digit4 <= (others => '0');
            digit5 <= (others => '0');
            digit6 <= (others => '0');
            digit7 <= (others => '0');
            digit8 <= (others => '0');
            seg_en <= '1';
        elsif(clock_sig'event and clock_sig = '1') then
            if (overflow_sig = '1') then
                digit4 <= "1010";-- O -> A
                digit3 <= "1111";-- F
                digit2 <= "1011";-- L -> B
                digit1 <= "1010";-- O
            elsif(max_sig = '1') then
                digit4 <= "1110";-- E
                digit3 <= "1100";-- R -> C
                digit2 <= "1100";-- R
                digit1 <= "1100";-- R
            else
                digit1 <= top_reg_out(3 downto 0);
                digit2 <= top_reg_out(7 downto 4);
                digit3 <= top_reg_out(11 downto 8);
                digit4 <= top_reg_out(15 downto 12);
            end if; 
            digit5 <= temp_reg_out(3 downto 0);
            digit6 <= temp_reg_out(7 downto 4);
            digit7 <= temp_reg_out(11 downto 8);
            digit8 <= temp_reg_out(15 downto 12);
            
            -- Tilt enables
            -- Up
            if (digit_out_signal(13) = '0' and (number9 = '1')) then
                seg_en <= '1'; 
            -- Flip
            elsif (digit_out_signal(13) = '1' and (number9 = '0')) then
                seg_en <= '0';
            end if;            
        end if;
    end process;
--    LEDs <= digit_out_signal;
    LEDs(7) <= '1' when (digit_out_signal(13) = '1' and (unsigned(digit_out_signal(7 downto 0)) > 10)) else '0';
    LEDs(6) <= '1' when (digit_out_signal(13) = '1' and (unsigned(digit_out_signal(7 downto 0)) > 30)) else '0';
    LEDs(5) <= '1' when (digit_out_signal(13) = '1' and (unsigned(digit_out_signal(7 downto 0)) > 60)) else '0';
    LEDs(4) <= '1' when (digit_out_signal(13) = '1' and (unsigned(digit_out_signal(7 downto 0)) > 90)) else '0';
    LEDs(3) <= '1' when (digit_out_signal(13) = '1' and (unsigned(digit_out_signal(7 downto 0)) > 120)) else '0';
    LEDs(2) <= '1' when (digit_out_signal(13) = '1' and (unsigned(digit_out_signal(7 downto 0)) > 150)) else '0';
    LEDs(1) <= '1' when (digit_out_signal(13) = '1' and (unsigned(digit_out_signal(7 downto 0)) > 180)) else '0';
    LEDs(0) <= '1' when (digit_out_signal(13) = '1' and (unsigned(digit_out_signal(7 downto 0)) > 210)) else '0';
    
    LEDs(8) <= '1' when (digit_out_signal(13) = '0' and (unsigned(digit_out_signal(7 downto 0)) > 10)) else '0';
    LEDs(9) <= '1' when (digit_out_signal(13) = '0' and (unsigned(digit_out_signal(7 downto 0)) > 30)) else '0';
    LEDs(10) <= '1' when (digit_out_signal(13) = '0' and (unsigned(digit_out_signal(7 downto 0)) > 60)) else '0';
    LEDs(11) <= '1' when (digit_out_signal(13) = '0' and (unsigned(digit_out_signal(7 downto 0)) > 90)) else '0';
    LEDs(12) <= '1' when (digit_out_signal(13) = '0' and (unsigned(digit_out_signal(7 downto 0)) > 120)) else '0';
    LEDs(13) <= '1' when (digit_out_signal(13) = '0' and (unsigned(digit_out_signal(7 downto 0)) > 150)) else '0';
    LEDs(14) <= '1' when (digit_out_signal(13) = '0' and (unsigned(digit_out_signal(7 downto 0)) > 180)) else '0';
    LEDs(15) <= '1' when (digit_out_signal(13) = '0' and (unsigned(digit_out_signal(7 downto 0)) > 210)) else '0';
end Behavioral;
