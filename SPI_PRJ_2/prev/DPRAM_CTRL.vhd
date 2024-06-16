library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity DPRAM_CTRL is
    Port (
		RST                     : in std_logic;
		CLK_10MHz		        : in std_logic;
        BRAM_EN                 : in std_logic;
        BRAM_W_R                : in std_logic;

        BRAM_WR_DATA            : in std_logic_vector(31 downto 0);
        BRAM_RD_DATA            : out std_logic_vector(31 downto 0);

		BRAM_CLK 		        : out std_logic;
		BRAM_WE				    : out std_logic_vector(3 downto 0);
		BRAM_ENA		        : out std_logic;
		BRAM_ADDR               : out std_logic_vector(31 downto 0);
		BRAM_DATA_WRITE		    : out std_logic_vector(31 downto 0);
		BRAM_DATA_READ		    : in std_logic_vector(31 downto 0)
    );
end DPRAM_CTRL;

architecture RTL of DPRAM_CTRL is

    signal bram_addr_reg : std_logic_vector(30 downto 0);
begin
    BRAM_CLK <= CLK_10MHz;

    process(CLK_10MHz)
    begin
        if RST = '0' then
            BRAM_WE <= (others => '0');
            BRAM_ENA <= '0';
            BRAM_ADDR <= (others => '0');
            BRAM_DATA_WRITE <= (others => '0');
        elsif falling_edge(CLK_10MHz) then
            if BRAM_EN = '1' then
                BRAM_ENA <= '1';
                BRAM_ADDR <= BRAM_W_R & bram_addr_reg;
                BRAM_WE <= (others => BRAM_W_R);
                if BRAM_W_R = '1' then
                    BRAM_DATA_WRITE <= BRAM_WR_DATA;
                    BRAM_RD_DATA <= (others => '0');
                else
                    BRAM_DATA_WRITE <= (others => '0');
                    BRAM_RD_DATA <= BRAM_DATA_READ;
                end if;
            else
                BRAM_ENA <= '0';
                BRAM_ADDR <= (others => '0');
                BRAM_DATA_WRITE <= (others => '0');
                BRAM_WE <= (others => '0');
            end if;
        end if;
    end process;

    process(CLK_10MHz)
    begin
        if RST = '0' then
            bram_addr_reg <= (others => '0');
        elsif rising_edge(CLK_10MHz) then
            if BRAM_EN = '1' then
                bram_addr_reg <= std_logic_vector(unsigned(bram_addr_reg)+4);
            else
                bram_addr_reg <= (others => '0');
            end if;
        end if;
    end process;

end RTL;