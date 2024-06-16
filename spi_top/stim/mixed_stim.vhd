library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity spi_tb is
end spi_tb;

architecture behavior of spi_tb is

    -- Signals for miso_module
    signal clk_10MHz : std_logic := '0';
    signal nReset : std_logic := '0';
    signal enable : std_logic := '0';
    signal miso_ready : std_logic;
    signal mosi_ready : std_logic:= '0';
    signal transmit : std_logic_vector(7 downto 0);
    signal MISO : std_logic := '0';

    -- Signals for mosi_module
    signal receive : std_logic_vector(7 downto 0) := (others => '0');
    signal MOSI : std_logic;

    -- Signals for SPI_MODULE
    signal sclk : std_logic;
    signal cs : std_logic;

begin

    -- Clock generation
    clk_process :process
    begin
        clk_10MHz <= '0';
        wait for 50 ns;
        clk_10MHz <= '1';
        wait for 50 ns;
    end process;

    -- Instantiate miso_module
    uut_miso : entity work.miso_module
        port map (
            clk_10MHz => clk_10MHz,
            nReset => nReset,
            enable => enable,
            ready => miso_ready,
            transmit => transmit,
            MISO => MISO
        );

    -- Instantiate mosi_module
    uut_mosi : entity work.mosi_module
        port map (
            clk_10MHz => clk_10MHz,
            nReset => nReset,
            enable => enable,
            ready => mosi_ready,
            receive => receive,
            MOSI => MOSI
        );

    -- Instantiate SPI_MODULE
    uut_spi : entity work.SPI_MODULE
        port map (
            clk_10MHz => clk_10MHz,
            nReset => nReset,
            enable => enable,
            sclk => sclk,
            cs => cs
        );

    -- Testbench stimulus
    stim_proc: process
    begin
        -- Initialize Inputs
        nReset <= '0';
        enable <= '0';
        MISO <= '0';
        wait for 100 ns;

        -- Apply reset
        nReset <= '1';
        wait for 100 ns;
        receive <= x"de";
        mosi_ready <= '1';
        wait for 100 ns;
        mosi_ready <= '0';
        wait for 100 ns;

        -- Enable modules
        enable <= '1';
        wait for 500 ns;

        -- Simulate data reception on MISO
        MISO <= '1';
        wait for 100 ns;
        MISO <= '0';
        wait for 100 ns;
        MISO <= '1';
        receive <= x"AD";
        mosi_ready <= '1';
        wait for 100 ns;
        mosi_ready <= '0';
        MISO <= '0';
        wait for 100 ns;
        MISO <= '1';
        wait for 100 ns;
        MISO <= '0';
        wait for 100 ns;
        MISO <= '1';
        wait for 100 ns;
        MISO <= '0';
        wait for 100 ns;

        -- Disable enable signal
        enable <= '0';
        wait for 500 ns;

        -- Stop the simulation
        wait;
    end process;

end behavior;
