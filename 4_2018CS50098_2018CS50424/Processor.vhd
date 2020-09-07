library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Processor is
	port(clk:in std_logic);
end Processor;

architecture Behavioral of Processor is
	type mem_type is array(0 to 4095)of std_logic_vector(31 downto 0);
	impure function make(infile_name:in string) return mem_type is
		variable memory:mem_type;
		variable index:integer:=0;
		variable invector:std_logic_vector(31 downto 0);
		variable inline:line;
		file infile:text;
	begin
		file_open(infile,infile_name,read_mode);
		while not endfile(infile) loop
			readline(infile,inline);
			read(inline,invector);
			memory(index):=invector;
			index:=index+1;
		end loop;
		return memory;
	end make;
	signal mem:mem_type:=make("C:\Users\Dipen Kumar\Desktop\Assignment3\input.txt");
	type reg_type is array(0 to 31)of std_logic_vector(31 downto 0);
	signal reg:reg_type:=(others=>(others=>'0'));
	signal state:integer:=0;
	signal cmd:std_logic_vector(31 downto 0);
	signal opcode:std_logic_vector(5 downto 0);
	signal rs:std_logic_vector(4 downto 0);
	signal rt:std_logic_vector(4 downto 0);
	signal rd:std_logic_vector(4 downto 0);
	signal shamt:std_logic_vector(4 downto 0);
	signal funct:std_logic_vector(5 downto 0);
	signal adrs:std_logic_vector(15 downto 0);
begin
	process(clk)
		variable i:integer:=0;
	begin
		if clk='1' and clk'event then
			if(state=0)then
				state<=1;
				cmd<=mem(i)(31 downto 0);
				opcode<=mem(i)(31 downto 26);
				rs<=mem(i)(25 downto 21);
				rt<=mem(i)(20 downto 16);
				rd<=mem(i)(15 downto 11);
				shamt<=mem(i)(10 downto 6);
				funct<=mem(i)(5 downto 0);
				adrs<=mem(i)(15 downto 0);
			elsif(state=1)then
				cmd <= mem(i)(31 downto 0);
				opcode<=mem(i)(31 downto 26);
				rs<=mem(i)(25 downto 21);
				rt<=mem(i)(20 downto 16);
				rd<=mem(i)(15 downto 11);
				shamt<=mem(i)(10 downto 6);
				funct<=mem(i)(5 downto 0);
				adrs<=mem(i)(15 downto 0);
				if(cmd="00000000000000000000000000000000")then
					state<=2;
				elsif(opcode="000000")then
					if(funct="100000")then--add
						reg(to_integer(unsigned(rd)))<=std_logic_vector(signed(reg(to_integer(unsigned(rs))))+signed(reg(to_integer(unsigned(rt)))));
					elsif(funct="100010")then--sub
						reg(to_integer(unsigned(rd)))<=std_logic_vector(signed(reg(to_integer(unsigned(rs))))-signed(reg(to_integer(unsigned(rt)))));
					elsif(funct="000000")then--sll
						reg(to_integer(unsigned(rd)))<=std_logic_vector(shift_left(unsigned(reg(to_integer(unsigned(rt)))),to_integer(unsigned(shamt))));
					elsif(funct="000010")then--srl
						reg(to_integer(unsigned(rd)))<=std_logic_vector(shift_right(unsigned(reg(to_integer(unsigned(rt)))),to_integer(unsigned(shamt))));
					end if;
 				elsif(opcode="100011")then--lw
					reg(to_integer(unsigned(rt)))<=mem((to_integer(unsigned(reg(to_integer(unsigned(rs))))))+(to_integer(signed(adrs))));
				elsif(opcode="101011")then--sw
					mem((to_integer(unsigned(reg(to_integer(unsigned(rs))))))+(to_integer(signed(adrs))))<=reg(to_integer(unsigned(rt)));
				end if;
			end if;
			i:=i+1;
		end if;
	end process;
end Behavioral;