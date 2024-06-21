library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity axi_conv_bridge_spi is
    port
    (
        clk_100MHz  : in std_logic;
        CTRL_DATA_MI : in std_logic_vector(31 downto 0);
        CTRL_DATA_SO : out std_logic_vector(31 downto 0);

        WD_CNT_MI : in std_logic_vector(15 downto 0);
        WD_CNT_SO : out std_logic_vector(15 downto 0);

        wd_cnt_conv : out std_logic_vector(31 downto 0);
        ctrl_data_conv : out std_logic
    );
end axi_conv_bridge_spi;

architecture RTL of axi_conv_bridge_spi is

signal ctrl_data_conv_reg : std_logic_vector(31 downto 0) := (others => '0');
signal wd_cnt_conv_reg : std_logic_vector(31 downto 0) := (others => '0');
begin

process(clk_100MHz)
begin
    if rising_edge(clk_100MHz) then
        ctrl_data_conv_reg <= CTRL_DATA_MI;
        wd_cnt_conv_reg(15 downto 0) <= WD_CNT_MI;
    end if;
end process;

ctrl_data_conv <= ctrl_data_conv_reg(0);
CTRL_DATA_SO <= ctrl_data_conv_reg;

wd_cnt_conv <= wd_cnt_conv_reg;
WD_CNT_SO <= wd_cnt_conv_reg(15 downto 0);

end RTL;