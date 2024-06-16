library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity tb_top is
end tb_top;

architecture sim of tb_top is

    -- Component under test
    component top
        port (
            clk_100MHz : in std_logic;
            clk_10MHz : in std_logic;
            nReset : in std_logic;
            enable : in std_logic
        );
    end component;

    -- Signals for the DUT
    signal clk_100MHz : std_logic := '0';
    signal clk_10MHz : std_logic := '0';
    signal nReset : std_logic := '0';
    signal enable : std_logic := '0';

    -- Clock period definitions
    constant clk_100MHz_period : time := 10 ns; -- 100MHz clock
    constant clk_10MHz_period : time := 100 ns; -- 10MHz clock

begin

    -- Instantiate the DUT
    uut: top
        port map (
            clk_100MHz => clk_100MHz,
            clk_10MHz => clk_10MHz,
            nReset => nReset,
            enable => enable
        );

    -- Clock process for clk_100MHz
    clk_100MHz_process :process
    begin
        clk_100MHz <= '0';
        wait for clk_100MHz_period/2;
        clk_100MHz <= '1';
        wait for clk_100MHz_period/2;
    end process;

    -- Clock process for clk_10MHz
    clk_10MHz_process :process
    begin
        clk_10MHz <= '0';
        wait for clk_10MHz_period/2;
        clk_10MHz <= '1';
        wait for clk_10MHz_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the system
        nReset <= '0';
        wait for 20 ns;        
        nReset <= '1';
        wait for 20 ns;
        
        -- Enable the system
        enable <= '1';
        wait for 500 ns; -- Wait for some time to observe behavior

        -- Disable the system
        enable <= '0';
        wait for 500 ns;

        -- Finish simulation
        wait;
    end process;

end sim;
