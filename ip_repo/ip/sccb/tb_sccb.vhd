----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/03/26 12:29:12
-- Design Name: 
-- Module Name: tb_sccb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity tb_sccb is
--  Port ( );
end tb_sccb;

architecture Behavioral of tb_sccb is

    constant PERIOD : time := 10 ns;

component sccb_top is
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
    end component;

    signal clk : std_logic;
    signal reset : std_logic;
    signal sda : std_logic;
    signal sck : std_logic;
    signal sccb_en : std_logic;
    signal addr : std_logic_vector(7 downto 0);
    signal subaddr : std_logic_vector(7 downto 0);
    signal w_data : std_logic_vector(7 downto 0);
    signal r_data : std_logic_vector(7 downto 0);
    signal start : std_logic;
    signal done : std_logic;
    signal busy : std_logic;
begin

clock_process: process begin
    clk <= '0';
    wait for PERIOD/2;
    clk <= '1';
    wait for PERIOD/2;
end process;
    
inst_sccb : sccb_top port map(
                clk_ip => clk,
                reset_ip => reset,
                clk_div_ip => "000000000011",
                
                sda_dp => sda,
                sck_op => sck,
                sccb_en_op => sccb_en,
                
                addr_ip => addr,
                subaddr_ip => subaddr,
                w_data_ip => w_data,
                r_data_op => r_data,
                
                start_ip => start,
                done_op => done,
                busy_op => busy
    );

    process begin
    reset <= '0';
    start <= '0';
    wait for PERIOD * 2;
    reset <= '1';
    wait for PERIOD;
    reset <= '0';
    wait for PERIOD;
    addr <= x"54";
    subaddr <= x"99";
    w_data <= x"AA";
    wait for PERIOD;
    start <= '1';
    wait for PERIOD;
    start <= '0';
    wait for PERIOD;
    wait;
    end process;


end Behavioral;
