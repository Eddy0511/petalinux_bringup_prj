library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity tranmitter is
    port
    (
        clk_100MHz : in std_logic;
        nReset : in std_logic;

        valid : in std_logic;
        ready : out std_logic;

        complete : out std_logic;
        transmit_count : in integer;

        bram_data : in std_logic_vector(31 downto 0);
        transmit_data : out std_logic_vector(7 downto 0);

        drdy : in std_logic;
        latch : out std_logic
    );
end tranmitter;


architecture RTL of tranmitter is

type transmit_state is (idle, s1, s2, s3, s4, done);

signal ready_reg : std_logic;
signal transmit_state_reg : transmit_state := idle;
signal bram_data_one_word_reg : std_logic_vector(7 downto 0);
signal bram_data_two_word_reg    : std_logic_vector(7 downto 0);
signal bram_data_three_word_reg  : std_logic_vector(7 downto 0); 
signal bram_data_four_word_reg   : std_logic_vector(7 downto 0); 
signal complete_reg : std_logic;
signal transmit_count_reg : integer;
signal latch_reg  : std_logic;
signal prev_drdy : std_logic;

begin

process(clk_100MHz, nReset)
begin
    if nReset = '0' then
        ready_reg <= '0';
        complete_reg <= '0';
        transmit_count_reg <= 0;
        prev_drdy <= '1';
        latch_reg <= '0';
        bram_data_one_word_reg <= (others => '0');
        bram_data_two_word_reg <= (others => '0');
        bram_data_three_word_reg  <= (others => '0');
        bram_data_four_word_reg <= (others => '0');
        transmit_data <= (others => '0');
    elsif rising_edge(clk_100MHz) then
        case transmit_state_reg is
            when idle =>
                if valid = '1' and transmit_count > 0 and transmit_count < 5 then
                    ready_reg <= '1';
                    complete_reg <= '0';
                    transmit_count_reg <= transmit_count;
                    bram_data_one_word_reg <= bram_data(7 downto 0);
                    bram_data_two_word_reg <= bram_data(15 downto 8);
                    bram_data_three_word_reg <= bram_data(23 downto 16);
                    bram_data_four_word_reg <= bram_data(31 downto 24);
                    transmit_state_reg <= s1;
                end if;
            when s1 =>
                transmit_data <= bram_data_one_word_reg;
                latch_reg <= '1';
                if transmit_count_reg = 1 then
                    transmit_state_reg <= done;
                else
                    transmit_state_reg <= s2;
                end if;
            when s2 =>
                if drdy = '1' and prev_drdy = '0' then
                    transmit_data <= bram_data_two_word_reg;
                    latch_reg <= '1';
                    if transmit_count_reg = 2 then
                        transmit_state_reg <= done;
                    else
                        transmit_state_reg <= s3;
                    end if; 
                end if;
            when s3 =>
                if drdy = '1' and prev_drdy = '0' then
                    transmit_data <= bram_data_three_word_reg;
                    latch_reg <= '1';
                    if transmit_count_reg = 3 then
                        transmit_state_reg <= done;
                    else
                        transmit_state_reg <= s4;
                    end if;
                end if;
            when s4 =>
                if drdy = '1' and prev_drdy = '0' then
                    transmit_data <= bram_data_four_word_reg;
                    latch_reg <= '1';
                    transmit_state_reg <= done;
                end if;
            when done =>
                complete_reg <= '1';
                if valid = '0' then
                    ready_reg <= '0';
                    transmit_state_reg <= idle;
                end if;
            when others =>
                null;
        end case;
        prev_drdy <= drdy;
    end if;
end process;

ready <= ready_reg;
complete <= complete_reg;
latch <= latch_reg;

end RTL;