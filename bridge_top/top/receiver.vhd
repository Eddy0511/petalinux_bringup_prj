library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity receiver is
    port
    (
        clk_100MHz : in std_logic;
        nReset : in std_logic;

        valid : in std_logic;
        ready : out std_logic;

        receive_count : in integer;

        bram_data : out std_logic_vector(31 downto 0);
        receive_data : in std_logic_vector(7 downto 0);

        drdy : in std_logic
    );
end receiver;


architecture RTL of receiver is

type receive_state is (idle, s1, s2, s3, s4, done);

signal ready_reg : std_logic;
signal receive_state_reg : receive_state := idle;
signal bram_data_one_word_reg : std_logic_vector(7 downto 0);
signal bram_data_two_word_reg    : std_logic_vector(7 downto 0);
signal bram_data_three_word_reg  : std_logic_vector(7 downto 0); 
signal bram_data_four_word_reg   : std_logic_vector(7 downto 0); 
signal bram_data_reg              : std_logic_vector(31 downto 0);
signal receive_count_reg        : integer;
signal prev_drdy : std_logic;

begin

process(clk_100MHz, nReset)
begin
    if nReset = '0' then
        prev_drdy <= '1';
        ready_reg <= '0';
        receive_count_reg <= 0;
        bram_data_one_word_reg <= (others => '0');
        bram_data_two_word_reg <= (others => '0');
        bram_data_three_word_reg  <= (others => '0');
        bram_data_four_word_reg <= (others => '0');
        bram_data_reg <= (others => '0');
    elsif rising_edge(clk_100MHz) then
        case receive_state_reg is
            when idle =>
                bram_data_one_word_reg <= (others => '0');
                bram_data_two_word_reg <= (others => '0');
                bram_data_three_word_reg  <= (others => '0');
                bram_data_four_word_reg <= (others => '0');
                if valid = '1' then
                    receive_count_reg <= receive_count;
                    ready_reg <= '1';
                    receive_state_reg <= s1;
                end if;
            when s1 =>
                if drdy = '1' and prev_drdy = '0' then
                    bram_data_one_word_reg <= receive_data;
                    if receive_count_reg = 1 then
                        receive_state_reg <= done;
                    else
                        receive_state_reg <= s2;
                    end if;
                end if;
            when s2 =>
                if drdy = '1' and prev_drdy = '0' then
                    bram_data_two_word_reg <= receive_data;
                    if receive_count_reg = 2 then
                        receive_state_reg <= done;
                    else
                        receive_state_reg <= s3;
                    end if;
                end if;
            when s3 =>
                if drdy = '1' and prev_drdy = '0' then
                    bram_data_three_word_reg <= receive_data;
                    if receive_count_reg = 3 then
                        receive_state_reg <= done;
                    else
                        receive_state_reg <= s4;
                    end if;
                end if;
            when s4 =>
                if drdy = '1' and prev_drdy = '0' then
                    bram_data_four_word_reg <= receive_data;
                    receive_state_reg <= done;
                end if;    
            when done =>
                bram_data_reg(31 downto 24) <= bram_data_four_word_reg;
                bram_data_reg(23 downto 16) <= bram_data_three_word_reg;
                bram_data_reg(15 downto 8) <= bram_data_two_word_reg;
                bram_data_reg(7 downto 0) <= bram_data_one_word_reg;
                if valid = '0' then
                    ready_reg <= '0';
                    receive_state_reg <= idle;
                end if;
            when others =>
                null;
        end case;
        prev_drdy <= drdy;
    end if;
end process;

ready <= ready_reg;
bram_data <= bram_data_reg;

end RTL;