library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity tranmitter is
    port
    (
        clk_100MHz : in std_logic;
        nReset : in std_logic;
        transmiter_en : in std_logic;
        drdy : in std_logic;
        ser_data : in std_logic_vector(31 downto 0);
        transmit : out std_logic_vector(7 downto 0);
        ready : out std_logic;
        ser_ready : out std_logic
    );
end tranmitter;

architecture RTL of tranmitter is
    type transmiter_state is (s0, s1, s2, s3, s4, s5);
    signal transmiter_state_reg : transmiter_state := s0;
    signal prev_drdy : std_logic;
    signal ser_state_cnt : std_logic_vector(2 downto 0);
    signal transmit_reg : std_logic_vector(7 downto 0);
    signal ready_reg : std_logic;
    signal ser_ready_reg : std_logic;
begin
    process(clk_100MHz, nReset)
    begin
        if nReset = '0' then
            transmit_reg <= (others => '0');
            ready_reg <= '0';
        elsif rising_edge(clk_100MHz) then
            case transmiter_state_reg is
                when s0 =>
                    ready_reg <= '0';
                    transmit_reg <= (others => '0');
                when s1 =>
                    ready_reg <= '1';
                    transmit_reg <= ser_data(7 downto 0);
                when s2 =>
                    ready_reg <= '1';
                    transmit_reg <= ser_data(15 downto 8);
                when s3 =>
                    ready_reg <= '1';
                    transmit_reg <= ser_data(23 downto 16);
                when s4 =>
                    ready_reg <= '1';
                    transmit_reg <= ser_data(31 downto 24);
                when s5 =>
                    ready_reg <= '0';
            end case;
        end if;
    end process;

    ready <= ready_reg;
    transmit <= transmit_reg;
    ser_ready <= ser_ready_reg;

    process(clk_100MHz, nReset)
    begin
        if nReset = '0' then
            transmiter_state_reg <= s0;
            ser_state_cnt <= "000";
            prev_drdy <= '0';
            ser_ready_reg <= '0';
        elsif rising_edge(clk_100MHz) then
            if transmiter_en = '1' then
                case ser_state_cnt is
                    when "000" =>
                        if drdy = '1' and prev_drdy = '0' then
                            transmiter_state_reg <= s1;
                            ser_state_cnt <= "001";
                        end if;
                    when "001" =>
                        if drdy = '1' and prev_drdy = '0' then
                            transmiter_state_reg <= s2;
                            ser_state_cnt <= "010";
                        end if;
                    when "010" =>
                        if drdy = '1' and prev_drdy = '0' then
                            transmiter_state_reg <= s3;
                            ser_state_cnt <= "011";
                        end if;
                    when "011" =>
                        ser_ready_reg <= '1';
                        if drdy = '1' and prev_drdy = '0' then
                            transmiter_state_reg <= s4;
                            ser_state_cnt <= "000";
                        end if;
                end case;
                prev_drdy <= drdy;
            end if;
        end if;
    end process;
end RTL;
