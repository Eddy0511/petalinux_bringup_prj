library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ram is
    port(
        ena_a : in std_logic;
        addr_a : in std_logic_vector(9 downto 0);
        wrena_a : in std_logic_vector(3 downto 0);
        wrdata_a : in std_logic_vector(31 downto 0);
        rddata_a : out std_logic_vector(31 downto 0);
        clk_a : in std_logic;
        rst_a : in std_logic
    );
end ram;

architecture RTL of ram is
    type mem_type is array (1024 downto 0) of std_logic_vector(31 downto 0);
    shared variable mem : mem_type := (
        0 => x"DEADBEEF",
        1 => x"CAFEBEBE",
        2 => x"12345678",
        3 => x"9ABCDEF0",
        4 => x"BEEFDEAD",
        5 => x"BEBECAFE",
        others =>(others=> '0')
    );
begin

    process (clk_a, rst_a)
    begin
        if rst_a = '0' then
            rddata_a <= (others => '0');
        elsif rising_edge(clk_a) then
            if ena_a = '1' then
                rddata_a <= mem(to_integer(unsigned(addr_a)));
                if wrena_a = "1111" then
                    mem(to_integer(unsigned(addr_a(31 downto 2)))) := wrdata_a;
                end if;
            end if;
        end if;
    end process;

end RTL;