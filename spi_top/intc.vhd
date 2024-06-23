library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity spi_intc is
port(
    clk : in std_logic;
    nreset : in std_logic;
    intc_pin : inout std_logic;
    intc_ctrl : out std_logic
);
end spi_intc;

architecture RTL of spi_intc is

signal intc_in_reg : std_logic;
signal intc_out_reg : std_logic;
signal intc_out_en : std_logic;
signal intc_cnt : integer;

begin

intc_pin <= intc_out_reg when intc_out_en = '0';
intc_in_reg <= intc_pin when intc_out_en = '1' else '1';


process(nreset,clk)
begin
    if nreset = '0' then
        --intc_in_reg <= '1';
        intc_out_reg <= '1';
        intc_cnt <= 0;
        intc_out_en <= '0';
    elsif rising_edge(clk) then
        if intc_cnt >= 1000 then
            intc_out_reg <= '0';
            intc_out_en <= '1';
        end if;
        if intc_out_reg = '1' then
            intc_cnt <= intc_cnt + 1;
        end if;
    end if;
    intc_ctrl <= intc_in_reg;
end process;


end RTL;