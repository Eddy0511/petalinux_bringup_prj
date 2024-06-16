library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPIPAR is
generic(
	MAX_CNT : integer := 8
);
port(
    -- 로직 동작 신호
    CLK_10MHz : in std_logic;
    RST : in std_logic;
    PARDATA : out std_logic_vector(MAX_CNT - 1 downto 0);
    PARCOM : out std_logic;
    PARING : out std_logic;
	PAREN : in std_logic;
    SERDATA : in std_logic

);
end SPIPAR;

architecture RTL of SPIPAR is
	signal par_cnt_enable : std_logic;
	signal par_cnt : std_logic_vector(MAX_CNT downto 0);
	signal par_reg : std_logic_vector (MAX_CNT - 1 downto 0);
	signal par_busy : std_logic;

	type PAR_STATE is (PAR_IDLE, PAR_READY, PAR_RUN, PAR_DONE);
	signal par_state_reg : PAR_STATE := PAR_IDLE;
begin

    PARDATA <= par_reg;
	PARCOM <= not par_busy;
	PARING <= par_busy;
	
	-- 패러렐 카운터
	process(CLK_10MHz)
	begin
		if RST = '0' then
			par_cnt <= (others => '0');
		elsif falling_edge(CLK_10MHz) then
			if par_cnt_enable = '1' then
				par_cnt <= std_logic_vector(unsigned(par_cnt) + 1);
			else
				par_cnt <= (others => '0');
			end if;
		end if;
	end process;
	
	-- 페러렐 -> 시리얼 변환기
	process(CLK_10MHz)
	begin
		if RST = '0' then
			par_busy <= '0';
			par_reg <= (others => '0');
			par_cnt_enable <= '0';
			par_state_reg <= PAR_IDLE;
		elsif rising_edge(CLK_10MHz) then
			case par_state_reg is
				when PAR_IDLE =>
					if PAREN = '0' then
						par_reg <= (others => '0');
						par_state_reg <= PAR_RUN;
					end if;
				when PAR_RUN =>
					if par_cnt = (std_logic_vector(unsigned(MAX_CNT) - 1 )) then
						par_cnt_enable <= '0';			
						par_state_reg <= PAR_DONE;
					else
						par_busy <= '1';
						par_cnt_enable <= '1';
						par_reg((MAX_CNT - 1)  - TO_UNSIGNED(unsigned(par_cnt))) <=  SERDATA;
					end if;
				when PAR_DONE =>
					par_busy <= '0';
					par_state_reg <= PAR_IDLE;
				when others => null;
			end case;
		end if;
	end process;


end RTL;
