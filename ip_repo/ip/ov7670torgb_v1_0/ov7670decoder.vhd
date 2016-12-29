----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2016/12/21 00:35:41
-- Design Name: 
-- Module Name: ov7670decoder - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ov7670decoder is
    port(
        aRst : in std_logic;
        
        PixelClk : out std_logic;
        
        cam_pclk : in std_logic;
        cam_href : in std_logic;
        cam_vsync : in std_logic;
        cam_data : in std_logic_vector(7 downto 0);

        vid_pData : out std_logic_vector(23 downto 0);
        vid_pVDE : out std_logic;
        vid_pHSync : out std_logic;
        vid_pVSync : out std_logic
    );
end ov7670decoder;

architecture Behavioral of ov7670decoder is
    signal pclk : std_logic := '0';
    
    signal pAlignRst : std_logic;
    signal tmp_reset : std_logic;
    signal reset_count : integer range 0 to 4;
    
    signal synced : std_logic;
    signal pclk_en : std_logic;
    
    signal vcount : integer range 0 to 512;
    signal hcount : integer range 0 to 784;
    signal dcount : integer range 0 to 3;
    
    constant VCOUNT_MAX : integer := 510;
    constant HCOUNT_MAX : integer := 784;
    
    constant VCOUNT_DISPLAY_START : integer := 20;
    constant VCOUNT_DISPLAY_END : integer   := 501;
    
    constant HCOUNT_VEN_START : integer := 0;
    constant HCOUNT_VEN_END : integer := 640;
    
    constant VCOUNT_VSYNC_START : integer := 0;
    constant VCOUNT_VSYNC_END   : integer := 3;
    
    constant HCOUNT_HSYNC_START : integer := 659;
    constant HCOUNT_HSYNC_END   : integer := 739;
    
    signal vde : std_logic;
    signal dtmp : std_logic_vector(7 downto 0);
begin

ResetProcess: process (cam_pclk, aRst) begin
    if (aRst = '1') then
        pAlignRst <= '1';
        reset_count <= 0;
        tmp_reset <= '1';
    elsif Rising_Edge(cam_pclk) then
        if (tmp_reset = '1') then
            if (reset_count = 4) then
                -- reset_count <= 0;
                pAlignRst <= '0';
            else
                reset_count <= reset_count + 1;
                pAlignRst <= '1';
            end if;
        end if;
    end if;
end process ResetProcess;

PixelClk <= pclk;
PixelClkGenProcess: process (cam_pclk, cam_vsync) begin
    if (pAlignRst = '1') then
        synced <= '0';
        pclk <= '0';
        pclk_en <= '0';
    else
        if (Rising_Edge(cam_vsync)) then
            pclk_en <= '1';
        end if;
        
        if (Rising_Edge(cam_pclk)) then
            if (pclk_en = '1') then
                pclk <= not pclk;
                synced <= '1';
            end if;
        end if;
    end if;
end process PixelClkGenProcess;

DataDecodeProcess: process (cam_pclk) begin
    if (pAlignRst = '1') then
        dcount <= 0;
        vid_pData <= (others => '0');
        dtmp <= (others => '0');
    elsif (synced = '1') then
        if (vde = '1') then
            -- Data Counter
            if (dcount = 3) then
                dcount <= 0;
            else
                dcount <= dcount + 1;
            end if;
            
            -- Data out
            if (dcount = 2) then
                dtmp <= cam_data;
            elsif (dcount = 0) then
                vid_pData <= dtmp(7 downto 3) & "000" &                       -- R
                             cam_data(4 downto 0) & "000" &                   -- B
                             dtmp(2 downto 0) & cam_data(7 downto 5) & "00";  -- G
            else
                dtmp <= dtmp;
            end if;
        end if;
    end if;
end process DataDecodeProcess;


VENProcess: process (cam_pclk) begin
    if (pAlignRst = '1') then
        vde <= '0';
        vid_pVDE <= '0';
    elsif (Rising_Edge(cam_pclk)) then
        vid_pVDE <= vde;
    
        if (vcount >= VCOUNT_DISPLAY_START and vcount < VCOUNT_DISPLAY_END) then
            if (hcount >= HCOUNT_VEN_START and hcount < HCOUNT_VEN_END) then
                vde <= '1';
            else
                vde <= '0';
            end if;
        else
            vde <= '0';
        end if;
    end if;
end process VENProcess;

CounterProcess: process (pclk) begin
    if (pAlignRst = '1') then
        vcount <= VCOUNT_MAX - 1;
        hcount <= HCOUNT_MAX - 1;
    elsif (Falling_Edge(pclk)) then
        if (pclk_en = '1') then
            if (hcount = HCOUNT_MAX - 1) then
                hcount <= 0;
                if (vcount = VCOUNT_MAX - 1) then
                    vcount <= 0;
                else
                    vcount <= vcount + 1;
                end if;
            else
                hcount <= hcount + 1;
            end if;
        end if;
    end if;
end process CounterProcess;

VSyncGenProcess: process (pclk) begin
    if (Rising_Edge(pclk)) then
        if (pAlignRst = '1') then
            vid_pVSync <= '0';
        else
            if (vcount >=  VCOUNT_VSYNC_START and vcount < VCOUNT_VSYNC_END) then
                vid_pVSync <= '1';
            else
                vid_pVSync <= '0';
            end if;
        end if;
    end if;
end process VSyncGenProcess;

HSyncGenProcess: process (pclk) begin
    if (Rising_Edge(pclk)) then
        if (pAlignRst = '1') then
            vid_pHSync <= '1';
        else
            if (hcount >= HCOUNT_HSYNC_START and hcount < HCOUNT_HSYNC_END) then
                vid_pHSync <= '0';
            else
                vid_pHSync <= '1';
            end if;
        end if;
    end if;
end process HSyncGenProcess;



end Behavioral;
