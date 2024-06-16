library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity mosi_module_tb is
--  Entity for testbench does not have any ports
end mosi_module_tb;

architecture TB of mosi_module_tb is

    -- Component declaration for the Unit Under Test (UUT)
    component mosi_module is
        port
        (
            clk_10MHz : in std_logic;
            nReset : in std_logic;
            enable : in std_logic;
            ready : in std_logic;
            receive : in std_logic_vector(7 downto 0);
            MOSI : out std_logic
        );
    end component;

    -- Clock period definitions
    constant clk_period : time := 100 ns; -- 10 MHz

    -- Testbench signals
    signal clk_10MHz : std_logic := '0';
    signal nReset : std_logic := '0';
    signal enable : std_logic := '0';
    signal ready : std_logic := '0';
    signal receive : std_logic_vector(7 downto 0) := (others => '0');
    signal MOSI : std_logic := '0';

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: mosi_module
        port map (
            clk_10MHz => clk_10MHz,
            nReset => nReset,
            enable => enable,
            ready => ready,
            receive => receive,
            MOSI => MOSI
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
        ready <= '0';
        receive <= "10101010";
        wait for 20 ns;

        -- Load data into the receive register
        ready <= '1';
        wait for clk_period;
        ready <= '0';
        wait for clk_period;

        -- Enable the MOSI module
        enable <= '1';
        wait for clk_period;
        
        -- Disable the MOSI module
        enable <= '0';

        -- Wait for the operation to complete
        wait for 200 ns;

        -- Check output data
        -- In this simple test, we will just print the MOSI values during the process
        -- The actual verification might involve comparing expected values with MOSI
        
        -- End of simulation
        wait;
    end process;

end TB;
