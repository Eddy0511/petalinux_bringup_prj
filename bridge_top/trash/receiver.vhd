library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity receiver is
    port
    (
        clk_100MHz : in std_logic;
        nReset : in std_logic;
        receiver_en : in std_logic;
        receive : in std_logic_vector(7 downto 0)
    );
end receiver;

architecture RTL of receiver is
begin
    process(clk_100MHz, nReset)
    begin
        if nReset = '0' then
            -- 초기화 코드
        elsif rising_edge(clk_100MHz) then
            if receiver_en = '1' then
                -- 리시버 로직 작성
            end if;
        end if;
    end process;
end RTL;
