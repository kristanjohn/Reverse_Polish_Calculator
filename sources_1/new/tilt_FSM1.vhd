library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tilt_FSM1 is
    Port ( A : in STD_LOGIC; -- Enable
           MISO : in STD_LOGIC;
           SCLK : in STD_LOGIC;
           reset : in STD_LOGIC;
           test : out std_logic;
           test2 : out std_logic;
           A_DONE : out STD_LOGIC; -- Complete
           N_CS_0 : out STD_LOGIC;
           MOSI_0 : out STD_LOGIC);
end tilt_FSM1;

architecture Behavioral of tilt_FSM1 is
    type State_type_FSM2 is (r0, r1, r2, r3, w4, w5, w6, w7, w8);
    signal state : State_type_FSM2;
    signal CMD_READ : std_logic_vector(7 downto 0);
    signal CMD_WRITE : std_logic_vector(7 downto 0);
    signal REG_CONTROL : std_logic_vector(7 downto 0);
    signal DATA_CONTROL : std_logic_vector(7 downto 0);
    signal count : integer range 0 to 7; -- Synthised as 3 bit counter
    signal r_count : integer range 0 to 7;
    signal state_r1 : std_logic;
    signal state_r2 : std_logic;
    --signal state_r3 : std_logic;
    signal state_w5 : std_logic;
    signal state_w6 : std_logic;
    signal state_w7 : std_logic;
begin
    CMD_WRITE <= "00001010";
    CMD_READ <= "00001011";
    REG_CONTROL <= "00101101";
    
    process(reset, SCLK)
    begin
        if (reset = '1') then
            state <= r0;
            count <= 0;
            DATA_CONTROL <= "01001010";--"----1-10";
            A_DONE <= '0';
    
        elsif(SCLK'event and SCLK = '0') then -- Falling edge
            case state is 
                when r0 => 
                    if (A = '1') then -- Triggered
                        state <= r1;
                    else 
                        state <= r0;
                    end if;
                when r1 => -- Output read cmd to spi
                    if (count < 7) then
                        state <= r1;
                        count <= count + 1;
                    else 
                        state <= r2;
                        count <= 0;
                    end if;
                when r2 => -- Output Control Reg
                    if (count < 7) then
                        state <= r2;
                        count <= count + 1;
                    else 
                        state <= r3;
                        count <= 0;
                    end if;
                when r3 => -- input reg data
                    if ((count = 6) or (count = 5) or (count = 4) or (count = 2)) then
                        --DATA_CONTROL(count) <= MISO; -- Store bits
                        count <= count + 1; -- Completely ignored
                        state <= r3;
                    elsif (count < 7) then
                        state <= r3;
                        count <= count + 1;
                    elsif (count = 7) then
                        --DATA_CONTROL(count) <= MISO;
                        state <= w4; -- Move to write
                        count <= 0;
                    else
                        state <= w4;
                        count <= 0;
                    end if;
                when w4 => -- Set N_CS low again for next CMD
                    -- Add delay
                    if (count < 7) then
                        state <= w4;
                        count <= count + 1;
                    else
                        state <= w5;
                        count <= 0;
                    end if;
                when w5 => -- output write to spi
                    if (count < 7) then
                        state <= w5;
                        count <= count + 1;
                    else
                        state <= w6;
                        count <= 0;
                    end if;
                when w6 => -- output Control reg
                    if (count < 7) then 
                        state <= w6;
                        count <= count + 1;
                    else
                        state <= w7;
                        count <= 0;
                    end if;
                when w7 => -- output data to control reg
                    if (count < 7) then
                        state <= w7;
                        count <= count + 1;
                    else
                        state <= w8;
                        count <= 0;
                        A_DONE <= '1';
                    end if;
                when w8 => -- Sit in loop
                    state <= w8;
            end case;
        end if;
    end process;
    test <= '1' when (state = r3) else '0';
    test2 <= '1' when (count = 7) else '0';
    
    r_count <= 7 - count;
    
    state_r1 <= '1' when (state = r1) and (CMD_READ(r_count) = '1') else '0';
    state_r2 <= '1' when (state = r2) and (REG_CONTROL(r_count)= '1') else '0';
    
    state_w5 <= '1' when (state = w5) and (CMD_WRITE(r_count) = '1') else '0';
    state_w6 <= '1' when (state = w6) and (REG_CONTROL(r_count) = '1') else '0';
    state_w7 <= '1' when (state = w7) and (DATA_CONTROL(r_count) = '1') else '0';
    
    MOSI_0 <= '1' when ((state_r1 = '1') or (state_r2 = '1') or (state_w5 = '1') or (state_w6 = '1') or (state_w7 = '1')) else '0';
    N_CS_0 <= '1' when (state = r0) or (state = w4) or (state = w8) else '0'; -- Goes down before data starts
end Behavioral;