library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity DPRAM_CTLR_tb is
end DPRAM_CTLR_tb;

architecture Behavioral of DPRAM_CTLR_tb is
    -- Component declaration for the Unit Under Test (UUT)
    component DPRAM_CTLR
        Port (
            RST                : in std_logic;
            CLK_10MHz          : in std_logic;
            BRAM_EN            : in std_logic;
            BRAM_W_R           : in std_logic;
            BRAM_WR_DATA       : in std_logic_vector(31 downto 0);
            BRAM_RD_DATA       : out std_logic_vector(31 downto 0);
            BRAM_CLK           : out std_logic;
            BRAM_WE            : out std_logic_vector(3 downto 0);
            BRAM_ENA           : out std_logic;
            BRAM_ADDR          : out std_logic_vector(31 downto 0);
            BRAM_DATA_WRITE    : out std_logic_vector(31 downto 0);
            BRAM_DATA_READ     : in std_logic_vector(31 downto 0)
        );
    end component;
    
    -- Signal declarations
    signal RST          : std_logic := '1';
    signal CLK_10MHz    : std_logic := '0';
    signal BRAM_EN      : std_logic := '0';
    signal BRAM_W_R     : std_logic := '0';
    signal BRAM_WR_DATA : std_logic_vector(31 downto 0) := (others => '0');
    signal BRAM_RD_DATA : std_logic_vector(31 downto 0);
    signal BRAM_CLK     : std_logic;
    signal BRAM_WE      : std_logic_vector(3 downto 0);
    signal BRAM_ENA     : std_logic;
    signal BRAM_ADDR    : std_logic_vector(31 downto 0);
    signal BRAM_DATA_WRITE : std_logic_vector(31 downto 0);
    signal BRAM_DATA_READ  : std_logic_vector(31 downto 0) := (others => '0');

    -- Clock generation
    constant clk_period : time := 100 ns; -- 10 MHz clock period

    -- Procedure to apply reset
    procedure apply_reset(signal rst : out std_logic) is
    begin
        rst <= '0';
        wait for 50 ns;
        rst <= '1';
        wait for 50 ns;
    end procedure;
    
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: DPRAM_CTLR
        Port map (
            RST           => RST,
            CLK_10MHz     => CLK_10MHz,
            BRAM_EN       => BRAM_EN,
            BRAM_W_R      => BRAM_W_R,
            BRAM_WR_DATA  => BRAM_WR_DATA,
            BRAM_RD_DATA  => BRAM_RD_DATA,
            BRAM_CLK      => BRAM_CLK,
            BRAM_WE       => BRAM_WE,
            BRAM_ENA      => BRAM_ENA,
            BRAM_ADDR     => BRAM_ADDR,
            BRAM_DATA_WRITE => BRAM_DATA_WRITE,
            BRAM_DATA_READ  => BRAM_DATA_READ
        );

    -- Clock process
    clk_process : process
    begin
        CLK_10MHz <= '0';
        wait for clk_period/2;
        CLK_10MHz <= '1';
        wait for clk_period/2;
    end process;

    -- Testbench stimulus
    stim_proc: process
    begin
        -- Apply reset
        apply_reset(RST);

        -- Enable BRAM and write data
        BRAM_EN <= '1';
        BRAM_W_R <= '1'; -- Write operation
        BRAM_WR_DATA <= x"DEADBEEF";
        wait for clk_period;
        
        BRAM_EN <= '0';
        wait for clk_period;
        BRAM_EN <= '1';
        -- Read data
        BRAM_W_R <= '0'; -- Read operation
        BRAM_DATA_READ <= x"DEADBEEF"; -- Simulate BRAM read data
        wait for clk_period;

        -- Disable BRAM
        BRAM_EN <= '0';
        wait for clk_period;

        -- End simulation
        wait;
    end process;
end Behavioral;
