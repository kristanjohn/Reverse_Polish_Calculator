-- Very Efficent ALU

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu2 is
  Port ( switches : in std_logic_vector(15 downto 0);
         temp_reg : out std_logic_vector(15 downto 0);
         top_reg : out std_logic_vector(15 downto 0);
         test : out std_logic_vector(7 downto 0);
         clock : in std_logic;
         reset : in std_logic;
         exec : in std_logic;
         load : in std_logic;
         overflow : out std_logic;
         max : out std_logic
         );
end alu2;
architecture Behavioral of alu2 is

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
        en : in std_logic;
        clk : in std_logic;
        reset : in std_logic;
        A : in std_logic_vector(15 downto 0);
        B : in std_logic_vector(15 downto 0);
        C : out std_logic_vector(15 downto 0);
        overflow : out std_logic
    );
end component;

component sub is
    Port (
        en : std_logic;
        clk : in std_logic;
        reset : in std_logic;
        A : in std_logic_vector(15 downto 0);
        B : in std_logic_vector(15 downto 0);
        C : out std_logic_vector(15 downto 0);
        overflow : out std_logic
    );
end component;

component mul is
    Port (
        en : std_logic;
        clk : in std_logic;
        reset : in std_logic;
        A : in std_logic_vector(15 downto 0);
        B : in std_logic_vector(15 downto 0);
        C : out std_logic_vector(15 downto 0);
        overflow : out std_logic
    );
end component;

component sqrt is
    Port (
        en : in std_logic;
        clk : in std_logic;
        reset : in std_logic;
        A : in std_logic_vector(15 downto 0);
        C : out std_logic_vector(15 downto 0)
    );
end component;

component div is 
    Port (
        en : in std_logic;
        clk : in std_logic;
        reset : in std_logic;
        A : in std_logic_vector(15 downto 0);
        B : in std_logic_vector(15 downto 0);
        C : out std_logic_vector(15 downto 0);
        overflow : out std_logic
    );
end component;
    -- Signals
    signal stack_counter : std_logic_vector(7 downto 0); -- 0 to 19 (addr)
    signal int_temp_reg  : std_logic_vector(7 downto 0);
    signal frac_temp_reg : std_logic_vector(7 downto 0);
    signal digit_a : std_logic_vector(15 downto 0);
    signal digit_b : std_logic_vector(15 downto 0);
    signal pop : std_logic;
    signal push: std_logic;
    signal masterReset : std_logic;
    signal overflow_sig : std_logic;
    
    -- RAM
    signal ram_addr : std_logic_vector(7 downto 0);
    signal ram_din : std_logic_vector(15 downto 0);
    signal ram_dout: std_logic_vector(15 downto 0);
    
    -- Overflow
    signal add_oflo : std_logic;
    signal sub_oflo : std_logic;
    signal mul_oflo : std_logic;
    signal div_oflo : std_logic;
    
    -- Results
    signal add_result : std_logic_vector(15 downto 0);
    signal sub_result : std_logic_vector(15 downto 0);
    signal mul_result : std_logic_vector(15 downto 0);
    signal sqrt_result : std_logic_vector(15 downto 0);
    signal div_result : std_logic_vector(15 downto 0);
    
    -- Enable operation
    signal add_e : std_logic;
    signal sub_e : std_logic;
    signal mul_e : std_logic;
    signal sqrt_e : std_logic;
    signal div_e : std_logic;
    
    signal write_e : std_logic;
    signal ram_e : std_logic;

    -- State machine
    type operation_type is (none_s, add_s, sub_s, mul_s, sqrt_s, div_s, enter, swap_s, swap_s1);
    signal operation : operation_type;
    
    type State_type is (r0, l1, l2, l3, l4, l5, e1, e2,
                        op1, op2, op3, op4, op5, clr1, ent1, ent2);
    signal state : State_type;
    
begin
    u4 : ram_mod port map (
    clk => clock,
    write_e => write_e,
    en => ram_e,
    addr => ram_addr,
    din => ram_din,
    dout => ram_dout);
    
    u1 : add port map (
    en => add_e,
    clk => clock,
    reset => masterReset,
    A => digit_a,
    B => digit_b,
    C => add_result,
    overflow => add_oflo);
    
    u2 : sub port map (
    en => sub_e,
    clk => clock,
    reset => masterReset,
    A => digit_a,
    B => digit_b,
    C => sub_result,
    overflow => sub_oflo);

    u3 : mul port map (
    en => mul_e,
    clk => clock,
    reset => masterReset,
    A => digit_a,
    B => digit_b,
    C => mul_result,
    overflow => mul_oflo);
    
    u5 : sqrt port map (
    en => sqrt_e,
    clk => clock,
    reset => masterReset,
    A => digit_a,
    C => sqrt_result);
    
    u6 : div port map (
    en => div_e,
    clk => clock,
    reset => masterReset,
    A => digit_a,
    B => digit_b,
    C => div_result,
    overflow => div_oflo);
    
    -- Entity Outputs
    temp_reg <= int_temp_reg & frac_temp_reg;
    top_reg  <= ram_dout;
    overflow <= overflow_sig;
    overflow_sig <= '1' when (operation = add_s and add_oflo = '1') or
                             (operation = sub_s and sub_oflo = '1') or
                             (operation = mul_s and mul_oflo = '1') or
                             (operation = div_s and div_oflo = '1') else '0';
    max      <= '1' when (stack_counter = 19) else '0';
    ram_addr <= stack_counter;
    test <= stack_counter;
    masterReset <= reset;
    
    -- State Results
    digit_a <= digit_a  when state = op3 or state = op2 or state = op1 or state = op4 else ram_dout; -- Latch
    digit_b <= ram_dout when state = op3 else digit_b;
    pop     <= '1'      when state = op2 or state = clr1 else '0';  
    push    <= '1'      when state = ent1 or state = op5 else '0';
    add_e   <= '1'      when state = op3 else '0'; 
    sub_e   <= '1'      when state = op3 else '0';
    mul_e   <= '1'      when state = op3 else '0';
    sqrt_e  <= '1'      when state = op3 else '0';
    div_e   <= '1'      when state = op3 else '0';
    write_e <= '1'      when state = op4 or state = op5 or state = ent2 else '0'; 
    ram_e   <= '1';
    
    with operation select
        ram_din <= add_result when add_s,
                   sub_result when sub_s,
                   mul_result when mul_s,
                   sqrt_result when sqrt_s,
                   div_result when div_s,
                   digit_a when swap_s,
                   digit_b when swap_s1,
                   (int_temp_reg & frac_temp_reg) when enter,
                   (others => '0') when none_s;
                   
                   
    -- Finite State Machine
    process(clock, masterReset)
        variable frac_temp_v : unsigned(7 downto 0);
        variable int_temp_v  : unsigned(7 downto 0);
        variable ten : unsigned(3 downto 0);
        variable neg : std_logic;
        variable oflo_v : std_logic := '0';
        begin
        if (masterReset='1') then
            state <= r0;
            operation <= none_s;
            frac_temp_reg <= (others => '0');
            int_temp_reg  <= (others => '0');
            
        elsif clock'event and clock='1' then
                 -- State Dependent Operations
            ten(3 downto 0) := "1010";
            -- Calculate int_temp_reg BCD to binary
            if (state = l1) then
                -- Check if negative number
                if (switches(15 downto 12) = "1111") then -- Neg
                    int_temp_v := unsigned("1000" & switches(11 downto 8));
                    neg := '1';
                else 
                    int_temp_v := unsigned(unsigned(switches(15 downto 12)) * ten + switches(11 downto 8));
                    neg := '0';
                end if;
                
                -- Check for overflow
                if ((neg = '1' and int_temp_v(3 downto 0) > 9) or (neg='0' and int_temp_v > 99)) then 
                      oflo_v := '1';               
                else
                    oflo_v := '0';
                    int_temp_reg <= std_logic_vector(int_temp_v);
                    frac_temp_reg <= (others => '0');
                end if; 
 
            end if;
            -- Calculate BCD to frac binary
            if (state = l3) then
                frac_temp_v := unsigned(unsigned(switches(15 downto 12)) * ten + switches(11 downto 8));
                                    
                for i in 0 to 7 loop
                    frac_temp_v := frac_temp_v(6 downto 0) & '0'; -- Multiply by 2
                    if (frac_temp_v > 99) then                    -- If > 1.00
                        frac_temp_v := frac_temp_v - "01100100";  -- Take 100 
                        frac_temp_reg(7-i) <= '1';                -- Binary bit is 1
                    else
                        frac_temp_reg(7-i) <= '0';                -- Else 0
                    end if;
                end loop;
                
            end if;
            
            if (state = l5 or state = ent2) then -- Clear Temp Reg
                int_temp_reg <= (others => '0');
                frac_temp_reg <= (others => '0');
            end if;
            
            -- State Machine
            case state is
                when r0 =>
                    if (load = '1') then
                        state <= l1;
                    elsif (exec = '1') then
                        state <= e1;
                    else
                        state <= r0;
                    end if;
                when l1 => -- Load Pressed
                    if (oflo_v = '1') then -- Ignore large value
                        state <= r0;
                    elsif (load = '0') then
                        state <= l2;
                    else
                        state <= l1;
                    end if;
                when l2 => 
                    if (load = '1') then    
                        state <= l3;
                    elsif (exec = '1') then
                        state <= e1;
                    else
                        state <= l2;
                    end if;
                when l3 => -- Load Pressed again
                    if (load = '0') then
                        state <= l4;
                    else
                        state <= l3;
                    end if;
                when l4 => 
                    if (load = '1') then
                        state <= l5;
                    elsif (exec = '1') then
                        state <= e1;
                    else 
                        state <= l4;
                    end if;
                when l5 => -- Load Pressed 3 times
                    if (load = '0') then    
                        state <= r0;
                    else
                        state <= l5;
                    end if;
                when e1 => -- Execute Pressed
                    if (exec = '0') then
                        state <= e2;
                    else 
                        state <= e1;
                    end if;
                when e2 => -- Select Operation
                    case switches(7 downto 0) is
                        when "00000000" => -- CLR
                            state <= clr1;
                            operation <= none_s;
                        when "00000001" => -- ADD
                            if (overflow_sig = '0') then
                                state <= op1;
                                operation <= add_s;
                            else
                                state <= r0;
                            end if;
                        when "00000010" => -- SUB
                            if (overflow_sig = '0') then
                                state <= op1;
                                operation <= sub_s;
                            else
                                state <= r0;
                            end if;
                        when "00000011" => -- MUL
                            if (overflow_sig = '0') then
                                state <= op1;
                                operation <= mul_s;
                            else
                                state <= r0;
                            end if;
                        when "00000100" => -- ENTER
                            if (overflow_sig = '0') then
                                state <= ent1;
                                operation <= enter;
                            else
                                state <= r0;
                            end if;
                        when "00000101" => -- SQRT
                            if (overflow_sig = '0') then
                                state <= op3;
                                operation <= sqrt_s;
                            else
                                state <= r0;
                            end if;
                        when "00000111" => -- DIV
                            if (overflow_sig = '0') then
                                state <= op1;
                                operation <= div_s;
                            else
                                state <= r0;
                            end if;
                        when "00000110" => -- SWAP
                            if (overflow_sig = '0') then
                                state <= op1;
                                operation <= swap_s;
                            else
                                state <= r0;
                            end if;
                        when others =>
                            state <= r0;
                    end case;
                when ent1 =>     -- Push stack counter
                    state <= ent2;
                when ent2 =>     -- Put temp in RAM 
                    state <= r0; 
                when op1 =>
                    state <= op2; -- Get digit A
                when op2 =>
                    state <= op3; -- Get digit B 
                when op3 =>
                    state <= op4; -- Add result
                when op4 =>
                                  -- Push result (Just turn on write enable)
                    if (operation = swap_s) then
                        state <= op5;
                        operation <= swap_s1;
                    else 
                        state <= r0;
                    end if;
                when op5 =>
                    state <= r0;
                when clr1 =>
                    state <= r0;  -- Pop
            end case;           
                   
        end if;        
    end process;      
            
     
    -- Pop and Push control stack counter
    process(clock, masterReset)
        begin
        if masterReset = '1' then
            stack_counter <= "00000001";
        elsif clock'event and clock='0' then          
            -- Pop Event
            if pop = '1' then
                if (stack_counter > 1) then
                    stack_counter <= stack_counter - 1;
                end if;
            
            -- Push Event
            elsif push = '1' then
                if (stack_counter < 19) then
                    stack_counter <= stack_counter + 1;           
                end if;
            
            -- Boundary Condition ( result can't be placed in reserved mem )
            elsif ((not (operation = none_s)) and stack_counter = 1) then
                stack_counter <= stack_counter + 1;
            end if;
        end if;
    end process;
               

end Behavioral;
