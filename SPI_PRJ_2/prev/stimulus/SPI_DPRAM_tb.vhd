library IEEE;
library work;
use work.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_SPIDPRAM is
end tb_SPIDPRAM;

architecture Behavioral of tb_SPIDPRAM is

    -- Component Declaration for the Unit Under Test (UUT)
    component SPIDPRAM
        Port (
            RST                     : in std_logic;
            CLK_10MHz               : in std_logic;
            BRAM_REN                : in std_logic;
            BRAM_WEN                : in std_logic;
            SPI_WR_DATA             : in std_logic_vector(31 downto 0);
            SPI_RD_DATA             : out std_logic_vector(31 downto 0);

            -- Write port
            SPI_BRAM_CLKA           : out std_logic;
            SPI_BRAM_WE_A           : out std_logic_vector(3 downto 0);
            SPI_BRAM_ENA_A          : out std_logic;
            SPI_BRAM_ADDRA          : out std_logic_vector(31 downto 0);
            SPI_BRAM_DATA_A_WRITE   : out std_logic_vector(31 downto 0);
            SPI_BRAM_DATA_A_READ    : in std_logic_vector(31 downto 0);

            -- Read port
            SPI_BRAM_CLKB           : out std_logic;
            SPI_BRAM_WE_B           : out std_logic_vector(3 downto 0);
            SPI_BRAM_ENA_B          : out std_logic;
            SPI_BRAM_ADDRB          : out std_logic_vector(31 downto 0);
            SPI_BRAM_DATA_B_WRITE   : out std_logic_vector(31 downto 0);
            SPI_BRAM_DATA_B_READ    : in std_logic_vector(31 downto 0)
        );
    end component;

    -- Inputs
    signal RST                : std_logic := '1';
    signal CLK_10MHz          : std_logic := '0';
    signal BRAM_REN           : std_logic := '0';
    signal BRAM_WEN           : std_logic := '0';
    signal SPI_WR_DATA        : std_logic_vector(31 downto 0) := (others => '0');

    -- Outputs
    signal SPI_RD_DATA        : std_logic_vector(31 downto 0);

    -- Internal signals for BRAM ports
    signal SPI_BRAM_CLKA       : std_logic;
    signal SPI_BRAM_WE_A       : std_logic_vector(3 downto 0);
    signal SPI_BRAM_ENA_A      : std_logic;
    signal SPI_BRAM_ADDRA      : std_logic_vector(31 downto 0);
    signal SPI_BRAM_DATA_A_WRITE : std_logic_vector(31 downto 0);
    signal SPI_BRAM_DATA_A_READ : std_logic_vector(31 downto 0) := (others => '0');

    signal SPI_BRAM_CLKB       : std_logic;
    signal SPI_BRAM_WE_B       : std_logic_vector(3 downto 0);
    signal SPI_BRAM_ENA_B      : std_logic;
    signal SPI_BRAM_ADDRB      : std_logic_vector(31 downto 0);
    signal SPI_BRAM_DATA_B_WRITE : std_logic_vector(31 downto 0);
    signal SPI_BRAM_DATA_B_READ : std_logic_vector(31 downto 0) := (others => '0');

    -- Clock period definitions
    constant clk_period : time := 100 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: SPIDPRAM
    Port map (
        RST => RST,
        CLK_10MHz => CLK_10MHz,
        BRAM_REN => BRAM_REN,
        BRAM_WEN => BRAM_WEN,
        SPI_WR_DATA => SPI_WR_DATA,
        SPI_RD_DATA => SPI_RD_DATA,

        SPI_BRAM_CLKA => SPI_BRAM_CLKA,
        SPI_BRAM_WE_A => SPI_BRAM_WE_A,
        SPI_BRAM_ENA_A => SPI_BRAM_ENA_A,
        SPI_BRAM_ADDRA => SPI_BRAM_ADDRA,
        SPI_BRAM_DATA_A_WRITE => SPI_BRAM_DATA_A_WRITE,
        SPI_BRAM_DATA_A_READ => SPI_BRAM_DATA_A_READ,

        SPI_BRAM_CLKB => SPI_BRAM_CLKB,
        SPI_BRAM_WE_B => SPI_BRAM_WE_B,
        SPI_BRAM_ENA_B => SPI_BRAM_ENA_B,
        SPI_BRAM_ADDRB => SPI_BRAM_ADDRB,
        SPI_BRAM_DATA_B_WRITE => SPI_BRAM_DATA_B_WRITE,
        SPI_BRAM_DATA_B_READ => SPI_BRAM_DATA_B_READ
    );

    -- Clock process definitions
    clk_process :process
    begin
        CLK_10MHz <= '0';
        wait for clk_period/2;
        CLK_10MHz <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin		
        -- hold reset state for 100 ns.
        wait for 100 ns;	
        RST <= '0';
        wait for clk_period*2;
        RST <= '1';
        
        -- Write data to address 0x00000000
        BRAM_WEN <= '1';
        SPI_WR_DATA <= X"DEADBEEF";
        wait for clk_period;
        BRAM_WEN <= '0';
        
        BRAM_WEN <= '1';
        SPI_WR_DATA <= X"BEEFDEAD";
        wait for clk_period;
        BRAM_WEN <= '0';
        
        -- Read data from address 0x00000000
        BRAM_REN <= '1';
        wait for clk_period;
        BRAM_REN <= '0';
        
        -- Wait for some time to observe the output
        wait for clk_period*10;

        -- Write data to address 0x00000001
        BRAM_WEN <= '1';
        SPI_WR_DATA <= X"C0FFEE00";
        wait for clk_period;
        BRAM_WEN <= '0';
        
        -- Read data from address 0x00000001
        BRAM_REN <= '1';
        wait for clk_period;
        BRAM_REN <= '0';

        -- Wait for some time to observe the output
        wait for clk_period*10;
        
        -- Finish the simulation
        wait;
    end process;

end Behavioral;
