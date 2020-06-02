LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
use work.arrays_pkg.all;

ENTITY Fetch IS
    PORT(   clk             : in std_logic;
            rst             : in std_logic;
            reg_arr         : in reg_array;
            mem_signal      : in std_logic;
            mem_val         : in std_logic_vector(31 downto 0);
            jz_signal       : in std_logic;
            zero_flag       : in std_logic;
            jz_address      : in std_logic_vector(7 downto 0);
            force_pc        : in std_logic;
            correct_pc      : in std_logic_vector (31 downto 0);
            skip_instruc    : in std_logic;
            branch_status   : out std_logic;
            out_instruc     : out std_logic_vector (15 downto 0);
            out_address     : out std_logic_vector (31 downto 0);
            -- Forwarding
            reg_match       : in std_logic;
            reg_fwd_val     : in std_logic_vector(31 downto 0);
            -- Stalling
            stall           : in std_logic
        );
END ENTITY Fetch;



ARCHITECTURE rtl OF Fetch IS
    COMPONENT reg_rise IS
        GENERIC ( n : integer := 32);
        PORT( E, Clk,Rst    : IN std_logic;
                d           : IN std_logic_vector(n-1 DOWNTO 0);
                q           : OUT std_logic_vector(n-1 DOWNTO 0));
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
    COMPONENT memory IS
    GENERIC (
        dataW : INTEGER := 16;
        busW : INTEGER := 128;
        addressW : INTEGER := 11);
    PORT (
        clk : IN std_logic;
        we : IN std_logic;
        re : IN std_logic;
        address : IN std_logic_vector(addressW - 1 DOWNTO 0);
        datain : IN std_logic_vector(busW - 1 DOWNTO 0);
        dataout : OUT std_logic_vector(busW - 1 DOWNTO 0));
    END COMPONENT;

    -- n-bit adder
    COMPONENT adder IS
    GENERIC (N  : integer := 16);
    PORT(A, B   : IN std_logic_vector(N-1  DOWNTO 0);
        Cin     : IN std_logic;  
        Cout    : OUT std_logic;
        SUM     : OUT std_logic_vector(N-1 DOWNTO 0));
    END COMPONENT;

    SIGNAL branch_prediction_out, branch_we     : std_logic;
    SIGNAL branch_prediction_address            : std_logic_vector (7 downto 0);
    SIGNAL new_address, curr_address, pc_inc    : std_logic_vector (31 downto 0);
    SIGNAL normal_curr_address                  : std_logic_vector (31 downto 0);
    SIGNAL new_instruction                      : std_logic_vector (15 downto 0);
    SIGNAL pc_enable                            : std_logic;
    SIGNAL correct_dst                          : std_logic;
BEGIN
    PC              : reg_rise GENERIC MAP (32) PORT MAP (pc_enable, clk, rst, new_address, normal_curr_address);
    -- instruction_reg : reg GENERIC MAP (16) PORT MAP ('1', clk, rst, new_instruction, out_instruc);
    bpram           : branch_prediction_ram PORT MAP (clk, rst, branch_we, branch_prediction_address, zero_flag, branch_prediction_out);
    instruction_mem : memory GENERIC MAP(16, 16, 11) PORT MAP ('0', '0', '1', curr_address(10 downto 0), "0000000000000000", new_instruction);
    PC_Adder        : adder GENERIC MAP (32) PORT MAP (curr_address,  "00000000000000000000000000000000", '1', open, pc_inc);
    
    pc_enable <= NOT stall;

    branch_prediction_address <= jz_address WHEN jz_signal = '1'
    ELSE curr_address(7 downto 0);

    branch_we <= jz_signal AND (NOT skip_instruc);

    curr_address <= mem_val WHEN mem_signal = '1'
    ELSE reg_fwd_val WHEN force_pc = '1' AND zero_flag = '1' AND reg_match = '1'
    ELSE correct_pc WHEN force_pc = '1'
    ELSE normal_curr_address;

    out_instruc <= new_instruction;
    out_address <= pc_inc;
    branch_status <= branch_prediction_out;

    correct_dst <= '1' WHEN skip_instruc = '0' AND new_instruction(15 downto 12) = "1100" AND (new_instruction(11) = '0' OR branch_prediction_out = '1')
                ELSE '0';

    new_address <= reg_fwd_val WHEN skip_instruc = '0' AND new_instruction(15 downto 12) = "1100" AND (new_instruction(11) = '0' OR zero_flag = '1') AND reg_match = '1' AND stall = '0'
    ELSE reg_arr(to_integer(unsigned(new_instruction(6 downto 4)))) WHEN skip_instruc = '0' AND new_instruction(15 downto 12) = "1100" AND (new_instruction(11) = '0' OR branch_prediction_out = '1')
    ELSE pc_inc;
END rtl;


