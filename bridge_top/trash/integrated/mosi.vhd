library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity mosi_module is
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
end mosi_module;

architecture RTL of mosi_module is

type mosi_state is (idle,r1,s1,s2,s3,s4,s5,s6,s7,s8,done);
signal mosi_state_reg : mosi_state := idle;
signal buf : std_logic_vector(6 downto 0);
signal receive_reg : std_logic_vector(7 downto 0);
signal drdy_reg : std_logic;
begin

drdy <= drdy_reg;

process(clk_10MHz,nReset)
begin
    if nReset = '0' then
        mosi_state_reg <= idle;
        buf <= (others => '0');
        MOSI <= '0';
        drdy_reg <= '0';
    elsif falling_edge(clk_10MHz) then
        case mosi_state_reg is
          when idle =>
            if enable = '1' then
                mosi_state_reg <= s1;
            end if;
          when s1 =>
            buf <= receive_reg(6 downto 0);
            MOSI <= receive_reg(7);
            mosi_state_reg <= s2;
          when s2 =>
            MOSI <= buf(6);
            mosi_state_reg <= s3;
          when s3 =>
            MOSI <= buf(5);
            mosi_state_reg <= s4;
          when s4 =>
            drdy_reg <= '1';
            MOSI <= buf(4);
            mosi_state_reg <= s5;
          when s5 =>
            MOSI <= buf(3);
            mosi_state_reg <= s6;
          when s6 =>
            MOSI <= buf(2);
            mosi_state_reg <= s7;
          when s7 =>
            MOSI <= buf(1);
            mosi_state_reg <= s8;
          when s8 =>
            drdy_reg <= '0';
            MOSI <= buf(0);
            if enable = '1' then
                mosi_state_reg <= s1;
            else
                mosi_state_reg <= done;
            end if;
          when done =>
            mosi_state_reg <= idle;
          when others => 
            null;
        end case;
    end if;
end process;

--receive_reg <= receive; --when ready = '1' else (others => '0');

process(clk_10MHz,nReset)
begin
    if nReset = '0' then
        receive_reg <= (others => '0');
    elsif rising_edge(clk_10MHz) then
        if ready = '1' then
            receive_reg <= receive;
        end if;
    end if;
end process;

end RTL;