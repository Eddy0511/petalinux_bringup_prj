library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity bridge_tb is
end bridge_tb;

architecture TB of bridge_tb is

    -- Signals to connect to the bridge entity
    signal clk_100MHz : std_logic := '0';
    signal clk_10MHz : std_logic := '0';
    signal nReset : std_logic := '0';
    signal wordcount : std_logic_vector(31 downto 0);
    signal enable : std_logic := '0';
    signal busy : std_logic;
    signal complete : std_logic;
    signal valid : std_logic := '0';
    signal ready : std_logic;
    signal drdy : std_logic := '0';
    signal receive : std_logic_vector(7 downto 0) := (others => '0');
    signal transmit : std_logic_vector(7 downto 0);
    signal ser_BRAM_CLKA : std_logic;
    signal ser_BRAM_ENA_A : std_logic;
    signal ser_bram_we_a : std_logic_vector(3 downto 0);
    signal ser_BRAM_ADDRA : std_logic_vector(31 downto 0);
    signal ser_BRAM_DATA_A_READ : std_logic_vector(31 downto 0) := (others => '0');
    signal ser_BRAM_DATA_A_write : std_logic_vector(31 downto 0);
    signal par_BRAM_CLKb : std_logic;
    signal par_BRAM_ENA_b : std_logic;
    signal par_bram_we_b : std_logic_vector(3 downto 0);
    signal par_BRAM_ADDRB : std_logic_vector(31 downto 0);
    signal par_BRAM_DATA_B_WRITE : std_logic_vector(31 downto 0);

    -- Clock period definition
    constant clk_period_100MHz : time := 10 ns;
    constant clk_period_10MHz : time := 100 ns;

    component bridge is
        port
        (
            clk_100MHz : in std_logic;
            nReset : in std_logic;

            -- axi modules interface
            wordcount : in std_logic_vector(31 downto 0);
            enable    : in std_logic;
            busy      : out std_logic;
            complete  : out std_logic;

            -- spi modules interface
            valid : in std_logic;
            ready : out std_logic;
            drdy : in std_logic;

            receive : in std_logic_vector(7 downto 0);
            transmit : out std_logic_vector(7 downto 0);

            -- bram interface for mosi
            ser_BRAM_CLKA 		        : out std_logic;
            ser_BRAM_ENA_A		        : out std_logic;
            ser_bram_we_a               : out std_logic_vector(3 downto 0);
            ser_BRAM_ADDRA              : out std_logic_vector(31 downto 0);
            ser_BRAM_DATA_A_READ        : in std_logic_vector(31 downto 0);
            ser_BRAM_DATA_A_write       : out std_logic_vector(31 downto 0);

            -- bram interface for miso
            par_BRAM_CLKb 		        : out std_logic;
            par_BRAM_ENA_b		        : out std_logic;
            par_bram_we_b               : out std_logic_vector(3 downto 0);
            par_BRAM_ADDRB              : out std_logic_vector(31 downto 0);
            -- not used read bus in miso modules
            par_BRAM_DATA_B_WRITE       : out std_logic_vector(31 downto 0)
        );
    end component;


    component SPI_MODULE is
        Port (
            clk_10MHz : in std_logic;
            nReset : in std_logic;
            enable : in std_logic;
            sclk : out std_logic;
            cs : out std_logic
        );
    end component;

    component mosi_module is
        port
        (
            clk_10MHz : in std_logic;
            nReset : in std_logic;
            enable : in std_logic;
            ready : in std_logic;
            drdy : out std_logic;
            receive : in std_logic_vector(7 downto 0);
            MOSI : out std_logic
        );
    end component;

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

begin

    -- Instantiate the bridge entity
    bridge_inst : bridge
        port map (
            clk_100MHz => clk_100MHz,
            nReset => nReset,
            wordcount => wordcount,
            enable => enable,
            busy => busy,
            complete => complete,
            valid => valid,
            ready => ready,
            drdy => drdy,
            receive => receive,
            transmit => transmit,
            ser_BRAM_CLKA => ser_BRAM_CLKA,
            ser_BRAM_ENA_A => ser_BRAM_ENA_A,
            ser_bram_we_a => ser_bram_we_a,
            ser_BRAM_ADDRA => ser_BRAM_ADDRA,
            ser_BRAM_DATA_A_READ => ser_BRAM_DATA_A_READ,
            ser_BRAM_DATA_A_write => ser_BRAM_DATA_A_write,
            par_BRAM_CLKb => par_BRAM_CLKb,
            par_BRAM_ENA_b => par_BRAM_ENA_b,
            par_bram_we_b => par_bram_we_b,
            par_BRAM_ADDRB => par_BRAM_ADDRB,
            par_BRAM_DATA_B_WRITE => par_BRAM_DATA_B_WRITE
        );

    -- Instantiate the spi_module
    spi_inst: spi_module
        port map (
            clk => clk_10MHz,
            reset => nReset
            -- Map other ports accordingly
        );

    -- Instantiate the mosi module
    mosi_inst: mosi
        port map (
            clk => clk_10MHz,
            reset => nReset
            -- Map other ports accordingly
        );

    -- Instantiate the miso module
    miso_inst: miso
        port map (
            clk => clk_10MHz,
            reset => nReset
            -- Map other ports accordingly
        );

    -- Clock generation
    clk_100MHz_process : process
    begin
        clk_100MHz <= '0';
        wait for clk_period_100MHz / 2;
        clk_100MHz <= '1';
        wait for clk_period_100MHz / 2;
    end process clk_100MHz_process;

    -- Clock generation
    clk_10MHz_process : process
    begin
        clk_10MHz <= '0';
        wait for clk_period_10MHz / 2;
        clk_10MHz <= '1';
        wait for clk_period_10MHz / 2;
    end process clk_10MHz_process;

    -- Testbench stimulus
    stim_proc: process
    begin
        -- Initialize inputs
        nReset <= '0';
        wait for 20 ns;
        
        nReset <= '1';
        wait for 20 ns;
        
        -- Apply test stimuli
        wordcount <= x"00000010"; -- Example wordcount
        enable <= '1';
        wait for 20 ns;
        
        enable <= '0';
        wait for 200 ns;
        
        -- Additional stimuli can be applied here
        
        -- End simulation
        wait;
    end process stim_proc;

end TB;
