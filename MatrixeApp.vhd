library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
--use MaxLed_inter.all;
entity MatrixeApp is

	port
	(
		clk		 : in	std_logic;
		input	 : in	std_logic;
		otrame	 : out std_logic_vector(15 downto 0);
		oclk10k : out std_logic
	);

end entity;

architecture rtl of MatrixeApp is
	signal tramescan 			: std_logic_vector(15 downto 0):="0000101100001111";-- scan limit display digits from 0-7
	signal trameshtdwn 		: std_logic_vector(15 downto 0):="0000110000000001";-- shutdown normal operation
	signal tramedisplay 		: std_logic_vector(15 downto 0):="0000111100000000";-- display test normal operation
	signal tramedecodemod	: std_logic_vector(15 downto 0):="0000100100000000";-- decode mode  no decode for digits 7-0
	signal trameintensity	: std_logic_vector(15 downto 0):="0000101000000111";-- intesity
	type state_type is (init,state2,cpt);
	signal state : state_type;
	signal clk10k :std_logic:='0';
	
	begin
	process(clk,clk10k)
	variable compteur : natural :=0;
	begin
		if rising_edge(clk) then
			compteur := compteur +1;
			if (compteur = 10000) then
				clk10k <= not clk10k;
				compteur :=0;
			end if;
		end if;		
	end process;
	
	process (state,clk10k,input)
	variable v : integer range 0 to 5 :=0;
	variable t : integer range 0 to 9 :=0;
	
	begin
		if input = '0' then
			state <= init; 
			v :=0;
			t :=0;
		elsif (falling_edge(clk10k)) then
			Case state is
				when init =>
					case v is	   -- Initialisation the frames 
						when 0 =>
							otrame <= tramescan;       
							--state <= d15;
						when 1 =>
							otrame <= tramedecodemod;
							--state <= d15;
						when 2 =>
							otrame <= trameshtdwn;
							--state <= d15;
						when 3 =>
							otrame <= tramedisplay;
							--state <= d15;
						when 4 =>
							otrame <= trameintensity; 
						when others => null;
					end case ;	
				state <= state2;
				when state2 => 
					case t is
						when 1 =>
							otrame <="0000" & "0001" & "00000000" ;   --std_logic_vector(to_unsigned(t,4))
						when 2 =>
							otrame <="0000" & "0010" & "00100100" ;    --std_logic_vector(to_unsigned(t,4)) 
						when 3 =>
							otrame <="0000" & "0011" & "00000000" ;
						when 4 =>
							otrame <="0000" & "0100" & "01000010" ;
						when 5 =>
							otrame <="0000" & "0101" & "00111100" ;
						when 6 =>
							otrame <="0000" & "0110" & "00000000" ;
						when 7 =>
							otrame <="0000" & "0111" & "00000000" ;
						when 8 =>
							otrame <="0000" & "1000" & "00000000" ;
						when others => null;
					  state <= cpt;
					end case;
				when cpt =>
					if v >=5 then
						v :=5;
						t:= (t mod 8)+1;
					else
						v := v+1;
					end if;
					state <= init;
				when others => null;	
			end case;
		end if;
	end process;
	oclk10k<=clk10k;	
end rtl;