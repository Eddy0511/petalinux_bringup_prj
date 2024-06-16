library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity TOT is
    Port (
		S_AXI_ACLK : in std_logic;
		S_AXI_ARESETN : in std_logic;
		S_AXI_AWADDR  : in std_logic_vector(4 downto 0);
		--S_AXI_AWPROT  : in std_logic_vector(2 downto 0);
		S_AXI_AWVALID : in std_logic;
		S_AXI_AWREADY : out std_logic;
		S_AXI_WDATA   : in std_logic_vector(31 downto 0);
		--S_AXI_WSTRB   : in std_logic_vector(3 downto 0);
		S_AXI_WVALID  : in std_logic;
		S_AXI_WREADY  : out std_logic;
		S_AXI_BRESP   : out std_logic_vector(1 downto 0);
		S_AXI_BVALID  : out std_logic;
		S_AXI_BREADY  : in std_logic;
		S_AXI_ARADDR  : in std_logic_vector(4 downto 0);
		--S_AXI_ARPROT  : in std_logic_vector(2 downto 0);
		S_AXI_ARVALID : in std_logic;
		S_AXI_ARREADY : out std_logic;
		S_AXI_RDATA   : out std_logic_vector(31 downto 0);
		S_AXI_RRESP   : out std_logic_vector(1 downto 0);
		S_AXI_RVALID  : out std_logic;
		S_AXI_RREADY  : in std_logic;

		-- bram interface
		BRAM_A_CLK					: out std_logic;
		BRAM_A_RST					: out std_logic;
		BRAM_A_WE				  	: out std_logic_vector(3 downto 0);
		BRAM_A_ENA		     	  	: out std_logic;
		BRAM_A_ADDR             	: out std_logic_vector(31 downto 0);
		BRAM_A_DATA_WRITE		    : out std_logic_vector(31 downto 0);
		BRAM_A_DATA_READ		    : in std_logic_vector(31 downto 0);

		BRAM_B_CLK					: out std_logic;
		BRAM_B_RST					: out std_logic;
		BRAM_B_WE				  	: out std_logic_vector(3 downto 0);
		BRAM_B_ENA		     	  	: out std_logic;
		BRAM_B_ADDR             	: out std_logic_vector(31 downto 0);
		BRAM_B_DATA_WRITE		    : out std_logic_vector(31 downto 0);

		MOSI : out std_logic;
		MISO : in std_logic;
		SCLK : out std_logic;
		CS : out std_logic
    );
end TOT;

architecture RTL of TOT is

--component AXI_TOP
--port(
--
--);
--end component;

component DPRAM_CTRL
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


component Parellel2Serial
port(
	PARELLEL_EN : in std_logic;
	BRAM_READ_EN : out std_logic;

	BRAM_RD_DATA : in std_logic_vector(31 downto 0);

	SERIAL_DATA : out stD_logic_vector(7 downto 0)
);
end component;

component Serial2Parellel
port(
	SERIAL_EN : in std_logic;

	BRAM_WRITE_EN : out std_logic;
	BRAM_EN : out std_logic;

	PARALLEL_DATA : in std_logic_vector(7 downto 0);
	BRAM_WR_DATA : out std_logic_vector(31 downto 0)
);
end component;

component SPI_TOP
port(
	SPI_EN	: IN STD_LOGIC;

	SER_EN : out std_logic;
	PAR_EN : out std_logic;

	IN_DATA : in std_logic_vector(7 downto 0);
	OUT_DATA : out std_logic_vector(7 downto 0);

	MOSI : out std_logic;
	MISO : in std_logic;
	SCLK : out std_logic;
	CS : out std_logic
);
end component;

signal main_rst : std_logic;
signal main_clk : std_logic;

-- AXI Handshake
signal axi_awready	: std_logic;                                        
signal axi_awaddr	: std_logic_vector(4 downto 0);  

signal axi_wready	: std_logic;

signal axi_bresp	: std_logic_vector(1 downto 0);  
signal axi_bvalid	: std_logic;

signal axi_arready	: std_logic;                                        
signal axi_araddr	: std_logic_vector(4 downto 0);  

signal axi_rdata	: std_logic_vector(31 downto 0);  
signal axi_rresp	: std_logic_vector(1 downto 0);
signal axi_rvalid	: std_logic;

constant ADDR_LSB          : integer := 2;
constant OPT_MEM_ADDR_BITS : integer := 2;
--signal byte_index   : integer;

signal slv_reg_rden : std_logic;
signal slv_reg_wren : std_logic;
signal reg_data_out	: std_logic_vector(31 downto 0);

signal control_reg	    : std_logic_vector(31 downto 0);

-- top logic to bram a
signal bram_a_en_reg : std_logic;
signal bram_a_clk_reg : std_logic;
signal bram_a_addr_reg : std_logic_vector(31 downto 0);
signal bram_a_data_read_reg : std_logic_vector(31 downto 0);

-- top logic to brma b
signal bram_b_wr_reg : std_logic_vector(3 downto 0);
signal bram_b_clk_reg : std_logic;
signal bram_b_en_reg : std_logic;
signal bram_b_addr_reg : std_logic_vector(31 downto 0);
signal bram_b_data_write_reg : std_logic_vector(31 downto 0);

-- bram to parallel conv logic signal 
signal serial_en_reg : std_logic;

-- serial conv logic to bram signal
signal parallel_en_reg : std_logic;

signal mosi_reg : std_logic;
signal miso_reg : std_logic;
signal cs_reg : std_logic;
signal sclk_reg : std_logic;

signal input_reg : std_logic_vector(7 downto 0);
signal output_reg : std_logic_vector(7 downto 0);

signal spi_en_reg : std_logic;

signal read_a_en_reg : std_logic;
signal read_a_data : std_logic_vector(31 downto 0);

signal read_b_en_reg : std_logic;
signal write_b_en_reg : std_logic;
signal write_b_data : std_logic_vector(31 downto 0);

begin

main_rst <= S_AXI_ARESETN;
main_clk <= S_AXI_ACLK;

S_AXI_AWREADY <= axi_awready;
S_AXI_WREADY  <= axi_wready;
S_AXI_BRESP	  <= axi_bresp;
S_AXI_BVALID  <= axi_bvalid;
S_AXI_ARREADY <= axi_arready;
S_AXI_RDATA	  <= axi_rdata;
S_AXI_RRESP	  <= axi_rresp;
S_AXI_RVALID  <= axi_rvalid;


AW_TRANSFER_HANDSHAKE: process (S_AXI_ACLK, S_AXI_ARESETN)
begin
if S_AXI_ARESETN = '0' then
    axi_awready <= '0';
	axi_awaddr <= (others => '1');
elsif rising_edge(S_AXI_ACLK) then
	if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' ) then
    	axi_awready <= '1';
		axi_awaddr <= S_AXI_AWADDR;
	else
		axi_awready <= '0';
	end if;
end if;
end process;

W_TRANSFER_HANDSHAKE : process (S_AXI_ACLK, S_AXI_ARESETN)
begin
	if S_AXI_ARESETN = '0' then
        axi_wready <= '0';
    elsif rising_edge(S_AXI_ACLK) then
	    if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1') then
            axi_wready <= '1';
        else
            axi_wready <= '0';
        end if; 
    end if; 
end process;

slv_reg_wren <= axi_wready and axi_awready;

W_TRANSFER_DATA : process (S_AXI_ACLK, S_AXI_ARESETN)
	variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
begin
	if S_AXI_ARESETN = '0' then
		control_reg(31 downto 8) <= (others => '0');
		control_reg(7 downto 0) <= (others => '1');
    elsif rising_edge(S_AXI_ACLK) then
        loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB); -- 4 downto 2
        if (slv_reg_wren = '1') then
            case loc_addr is
    	        when b"000" => 
        	        control_reg <= S_AXI_WDATA;
			    when others => null;
            end case;
		end if; 
    end if;
end process;

B_TRANSFER_HANDSHAKE : process (S_AXI_ACLK, S_AXI_ARESETN)
begin
    if S_AXI_ARESETN = '0' then
        axi_bvalid  <= '0';
        axi_bresp   <= "00";	
	elsif rising_edge(S_AXI_ACLK) then
	    if (axi_awready = '1' and axi_wready = '1' and axi_bvalid = '0'  ) then
			axi_bvalid <= '1';
			axi_bresp  <= "00";
	    elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
            axi_bvalid <= '0';                 
        end if;	
	end if;
end process;

AR_TRANSFER_HANDSHAKE : process (S_AXI_ACLK, S_AXI_ARESETN)
begin
    if S_AXI_ARESETN = '0' then
        axi_arready <= '0';
        axi_araddr  <= (others => '1');
	elsif rising_edge(S_AXI_ACLK) then
		if (axi_arready = '0' and S_AXI_ARVALID = '1') then
            axi_arready <= '1';
            axi_araddr  <= S_AXI_ARADDR;
        else
            axi_arready <= '0';
        end if;
    end if;
end process;

R_TRANSFER_HANDSHAKE : process (S_AXI_ACLK, S_AXI_ARESETN)
begin
	if S_AXI_ARESETN = '0' then
        axi_rvalid <= '0';
        axi_rresp  <= "00";
    elsif rising_edge(S_AXI_ACLK) then
	    if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
            axi_rvalid <= '1';
            axi_rresp  <= "00";
        elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
            axi_rvalid <= '0';
        end if;
    end if;
end process;

slv_reg_rden <= axi_arready  and (not axi_rvalid);
				
R_TRANSFER_READY : process (control_reg ,axi_araddr, slv_reg_rden)
    variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
begin
    loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
    case loc_addr is	
            when b"000" =>  
            reg_data_out <= control_reg;	
        when others =>
            reg_data_out  <= (others => '0');
    end case;
end process;	

R_TRANSFER_DATA : process( S_AXI_ACLK , S_AXI_ARESETN) is
begin	
	if ( S_AXI_ARESETN = '0' ) then
		axi_rdata  <= (others => '0');
	elsif (rising_edge (S_AXI_ACLK)) then   
		if (slv_reg_rden = '1') then
			axi_rdata <= reg_data_out;
		end if;
	end if;
end process;			

IO_PIN_ASSIGN : process ( S_AXI_ACLK, S_AXI_ARESETN ) is
begin
	if ( S_AXI_ARESETN = '0' ) then

		bram_a_clk_reg <= '0';
		bram_a_en_reg <= '0';
		bram_a_addr_reg <= (others => '0');
		bram_b_clk_reg <= '0';
		bram_b_wr_reg <= (others => '0');
		bram_b_en_reg <= '0';
		bram_b_addr_reg <= (others => '0');
		bram_b_data_write_reg <= (others => '0');

		spi_en_reg <= '1';
	elsif (rising_edge (S_AXI_ACLK)) then
		spi_en_reg <= control_reg(0);
	end if;
end process;

SPI_TOP_inst : SPI_TOP
	port map(
		SPI_EN => spi_en_reg,
		SER_EN => serial_en_reg,
		PAR_EN => parallel_en_reg,

		IN_DATA => input_reg,
		OUT_DATA => output_reg,

		MOSI => mosi_reg,
		MISO => miso_reg,
		SCLK => sclk_reg,
		CS => cs_reg
	);

	MOSI <= mosi_reg;
	miso_reg <= MISO;
	SCLK <= sclk_reg;
	CS <= cs_reg;


Parallel_conv_inst : Parellel2Serial
	port map(
		PARELLEL_EN => parallel_en_reg,
		BRAM_READ_EN => read_a_en_reg,

		BRAM_RD_DATA => read_a_data,
		SERIAL_DATA => input_reg
	);	

Serial_conv_inst : Serial2Parellel
	port map(
		SERIAL_EN => serial_en_reg,
		BRAM_WRITE_EN => write_b_en_reg,
		BRAM_EN => read_b_en_reg,

		PARALLEL_DATA => output_reg,
		BRAM_WR_DATA => write_b_data
	);		

READ_RAM : DPRAM_CTRL
	port map(
		RST => main_rst,
		CLK_10MHz => main_clk,

		BRAM_EN => read_a_en_reg,
		BRAM_W_R => '0',
		BRAM_WR_DATA => (others => '0'),
		BRAM_RD_DATA => read_a_data,

		BRAM_CLK => bram_a_clk_reg,
		BRAM_WE => open,
		BRAM_ENA => bram_a_en_reg,
		BRAM_ADDR => bram_a_addr_reg,
		BRAM_DATA_WRITE => open,
		BRAM_DATA_READ => bram_a_data_read_reg
	);

	BRAM_A_CLK <= bram_a_clk_reg;
	BRAM_A_ENA <= bram_a_en_reg;
	BRAM_A_WE <= (others => '0');
	BRAM_A_ADDR <= bram_a_addr_reg;
	BRAM_A_DATA_WRITE <= (others => '0');
	BRAM_A_RST <= '1';
	bram_a_data_read_reg <= BRAM_A_DATA_READ;

WRITE_RAM : DPRAM_CTRL
	port map(
		RST => main_rst,
		CLK_10MHz => main_clk,

		BRAM_EN => read_b_en_reg,
		BRAM_W_R => write_b_en_reg,
		BRAM_WR_DATA => write_b_data,
		BRAM_RD_DATA => open,

		BRAM_CLK => bram_b_clk_reg,
		BRAM_WE => bram_b_wr_reg,
		BRAM_ENA => bram_b_en_reg,
		BRAM_ADDR => bram_b_addr_reg,
		BRAM_DATA_WRITE => bram_b_data_write_reg,
		BRAM_DATA_READ => (others => '0')
	);	

	BRAM_B_CLK <= bram_b_clk_reg;
	BRAM_B_RST <= '1';
	BRAM_B_WE <= bram_b_wr_reg;
	BRAM_B_ENA <= bram_b_en_reg;
	BRAM_B_ADDR <= bram_b_addr_reg;
	BRAM_B_DATA_WRITE <= bram_b_data_write_reg;


end RTL;