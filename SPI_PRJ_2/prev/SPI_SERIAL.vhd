library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPISER is
generic(
	MAX_CNT : integer := 8
);
port(
    -- 로직 동작 신호
    CLK_10MHz : in std_logic;
    RST : in std_logic;
    SER2PAR : in std_logic_vector(MAX_CNT - 1 downto 0);
	SEREN : in std_logic;
    SERCOM : out std_logic;
    SERDATA : out std_logic

);
end SPISER;

architecture RTL of SPISER is
	signal ser_cnt : std_logic_vector(MAX_CNT/4 downto 0);
	signal ser_reg : std_logic_vector (MAX_CNT - 1 downto 0);
	signal ser_busy : std_logic;
	signal ser_cnt_enable : std_logic;
    type SER_STATE is (SER_IDLE, SER_READY, SER_RUN, SER_DONE);
	signal ser_state_reg : SER_STATE := SER_IDLE;
begin

	SERDATA <= ser_reg((MAX_CNT - 1) - to_integer(unsigned(ser_cnt))) when ser_busy = '1' else '0';
    SERCOM <= not ser_busy;

-- 레지스터 데이터(SPI_CMD) 를 시리얼로 변환한다.
process(CLK_10MHz)
begin
	if RST = '0' then
		ser_busy <= '0';
		ser_reg <= (others => '0');
		ser_cnt_enable <= '0';
		ser_state_reg <= SER_IDLE;
	elsif falling_edge(CLK_10MHz) then
		case ser_state_reg is
			when SER_IDLE =>
				if SEREN = '0' then
					ser_reg <= SER2PAR;
					ser_state_reg <= SER_READY;
				end if;
			when SER_READY =>
			    ser_busy <= '1';
			    ser_cnt_enable <= '1';
			    ser_state_reg <= SER_RUN;
			when SER_RUN =>
				if ser_cnt = (std_logic_vector(TO_UNSIGNED(MAX_CNT,ser_cnt'length) - 1 )) then
					ser_cnt_enable <= '0';
					ser_state_reg <= SER_DONE;
				end if;
			when SER_DONE =>
				ser_busy <= '0';
				ser_state_reg <= SER_IDLE;
			when others => null;
		end case;
	end if;
end process;
	
-- 시리얼 카운터
process(CLK_10MHz)
begin
	if RST = '0' then
		ser_cnt <= (others => '0');
	elsif falling_edge(CLK_10MHz) then
		if ser_cnt_enable = '1' then
			ser_cnt <= std_logic_vector(unsigned(ser_cnt) + 1);
		else
			ser_cnt <= (others => '0');
		end if;
	end if;
end process; 

end RTL;

