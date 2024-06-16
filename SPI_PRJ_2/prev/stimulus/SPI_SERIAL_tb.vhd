library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_SPISER is
end tb_SPISER;

architecture behavior of tb_SPISER is

    -- Component Declaration for the Unit Under Test (UUT)
    component SPISER
    port(
        CLK_10MHz : in std_logic;
        RST : in std_logic;
        SER2PAR : in std_logic_vector(15 downto 0);
        SEREN : in std_logic;
        SERCOM : out std_logic;
        SERDATA : out std_logic
    );
    end component;

    -- Signals for connecting to the UUT
    signal CLK_10MHz : std_logic := '0';
    signal RST : std_logic := '1';
    signal SER2PAR : std_logic_vector(15 downto 0) := (others => '0');
    signal SERCOM : std_logic;
    signal SERDATA : std_logic;
    signal SEREN : std_logic := '1';

    -- Clock period definitions
    constant CLK_PERIOD : time := 100 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: SPISER
    port map (
        CLK_10MHz => CLK_10MHz,
        RST => RST,
        SER2PAR => SER2PAR,
        SEREN => SEREN,
        SERCOM => SERCOM,
        SERDATA => SERDATA
    );

    -- Clock process definitions
    CLK_10MHz_process :process
    begin
        CLK_10MHz <= '0';
        wait for CLK_PERIOD/2;
        CLK_10MHz <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- hold reset state for 50 ns.
        wait for 50 ns;  
        RST <= '0';
        wait for 50 ns;
        RST <= '1';
        
        wait for 100 ns;
        SEREN <= '0';
        SER2PAR <= x"ABCD";  -- Example input
        
        wait until SERCOM = '1';
        SEREN <= '1';
        -- Add more test vectors as needed
        wait for 1000 ns;  -- wait for 1000 ns before ending the simulation

        -- end simulation
        wait;
    end process;

end behavior;
