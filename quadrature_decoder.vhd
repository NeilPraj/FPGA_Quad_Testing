library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity quadrature_decoder is
    generic(
        positions                 : integer := 128;
        debounce_time             : integer := 50_000;
        set_origin_debounce_time  : integer := 500_000
    );
    port(
        clk         : in  std_logic;
        a           : in  std_logic;
        b           : in  std_logic;
        reset_pos   : in  std_logic;
        direction   : out std_logic;
        position    : out integer range 0 to positions - 1;
		position_leds : out std_logic_vector(6 downto 0)	
    );
end quadrature_decoder;

architecture logic of quadrature_decoder is

    signal a_new                 : std_logic_vector(1 downto 0) := (others => '0');
    signal b_new                 : std_logic_vector(1 downto 0) := (others => '0');
    signal a_prev                : std_logic := '0';
    signal b_prev                : std_logic := '0';

    signal reset_new             : std_logic_vector(1 downto 0) := (others => '0');
    signal internal_origin_reset : std_logic := '0';
    signal reset_count           : integer range 0 to set_origin_debounce_time := 0;
    signal debounce_cnt          : integer range 0 to debounce_time := 0;
    signal pos_reg               : integer range 0 to positions - 1 := 0;
	 
	 signal pos_vec : std_logic_vector(6 downto 0); 

begin

    -- Drive the output port from our internal signal
    position <= pos_reg;

    process(clk)
    begin
        if rising_edge(clk) then

            ----------------------------------------------------------
            -- 1) Sync and debounce 'a' and 'b' quadrature inputs
            ----------------------------------------------------------
            a_new <= a_new(0) & a;   -- shift in new values of 'a'
            b_new <= b_new(0) & b;   -- shift in new values of 'b'

            -- If either 'a' or 'b' has changed, reset the debounce counter.
            if ((a_new(0) xor a_new(1)) = '1') or ((b_new(0) xor b_new(1)) = '1') then
                debounce_cnt <= 0;
            elsif debounce_cnt = debounce_time then
                -- Once the debounce time has been met, finalize the stable inputs
                a_prev <= a_new(1);
                b_prev <= b_new(1);
            else
                debounce_cnt <= debounce_cnt + 1;
            end if;

            ----------------------------------------------------------
            -- 2) Sync and debounce the reset signal
            ----------------------------------------------------------
            reset_new <= reset_new(0) & reset_pos; -- shift in new values of reset
            if (reset_new(0) xor reset_new(1)) = '1' then
                reset_count <= 0;   -- reset is changing, clear the debounce counter
            elsif reset_count = set_origin_debounce_time then
                -- Once the debounce time is met, update the internal reset
                internal_origin_reset <= reset_new(1);
            else
                reset_count <= reset_count + 1;
            end if;

            ----------------------------------------------------------
            -- 3) Determine direction and update position
            ----------------------------------------------------------
            if internal_origin_reset = '0' then
                -- If reset was asserted, force position to zero
                pos_reg <= 0;

            elsif (debounce_cnt = debounce_time) and
                  ( ((a_prev xor a_new(1)) = '1') or ((b_prev xor b_new(1)) = '1') ) then

                -- A change was detected, and debounce time has been met
                direction <= b_prev xor a_new(1);

                if (b_prev xor a_new(1)) = '1' then
                    -- Clockwise direction
                    if pos_reg < (positions - 1) then
                        pos_reg <= pos_reg + 1;
                    else
                        pos_reg <= 0;
                    end if;
                else
                    -- Counterclockwise direction
                    if pos_reg > 0 then
                        pos_reg <= pos_reg - 1;
                    else
                        pos_reg <= positions - 1;
                    end if;
                end if;
            end if;

        end if;
    end process;

    -- Combinational logic to convert position to LED output
    pos_vec <= std_logic_vector(to_unsigned(pos_reg, 7));
    position_leds <= pos_vec;

end logic;
