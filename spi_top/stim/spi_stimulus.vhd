library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity tb_SPI_MODULE is
end tb_SPI_MODULE;

architecture testbench of tb_SPI_MODULE is

    -- Component Declaration for the Unit Under Test (UUT)
    component SPI_MODULE is
        Port (
            clk_10MHz : in std_logic;
            nReset : in std_logic;
            enable : in std_logic;
            sclk : out std_logic;
            cs : out std_logic
        );
    end component;

    -- Signals for connecting to the UUT
    signal clk_10MHz : std_logic := '0';
    signal nReset : std_logic := '0';
    signal enable : std_logic := '0';
    signal sclk : std_logic;
    signal cs : std_logic;

    -- Clock period definitions
    constant clk_period : time := 100 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: SPI_MODULE
        Port map (
            clk_10MHz => clk_10MHz,
            nReset => nReset,
            enable => enable,
            sclk => sclk,
            cs => cs
        );

    -- Clock process definitions
    clk_process :process
    begin
        clk_10MHz <= '0';
        wait for clk_period/2;
        clk_10MHz <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- hold reset state for 100 ns.
        nReset <= '0';
        wait for 100 ns;

        nReset <= '1';
        wait for clk_period;

        -- Enable SPI module
        enable <= '1';
        wait for 10 * clk_period; -- Wait for some cycles

        -- Disable SPI module
        enable <= '0';
        wait for 10 * clk_period; -- Wait for some cycles

        -- Re-enable SPI module
        enable <= '1';
        wait for 10 * clk_period; -- Wait for some cycles

        -- Finish the simulation
        wait;
    end process;

end testbench;
