LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
use work.arrays_pkg.all;

ENTITY Fetch IS
    PORT(   clk         : in std_logic;
            rst         : in std_logic;
            reg_arr     : in reg_array;
            mem_signal  : in std_logic;
            mem_val     : in std_logic_vector(31 downto 0);
            jz_singal   : in std_logic;
            zero_flag   : in std_logic;
            jz_address  : in std_logic_vector(7 downto 0);
            out_instruc : out std_logic_vector (15 downto 0);
            out_address : out std_logic_vector (31 downto 0)
        );
END ENTITY Fetch;



ARCHITECTURE rtl OF Fetch IS
    COMPONENT reg IS
        GENERIC ( n : integer := 32);
        PORT( E, Clk,Rst : IN std_logic;
                d : IN std_logic_vector(n-1 DOWNTO 0);
                q : OUT std_logic_vector(n-1 DOWNTO 0));
    END COMPONENT;

    COMPONENT branch_prediction_ram IS
    GENERIC ( n : integer := 8);
	PORT(
		clk 		: IN std_logic;
		rst			: IN std_logic;
		we  		: IN std_logic;
		address 	: IN  std_logic_vector(n-1 DOWNTO 0);
		take  		: IN  std_logic;
		outState	: OUT std_logic
	);
    END COMPONENT;

    --Instruction Memory
    COMPONENT rom IS
    GENERIC ( n : integer := 16);
    PORT(
        address : IN  std_logic_vector(10 DOWNTO 0);
        dataout : OUT std_logic_vector(n-1 DOWNTO 0));
    END COMPONENT;

    -- n-bit adder
    COMPONENT adder IS
    GENERIC (N : integer := 16);
    PORT(A, B : IN std_logic_vector(N-1  DOWNTO 0);
        Cin : IN std_logic;  
        Cout : OUT std_logic;
        SUM : OUT std_logic_vector(N-1 DOWNTO 0));
    END COMPONENT;

    SIGNAL branch_prediction_out                : std_logic;
    SIGNAL branch_prediction_address            : std_logic_vector (7 downto 0);
    SIGNAL new_address, curr_address, pc_inc    : std_logic_vector (31 downto 0);
    SIGNAL new_instruction, prev_instruction    : std_logic_vector (15 downto 0);
BEGIN
    PC              : reg GENERIC MAP (32) PORT MAP ('1', clk, rst, new_address, curr_address);
    instruction_reg : reg GENERIC MAP (16) PORT MAP ('1', clk, rst, new_instruction, prev_instruction);
    bpram           : branch_prediction_ram PORT MAP (clk, rst, jz_singal, branch_prediction_address, zero_flag, branch_prediction_out);
    instruction_mem : rom PORT MAP (curr_address(10 downto 0), new_instruction);
    PC_Adder        : adder GENERIC MAP (32) PORT MAP (curr_address,  "00000000000000000000000000000000", '1', open, pc_inc);
    
    branch_prediction_address <= jz_address WHEN jz_singal = '1'
    ELSE pc_inc(7 downto 0);

    out_instruc <= prev_instruction;
    out_address <= new_address;

    new_address <= mem_val WHEN mem_signal = '1'
    ELSE reg_arr(to_integer(unsigned(new_instruction(6 downto 4)))) WHEN new_instruction(15 downto 12) = "1100" AND (new_instruction(11) = '0' OR branch_prediction_out = '1')
    ELSE pc_inc;
END rtl;


