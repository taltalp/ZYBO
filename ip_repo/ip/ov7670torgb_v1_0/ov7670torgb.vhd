----------------------------------------------------------------------------------
-- Company: 
-- Engineer: taltalp 
-- 
-- Create Date: 2016/12/20 23:37:39
-- Design Name: ov7670torgb
-- Module Name: ov7670torgb - Behavioral
-- Project Name: ov7670torgb
-- Target Devices: 7-Series
-- Tool Versions: 2016.2
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision: 0.01
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

entity ov7670torgb is
    Generic (
        kRstActiveHigh : boolean := true -- select active-high or active-low reset
    );
    Port (
        -- OV7670 camera interface
        cam_pclk : in std_logic;
        cam_xclk : out std_logic; 
        cam_href : in std_logic;
        cam_vsync : in std_logic;
        cam_data : in std_logic_vector(7 downto 0);
        
        -- OV7670 camera sccb interface
        sccb_scl : out std_logic;
        sccb_sda : inout std_logic;
        
        -- RGB video out
        vid_pData : out std_logic_vector(23 downto 0);
        vid_pVDE : out std_logic;
        vid_pHSync : out std_logic;
        vid_pVSync : out std_logic;
        
        PixelClk : out std_logic;
        
        RefClk : in std_logic; -- 48MHz clock input
        aRst : in std_logic;
        aRst_n : in std_logic
        
    );
end ov7670torgb;

architecture Behavioral of ov7670torgb is
    signal aRst_int : std_logic;
    
    component ov7670decoder is
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
    end component;
begin

ResetActiveLow: if not kRstActiveHigh generate
    aRst_int <= not aRst_n;
end generate ResetActiveLow;

ResetActiveHigh: if kRstActiveHigh generate
    aRst_int <= aRst;
end generate ResetActiveHigh;

-- ========== OV7670 DECODER ==========
ov7670decoder_inst: ov7670decoder
    port map (
        aRst => aRst_int,
        
        PixelClk => PixelClk,
        
        cam_pclk => cam_pclk,
        cam_href => cam_href,
        cam_vsync => cam_vsync,
        cam_data => cam_data,
        
        vid_pData => vid_pData,
        vid_pVDE => vid_pVDE,
        vid_pHSync => vid_pHSync,
        vid_pVSync => vid_pVSync
    );
    
cam_xclk <= RefClk; -- output system clock
-- ====================================

end Behavioral;
