library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity top is
port (
    clk_100MHz : in std_logic;
    clk_10MHz : in std_logic;
    miso : in std_logic;
    nReset : in std_logic;
    enable : in std_logic
);
end top;

architecture RTL of top is

    component tranmitter
        port(
            clk_100MHz : in std_logic;
            nReset : in std_logic;
            valid : in std_logic;
            ready : out std_logic;
            complete : out std_logic;
            transmit_count : in integer;
            bram_data : in std_logic_vector(31 downto 0);
            transmit_data : out std_logic_vector(7 downto 0);
            drdy : in std_logic;
            latch : out std_logic
        );
    end component;

    component bram_ctrl
        port(
            clk_100MHz : in std_logic;
            nReset : in std_logic;
            valid : in std_logic;
            ready : out std_logic;
            addr_clr : in std_logic;
            read_data : out std_logic_vector(31 downto 0);
            bram_clka : out std_logic;
            bram_rsta : out std_logic;
            bram_wea : out std_logic_vector(3 downto 0);
            bram_ena : out std_logic;
            bram_addra : out std_logic_vector(31 downto 0);
            bram_read_dataa : in std_logic_vector(31 downto 0);
            bram_write_dataa : out std_logic_vector(31 downto 0)
        );
    end component;    

    component SPI_top
    Port (
        clk_10MHz : in std_logic;
        nReset : in std_logic;
        enable : in STD_LOGIC;

        valid : out std_logic;
        ready : in std_logic;
        drdy : out std_logic;

        transmit : out std_logic_vector(7 downto 0);
        receive : in std_logic_vector(7 downto 0);

        sclk : out STD_LOGIC;
        MISO : in STD_LOGIC;
        MOSI : out STD_LOGIC;
        cs : out STD_LOGIC
    );
    end component;    

    component ram
    port(
        ena_a : in std_logic;
        addr_a : in std_logic_vector(9 downto 0);
        wrena_a : in std_logic_vector(3 downto 0);
        wrdata_a : in std_logic_vector(31 downto 0);
        rddata_a : out std_logic_vector(31 downto 0);
        clk_a : in std_logic;
        rst_a : in std_logic
    );
    end component;

    component receiver 
    port
    (
        clk_100MHz : in std_logic;
        nReset : in std_logic;

        valid : in std_logic;
        ready : out std_logic;

        receive_count : in integer;

        bram_data : out std_logic_vector(31 downto 0);
        receive_data : in std_logic_vector(7 downto 0);

        drdy : in std_logic
    );
    end component;

    component miso_bram_ctrl
    port
    (
        clk_100MHz : in std_logic;
        nReset : in std_logic;

        valid : in std_logic;
        ready : out std_logic;
        addr_clr : in std_logic;

        write_data : in std_logic_vector(31 downto 0);

        bram_clka : out std_logic;
        bram_rsta : out std_logic;
        bram_wea : out std_logic_vector(3 downto 0);
        bram_ena : out std_logic;
        bram_addra : out std_logic_vector(31 downto 0);
        bram_write_dataa : out std_logic_vector(31 downto 0)
    );
    end component;

    signal transmit_valid_reg : std_logic;
    signal transmit_ready_reg : std_logic;
    signal transmit_complete_reg : std_logic;
    signal transmit_count_reg : integer;
    signal bram_data_reg : std_logic_vector(31 downto 0);
    signal transmit_data_reg : std_logic_vector(7 downto 0);
    signal drdy_reg : std_logic;
    signal latch_reg : std_logic;
    signal read_data_reg : std_logic_vector(31 downto 0);

    signal bram_valid_reg : std_logic;
    signal bram_ready_reg : std_logic;
    signal bram_addr_clr_reg : std_logic;
    signal bram_clka_reg : std_logic;
    signal bram_rsta_reg : std_logic;
    signal bram_wea_reg : std_logic_vector(3 downto 0);
    signal bram_ena_reg : std_logic;
    signal bram_addra_reg : std_logic_vector(31 downto 0);
    signal bram_read_dataa_reg : std_logic_vector(31 downto 0);
    signal bram_write_dataa_reg : std_logic_vector(31 downto 0);

    signal spi_enable_reg : std_logic;
    signal spi_valid_reg : std_logic;
    signal mosi_ready_reg : std_logic;
    signal receive_data_reg : std_logic_vector(7 downto 0);
    signal sclk_reg : std_logic;
    signal mosi_reg : std_logic;
    signal miso_reg : std_logic;
    signal cs_reg : std_logic;
    signal prev_spi_valid : std_logic;
    signal spi_cnt : integer;
    signal spi_cycle : integer;
    signal drdy_cnt : integer;
    signal prev_drdy : std_logic;

    type main_state is (idle,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,done);
    signal main_state_reg : main_state;

    signal receive_valid_reg : std_logic;
    signal receive_ready_reg : std_logic;
    signal receive_count_reg : integer;
    signal recv_bram_data : std_logic_vector(31 downto 0);
    signal recv_drdy : std_logic;

    signal bram_validb_reg : std_logic;
    signal bram_readyb_reg : std_logic;
    signal bram_addrb_clr_reg : std_logic;
    signal bram_clkb_reg : std_logic;
    signal bram_rstb_reg : std_logic;
    signal bram_web_reg : std_logic_vector(3 downto 0);
    signal bram_enb_reg : std_logic;
    signal bram_addrb_reg : std_logic_vector(31 downto 0);
    signal bram_read_datab_reg : std_logic_vector(31 downto 0);
    signal bram_write_datab_reg : std_logic_vector(31 downto 0);
    signal write_data_reg : std_logic_vector(31 downto 0);
begin

    u1 : tranmitter
    port map(
        clk_100MHz => clk_100MHz,
        nReset => nReset,
        valid => transmit_valid_reg,
        ready => transmit_ready_reg,
        complete => transmit_complete_reg,
        transmit_count => transmit_count_reg,
        bram_data => bram_data_reg,
        transmit_data => transmit_data_reg,
        drdy => drdy_reg,
        latch => latch_reg
    );

    u2 : bram_ctrl
    port map(
        clk_100MHz => clk_100MHz,
        nReset => nReset,
        valid => bram_valid_reg,
        ready => bram_ready_reg,
        addr_clr => bram_addr_clr_reg,
        read_data => read_data_reg,
        bram_clka => bram_clka_reg,
        bram_rsta => bram_rsta_reg,
        bram_wea => bram_wea_reg,
        bram_ena => bram_ena_reg,
        bram_addra => bram_addra_reg,
        bram_read_dataa => bram_read_dataa_reg,
        bram_write_dataa => bram_write_dataa_reg
    );

    u3 : SPI_top
    Port map (
        clk_10MHz => clk_10MHz,
        nReset =>   nReset,
        enable => spi_enable_reg,
        valid =>  spi_valid_reg,
        ready =>  mosi_ready_reg,
        drdy =>   drdy_reg,
        transmit =>  receive_data_reg,
        receive =>  transmit_data_reg,
        sclk =>   sclk_reg,
        MISO =>   miso_reg,
        MOSI =>   mosi_reg,
        cs =>   cs_reg
    );

    u4 : ram
    port map(
        ena_a => bram_ena_reg,
        addr_a => bram_addra_reg(11 downto 2),
        wrena_a => bram_wea_reg,
        wrdata_a => bram_write_dataa_reg,
        rddata_a => bram_read_dataa_reg,
        clk_a => bram_clka_reg,
        rst_a => bram_rsta_reg
    );

    u5 : receiver
    port map(
        clk_100MHz => clk_100MHz,
        nReset  =>   nReset,

        valid => receive_valid_reg,
        ready => receive_ready_reg,

        receive_count => receive_count_reg,

        bram_data => recv_bram_data,
        receive_data => receive_data_reg,

        drdy => recv_drdy
    );

    u6 : miso_bram_ctrl 
    port map
    (
        clk_100MHz => clk_100MHz,
        nReset  =>   nReset,

        valid => bram_validb_reg,
        ready => bram_readyb_reg,
        addr_clr => bram_addrb_clr_reg,

        write_data => write_data_reg,

        bram_clka  => bram_clkb_reg,
        bram_rsta  => bram_rstb_reg,
        bram_wea  => bram_web_reg,
        bram_ena  => bram_enb_reg,
        bram_addra => bram_addrb_reg,
        bram_write_dataa => bram_write_datab_reg
    );

    u7 : ram
    port map(
        ena_a => bram_enb_reg,
        addr_a => bram_addrb_reg(11 downto 2),
        wrena_a => bram_web_reg,
        wrdata_a => write_data_reg,
        rddata_a => open,
        clk_a => bram_clkb_reg,
        rst_a => bram_rstb_reg
    );


    miso_reg <= miso;
    

process(clk_100MHz,nReset)
begin
    if nReset = '0' then
        recv_drdy <= '0';
        receive_valid_reg <= '0';
        main_state_reg <= idle;
        bram_valid_reg <= '0';
        bram_data_reg <= (others => '0');
        --receive_data_reg <= (others => '0');
        transmit_valid_reg <= '0';
        transmit_count_reg <= 0;
        receive_count_reg <= 0;
        mosi_ready_reg <= '0';
        spi_enable_reg <= '0';
        prev_spi_valid <= '0';
        spi_cnt <= 0;
        spi_cycle <= 0;
        bram_validb_reg <= '0';
        bram_addrb_clr_reg <= '0';
        write_data_reg <= (others => '0');
    elsif rising_edge(clk_100MHz) then
        case main_state_reg is
          when idle =>
            if enable = '1' then
                bram_valid_reg <= '1';
                main_state_reg <= s1;
            end if;
          when s1 =>
            if bram_ready_reg = '1' then
                bram_valid_reg <= '0';
                bram_data_reg <= read_data_reg;
                transmit_valid_reg <= '1';
                transmit_count_reg <= 3;
                receive_valid_reg <= '1';
                receive_count_reg <= 3;
                main_state_reg <= s2;
            end if;
          when s2 =>
            if transmit_complete_reg = '1'  then
                if spi_cnt = transmit_count_reg then
                    transmit_valid_reg <= '0';
                    mosi_ready_reg <= '0';
                    spi_enable_reg <= '0';
                    
                    main_state_reg <= s3;
                end if;
            else
                mosi_ready_reg <= '1';
                spi_enable_reg <= '1';
            end if;



            if prev_spi_valid = '0' and spi_valid_reg = '1' then
                spi_cnt <= spi_cnt + 1;
            --elsif prev_spi_valid = '1' and spi_valid_reg = '0' then
                recv_drdy <= '1';
            else
                recv_drdy <= '0';
            end if;
          when s3 =>
            

            

            

            if cs_reg = '1' then
                spi_cnt <= 0;
                -- 원래는 여기서 끝남. 여기까지는 miso 데이터 저장되는거 확인함
                bram_validb_reg <= '1';
                write_data_reg <= recv_bram_data;
                bram_valid_reg <= '1';
                main_state_reg <= s4;
            end if;
          when s4 =>
            bram_validb_reg <= '0';
            if bram_ready_reg = '1' then
                bram_valid_reg <= '0';
                bram_data_reg <= read_data_reg;
                transmit_valid_reg <= '1';
                transmit_count_reg <= 4;
                main_state_reg <= s5;
            end if;
          when s5 =>
            if transmit_complete_reg = '1' then
                if spi_cnt = transmit_count_reg then
                    transmit_valid_reg <= '0';
                    mosi_ready_reg <= '0';
                    spi_enable_reg <= '0';
                    main_state_reg <= s6;
                end if;
            else
                mosi_ready_reg <= '1';
                spi_enable_reg <= '1';
            end if;
            if prev_spi_valid = '0' and spi_valid_reg = '1' then
                spi_cnt <= spi_cnt + 1;
            end if;
        when s6 =>
            if cs_reg = '1' then

                spi_cnt <= 0;
                bram_valid_reg <= '1';
                main_state_reg <= s7;
            end if;
        when s7 =>
            drdy_cnt <= 0;
            if bram_ready_reg = '1' then
                bram_valid_reg <= '0';
                bram_data_reg <= read_data_reg;
                transmit_valid_reg <= '1';
                transmit_count_reg <= 4;
                main_state_reg <= s8;
            end if;
        when s8 =>
            if transmit_complete_reg = '1' then
                if spi_cnt = transmit_count_reg then
                    transmit_valid_reg <= '0';
                    mosi_ready_reg <= '0';
                    main_state_reg <= s9;
                end if;
            else
                mosi_ready_reg <= '1';
                spi_enable_reg <= '1';
            end if;
            if prev_spi_valid = '0' and spi_valid_reg = '1' then
                spi_cnt <= spi_cnt + 1;
            end if;
            if prev_drdy = '0' and drdy_reg = '1' then
                drdy_cnt <= drdy_cnt + 1;
            end if;
        when s9 =>
            if drdy_cnt = 4 then
                if spi_cycle < 3 then
                    spi_cnt <= 0;
                    bram_valid_reg <= '1';
                    main_state_reg <= s7;
                    spi_cycle <= spi_cycle + 1;
                else
                    spi_cnt <= 0;
                    main_state_reg <= done;
                end if;
            end if;

            if prev_drdy = '0' and drdy_reg = '1' then
                drdy_cnt <= drdy_cnt + 1;
            end if;
        when done =>
            main_state_reg <= idle;
          when others =>
            null;
        end case;

        prev_drdy <= drdy_reg;
        prev_spi_valid <= spi_valid_reg;
    end if;
end process;

end RTL;