library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity spi_tb is
end spi_tb;

architecture behavior of spi_tb is

    -- Signals for SPI_top
    signal clk_10MHz : std_logic := '0';
    signal nReset : std_logic := '0';
    signal enable : std_logic := '0';
    signal valid : std_logic;
    signal ready : std_logic := '0';
    signal transmit : std_logic_vector(7 downto 0);
    signal receive : std_logic_vector(7 downto 0) := (others => '0');
    signal sclk : std_logic;
    signal MISO : std_logic := '0';
    signal MOSI : std_logic;
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

    -- Instantiate SPI_top
    uut : entity work.SPI_top
        port map (
            clk_10MHz => clk_10MHz,
            nReset => nReset,
            enable => enable,
            valid => valid,
            ready => ready,
            transmit => transmit,
            receive => receive,
            sclk => sclk,
            MISO => MISO,
            MOSI => MOSI,
            cs => cs
        );

    -- Testbench stimulus
    stim_proc: process
    begin
        -- Initialize Inputs
        nReset <= '0';
        enable <= '0';
        MISO <= '0';
        ready <= '0';
        wait for 100 ns;

        -- Apply reset
        nReset <= '1';
        wait for 100 ns;
        
        -- Provide data to be sent via MOSI
        receive <= "10101010";
        ready <= '1';
        wait for 100 ns;
        ready <= '0';

        -- Enable modules
        enable <= '1';
        wait for 200 ns;
        
        -- Simulate data reception on MISO
        MISO <= '1';
        wait for 100 ns;
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
