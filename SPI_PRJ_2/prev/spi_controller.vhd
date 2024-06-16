library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity spi_controller is
    port
    (
        -- this module interface
        clk_100MHz : in std_logic;
        nReset : in std_logic;
        module_enable : in std_logic;

        -- mosi module interface
        mosi_enable : out std_logic;
        mosi_ready : out std_logic;
        mosi_receive : out std_logic_vector(7 downto 0);

        -- miso module interface
        miso_enable : out std_logic;
        miso_ready : in std_logic;
        miso_transmit : in std_logic_vector(7 downto 0);

        -- spi module interface
        spi_enable : out std_logic

    );
end spi_controller;

architecture RTL of spi_controller is

type controller_state is (idle,run,done);
signal ctrl_state_reg : controller_state := idle;

begin

process(clk_100MHz, nReset)
begin
    if nReset = '0' then
    elsif rising_edge(clk_100MHz) then
        case ctrl_state_reg is
            when idle =>
                
            when run =>
            when done =>
            when others =>
        end case;
    end if;
end process;

end RTL;