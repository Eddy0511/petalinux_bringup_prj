library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_tranmitter is
end tb_tranmitter;

architecture test of tb_tranmitter is
    -- Component declaration for the unit under test (UUT)
    component tranmitter
        port(
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
    end component;

    -- Testbench signals
    signal clk_100MHz : std_logic := '0';
    signal nReset : std_logic := '0';
    signal valid : std_logic := '0';
    signal ready : std_logic;
    signal complete : std_logic;
    signal transmit_count : integer := 0;
    signal bram_data : std_logic_vector(31 downto 0) := (others => '0');
    signal transmit_data : std_logic_vector(7 downto 0);
    signal drdy : std_logic := '0';
    signal latch : std_logic;

    -- Clock generation
    constant clk_period : time := 10 ns;
begin

    -- Instantiate the Unit Under Test (UUT)
    uut: tranmitter
        port map (
            clk_100MHz => clk_100MHz,
            nReset => nReset,
            valid => valid,
            ready => ready,
            complete => complete,
            transmit_count => transmit_count,
            bram_data => bram_data,
            transmit_data => transmit_data,
            drdy => drdy,
            latch => latch
        );

    -- Clock process
    clk_process : process
    begin
        while True loop
            clk_100MHz <= '0';
            wait for clk_period / 2;
            clk_100MHz <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize inputs
        nReset <= '0';
        wait for 20 ns;
        
        nReset <= '1';
        wait for 20 ns;
        
        -- Test case: Transmit a single word
        valid <= '1';
        transmit_count <= 1;
        bram_data <= X"DEADBEEF";
        drdy <= '1';
        wait for clk_period;
        
        drdy <= '0';
        wait for clk_period * 2;
        
        drdy <= '1';
        wait for clk_period;
        
        -- Check for completion
        wait until complete = '1';
        
        -- Test case: Transmit multiple words
        valid <= '0';
        wait for clk_period * 5;
        
        valid <= '1';
        transmit_count <= 4;
        bram_data <= X"CAFEBABE";
        drdy <= '1';
        wait for clk_period;
        
        drdy <= '0';
        wait for clk_period * 2;
        
        drdy <= '1';
        wait for clk_period;
        
        -- Check for completion
        wait until complete = '1';

        -- End of simulation
        wait;
    end process;
end architecture test;
