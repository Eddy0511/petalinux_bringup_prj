library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity receiver_tb is
end receiver_tb;

architecture behavior of receiver_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component receiver
    port(
        clk_100MHz : in std_logic;
        nReset : in std_logic;
        valid : in std_logic;
        ready : out std_logic;
        receive_count : in integer;
        bram_data : out std_logic_vector(31 downto 0);
        receive_data : in std_logic_vector(7 downto 0);
        drdy : in std_logic
    );
    end component;

    -- Signals to connect to the UUT
    signal clk_100MHz : std_logic := '0';
    signal nReset : std_logic := '0';
    signal valid : std_logic := '0';
    signal ready : std_logic;
    signal receive_count : integer := 0;
    signal bram_data : std_logic_vector(31 downto 0);
    signal receive_data : std_logic_vector(7 downto 0) := (others => '0');
    signal drdy : std_logic := '0';

    -- Clock period definitions
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: receiver Port map (
        clk_100MHz => clk_100MHz,
        nReset => nReset,
        valid => valid,
        ready => ready,
        receive_count => receive_count,
        bram_data => bram_data,
        receive_data => receive_data,
        drdy => drdy
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk_100MHz <= '0';
        wait for clk_period/2;
        clk_100MHz <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the system
        nReset <= '0';
        wait for clk_period*2;
        nReset <= '1';
        wait for clk_period*2;

        -- Initialize Inputs
        valid <= '0';
        receive_data <= x"00";
        drdy <= '0';

        -- Wait for global reset to finish
        wait for clk_period*10;

        -- Start the test
        -- Test Case 1: Receive 1 data
        receive_count <= 1;
        valid <= '1';
        wait for clk_period;
        valid <= '0';
        wait for clk_period*2;
        drdy <= '1';
        receive_data <= X"CA";
        wait for clk_period;
        drdy <= '0';
        wait for clk_period*2;

        -- Test Case 2: Receive 4 data
        receive_count <= 4;
        valid <= '1';
        wait for clk_period;
        valid <= '0';

        wait for clk_period*2;
        drdy <= '1';
        receive_data <= X"EF";
        wait for clk_period;
        drdy <= '0';

        wait for clk_period*2;
        drdy <= '1';
        receive_data <= X"BE";
        wait for clk_period;
        drdy <= '0';

        wait for clk_period*2;
        drdy <= '1';
        receive_data <= X"AD";
        wait for clk_period;
        drdy <= '0';

        wait for clk_period*2;
        drdy <= '1';
        receive_data <= X"DE";
        wait for clk_period;
        drdy <= '0';
        wait for clk_period*2;
        drdy <= '1';
        wait for clk_period*2;
        -- Stop the simulation
        wait;
    end process;

end behavior;
