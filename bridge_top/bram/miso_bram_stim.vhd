library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity bram_ctrl_tb is
end bram_ctrl_tb;

architecture tb of bram_ctrl_tb is
    signal clk_100MHz : std_logic := '0';
    signal nReset : std_logic := '0';

    signal valid : std_logic := '0';
    signal ready : std_logic;
    signal addr_clr : std_logic := '0';

    signal write_data : std_logic_vector(31 downto 0) := (others => '0');

    signal bram_clka : std_logic;
    signal bram_rsta : std_logic;
    signal bram_wea : std_logic_vector(3 downto 0);
    signal bram_ena : std_logic;
    signal bram_addra : std_logic_vector(31 downto 0);
    signal bram_write_dataa : std_logic_vector(31 downto 0);

    constant clk_period : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: entity miso_bram_ctrl
        port map (
            clk_100MHz => clk_100MHz,
            nReset => nReset,
            valid => valid,
            ready => ready,
            addr_clr => addr_clr,
            write_data => write_data,
            bram_clka => bram_clka,
            bram_rsta => bram_rsta,
            bram_wea => bram_wea,
            bram_ena => bram_ena,
            bram_addra => bram_addra,
            bram_write_dataa => bram_write_dataa
        );

    -- Clock generation
    clk_process : process
    begin
        clk_100MHz <= '0';
        wait for clk_period / 2;
        clk_100MHz <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize Inputs
        nReset <= '0';
        valid <= '0';
        addr_clr <= '0';
        write_data <= (others => '0');
        wait for clk_period * 10;

        -- Apply reset
        nReset <= '1';
        wait for clk_period * 10;

        -- Test case 1: Write data with addr_clr
        addr_clr <= '1';
        write_data <= x"DEADBEEF";
        valid <= '1';
        wait for clk_period * 10;
        valid <= '0';
        addr_clr <= '0';
        wait for clk_period * 10;

        -- Test case 2: Write more data
        write_data <= x"CAFEBABE";
        valid <= '1';
        wait for clk_period * 10;
        valid <= '0';
        wait for clk_period * 10;

        -- Test case 3: Write additional data without clearing address
        write_data <= x"12345678";
        valid <= '1';
        wait for clk_period * 10;
        valid <= '0';
        wait for clk_period * 10;

        -- Wait and observe the outputs
        wait for clk_period * 100;

        -- End simulation
        wait;
    end process;

end tb;
