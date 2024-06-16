library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TB_SPIPAR is
end TB_SPIPAR;

architecture behavior of TB_SPIPAR is

    -- Component Declaration for the Unit Under Test (UUT)
    component SPIPAR
    port(
        CLK_10MHz : in std_logic;
        RST : in std_logic;
        PARDATA : out std_logic_vector(15 downto 0);
        PARCOM : out std_logic;
        PARING : out std_logic;
        PAREN : in std_logic;
        SERDATA : in std_logic
    );
    end component;

    -- Signals for Stimulus
    signal CLK_10MHz : std_logic := '0';
    signal RST : std_logic := '1';
    signal PARDATA : std_logic_vector(15 downto 0);
    signal PARCOM : std_logic;
    signal PARING : std_logic;
    signal SERDATA : std_logic := '0';
    signal PAREN : std_logic := '1';

    -- Clock period definitions
    constant CLK_PERIOD : time := 100 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: SPIPAR
    port map (
        CLK_10MHz => CLK_10MHz,
        RST => RST,
        PARDATA => PARDATA,
        PARCOM => PARCOM,
        PARING => PARING,
        PAREN => PAREN,
        SERDATA => SERDATA
    );

    -- Clock process definitions
    CLK_10MHz_process : process
    begin
        CLK_10MHz <= '0';
        wait for CLK_PERIOD/2;
        CLK_10MHz <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- hold reset state for 100 ns.
        wait for 50 ns;  
        RST <= '0';
        wait for 50 ns;
        RST <= '1';
        wait for 100 ns;

        PAREN <= '0';
        SERDATA <= '1';
        wait for 200 ns;
        -- Add stimulus here

        SERDATA <= '1';
        wait for 100 ns;
        SERDATA <= '0';
        wait for 100 ns;
        SERDATA <= '1';

        wait for 100 ns;
        SERDATA <= '1';
        wait for 100 ns;
        SERDATA <= '1';
        wait for 100 ns;
        SERDATA <= '0';
        wait for 100 ns;
        SERDATA <= '0';

        wait for 100 ns;
        SERDATA <= '1';
        wait for 100 ns;
        SERDATA <= '0';
        wait for 100 ns;
        SERDATA <= '1';
        wait for 100 ns;
        SERDATA <= '1';

        wait for 100 ns;
        SERDATA <= '1';
        wait for 100 ns;
        SERDATA <= '0';
        wait for 100 ns;
        SERDATA <= '1';
        wait for 100 ns;
        SERDATA <= '0';                        
        wait for 100 ns;

        SERDATA <= '0';

        wait until PARCOM = '1';
        PAREN <= '1';
        
        -- more stimulus can be added as needed

        wait;
    end process;

end behavior;
