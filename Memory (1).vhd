----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:00:28 09/21/2018 
-- Design Name: 
-- Module Name:    Memory - Behavioral 
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
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Memory is
    Port ( data : inout  STD_LOGIC_VECTOR (3 downto 0);
           addr : in  STD_LOGIC_VECTOR (7 downto 0);
           wr : in  STD_LOGIC);
end Memory;

architecture Behavioral of Memory is
	-- Creates a simple array of bytes, 256 bytes total:
	type Memory_Array is array (0 to 2 ** 8) of std_logic_vector(3 downto 0);
	signal mem : Memory_Array;
	
	signal input : std_logic_vector(3 DOWNTO 0);
	signal output : std_logic_vector(3 DOWNTO 0);
	
begin
	input <= data;
	data <= output when wr = '0' else (others => 'Z');
	
	process(addr, wr, input, output)
	begin
		-- Test STA
		mem(0) <= "0010"; -- INC
		mem(1) <= "0011"; -- COM
		mem(2) <= "1011"; -- STA
		mem(3) <= "1111";
		mem(4) <= "1111";
		mem(5) <= "0010"; -- INC
		mem(6) <= "1010"; -- LDA
		mem(7) <= "1111"; 
		mem(8) <= "1111";
		mem(9) <= "0000";
		
		if wr = '1' then
			mem(to_integer(unsigned(addr))) <= input;
		else
			output <= mem(to_integer(unsigned(addr)));
		end if;
	end process;
	
end Behavioral;

