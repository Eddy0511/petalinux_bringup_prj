----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/13/2024 11:44:05 PM
-- Design Name: 
-- Module Name: AXI_TOP - RTL
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

entity test is
port (
    CTRL_DATA_OUT : out std_logic_vector(31 downto 0);
    CTRL_DATA_IN : in std_logic_vector(31 downto 0)
);
end test;

architecture RTL of test is

    signal test_reg : std_logic_vector(31 downto 0);

begin
    test_reg <= CTRL_DATA_IN;
    CTRL_DATA_OUT <= test_reg;

end RTL;
