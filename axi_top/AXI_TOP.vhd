----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/13/2024 11:44:05 PM
-- Design Name: 
-- Module Name: AXI_TOP - RTL
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AXI_TOP is
    Port ( 
        S_AXI_ACLK : in std_logic;
		S_AXI_ARESETN : in std_logic;
		S_AXI_AWADDR  : in std_logic_vector(4 downto 0);

		S_AXI_AWVALID : in std_logic;
		S_AXI_AWREADY : out std_logic;
		S_AXI_WDATA   : in std_logic_vector(31 downto 0);
	
		S_AXI_WVALID  : in std_logic;
		S_AXI_WREADY  : out std_logic;
		S_AXI_BRESP   : out std_logic_vector(1 downto 0);
		S_AXI_BVALID  : out std_logic;
		S_AXI_BREADY  : in std_logic;
		S_AXI_ARADDR  : in std_logic_vector(4 downto 0);

		S_AXI_ARVALID : in std_logic;
		S_AXI_ARREADY : out std_logic;
		S_AXI_RDATA   : out std_logic_vector(31 downto 0);
		S_AXI_RRESP   : out std_logic_vector(1 downto 0);
		S_AXI_RVALID  : out std_logic;
		S_AXI_RREADY  : in std_logic;

        CTRL_DATA_OUT : out std_logic_vector(31 downto 0);
        CTRL_DATA_IN : in std_logic_vector(31 downto 0);

        WD_CNT_OUT : out std_logic_vector(15 downto 0);
        WD_CNT_IN  : in std_logic_vector(15 downto 0)
        );
end AXI_TOP;

architecture RTL of AXI_TOP is

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

signal slv_reg_rden : std_logic;
signal slv_reg_wren : std_logic;
signal reg_data_out	: std_logic_vector(31 downto 0);

signal ctrl_reg : std_logic_vector(31 downto 0);
signal word_count_reg : std_logic_vector(15 downto 0);


begin

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
        ctrl_reg <= (others => '0');
    elsif rising_edge(S_AXI_ACLK) then
        loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
        if (slv_reg_wren = '1') then
            case loc_addr is
    	        when b"000" => 
        	        ctrl_reg <= S_AXI_WDATA;
                when b"001" =>
                    word_count_reg <= S_AXI_WDATA(15 downto 0);
			    when others => null;
            end case;
		end if; 
    end if;
end process;

CTRL_DATA_OUT <= ctrl_reg;
WD_CNT_OUT <= word_count_reg;

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
				
R_TRANSFER_READY : process (axi_araddr, slv_reg_rden)
    variable loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
begin
    loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
    case loc_addr is	
            when b"000" =>  
            reg_data_out <= CTRL_DATA_IN;	
            when b"001" =>
            reg_data_out <= WD_CNT_IN;
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




end RTL;
