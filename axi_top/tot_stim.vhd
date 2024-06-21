library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top is
end tb_top;

architecture behavior of tb_top is

    -- Component Declarations
    component AXI_TOP
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
    end component;

    component axi_conv_bridge_spi
        port (
            clk_100MHz  : in std_logic;
            CTRL_DATA_MI : in std_logic_vector(31 downto 0);
            CTRL_DATA_SO : out std_logic_vector(31 downto 0);
            WD_CNT_MI : in std_logic_vector(15 downto 0);
            WD_CNT_SO : out std_logic_vector(15 downto 0);
            wd_cnt_conv : out std_logic_vector(31 downto 0);
            ctrl_data_conv : out std_logic
        );
    end component;

    component top
        port (
            clk_100MHz : in std_logic;
            clk_10MHz : in std_logic;
            miso : in std_logic;
            mosi : out std_logic;
            sclk : out std_logic;
            cs : out std_logic;
            bram_clk_a : out std_logic;
            bram_rst_a : out std_logic;
            bram_we_a : out std_logic_vector(3 downto 0);
            bram_en_a : out std_logic;
            bram_rd_a : in std_logic_vector(31 downto 0);
            bram_wr_a : out std_logic_vector(31 downto 0);
            bram_addr_a : out std_logic_vector(29 downto 0);
            bram_clk_b : out std_logic;
            bram_rst_b : out std_logic;
            bram_we_b : out std_logic_vector(3 downto 0);
            bram_en_b : out std_logic;
            bram_rd_b : in std_logic_vector(31 downto 0);
            bram_wr_b : out std_logic_vector(31 downto 0);
            bram_addr_b : out std_logic_vector(29 downto 0);
            nReset : in std_logic;
            enable : in std_logic;
            count : in std_logic_vector(31 downto 0)
        );
    end component;

    component spi_intc
        port(
            clk : in std_logic;
            nreset : in std_logic;
            intc_pin : inout std_logic;
            intc_ctrl : out std_logic
        );
    end component;

    -- Signal Declarations
    signal clk_100MHz : std_logic := '0';
    signal clk_10MHz : std_logic := '0';
    signal S_AXI_ARESETN : std_logic := '1';
    signal S_AXI_AWADDR : std_logic_vector(4 downto 0) := (others => '0');
    signal S_AXI_AWVALID : std_logic := '0';
    signal S_AXI_AWREADY : std_logic;
    signal S_AXI_WDATA : std_logic_vector(31 downto 0) := (others => '0');
    signal S_AXI_WVALID : std_logic := '0';
    signal S_AXI_WREADY : std_logic;
    signal S_AXI_BRESP : std_logic_vector(1 downto 0);
    signal S_AXI_BVALID : std_logic;
    signal S_AXI_BREADY : std_logic := '0';
    signal S_AXI_ARADDR : std_logic_vector(4 downto 0) := (others => '0');
    signal S_AXI_ARVALID : std_logic := '0';
    signal S_AXI_ARREADY : std_logic;
    signal S_AXI_RDATA : std_logic_vector(31 downto 0);
    signal S_AXI_RRESP : std_logic_vector(1 downto 0);
    signal S_AXI_RVALID : std_logic;
    signal S_AXI_RREADY : std_logic := '0';
    signal CTRL_DATA_OUT : std_logic_vector(31 downto 0);
    signal CTRL_DATA_IN : std_logic_vector(31 downto 0) := (others => '0');
    signal WD_CNT_OUT : std_logic_vector(15 downto 0);
    signal WD_CNT_IN : std_logic_vector(15 downto 0) := (others => '0');
    signal miso : std_logic := '0';
    signal mosi : std_logic;
    signal sclk : std_logic;
    signal cs : std_logic;
    signal bram_clk_a : std_logic;
    signal bram_rst_a : std_logic;
    signal bram_we_a : std_logic_vector(3 downto 0);
    signal bram_en_a : std_logic;
    signal bram_rd_a : std_logic_vector(31 downto 0) := (others => '0');
    signal bram_wr_a : std_logic_vector(31 downto 0);
    signal bram_addr_a : std_logic_vector(29 downto 0);
    signal bram_clk_b : std_logic;
    signal bram_rst_b : std_logic;
    signal bram_we_b : std_logic_vector(3 downto 0);
    signal bram_en_b : std_logic;
    signal bram_rd_b : std_logic_vector(31 downto 0) := (others => '0');
    signal bram_wr_b : std_logic_vector(31 downto 0);
    signal bram_addr_b : std_logic_vector(29 downto 0);
    signal nReset : std_logic := '1';
    signal enable : std_logic := '0';
    signal count : std_logic_vector(31 downto 0) := (others => '0');
    signal intc_pin : std_logic := '1';
    signal intc_ctrl : std_logic;

    -- Clock Generation
    constant clk_100MHz_period : time := 10 ns;
    constant clk_10MHz_period : time := 100 ns;

begin

    -- Instantiate AXI_TOP
    uut_axi_top : AXI_TOP
        port map (
            S_AXI_ACLK => clk_100MHz,
            S_AXI_ARESETN => S_AXI_ARESETN,
            S_AXI_AWADDR => S_AXI_AWADDR,
            S_AXI_AWVALID => S_AXI_AWVALID,
            S_AXI_AWREADY => S_AXI_AWREADY,
            S_AXI_WDATA => S_AXI_WDATA,
            S_AXI_WVALID => S_AXI_WVALID,
            S_AXI_WREADY => S_AXI_WREADY,
            S_AXI_BRESP => S_AXI_BRESP,
            S_AXI_BVALID => S_AXI_BVALID,
            S_AXI_BREADY => S_AXI_BREADY,
            S_AXI_ARADDR => S_AXI_ARADDR,
            S_AXI_ARVALID => S_AXI_ARVALID,
            S_AXI_ARREADY => S_AXI_ARREADY,
            S_AXI_RDATA => S_AXI_RDATA,
            S_AXI_RRESP => S_AXI_RRESP,
            S_AXI_RVALID => S_AXI_RVALID,
            S_AXI_RREADY => S_AXI_RREADY,
            CTRL_DATA_OUT => CTRL_DATA_OUT,
            CTRL_DATA_IN => CTRL_DATA_IN,
            WD_CNT_OUT => WD_CNT_OUT,
            WD_CNT_IN => WD_CNT_IN
        );

    -- Instantiate axi_conv_bridge_spi
    uut_axi_conv_bridge_spi : axi_conv_bridge_spi
        port map (
            clk_100MHz => clk_100MHz,
            CTRL_DATA_MI => CTRL_DATA_OUT,
            CTRL_DATA_SO => CTRL_DATA_IN,
            WD_CNT_MI => WD_CNT_OUT,
            WD_CNT_SO => WD_CNT_IN,
            wd_cnt_conv => open,
            ctrl_data_conv => open
        );

    -- Instantiate top
    uut_top : top
        port map (
            clk_100MHz => clk_100MHz,
            clk_10MHz => clk_10MHz,
            miso => miso,
            mosi => mosi,
            sclk => sclk,
            cs => cs,
            bram_clk_a => bram_clk_a,
            bram_rst_a => bram_rst_a,
            bram_we_a => bram_we_a,
            bram_en_a => bram_en_a,
            bram_rd_a => bram_rd_a,
            bram_wr_a => bram_wr_a,
            bram_addr_a => bram_addr_a,
            bram_clk_b => bram_clk_b,
            bram_rst_b => bram_rst_b,
            bram_we_b => bram_we_b,
            bram_en_b => bram_en_b,
            bram_rd_b => bram_rd_b,
            bram_wr_b => bram_wr_b,
            bram_addr_b => bram_addr_b,
            nReset => nReset,
            enable => enable,
            count => count
        );

    -- Instantiate spi_intc
    uut_spi_intc : spi_intc
        port map (
            clk => clk_100MHz,
            nreset => nReset,
            intc_pin => intc_pin,
            intc_ctrl => intc_ctrl
        );

    -- Clock Process for 100MHz
    clk_100MHz_process : process
    begin
        clk_100MHz <= '0';
        wait for clk_100MHz_period / 2;
        clk_100MHz <= '1';
        wait for clk_100MHz_period / 2;
    end process;

    -- Clock Process for 10MHz
    clk_10MHz_process : process
    begin
        clk_10MHz <= '0';
        wait for clk_10MHz_period / 2;
        clk_10MHz <= '1';
        wait for clk_10MHz_period / 2;
    end process;

    -- Stimulus process
    stimulus : process
    begin
        -- Reset
        S_AXI_ARESETN <= '0';
        nReset <= '0';
        wait for 20 ns;
        S_AXI_ARESETN <= '1';
        nReset <= '1';
        wait for 20 ns;

        -- Write to AXI
        S_AXI_AWADDR <= "00000";
        S_AXI_AWVALID <= '1';
        S_AXI_WDATA <= x"00000001";
        S_AXI_WVALID <= '1';
        wait until (S_AXI_AWREADY = '1' and S_AXI_WREADY = '1');
        S_AXI_AWVALID <= '0';
        S_AXI_WVALID <= '0';
        wait for 10 ns;

        -- Read from AXI
        S_AXI_ARADDR <= "00000";
        S_AXI_ARVALID <= '1';
        wait until (S_AXI_ARREADY = '1');
        S_AXI_ARVALID <= '0';
        S_AXI_RREADY <= '1';
        wait until (S_AXI_RVALID = '1');
        S_AXI_RREADY <= '0';
        wait for 10 ns;

        -- Enable SPI communication
        enable <= '1';
        count <= x"0000000A"; -- count = 10
        wait for 200 ns;
        enable <= '0';

        wait;
    end process;
    
end behavior;
