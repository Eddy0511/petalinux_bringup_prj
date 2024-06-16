library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

entity tb_bram_ctrl is
end tb_bram_ctrl;

architecture behavior of tb_bram_ctrl is

    -- Component Declaration for the Unit Under Test (UUT)
    component bram_ctrl
        port(
            clk_100MHz : in std_logic;
            nReset : in std_logic;
            valid : in std_logic;
            ready : out std_logic;
            addr_clr : in std_logic;
            read_data : out std_logic_vector(31 downto 0);
            bram_clka : out std_logic;
            bram_rsta : out std_logic;
            bram_wea : out std_logic_vector(3 downto 0);
            bram_ena : out std_logic;
            bram_addra : out std_logic_vector(31 downto 0);
            bram_read_dataa : in std_logic_vector(31 downto 0);
            bram_write_dataa : out std_logic_vector(31 downto 0)
        );
    end component;

    -- Inputs
    signal clk_100MHz : std_logic := '0';
    signal nReset : std_logic := '0';
    signal valid : std_logic := '0';
    signal addr_clr : std_logic := '0';

    -- Outputs
    signal ready : std_logic;
    signal read_data : std_logic_vector(31 downto 0);
    signal bram_clka : std_logic;
    signal bram_rsta : std_logic;
    signal bram_wea : std_logic_vector(3 downto 0);
    signal bram_ena : std_logic;
    signal bram_addra : std_logic_vector(31 downto 0);
    signal bram_read_dataa : std_logic_vector(31 downto 0) := (others => '0');
    signal bram_write_dataa : std_logic_vector(31 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: bram_ctrl
        port map (
            clk_100MHz => clk_100MHz,
            nReset => nReset,
            valid => valid,
            ready => ready,
            addr_clr => addr_clr,
            read_data => read_data,
            bram_clka => bram_clka,
            bram_rsta => bram_rsta,
            bram_wea => bram_wea,
            bram_ena => bram_ena,
            bram_addra => bram_addra,
            bram_read_dataa => bram_read_dataa,
            bram_write_dataa => bram_write_dataa
        );

    -- Clock process definitions
    clk_process : process
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
        wait for 20 ns;
        nReset <= '1';
        wait for clk_period*10;
        
        -- Insert stimulus here
        -- Test case 1: Basic read operation
        addr_clr <= '1';
        valid <= '1';
        wait for clk_period*2;
        addr_clr <= '0';
        wait for clk_period*5;
        valid <= '0';
        wait for clk_period*5;

        -- Add more test cases as needed
        
        wait;
    end process;

end behavior;
