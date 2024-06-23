library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
--use IEEE.STD_LOGIC_ARITH.ALL;

entity top is
port (
    clk_100MHz : in std_logic;

    nReset : in std_logic;
    enable : in std_logic;
    complete : out std_logic;
    count : in std_logic_vector(31 downto 0);  -- 변경된 부분

    transmit_valid : out std_logic;
    transmit_ready : in std_logic;
    transmit_complete : in std_logic;
    transmit_count : out std_logic_vector(31 downto 0);
    transmit_bram_data : out std_logic_vector(31 downto 0);
    
    transmit_bram_ctrl_valid : out std_logic;
    transmit_bram_ctrl_ready : in std_logic;
    transmit_bram_addr_clr : out std_logic;
    transmit_bram_read_data : in std_logic_vector(31 downto 0);

    spi_top_enable : out std_logic;
    spi_top_valid : in std_logic;
    spi_top_ready : out std_logic;
    spi_top_drdy : in std_logic;

    receivce_valid : out std_logic;
    receive_ready : in std_logic;
    receive_count : out std_logic_vector(31 downto 0);
    receive_bram_data : in std_logic_vector(31 downto 0);
    receive_drdy : out std_logic;

    receive_bram_ctrl_valid : out std_logic;
    receive_bram_ctrl_ready : in std_logic;
    receive_bram_ctrl_addr_clr : out std_logic;
    receive_bram_ctrl_write_data : out std_logic_vector(31 downto 0)

);
end top;

architecture RTL of top is

    signal transmit_valid_reg : std_logic;
    signal transmit_ready_reg : std_logic;
    signal transmit_complete_reg : std_logic;
    signal transmit_count_reg : integer;
    signal bram_data_reg : std_logic_vector(31 downto 0);

    signal drdy_reg : std_logic;

    signal read_data_reg : std_logic_vector(31 downto 0);

    signal bram_valid_reg : std_logic;
    signal bram_ready_reg : std_logic;
    signal bram_addr_clr_reg : std_logic;

    signal spi_enable_reg : std_logic;
    signal spi_valid_reg : std_logic;
    signal mosi_ready_reg : std_logic;

    signal prev_spi_valid : std_logic;
    signal spi_cnt : integer;
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

    signal write_data_reg : std_logic_vector(31 downto 0);
    signal last_flag : std_logic;
    signal complete_reg : std_logic;
begin

    complete <= complete_reg;

    transmit_valid <= transmit_valid_reg;
    transmit_ready_reg <= transmit_ready;
    transmit_complete_reg <= transmit_complete;
    transmit_count <= std_logic_vector(to_unsigned(transmit_count_reg,32));
    transmit_bram_data <= bram_data_reg;

    transmit_bram_ctrl_valid <= bram_valid_reg;
    bram_ready_reg <= transmit_bram_ctrl_ready;
    transmit_bram_addr_clr <= bram_addr_clr_reg;
    read_data_reg <= transmit_bram_read_data;

    spi_top_enable <= spi_enable_reg;
    spi_valid_reg <= spi_top_valid;
    spi_top_ready <= mosi_ready_reg;
    drdy_reg <= spi_top_drdy;


    receivce_valid <= receive_valid_reg;
    receive_ready_reg <= receive_ready;
    receive_count <= std_logic_vector(to_unsigned(receive_count_reg,32));
    recv_bram_data <= receive_bram_data;
    receive_drdy <= recv_drdy;

    receive_bram_ctrl_valid <= bram_validb_reg;
    bram_readyb_reg <= receive_bram_ctrl_ready;
    receive_bram_ctrl_addr_clr <= bram_addrb_clr_reg;
    receive_bram_ctrl_write_data <= write_data_reg;

process(clk_100MHz,nReset)
    variable tmp : integer;
    variable last_count : integer;
    variable target : integer;
begin
    if nReset = '0' then
        recv_drdy <= '0';
        receive_valid_reg <= '0';
        main_state_reg <= idle;
        bram_valid_reg <= '0';
        bram_data_reg <= (others => '0');
        transmit_valid_reg <= '0';
        transmit_count_reg <= 0;
        receive_count_reg <= 0;
        mosi_ready_reg <= '0';
        spi_enable_reg <= '0';
        prev_spi_valid <= '0';
        spi_cnt <= 0;
        bram_validb_reg <= '0';
        bram_addrb_clr_reg <= '0';
        drdy_cnt <= 0;
        tmp := 0;
        complete_reg <= '0';
        last_flag <= '0';
        bram_addr_clr_reg <= '0';
        write_data_reg <= (others => '0');
    elsif rising_edge(clk_100MHz) then
        case main_state_reg is
          when idle =>
            complete_reg <= '0';
            if enable = '1' then
                bram_addr_clr_reg <= '1';
                bram_addrb_clr_reg <= '1';
                drdy_cnt <= 0;
                bram_valid_reg <= '1';
                main_state_reg <= s1;
                tmp := to_integer(unsigned(count));
                if tmp rem 4 = 0 then
                    target := (tmp / 4);
                else
                  target := (tmp / 4) + 1;
                end if;
                
                
                if target > 1 then
                    last_count := 4;
                elsif target = 1 then
                    last_flag <= '1';
                    if tmp rem 4 = 0 then
                        last_count := 4;
                    else
                        last_count := tmp rem 4;
                    end if;
                    
                end if;
            end if;
          when s1 =>
            bram_addr_clr_reg <= '0';
            bram_addrb_clr_reg <= '0';
            if bram_ready_reg = '1' then
                bram_valid_reg <= '0';
                bram_data_reg <= read_data_reg;
                transmit_valid_reg <= '1';
                transmit_count_reg <= last_count;  -- 변경된 부분
                receive_valid_reg <= '1';
                receive_count_reg <= last_count;  -- 변경된 부분
                main_state_reg <= s2;
            end if;
          when s2 =>
            if transmit_complete_reg = '1'  then
                if spi_cnt = transmit_count_reg then
                    transmit_valid_reg <= '0';
                    mosi_ready_reg <= '0';
                    spi_enable_reg <= '0';
                    receive_valid_reg <= '0';
                    main_state_reg <= s3;
                end if;
            else
                mosi_ready_reg <= '1';
                spi_enable_reg <= '1';
            end if;
            if prev_spi_valid = '0' and spi_valid_reg = '1' then
                spi_cnt <= spi_cnt + 1;
                recv_drdy <= '1';
            else
                recv_drdy <= '0';
            end if;
          when s3 =>
            if last_flag = '1' then
                complete_reg <= '1';
                main_state_reg <= done;
            end if;
            
            target := target - 1;
            if target > 1 then
                    last_count := 4;
                    bram_valid_reg <= '1';
                    main_state_reg <= s1;
            elsif target = 1 then
                    last_flag <= '1';
                    if tmp rem 4 = 0 then
                        last_count := 4;
                    else
                        last_count := tmp rem 4;
                    end if;
                    bram_valid_reg <= '1';
                    main_state_reg <= s1;
            end if;
            spi_cnt <= 0;
            bram_validb_reg <= '1';
            write_data_reg <= recv_bram_data;
        when done =>
            main_state_reg <= idle;
          when others =>
            null;
        end case;
        if prev_drdy = '0' and drdy_reg = '1' then
                drdy_cnt <= drdy_cnt + 1;
        end if;
        prev_drdy <= drdy_reg;
        prev_spi_valid <= spi_valid_reg;
    end if;
end process;

end RTL;