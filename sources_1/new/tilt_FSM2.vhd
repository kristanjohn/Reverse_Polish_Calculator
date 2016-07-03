
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tilt_FSM2 is
    Port ( SCLK : in STD_LOGIC;
           reset : in STD_LOGIC;
           X : in STD_LOGIC;
           Y : in STD_LOGIC;
           Z : in STD_LOGIC;
           MISO : in STD_LOGIC;
           digit_out : out STD_LOGIC_VECTOR(15 downto 0);
           N_CS_1 : out STD_LOGIC;
           MOSI_1 : out STD_LOGIC);
end tilt_FSM2;

architecture Behavioral of tilt_FSM2 is
    type State_signal_FSM3 is (s0, m1, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12);
    signal state : State_signal_FSM3;
    signal count : integer range 0 to 7;
    signal r_count : integer range 0 to 7; -- reverse count
    signal CMD_READ : std_logic_vector(7 downto 0);
    signal REG_X_L : std_logic_vector(7 downto 0);
    signal REG_X_H : std_logic_vector(7 downto 0);
    signal REG_Y_L : std_logic_vector(7 downto 0);
    signal REG_Y_H : std_logic_vector(7 downto 0);
    signal REG_Z_L : std_logic_vector(7 downto 0);
    signal REG_Z_H : std_logic_vector(7 downto 0);
    --signal digit_H : std_logic_vector(7 downto 0);
    --signal digit_L : std_logic_vector(7 downto 0);
    signal state_s1 : std_logic;
    signal state_s2 : std_logic;
    signal state_s3 : std_logic;
    signal state_s4 : std_logic;
    signal state_s7 : std_logic;
    signal state_s8 : std_logic;
    signal state_s9 : std_logic;
    signal state_s10 : std_logic;
    
begin
    CMD_READ <= "00001011";
    REG_X_L <= "00001110";
    REG_X_H <= "00001111";
    REG_Y_L <= "00010000";
    REG_Y_H <= "00010001";
    REG_Z_L <= "00010010";
    REG_Z_H <= "00010011";
    
    process(reset, SCLK)
    variable digit_H : unsigned(7 downto 0);
    variable digit_L : unsigned(7 downto 0);
    begin 
        if (reset = '0') then
            state <= s0;
            count <= 0;
            digit_out <= "0000000000000000";
            digit_H := "00000000";
            digit_L := "00000000";
        
        elsif(SCLK'event and SCLK = '0') then -- Falling Edge
            case state is
                when s0 => -- Wait state
                    if ((X = '1') or (Y = '1') or (Z = '1')) then
                        state <= m1;
                    else
                        state <= s0;
                    end if;
                when m1 => 
                    if (count < 7) then
                        state <= m1;
                        count <= count + 1;
                    else
                        state <= s1;
                        count <= 0;
                    end if;
                when s1 => -- Output READ CMD
                    if (count < 7) then
                        state <= s1;
                        count <= count + 1;
                    elsif (X = '1') then -- Go to x reg
                        state <= s2;
                        count <= 0;
                    elsif (Y = '1') then -- Go to y reg
                        state <= s3;
                        count <= 0;
                    else -- Go to z reg
                        state <= s2;
                        count <= 0;
                    end if;
                when s2 => -- Output X reg
                    if (count < 7) then
                        state <= s2;
                        count <= count + 1;
                    else -- Go to read state
                        state <= s5;
                        count <= 0;
                    end if;
                when s3 => -- Output Y reg
                    if (count < 7) then
                        state <= s3;
                        count <= count + 1;
                    else -- Go to read state
                        state <= s5;
                        count <= 0;
                    end if;
                when s4 => -- Output Z reg
                    if (count < 7) then
                        state <= s4;
                        count <= count + 1;
                    else -- Go to read state
                        state <= s5;
                        count <= 0;
                    end if;
                when s5 => -- Input read HIGH
                    if (count < 7) then
                        digit_H(r_count) := MISO;
                        count <= count + 1;
                        state <= s5;
                    else -- Go to quick wait state
                        state <= s6;
                        count <= 0;
                    end if;
                when s6 => -- Set N_CS low again for next CMD
                    -- Add delay
                    if (count < 7) then
                        state <= s6;
                        count <= count + 1;
                    else
                        state <= s7;
                        count <= 0;
                    end if;
                when s7 => -- Output READ CMD
                    if (count < 7) then
                        state <= s7;
                        count <= count + 1;
                    elsif (X = '1') then -- Go to x reg
                        state <= s8;
                        count <= 0;
                    elsif (Y = '1') then -- Go to y reg
                        state <= s9;
                        count <= 0;
                    else -- Go to z reg
                        state <= s10;
                        count <= 0;
                    end if;
                when s8 => -- Output x reg
                    if (count < 7) then
                        state <= s8;
                        count <= count + 1;
                    else -- Go to read state
                        state <= s11;
                        count <= 0;
                    end if;
                when s9 => -- Output y reg
                    if (count < 7) then
                        state <= s9;
                        count <= count + 1;
                    else -- Go to read state
                        state <= s11;
                        count <= 0;
                    end if;
                when s10 => -- Output z reg
                    if (count < 7) then
                        state <= s10;
                        count <= count + 1;
                    else  -- Go to read state
                        state <= s11;
                        count <= 0;
                    end if;
                when s11 => -- Input read LOW
                    if (count < 7) then
                        digit_L(r_count) := MISO;
                        state <= s11;
                        count <= count + 1;
                    else  -- Back to beginning
                        state <= s12;
                        count <= 0;
                    end if;
                when s12 => -- Add delay
                    -- Add delay
                    if (count < 7) then
                        state <= s12;
                        count <= count + 1;
                    else
                        state <= s0;
                        count <= 0;
                    end if;
            end case;
            -- Fix negatives
            if (digit_H(6) = '1') then-- Should be negative
                digit_out(15 downto 8) <= std_logic_vector(digit_H);
                digit_out(7 downto 0)  <= (not std_logic_vector(digit_L)) + 1; 
            else
                digit_out(15 downto 8) <= std_logic_vector(digit_H);
                digit_out(7 downto 0) <= std_logic_vector(digit_L);
            end if;
        end if;
    end process;
    
    r_count <= 7 - count; -- Fix direction issue
    
    state_s1 <= '1' when (state = s1) and (CMD_READ(r_count) = '1') else '0';
    state_s2 <= '1' when (state = s2) and (REG_X_H(r_count) = '1') else '0';
    state_s3 <= '1' when (state = s3) and (REG_Y_H(r_count) = '1') else '0';
    state_s4 <= '1' when (state = s4) and (REG_Z_H(r_count) = '1') else '0';
    
    state_s7 <= '1' when (state = s7) and (CMD_READ(r_count) = '1') else '0';
    state_s8 <= '1' when (state = s8) and (REG_X_L(r_count) = '1') else '0';
    state_s9 <= '1' when (state = s9) and (REG_Y_L(r_count) = '1') else '0';
    state_s10 <= '1' when (state = s10) and (REG_Z_L(r_count) = '1') else '0';
    

    MOSI_1 <= '1' when ((state_s1 = '1') or (state_s2 = '1') or (state_s3 = '1') or (state_s4 = '1') or (state_s7 = '1') or (state_s8 = '1') or (state_s9 = '1') or (state_s10 = '1')) else '0';
    N_CS_1 <= '1' when (state = s0) or (state = m1) or (state = s6) or (state = s12) else '0'; -- Goes down before data starts             
                        

end Behavioral;
