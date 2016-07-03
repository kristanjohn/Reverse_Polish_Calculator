

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu is
  Port ( switches : in std_logic_vector(15 downto 0);
         temp_reg : out std_logic_vector(15 downto 0);
         top_reg : out std_logic_vector(15 downto 0);
         test_lc : out std_logic_vector(1 downto 0);
         clock : in std_logic;
         reset : in std_logic;
         exec : in std_logic;
         load : in std_logic;
         overflow : out std_logic;
         max : out std_logic
         );
end alu;

architecture Behavioral of alu is

component ram_mod is
    Port (
        clk: in std_logic;
        write_e : in std_logic;
        en : in std_logic;
        addr : in std_logic_vector(7 downto 0);
        din : in std_logic_vector(15 downto 0);
        dout: out std_logic_vector(15 downto 0)
    );
end component;

component add is
    Port (
        clk : in std_logic;
        A : in std_logic_vector(15 downto 0);
        B : in std_logic_vector(15 downto 0);
        C : out std_logic_vector(15 downto 0);
        overflow : out std_logic
    );
end component;

component sub is
    Port (
        clk : in std_logic;
        A : in std_logic_vector(15 downto 0);
        B : in std_logic_vector(15 downto 0);
        C : out std_logic_vector(15 downto 0);
        overflow : out std_logic
    );
end component;

component mul is
    Port (
        clk : in std_logic;
        A : in std_logic_vector(15 downto 0);
        B : in std_logic_vector(15 downto 0);
        C : out std_logic_vector(15 downto 0);
        overflow : out std_logic
    );
end component;

    -- Inputs
    signal digit_a : std_logic_vector(15 downto 0);
    signal digit_b : std_logic_vector(15 downto 0);
    
    signal max_check : std_logic;
    signal load_reset : std_logic;
    
    -- Outputs
    signal overflow_add : std_logic;
    signal overflow_sub : std_logic;
    signal overflow_mul : std_logic;
    signal result_add : std_logic_vector(15 downto 0);
    signal result_sub : std_logic_vector(15 downto 0);
    signal result_mul : std_logic_vector(15 downto 0);
    
    -- RAM
    signal load_counter : std_logic_vector(1 downto 0); -- 0 to 2
    signal stack_counter : std_logic_vector(7 downto 0); -- 0 to 19 (addr)
    
    signal write_e_sig : std_logic;
    signal en_sig : std_logic;
    signal din_sig : std_logic_vector(15 downto 0);
    signal dout_sig : std_logic_vector(15 downto 0);
    signal addr_sig : std_logic_vector(7 downto 0);
    
    signal temp_reg_sig : std_logic_vector(15 downto 0);
    signal sel_ab : std_logic;
    signal count_we : std_logic;
    
    signal lock1 : std_logic;
    signal lock2 : std_logic;
    
begin
    u1 : add port map (
        clk => clock,
        A => digit_a,
        B => digit_b,
        C => result_add,
        overflow => overflow_add);

    u2 : sub port map (
        clk => clock,
        A => digit_a,
        B => digit_b,
        C => result_sub,
        overflow => overflow_sub);

    u3 : mul port map (
        clk => clock,
        A => digit_a,
        B => digit_b,
        C => result_mul,
        overflow => overflow_mul);
        
    u4 : ram_mod port map (
        clk => clock,
        write_e => write_e_sig,
        en => en_sig,
        addr => addr_sig,
        din => din_sig,
        dout => dout_sig);

    -- Control statements

    max <= max_check;
    top_reg <= digit_a;
    temp_reg <= temp_reg_sig;
    test_lc <= load_counter;

    -- Select Operation (latch switch operation on exec btn)
    process(clock, exec, load, reset)
        variable stack_counter_v : std_logic_vector(7 downto 0);
        begin
            if (reset = '1') then
                lock1 <= '0';
                lock2 <= '0';
                max_check <= '0';
                stack_counter <= "00000001";
                load_reset <= '0';
                overflow <= '0';
                temp_reg_sig <= (others => '0');
                load_counter <= "00";
                en_sig <= '1'; -- RAM mod always enabled
                sel_ab <= '0';
                addr_sig <= stack_counter;
                count_we <= '0';
                write_e_sig <= '0';
                
            ---- EXEC BUTTON PUSHED
            elsif ((exec = '1') and (lock1 = '0')) then
                lock1 <= '1';
                stack_counter_v := stack_counter;
                 -- Clr (Done here) or Add or sub or Mul
                 --- decrement stack counter & check if empty => set A & B to 0
                 if ((switches(7 downto 0) = 0) or (switches(7 downto 0) = 1) or 
                       (switches(7 downto 0) = 2) or (switches(7 downto 0) = 3)) then
                    if (stack_counter > 1) then-- Stack has elements, leave 0 and 1
                       stack_counter_v := stack_counter_v - 1;
                       max_check <= '0'; -- Can't be max
                    end if;
                end if;
                
                -- Add
                if (switches(7 downto 0) = 1 and max_check = '0') then
                    din_sig <= result_add;
                    write_e_sig <= '1';
                    overflow <= overflow_add;
                
                -- Sub
                elsif (switches(7 downto 0) = 2 and max_check = '0') then
                    din_sig <= result_sub;
                    write_e_sig <= '1';
                    overflow <= overflow_sub;
                
                -- Mul
                elsif (switches(7 downto 0) = 3 and max_check = '0') then
                    din_sig <= result_mul;
                    write_e_sig <= '1';
                    overflow <= overflow_mul;
                
                -- Enter (Done here)
                --- increment stack counter & check if FULL => "ERR"
                --- push temp reg to TOS
                --- clear temp reg, set to 00.00
                elsif (switches(7 downto 0) = 4) then
                    -- check max
                    if (stack_counter > 18) then -- stack is 19 therfore FULL
                        max_check <= '1';
                    else 
                        din_sig <= temp_reg_sig;
                        write_e_sig <= '1';
                        stack_counter_v := stack_counter_v + 1;
                        temp_reg_sig <= "0000000000000000"; -- Reset temp reg
                        load_counter <= "00";               -- reset load reg
                    end if;
                end if;
                stack_counter <= stack_counter_v;
                addr_sig <= stack_counter_v;
                sel_ab <= '0';
                
           ---- LOAD BUTTON PUSHED
           elsif ((load = '1') and (lock2 = '0')) then
                lock2 <= '1';
                
                -- load integer part of number to temp reg and set frac part to 0
                if (load_counter = "00") then
                    -- check if neg
                    if (switches(15 downto 12) = "1111") then
                        temp_reg_sig(15 downto 8) <= "1000" & switches(11 downto 8); -- Value
                        temp_reg_sig(7 downto 0) <= "00000000"; -- Frac part set to 0
                    else
                        -- Check if number too large
                        if (switches(15 downto 8) < 100) then
                            temp_reg_sig(15 downto 8) <= switches(15 downto 8);
                            temp_reg_sig(7 downto 0) <= "00000000";
                        end if; -- Don't load value
                    end if;
                
                -- load Fractional part
                elsif (load_counter = "01") then
                    temp_reg_sig(7 downto 0) <= switches(15 downto 8); 
                    
                -- Clear Temp
                elsif (load_counter = "10") then
                    temp_reg_sig <= (others => '0');
                end if;
                
                -- Increment load counter
                case load_counter is
                    when "00" =>
                        load_counter <= "01";
                    when "01" => 
                        load_counter <= "10";
                    when "10" =>
                        load_counter <= "00";
                    when "11" =>
                        load_counter <= "11";
                end case;                
                
           ---- CLOCK EVENT
           elsif(clock'event and clock = '1') then

                if (write_e_sig = '1') then    -- Turn off write enable
                    if (count_we = '0') then
                        count_we <= '1';
                    else
                        count_we <= '0';
                        write_e_sig <= '0';
                    end if;
                else -- Don't change on write enable
                    if (sel_ab = '0') then -- Get TOS
                        addr_sig <= stack_counter;
                        digit_a <= dout_sig; 
                        sel_ab <= '1';
                    else -- Get Second
                        addr_sig <= stack_counter - 1;
                        digit_b <= dout_sig;
                        sel_ab <= '0';
                    end if;
                end if;
                -- Remove debouncing lock
                if (exec = '0') then
                    lock1 <= '0';
                end if;
                if (load = '0') then
                    lock2 <= '0';
                end if;
           end if;
    end process;
            
end Behavioral;
