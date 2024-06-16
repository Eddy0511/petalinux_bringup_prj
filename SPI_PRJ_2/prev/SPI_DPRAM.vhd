library IEEE;
library work;
use work.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity SPIDPRAM is
    Port (
		RST                         : in std_logic;
		CLK_10MHz		            : in std_logic;
        BRAM_REN                    : in std_logic;
		BRAM_WEN					: in std_logic;
		SPI_WR_DATA 				: in std_logic_vector(31 downto 0);
		SPI_RD_DATA					: out std_logic_vector(31 downto 0);

		--/* Write port */
		SPI_BRAM_CLKA 		        : out std_logic;
		SPI_BRAM_WE_A				: out std_logic_vector(3 downto 0);
		SPI_BRAM_ENA_A		        : out std_logic;
		SPI_BRAM_ADDRA              : out std_logic_vector(31 downto 0);
		SPI_BRAM_DATA_A_WRITE		: out std_logic_vector(31 downto 0);
		SPI_BRAM_DATA_A_READ		: in std_logic_vector(31 downto 0);

		--/* Read port */
		SPI_BRAM_CLKB 		        : out std_logic;
		SPI_BRAM_WE_B				: out std_logic_vector(3 downto 0);
		SPI_BRAM_ENA_B		        : out std_logic;
		SPI_BRAM_ADDRB              : out std_logic_vector(31 downto 0);
		SPI_BRAM_DATA_B_WRITE		: out std_logic_vector(31 downto 0);
		SPI_BRAM_DATA_B_READ		: in std_logic_vector(31 downto 0)
          );
end SPIDPRAM;

architecture RTL of SPIDPRAM is

	signal write_en_reg : std_logic;
	signal read_en_reg	: std_logic;
	signal r_w_reg		: std_logic;
	signal wr_data_reg : std_logic_vector(31 downto 0);
	signal rd_data_reg : std_logic_vector(31 downto 0);


	component DPRAM_CTLR
	port(
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
	end component;

begin

	SPI_RD_DATA <= rd_data_reg;

	--/* Write port */
	U1 : DPRAM_CTLR port map(
		RST => RST,
		CLK_10MHz => CLK_10MHz,
		BRAM_EN => write_en_reg,
		BRAM_W_R => r_w_reg,

		BRAM_WR_DATA => wr_data_reg,
		BRAM_RD_DATA => open,

		BRAM_CLK => SPI_BRAM_CLKA,
		BRAM_WE => SPI_BRAM_WE_A,
		BRAM_ENA => SPI_BRAM_ENA_A,
		BRAM_ADDR => SPI_BRAM_ADDRA,
		BRAM_DATA_WRITE => SPI_BRAM_DATA_A_WRITE,
		BRAM_DATA_READ => SPI_BRAM_DATA_A_READ
	);

	--/* Read port */
	U2 : DPRAM_CTLR port map(
		RST => RST,
		CLK_10MHz => CLK_10MHz,
		BRAM_EN => read_en_reg,
		BRAM_W_R => r_w_reg,

		BRAM_WR_DATA => (others => '0'),
		BRAM_RD_DATA => rd_data_reg,

		BRAM_CLK => SPI_BRAM_CLKB,
		BRAM_WE => SPI_BRAM_WE_B,
		BRAM_ENA => SPI_BRAM_ENA_B,
		BRAM_ADDR => SPI_BRAM_ADDRB,
		BRAM_DATA_WRITE => SPI_BRAM_DATA_B_WRITE,
		BRAM_DATA_READ => SPI_BRAM_DATA_B_READ
	);

	process(CLK_10MHz)
	begin
		if RST = '0' then
			write_en_reg <= '0';
			read_en_reg <= '0';
			r_w_reg <= '0';
			rd_data_reg <= (others => '0');
			wr_data_reg <= (others => '0');
		elsif falling_edge(CLK_10MHz) then
			if BRAM_REN = '1' then
				read_en_reg <= '1';
				r_w_reg <= '0';
				write_en_reg <= '0';
			elsif BRAM_WEN = '1' then
				wr_data_reg <= SPI_WR_DATA;
				r_w_reg <= '1';
				read_en_reg <= '0';
				write_en_reg <= '1';
			else
				write_en_reg <= '0';
				read_en_reg <= '0';
				r_w_reg <= '0';
			end if;
		end if;
	end process;

end RTL;