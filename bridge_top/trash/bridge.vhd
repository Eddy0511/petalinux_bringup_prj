library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity bridge is
    port
    (
        clk_100MHz : in std_logic;
        nReset : in std_logic;
        wordcount : in std_logic_vector(31 downto 0);
        enable : in std_logic;
        busy : out std_logic;
        complete : out std_logic;
        valid : in std_logic;
        ready : out std_logic;
        drdy : in std_logic;
        receive : in std_logic_vector(7 downto 0);
        transmit : out std_logic_vector(7 downto 0);
        ser_BRAM_CLKA : out std_logic;
        ser_BRAM_ENA_A : out std_logic;
        ser_bram_we_a : out std_logic_vector(3 downto 0);
        ser_BRAM_ADDRA : out std_logic_vector(31 downto 0);
        ser_BRAM_DATA_A_READ : in std_logic_vector(31 downto 0);
        ser_BRAM_DATA_A_write : out std_logic_vector(31 downto 0);
        par_BRAM_CLKb : out std_logic;
        par_BRAM_ENA_b : out std_logic;
        par_bram_we_b : out std_logic_vector(3 downto 0);
        par_BRAM_ADDRB : out std_logic_vector(31 downto 0);
        par_BRAM_DATA_B_WRITE : out std_logic_vector(31 downto 0)
    );
end bridge;

architecture RTL of bridge is
    component tranmitter
        port
        (
            clk_100MHz : in std_logic;
            nReset : in std_logic;
            transmiter_en : in std_logic;
            drdy : in std_logic;
            ser_data : in std_logic_vector(31 downto 0);
            transmit : out std_logic_vector(7 downto 0);
            ready : out std_logic;
            ser_ready : out std_logic
        );
    end component;

    component receiver
        port
        (
            clk_100MHz : in std_logic;
            nReset : in std_logic;
            receiver_en : in std_logic;
            receive : in std_logic_vector(7 downto 0)
        );
    end component;

    type bridge_state is (idle,r1,s1,s2,done);
    signal bridge_state_reg : bridge_state := idle;
    signal access_count_reg : std_logic_vector(31 downto 0);
    signal busy_reg : std_logic;
    signal com_reg : std_logic;
    signal transmiter_en : std_logic;
    signal receiver_en : std_logic;

    signal ser_data : std_logic_vector(31 downto 0);
    signal bram_read_complete_reg : std_logic;
    signal bram_ser_en : std_logic;
    signal bram_ena_reg : std_logic;
    signal bram_we_a_reg : std_logic_vector(3 downto 0);
    signal bram_addra_reg : std_logic_vector(31 downto 0);
    signal bram_writea_reg : std_logic_vector(31 downto 0);
    signal bram_read_data : std_logic_vector(31 downto 0);
    signal bram_ser_drdy : std_logic;
    signal bram_ser_reada_data_reg : std_logic_vector(31 downto 0);
    type bram_ser_state is (s0,s1,s2);
    signal bram_ser_state_reg : bram_ser_state;
    signal ser_ready_reg : std_logic;
begin
    busy <= busy_reg;
    complete <= com_reg;

    transceiver_inst : tranmitter
        port map
        (
            clk_100MHz => clk_100MHz,
            nReset => nReset,
            transmiter_en => transmiter_en,
            drdy => drdy,
            ser_data => bram_read_data,
            transmit => transmit,
            ready => ready,
            ser_ready => ser_ready_reg
        );

    receiver_inst : receiver
        port map
        (
            clk_100MHz => clk_100MHz,
            nReset => nReset,
            receiver_en => receiver_en,
            receive => receive
        );

    process(clk_100MHz, nReset)
    begin
        if nReset = '0' then
            bridge_state_reg <= idle;
            busy_reg <= '0';
            com_reg <= '0';
            receiver_en <= '0';
            transmiter_en <= '0';
            access_count_reg <= (others => '0');
        elsif rising_edge(clk_100MHz) then
            case bridge_state_reg is
                when idle =>
                    if enable = '1' then
                        if unsigned(wordcount) = 0 then
                            access_count_reg <= (others => '0');
                        else
                            access_count_reg <= std_logic_vector((unsigned(wordcount) / 4) + 1);
                            busy_reg <= '1';
                            com_reg <= '0';
                            bridge_state_reg <= r1;
                        end if;
                    end if;
                when r1 =>
                    transmiter_en <= '1';
                    receiver_en <= '1';
                    bridge_state_reg <= s1;
                when s1 =>
                    if bram_read_complete_reg = '1' then
                        bridge_state_reg <= done;
                    end if;
                when done =>
                    busy_reg <= '0';
                    com_reg <= '1';
                    bridge_state_reg <= idle;
                when others =>
                    null;
            end case;
        end if;
    end process;

    ser_BRAM_CLKA <= clk_100MHz;
    ser_BRAM_ENA_A <= bram_ena_reg;
    ser_bram_we_a <= bram_we_a_reg;
    ser_BRAM_ADDRA <= bram_addra_reg;
    bram_ser_reada_data_reg <= ser_BRAM_DATA_A_READ;
    ser_BRAM_DATA_A_write <= bram_writea_reg;

    process(clk_100MHz, nReset)
    begin
        if nReset = '0' then
            bram_ser_state_reg <= '0';
            bram_we_a_reg <= "0000";
            bram_writea_reg <= (others => '0');
            bram_read_data <= (others => '0');
            bram_ser_drdy <= '0';
            bram_read_complete_reg <= '0';
        elsif rising_edge(clk_100MHz) then
            case bram_ser_state_reg is
                when s0 =>
                    if transmiter_en = '1' then
                        if bram_ser_en = '1' then
                            if access_count_reg = bram_addra_reg then
                                bram_ser_state_reg <= s0;
                                bram_read_complete_reg <= '1';
                            else
                                bram_ena_reg <= '1';
                                bram_read_complete_reg <= '0';
                                bram_addra_reg <= std_logic_vector(unsigned(bram_addra_reg) + 1);
                                bram_ser_state_reg <= s1;
                            end if;
                        end if;
                    else
                        bram_ser_drdy <= '0';
                        bram_ena_reg <= '0';
                        bram_addra_reg <= (others => '0');
                    end if;
                when s1 =>
                    bram_ena_reg <= '0';
                    bram_read_data <= bram_ser_reada_data_reg;
                    bram_ser_drdy <= '1';
                    bram_ser_state_reg <= s2;
                when s2 =>
                    bram_ser_drdy <= '0';
                    if ser_ready_reg = '1' then
                        bram_ser_state_reg <= s1;
                    end if;
            end case;
        end if;
    end process;
end RTL;
