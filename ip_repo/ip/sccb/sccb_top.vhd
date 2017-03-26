----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/03/26 10:13:42
-- Design Name: 
-- Module Name: sccb_top - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity sccb_top is
    Port ( clk_ip     : in  STD_LOGIC;
           reset_ip   : in  STD_LOGIC;
           clk_div_ip : in  STD_LOGIC_VECTOR (11 downto 0); -- Clock divider value to configure SCK frequency
           
           sda_dp     : inout STD_LOGIC;  -- SCCB DATA
           sck_op     : out STD_LOGIC;    -- SCCB CLOCK
           sccb_en_op : out STD_LOGIC;    -- SCCB Transmission Enable
           
           addr_ip    : in  STD_LOGIC_VECTOR (7 downto 0); -- Address
           subaddr_ip : in  STD_LOGIC_VECTOR (7 downto 0); -- Sub-Address
           w_data_ip  : in  STD_LOGIC_VECTOR (7 downto 0); -- Write Data
           r_data_op  : out STD_LOGIC_VECTOR (7 downto 0); -- Read Data
           
           start_ip   : in  STD_LOGIC;  -- Start Transmission
           done_op    : out STD_LOGIC;  -- Transmission process done
           busy_op    : out STD_LOGIC); -- Transmissino processing
end sccb_top;

architecture Behavioral of sccb_top is
    signal write : std_logic;
    signal read  : std_logic;
    signal done : std_logic;
    signal busy : std_logic;
    
    signal addr : std_logic_vector(7 downto 0);
    signal subaddr : std_logic_vector(7 downto 0);
    signal w_data : std_logic_vector(7 downto 0);
    
    signal sccb_en : std_logic;
    
    signal sck : std_logic;
    signal sda : std_logic;
    
    signal out_en : std_logic;
    signal clk_count : std_logic_vector(11 downto 0);
    signal cycle : std_logic;
    signal bit_cnt : std_logic_vector(3 downto 0);
    signal div2 :  std_logic;
    
    type state_e is (s_start, s_idle, s_addr, s_subaddr, s_write, s_read, s_stop);
    signal state : state_e;
begin
    write <= not addr_ip(0);
    read  <= addr_ip(0);
    
    sda_dp <= sda;
    sck_op <= sck when sccb_en = '0' else '1';
    sccb_en_op <= sccb_en;

    done_op <= done;
    busy_op <= busy;
    done <= '1' when (state = s_idle) or (busy = '0') else '0';
    
    process (clk_ip) begin
        if (rising_edge(clk_ip)) then
            if (reset_ip = '1') then
                state <= s_idle;
                
                sck <= '0';
                clk_count <= (others => '0');
                
                busy <= '0';
                cycle <= '0';
                out_en <= '1';
                
                sccb_en <= '1';
                sda <= 'Z';
                
                bit_cnt <= (others => '0');
                
                r_data_op <= (others => 'Z');
            else 
                if (state = s_idle) then
                    busy <= '0';
                    sccb_en <= '1';
                    sda <= '1';
                    
                    bit_cnt <= (others => '0');
                    cycle <= '0';
                    div2 <= '0';
                    
                    if (start_ip = '1') then
                        state <= s_start;
                        addr <= addr_ip;
                        subaddr <= subaddr_ip;
                        w_data <= w_data_ip;
                    else
                        state <= s_idle;
                    end if;
                else
                    if (clk_count = clk_div_ip) then
                        if (div2 = '1') then
                            clk_count <= (others => '0');
                            div2 <= '0';
                        else
                            div2 <= '1';
                        end if;
                        
                        sck <= not sck;
                        
                        if (div2 = '1') then
                            case (state) is
                                when s_start =>
                                    busy <= '1';
                                    state <= s_addr;
                                    sda <= '0';
                                when s_addr =>
                                    sccb_en <= '0';
                                    
                                    if (bit_cnt < "1000") then
                                        sda <= addr(7 - conv_integer(bit_cnt));
                                        bit_cnt <= bit_cnt + 1;
                                    else
                                        sda <= 'Z';
                                        bit_cnt <= "0000";
                                        
                                        if (read = '1' and cycle = '1') then
                                            state <= s_read;
                                        else
                                            state <= s_subaddr;
                                        end if;
                                    end if;
                                when s_subaddr =>
                                    busy <= '1';
                                    
                                    if (bit_cnt < "1000") then
                                        out_en <= '0';
                                        sda <= subaddr(7 - conv_integer(bit_cnt));
                                        bit_cnt <= bit_cnt + 1;
                                    else
                                        sda <= 'Z';
                                        bit_cnt <= "0000";
                                        
                                        cycle <= read;
                                        
                                        if (read = '1') then
                                            state <= s_addr;
                                        else
                                            state <= s_write;
                                        end if;
                                    end if;
                                when s_read =>
                                    state <= s_idle; -- Not Implemented
                                when s_write =>
                                    busy <= '1';
                                    
                                    if (bit_cnt < "1000") then
                                        sda <= w_data(7 - conv_integer(bit_cnt));
                                        bit_cnt <= bit_cnt + '1';
                                    else
                                        bit_cnt <= "0000";
                                        sda <= 'Z';
                                        state <= s_stop;
                                    end if;
                                when s_stop =>
                                    if(bit_cnt < "0001") then
                                        sda <= '0';
                                        sccb_en <= '0';
                                        bit_cnt <= bit_cnt + 1;
                                    else
                                        sccb_en <= '1';
                                        state <= s_idle;
                                        bit_cnt <= "0000";
                                    end if;
                                when others =>
                                    state <= s_idle;
                            end case;
                        end if;
                    else
                        if (div2 = '1') then
                            clk_count <= clk_count + 1;
                            div2 <= '0';
                        else
                            div2 <= '1';
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
