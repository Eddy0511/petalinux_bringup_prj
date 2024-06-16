library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity SPI_top is
Port (
        clk_10MHz : in std_logic;
        nReset : in std_logic;
        enable : in STD_LOGIC;

        valid : out std_logic;
        ready : in std_logic;
        drdy : out std_logic;

        transmit : out std_logic_vector(7 downto 0);
        receive : in std_logic_vector(7 downto 0);

        sclk : out STD_LOGIC;
        MISO : in STD_LOGIC;
        MOSI : out STD_LOGIC;
        cs : out STD_LOGIC
    );

end SPI_top;

architecture RTL of SPI_top is

component SPI_MODULE is
    Port (  
            clk_10MHz : in std_logic;
            nReset : in std_logic;
            enable : in STD_LOGIC;
            sclk : out STD_LOGIC;
            cs : out STD_LOGIC
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
        MISO : in STD_LOGIC
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
        MOSI : out STD_LOGIC
    );
end component;

signal clk_reg : std_logic;
signal nReset_reg : std_logic;
signal enable_reg : std_logic;
signal sclk_reg : std_logic;
signal cs_reg : std_logic;
signal miso_reg : std_logic;
signal mosi_reg : std_logic;

signal ready_reg : std_logic;
signal valid_reg : std_logic;

signal receive_reg : std_logic_vector(7 downto 0);
signal transmit_reg : std_logic_vector(7 downto 0);

signal drdy_reg : std_logic;
begin
    clk_reg <= clk_10MHz;
    nReset_reg <= nReset;
    enable_reg <= enable;

    valid <= valid_reg;
    ready_reg <= ready;
    drdy <= drdy_reg;

    transmit <= transmit_reg;
    receive_reg <= receive;

    sclk <= sclk_reg;
    miso_reg <= MISO;
    MOSI <= mosi_reg;
    cs <= cs_reg;

    spi_inst : spi_module
    port map(
        clk_10MHz => clk_reg,
        nReset => nReset_reg,
        enable => enable_reg,
        sclk => sclk_reg,
        cs => cs_reg
    );

    miso_inst : miso_module
    port map(
        clk_10MHz => clk_reg,
        nReset => nReset_reg,
        enable => enable_reg,
        ready => valid_reg,
        transmit => transmit_reg,
        MISO => miso_reg
    );

    mosi_inst : mosi_module
    port map(
        clk_10MHz => clk_reg,
        nReset => nReset_reg,
        enable => enable_reg,
        ready => ready_reg,
        drdy => drdy_reg,
        receive => receive_reg,
        MOSI => mosi_reg
    );

end RTL;