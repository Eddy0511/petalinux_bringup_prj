library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity bram_ctrl is
    port
    (
        clk_100MHz : in std_logic;
        nReset : in std_logic;

        valid : in std_logic;
        ready : out std_logic;
        addr_clr : in std_logic;

        write_data : in std_logic_vector(31 downto 0);

        bram_clka : out std_logic;
        bram_rsta : out std_logic;
        bram_wea : out std_logic_vector(3 downto 0);
        bram_ena : out std_logic;
        bram_addra : out std_logic_vector(31 downto 0);
        bram_write_dataa : out std_logic_vector(31 downto 0)
    );
end bram_ctrl;

architecture RTL of bram_ctrl is
signal addr_reg : integer;

signal ready_reg : std_logic;
signal bram_write_data_reg : std_logic_vector(31 downto 0);
signal bram_read_en_reg : std_logic;
signal bram_read_addr_reg : std_logic_vector(31 downto 0);
signal transfer_data : std_logic_vector(31 downto 0);
signal bram_write_en_reg : std_logic_vector(3 downto 0);

signal bram_valid : std_logic;
signal bram_ready : std_logic;
type bram_state is (idle,s1,s2,s3,done);
signal bram_state_reg : bram_state := idle;
type interface_state is (idle,s1,s2,done);
signal interface_reg : interface_state := idle;

begin

ready <= ready_reg;

process(clk_100MHz, nReset)
begin
    if nReset = '0' then
        bram_state_reg <= idle;
        addr_reg <= 0;
        ready_reg <= '0';
        bram_valid <= '0';
        transfer_data <= (others => '0');
    elsif rising_edge(clk_100MHz) then
        case bram_state_reg is
          when idle =>
            if valid = '1' then
                if addr_clr = '1' then
                    addr_reg <= 0;
                end if;
                transfer_data <= write_data;
                bram_state_reg <= s1;
            end if;
          when s1 =>
            if bram_ready = '1' then
                bram_valid <= '0';
                bram_state_reg <= s2;
            else
                bram_valid <= '1';
            end if;
          when s2 =>
            addr_reg <= addr_reg + 4;
            ready_reg <= '1';
            bram_state_reg <= s3;
          when s3 =>
            if valid = '0' then
                bram_state_reg <= done;
            end if;
          when done =>
            ready_reg <= '0';
            bram_state_reg <= idle;
          when others =>
            null;
        end case;
    end if;
end process;

bram_addra <= bram_read_addr_reg;
bram_ena <= bram_read_en_reg;
bram_write_dataa <= bram_write_data_reg;
bram_wea <= bram_write_en_reg;
bram_rsta <= '1';
bram_clka <= clk_100MHz;

process(clk_100MHz,nReset)
begin
    if nReset = '0' then
        bram_ready <= '0';
        interface_reg <= idle;
        bram_read_en_reg <= '0';
        bram_read_addr_reg <= (others => '0');
        bram_write_en_reg <= "0000";
        bram_write_data_reg <= (others =>'0');
    elsif falling_edge(clk_100MHz) then
        case interface_reg is
          when idle =>
            if bram_valid = '1' then
                bram_read_en_reg <= '1';
                bram_read_addr_reg <= std_logic_vector(to_unsigned(addr_reg,32));
                bram_write_en_reg <= "1111";
                bram_write_data_reg <= transfer_data;
                interface_reg <= s1;
            end if;
          when s1 =>
            interface_reg <= s2;
          when s2 =>
            bram_write_en_reg <= "0000";
            bram_write_data_reg <= (others => '0');
            bram_ready <= '1';
            bram_read_en_reg <= '0';
            interface_reg <= done;
          when done =>
            if bram_valid = '0' then
                bram_ready <= '0';
                interface_reg <= idle;
            end if;
          when others =>
            null;
        end case;
    end if;
end process;


end RTL;

