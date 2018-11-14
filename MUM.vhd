----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:23:54 10/07/2018 
-- Design Name: 
-- Module Name:    MUM - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MUM is
    Port ( CLK 	: in  STD_LOGIC;
           INI 	: in  STD_LOGIC--;
			  --dbus 	: inout  STD_LOGIC_VECTOR 	(3 downto 0)
			  );
end MUM;

architecture Behavioral of MUM is

-- Component for the Memory
	Component Memory is
		PORT( data : inout STD_LOGIC_VECTOR(3 DOWNTO 0);-- Data Read From Memory
				addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);-- Address
				wr : IN STD_LOGIC); -- Memory Enable
	End Component;

-- Component for the CPU
	Component CPU is
		PORT( CLK 	: in  STD_LOGIC;
				INI 	: in  STD_LOGIC;
				dbus 	: inout  STD_LOGIC_VECTOR 	(3 downto 0);
				abus 	: out  STD_LOGIC_VECTOR 	(7 downto 0);
				wr		: out STD_LOGIC);
	End Component;
	
	signal wrTMP : STD_LOGIC;
	signal dataTmpIO_Tmp : STD_LOGIC_VECTOR (3 DOWNTO 0);
	signal addressTMP: STD_LOGIC_VECTOR 	(7 downto 0);
	
	begin
		-- Map Registers To CPU0
		CPU_instance : CPU
		port map (CLK, INI, dataTmpIO_Tmp, addressTMP, wrTMP);
		
		Memory_instance : Memory
		port map (dataTmpIO_Tmp, addressTMP, wrTMP);
		
		--dbus <= dataTmpIO_Tmp;
end Behavioral;

