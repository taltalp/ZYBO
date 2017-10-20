----------------------------------------------------------------------------------
-- Engineer: taltalp
-- Create Date: 2017/06/16
-- Design Name: VideoTestPatternGenerator
-- Module Name: testpatterngen - Behavioral
-- Description: 
-- 
-- Revision:
-- Revision 0.01 - File Created
--
-- Additional Comments:
--  Video Timing Charts
--  http://www.3dexpress.de/displayconfigx/timings.html
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity testpatterngen is
    Port ( refclk_ip : in STD_LOGIC;
           reset_n_ip : in STD_LOGIC;
           hsync_op : out STD_LOGIC;
           vsync_op : out STD_LOGIC;
           data_op : out STD_LOGIC_VECTOR(23 downto 0);
           vde_op : out STD_LOGIC
           );
end testpatterngen;

architecture Behavioral of testpatterngen is
    signal clk : std_logic;
    signal reset : std_logic;
    
    signal hcnt : integer range 0 to 2000;
    signal vcnt : integer range 0 to 1000;
    
    constant H_SYNC_START : integer := 73;
    constant H_SYNC_STOP  : integer := 152;
    constant V_SYNC_START : integer := 4;
    constant V_SYNC_STOP  : integer := 8;
    
    constant H_VEN_START : integer := 368;
    constant H_VEN_STOP  : integer := 1648;
    constant V_VEN_START : integer := 30;
    constant V_VEN_STOP  : integer := 750;
    
    constant H_TOTAL : integer := 1648;
    constant V_TOTAL : integer := 750;
    
    signal hsync : std_logic;
    signal vsync : std_logic;
    
    signal hen : std_logic;
    signal ven : std_logic;
    signal vde : std_logic;
    
    signal data : std_logic_vector(23 downto 0);
begin
    clk <= refclk_ip;
    reset <= not reset_n_ip;
    
    -- Pixel Counter
    process (clk) begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                hcnt <= 0;
                vcnt <= 0;
            else
                if (hcnt = H_TOTAL - 1) then
                    hcnt <= 0;
                    if (vcnt = V_TOTAL - 1) then
                        vcnt <= 0;
                    else
                        vcnt <= vcnt + 1;
                    end if;
                else
                    hcnt <= hcnt + 1;
                end if;
            end if;
        end if;
    end process;

    -- HSYNC HEN
    hsync_op <= hsync;
    process (clk) begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                hsync <= '0';
            else
                if (hcnt >= H_SYNC_START and hcnt < H_SYNC_STOP) then
                    hsync <= '1';
                else
                    hsync <= '0';
                end if;
                
                if (hcnt >= H_VEN_START and hcnt < H_VEN_STOP) then
                    hen <= '1';
                else
                    hen <= '0';
                end if;
            end if;
        end if;
    end process;

    -- VSYNC VEN
    vsync_op <= vsync;
    process (clk) begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                vsync <= '0';
            else
                if (vcnt >= V_SYNC_START and vcnt < V_SYNC_STOP) then
                    vsync <= '1';
                else
                    vsync <= '0';
                end if; 
                
                if (vcnt >= V_VEN_START and vcnt < V_VEN_STOP) then
                    ven <= '1';
                else
                    ven <= '0';
                end if;
            end if;
        end if;
    end process;

    -- VDE
    vde_op <= vde;
    vde <= hen and ven;

    -- DATA
    data_op <= data;
    process (clk) begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                data <= x"000000";
            else
                if (hcnt >= 368 and hcnt < 496) then
                    data <= x"FFFFFF";
                elsif (hcnt >= 496 and hcnt < 624) then
                    data <= x"7F7F7F";
                elsif (hcnt >= 624 and hcnt < 752) then
                    data <= x"FFFF00";
                elsif (hcnt >= 752 and hcnt < 880) then
                    data <= x"00FFFF";
                elsif (hcnt >= 880 and hcnt < 1008) then
                    data <= x"00FF00";
                elsif (hcnt >= 1008 and hcnt < 1136) then
                    data <= x"FF00FF";
                elsif (hcnt >= 1136 and hcnt < 1264) then
                    data <= x"FF0000";
                elsif (hcnt >= 1264 and hcnt < 1392) then
                    data <= x"0000FF";
                elsif (hcnt >= 1392 and hcnt < 1520) then
                    data <= x"1C7F1C";
                elsif (hcnt >= 1520 and hcnt < 1648) then
                    data <= x"000000";
                else
                    data <= x"000000";
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;
