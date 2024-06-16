library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity miso_module_tb is
--  Entity for testbench does not have any ports
end miso_module_tb;

architecture TB of miso_module_tb is

    -- Component declaration for the Unit Under Test (UUT)
    component miso_module is
        port
        (
            clk_10MHz : in std_logic;
            nReset : in std_logic;
            enable : in std_logic;
            ready : out std_logic;
            transmit : out std_logic_vector(7 downto 0);
            MISO : in std_logic
        );
    end component;

    -- Clock period definitions
    constant clk_period : time := 100 ns; -- 10 MHz

    -- Testbench signals
    signal clk_10MHz : std_logic := '0';
    signal nReset : std_logic := '0';
    signal enable : std_logic := '0';
    signal ready : std_logic;
    signal transmit : std_logic_vector(7 downto 0);
    signal MISO : std_logic := '0';

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: miso_module
        port map (
            clk_10MHz => clk_10MHz,
            nReset => nReset,
            enable => enable,
            ready => ready,
            transmit => transmit,
            MISO => MISO
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
        -- Reset the design
        nReset <= '0';
        wait for 20 ns;
        nReset <= '1';
        wait for 20 ns;

        -- Initialize inputs
        enable <= '0';
        wait for 20 ns;

        -- Enable the MISO module
        enable <= '1';
        -- Simulate MISO data
        wait for clk_period;
        MISO <= '1';
        wait for clk_period;
        MISO <= '0';
        wait for clk_period;
        MISO <= '1';
        wait for clk_period;
        MISO <= '0';
        wait for clk_period;
        MISO <= '1';
        wait for clk_period;
        MISO <= '0';
        wait for clk_period;
        MISO <= '1';
        wait for clk_period;
        MISO <= '0';
        wait for clk_period;

        -- Disable the MISO module
        enable <= '0';
        wait for clk_period;

        -- Wait for the operation to complete
        wait for 200 ns;

        -- Check output data
        assert transmit = "10101010"
        report "Test failed: transmit does not match expected value"
        severity error;

        -- End of simulation
        wait;
    end process;

end TB;
