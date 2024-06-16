library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AXI_TOP_TB is
--  Entity for testbench does not have any ports
end AXI_TOP_TB;

architecture TB of AXI_TOP_TB is

    -- Component declaration for the Unit Under Test (UUT)
    component AXI_TOP is
        Port (
            S_AXI_ACLK : in std_logic;
            S_AXI_ARESETN : in std_logic;
            S_AXI_AWADDR : in std_logic_vector(4 downto 0);
            S_AXI_AWVALID : in std_logic;
            S_AXI_AWREADY : out std_logic;
            S_AXI_WDATA : in std_logic_vector(31 downto 0);
            S_AXI_WVALID : in std_logic;
            S_AXI_WREADY : out std_logic;
            S_AXI_BRESP : out std_logic_vector(1 downto 0);
            S_AXI_BVALID : out std_logic;
            S_AXI_BREADY : in std_logic;
            S_AXI_ARADDR : in std_logic_vector(4 downto 0);
            S_AXI_ARVALID : in std_logic;
            S_AXI_ARREADY : out std_logic;
            S_AXI_RDATA : out std_logic_vector(31 downto 0);
            S_AXI_RRESP : out std_logic_vector(1 downto 0);
            S_AXI_RVALID : out std_logic;
            S_AXI_RREADY : in std_logic;
            CTRL_DATA : inout std_logic_vector(31 downto 0)
        );
    end component;

    -- Clock period definitions
    constant clk_period : time := 10 ns;

    -- Testbench signals
    signal S_AXI_ACLK : std_logic := '0';
    signal S_AXI_ARESETN : std_logic := '0';
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
    signal CTRL_DATA : std_logic_vector(31 downto 0) := (others => '0');

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: AXI_TOP
        port map (
            S_AXI_ACLK => S_AXI_ACLK,
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
            CTRL_DATA => CTRL_DATA
        );

    -- Clock process definitions
    clk_process :process
    begin
        S_AXI_ACLK <= '0';
        wait for clk_period/2;
        S_AXI_ACLK <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin	
        -- Reset the design
        S_AXI_ARESETN <= '0';
        wait for 20 ns;
        S_AXI_ARESETN <= '1';
        wait for 20 ns;

        -- Test write transaction
        S_AXI_AWADDR <= "00000";
        S_AXI_AWVALID <= '1';
        S_AXI_WDATA <= X"DEADBEEF";
        S_AXI_WVALID <= '1';
        wait until (S_AXI_AWREADY = '1' and S_AXI_WREADY = '1');
        S_AXI_AWVALID <= '0';
        S_AXI_WVALID <= '0';

        -- Wait for write response
        wait until (S_AXI_BVALID = '1');
        S_AXI_BREADY <= '1';
        wait for clk_period;
        wait for clk_period;
        S_AXI_BREADY <= '0';
        wait for clk_period;
        wait for clk_period;
        
        
        -- Test read transaction
        S_AXI_ARADDR <= "00000";
        S_AXI_ARVALID <= '1';
        wait for clk_period;
        S_AXI_ARVALID <= '0';

        -- Wait for read response
        S_AXI_RREADY <= '1';
        wait for clk_period;
        S_AXI_RREADY <= '0';
        wait for clk_period;
  
        -- Test write transaction
        S_AXI_AWADDR <= "00000";
        S_AXI_AWVALID <= '1';
        S_AXI_WDATA <= X"BEAFDEAD";
        S_AXI_WVALID <= '1';
        wait until (S_AXI_AWREADY = '1' and S_AXI_WREADY = '1');
        S_AXI_AWVALID <= '0';
        S_AXI_WVALID <= '0';

        -- Wait for write response
        wait until (S_AXI_BVALID = '1');
        S_AXI_BREADY <= '1';
        wait for clk_period;
        wait for clk_period;
        S_AXI_BREADY <= '0';

        -- Test read transaction
        S_AXI_ARADDR <= "00000";
        S_AXI_ARVALID <= '1';
        wait until (S_AXI_ARREADY = '1');
        S_AXI_ARVALID <= '0';

        -- Wait for read response
        wait until (S_AXI_RVALID = '1');
        S_AXI_RREADY <= '1';
        wait for clk_period;
        S_AXI_RREADY <= '0';

        -- End of simulation
        wait;
    end process;

end TB;
