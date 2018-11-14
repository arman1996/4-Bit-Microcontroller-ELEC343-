----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:17:00 09/21/2018 
-- Design Name: 
-- Module Name:    CPU - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CPU is
    Port ( CLK 	: in  STD_LOGIC;
           INI 	: in  STD_LOGIC;
           dbus 	: inout  STD_LOGIC_VECTOR 	(3 downto 0);
           abus 	: out  STD_LOGIC_VECTOR 	(7 downto 0);
			  wr		: out STD_LOGIC);
end CPU;

architecture Behavioral of CPU is
	-- Define Registers
	signal PC 			: std_logic_vector(7 downto 0);
	signal ACC 			: std_logic_vector(3 downto 0);
	signal OP 			: std_logic_vector(3 downto 0);
	signal Nib2 		: std_logic_vector(3 downto 0);
	signal Nib3 		: std_logic_vector(3 downto 0);
	signal mem_addr 	: std_logic_vector(7 downto 0);
	signal mem_data 	: std_logic_vector(3 downto 0);
	signal mem_data_O 	: std_logic_vector(3 downto 0);
	signal RUN 			: std_logic;
	signal accessMemory : std_logic;
	
	-- Define Flags
	signal C : std_logic;
	signal Z : std_logic;

	signal mem_input : STD_LOGIC_VECTOR(3 DOWNTO 0);
	signal mem_output : STD_LOGIC_VECTOR(3 DOWNTO 0);

	-- Define States
	type state is (FO, FN, FB, EX);
	signal currentST : state; -- current state

begin
	mem_data <= dbus;
	process(CLK)
		variable temp		: std_logic_vector(4 downto 0);
		--variable temp8		: std_logic_vector(7 downto 0);
	begin
		if INI='1' then
			PC 			<= "00000000"; 
			ACC 			<= "0000";
			OP 			<= "0000"; 
			currentST 	<= FO;
			Nib2 			<= "0000"; 
			Nib3 			<= "0000";
			C 				<= '0';
			Z 				<= '0';
			RUN 			<= '1';
			wr 			<= '0';
			accessMemory <= '0';
			dbus			<= "ZZZZ";
		
		elsif (CLK'event and CLK='1' and RUN='1') then
			case currentST is
				when FO =>
					OP <= mem_data;
					
					-- For INH
					if mem_data(3) = '0' then --0000 checking 4th bit
						currentST <= EX;
						PC <= (PC + 1);
					elsif mem_data(3) = '1' then
						currentST <= FN;
						PC <= (PC + 1);
					else
						currentST <= FO;
					end if;
				
				when FN =>
					PC <= (PC + 1);
					Nib2 <= mem_data;
					
					-- For REL
					if (OP = "1000" or OP = "1001") then
						currentST <= EX;
					-- For EXT
					elsif (OP >= "1010" and OP <= "1111") then
						currentST <= FB;
					else
						currentST <= FO; -- If OP code error reset
					end if;
					
				-- Go To Execution
				when FB =>
					PC <= (PC + 1);
					Nib3 <= mem_data;
					currentST <= EX;
					--if OP = "1011" then
					--	wr <= '1';
					--end if;
				
				-- Execution Of Operations
				when EX =>
					case OP is
						-- Performs STOP
						when "0000" => -- STP
							RUN <= '0';
						
						-- Performs CLEAR ACC and CLEAR CARRY FLAG
						when "0001" => -- CLR
							ACC <= "0000";
							C <= '0';
						
						-- Performs INCREMENTS ACC
						when "0010" => -- INC
							temp := ('0'&ACC) + "0001";
							ACC <= temp(3 downto 0);
							C <= temp(4);
							if(temp(3 downto 0) = "0000") then
								Z <= '1';
							else Z <= '0';
							end if;
						
						-- Performs 1's COMPLEMENT On ACC
						when "0011" => -- COM
							if(ACC = "1111") then
								Z <= '1';
							else Z <= '0';
							end if;
							ACC <= not ACC;
							
						-- Performs ROTATE A left through C
						when "0100" => -- ROL
							temp := ACC( 2 downto 0)&C&ACC(3);
							c <= temp(4);
							if(temp(4 downto 1) = "0000") then
								Z <= '1';
							else Z <= '0';
							end if;
							ACC <= temp(4 downto 1);
						
						-- Performs arithmetic SHIFT left A
						when "0101" => -- ASL
							temp := ACC(3 downto 0)&'0';
							if(temp(3 downto 0) = "0000") then
								Z <= '1';
							else Z <= '0';
							end if;
							ACC <= temp(3 downto 0);
							
						-- Performs ROTATE A right through C
						when "0110" => -- ROR
							temp := ACC(0)&C&ACC(3 downto 1);
							c <= temp(4);
							if(temp(3 downto 0) = "0000") then
								Z <= '1';
							else Z <= '0';
							end if;
							ACC <= temp(3 downto 0);
						
						-- Performs arithmetic SHIFT right A and C
						when "0111" => -- ASR
							--temp := '0'&ACC(3)&ACC(3 downto 1);
							temp := '0'&C&ACC(3 downto 1);
							if (temp(3 downto 0) = "0000") then
								Z <= '1';
							else Z <= '0';
							end if;
							ACC <= temp(3 downto 0);
							
						when "1000" => --BRC
							if (C = '1') then
								if(Nib2(3) = '0') then
									-- Forward Branch
									PC <= PC + ("00000"&Nib2(2 downto 0));
								elsif (Nib2(3) = '1') then
									-- Backward Branch
									--if PC > "0001" then -- greater than 1
										PC <= PC - 2 -("00000"&Nib2(2 downto 0));
									--else
									--	PC <= "00000000";
									--end if;
								else
									PC <= "00000000";
								end if;
							end if;
						
						when "1001" => --BRZ
							if (Z = '1') then
								if(Nib2(3) = '0') then
									-- Forward Branch
									PC <= PC + ("00000"&Nib2(2 downto 0));
								elsif (Nib2(3) = '1') then
									-- Backward Branch
									--if PC > "0001" then -- greater than 1
										PC <= PC - 2 -("00000"&Nib2(2 downto 0));
									--else
									--	PC <= "00000000";
									--end if;
								else
									PC <= "00000000";
								end if;
							end if;
						
						when "1010" => --LDA
								temp := '0'&mem_data;
								if(temp = "0000") then
									Z <= '1';
								else Z <= '0';
								end if;
								ACC <= temp(3 downto 0);
						
						when "1011" => --STA
							wr <= '0';
							
						when "1100" => --ADD
							temp := ('0'&ACC) + ('0'&mem_data);
							C <= temp(4);
							ACC <= temp(3 downto 0);
							if (temp(3 downto 0) = "0000") then
								Z <= '1';
							else Z <= '0';
							end if;
	
						
						when "1101" => --SBA
							temp := ('0'&ACC) + (not('0'&mem_data) + "00001");
							C <= temp(4);
							ACC <= temp(3 downto 0);
							if(temp(3 downto 0) = "0000") then
								Z <= '1';
							else Z <= '0';
							end if;
	
							
						when "1110" => --AND
							temp := '0'&ACC and '0'&mem_data;
							if (temp(3 downto 0) = "0000") then
								Z <= '1';
							else Z <= '0';
							end if;
							ACC <= temp(3 downto 0);
							
						when "1111" => --JMP
							PC <= Nib2 & Nib3;
							
						when others =>
					end case;
					currentST <= FO;
			end case;
			if OP = "1011" and currentST = FB then
				wr <= '1';
			end if;
		end if;
	end process;
	
	dbus <= ACC when (OP = "1011" and currentST = EX) else (others => 'Z');
	
	with currentST select
		abus <= PC when FO|FN|FB,
		Nib2 & Nib3 when others;
	
end Behavioral;

