----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/13/2024 11:44:05 PM
-- Design Name: 
-- Module Name: SPI_MODULE - RTL
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPI_MODULE is
    Port (  
            clk_10MHz : in std_logic;
            nReset : in std_logic;

            enable : in STD_LOGIC;

            sclk : out STD_LOGIC;
            cs : out STD_LOGIC
        );
end SPI_MODULE;

architecture RTL of SPI_MODULE is

type spi_state is (idle,r1,r2,s1,s2,s3,s4,s5,s6,s7,s8,done);
signal spi_state_reg : spi_state := idle;
signal cs_reg : std_logic;
signal sclk_en_reg : std_logic;

begin

sclk <= clk_10MHz when sclk_en_reg = '0' else '0';
cs <= cs_reg;

process(clk_10MHz, nReset)
begin
    if nReset = '0' then
        spi_state_reg <= idle;
        cs_reg <= '1';
        sclk_en_reg <= '1';
    elsif rising_edge(clk_10MHz) then
        case spi_state_reg is
            when idle =>
                if enable = '1' then
                    cs_reg <= '0';
                    spi_state_reg <= r1;
                end if;
            when r1 =>
                spi_state_reg <= r2;
            when r2 =>
                sclk_en_reg <= '0';
                spi_state_reg <= s1;
            when s1 =>
                spi_state_reg <= s2;
            when s2 =>
                spi_state_reg <= s3;
            when s3 =>
                spi_state_reg <= s4;
            when s4 =>
                spi_state_reg <= s5;
            when s5 =>
                spi_state_reg <= s6;
            when s6 =>
                spi_state_reg <= s7;
            when s7 =>
                spi_state_reg <= s8;
            when s8 =>
                if enable = '1' then
                    spi_state_reg <= s1;
                else
                    spi_state_reg <= done;
                    sclk_en_reg <= '1';
                end if;
            when done =>
                cs_reg <= '1';
                spi_state_reg <= idle;
            when others =>
                null;
        end case;
    end if;
end process;


end RTL;
