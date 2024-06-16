library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity miso_module is
    port
    (
        clk_10MHz : in std_logic;
        nReset : in std_logic;

        enable : in std_logic;
        ready : out std_logic;
        transmit : out std_logic_vector(7 downto 0);

        MISO : in STD_LOGIC

    );
end miso_module;

architecture RTL of miso_module is

type miso_state is (idle,r1,s1,s2,s3,s4,s5,s6,s7,s8,done);
signal miso_state_reg : miso_state := idle;
signal buf : std_logic_vector(6 downto 0);
signal rd_reg : std_logic;
signal transmit_reg : std_logic_vector(7 downto 0);
begin

ready <= rd_reg;
transmit <= transmit_reg;

process(clk_10MHz,nReset)
begin
    if nReset = '0' then
        miso_state_reg <= idle;
        buf <= (others => '0');
        transmit_reg <= (others => '0');
        rd_reg <= '0';
    elsif rising_edge(clk_10MHz) then
        case miso_state_reg is
          when idle =>
            if enable = '1' then
                miso_state_reg <= s1;
            end if;
          when s1 =>
            rd_reg <= '0';
            buf(6) <= MISO;
            miso_state_reg <= s2;
          when s2 =>
            buf(5) <= MISO;
            miso_state_reg <= s3;
          when s3 =>
            buf(4) <= MISO;
            miso_state_reg <= s4;
          when s4 =>
            buf(3) <= MISO;
            miso_state_reg <= s5;
          when s5 =>
            buf(2) <= MISO;
            miso_state_reg <= s6;
          when s6 =>
            buf(1) <= MISO;
            miso_state_reg <= s7;
          when s7 =>
            buf(0) <= MISO;
            miso_state_reg <= s8;
          when s8 =>
            rd_reg <= '1';
            transmit_reg <= buf & miso;
            if enable = '1' then
                miso_state_reg <= s1;
            else
                miso_state_reg <= done;
            end if;
          when done =>
            miso_state_reg <= idle;
          when others => 
            null;
        end case;
    end if;
end process;

end RTL;