LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
use work.arrays_pkg.ALL;

ENTITY Processor IS
    PORT(   clk         : IN std_logic;
            int         : IN std_logic;
            rst         : IN std_logic;
            in_port     : IN std_logic_vector (31 DOWNTO 0);
            out_port    : OUT std_logic_vector (31 DOWNTO 0)
        );
END ENTITY Processor;



ARCHITECTURE arch OF Processor IS

    SIGNAL reg_file : reg_array;
    SIGNAL PC       : std_logic_vector (31 DOWNTO 0);
    SIGNAL SP       : std_logic_vector (31 DOWNTO 0);
    SIGNAL FR       : std_logic_vector (3 DOWNTO 0);    -- Z : <0> | N : <1> | C : <2>

    SIGNAL WB_values : reg_array;
    SIGNAL reg_file_enables : std_logic_vector (7 DOWNTO 0);

    SIGNAL PC_value : std_logic_vector (31 DOWNTO 0);
    SIGNAL PC_enable : std_logic;
    
    SIGNAL SP_value : std_logic_vector (31 DOWNTO 0);
    SIGNAL SP_enable : std_logic;
    
    SIGNAL FR_value : std_logic_vector (3 DOWNTO 0);
    SIGNAL FR_enable : std_logic;

    SIGNAL IF_ID    : std_logic_vector (48 DOWNTO 0);
    SIGNAL ID_EX    : std_logic_vector (136 DOWNTO 0);
    SIGNAL EX_MEM   : std_logic_vector (112 DOWNTO 0);
    SIGNAL MEM_WB   : std_logic_vector (76 DOWNTO 0);

    
    TYPE state_machine IS (i0, i1, i2, i3, i4);
    SIGNAL state : state_machine;
    VARIABLE cnt : INTEGER RANGE 0 TO 5;
    
BEGIN

    GEN_REG : FOR i IN 0 TO 7 GENERATE
        REGX : work.register_fall PORT MAP (reg_file_enables (i), clk, rst, WB_values (i), reg_file(i));
    END GENERATE GEN_REG;
    GEN_PC : work.register_fall PORT MAP (PC_enable, clk, rst, PC_value, PC);
    GEN_SP : work.register_fall PORT MAP (SP_enable, clk, rst, SP_value, SP);
    GEN_FR : work.register_fall GENERIC MAP (4) 
                                PORT MAP (FR_enable, clk, rst, FR_value, FR);

    IF_stage : work.Fetch PORT MAP (
                                    clk => clk,
                                    rst => rst,
                                    reg_arr => reg_file,
                                    mem_signal => MEM_WB(74),
                                    mem_val => MEM_WB (31 DOWNTO 0),
                                    jz_singal => --TODO: ? also, signal*,
                                    zero_flag => FR (0),
                                    jz_address => ID_EX (23 DOWNTO 16),
                                    out_instruc => IF_ID (15 DOWNTO 0),
                                    out_address => IF_ID (47 DOWNTO 16)
                                    branch_status => IF_ID (48)
                                    -- TODO: What is skip instruction?
                                );

    GEN_IF_ID : work.register_rise  GENERIC MAP (49)
                                    PORT MAP (E??, clk, rst => (flushing?), IF_ID, IF_ID);

    ID_stage : work.Decode PORT MAP (   clk,
                                        reg_arr => reg_file,
                                        spReg => SP,
                                        inPort => in_port,
                                        instruction => IF_ID (15 DOWNTO 0),
                                        curinstruction => ID_EX (3 DOWNTO 0),
                                        incrementedPc => IF_ID (47 DOWNTO 16),
                                        -- TODO: Split ^ into input and output?
                                        src1 => ID_EX (79 DOWNTO 48),
                                        src2 => ID_EX (111 DOWNTO 80),
                                        Rsrc1 => ID_EX (114 DOWNTO 112),
                                        Rsrc2 => ID_EX (117 DOWNTO 115),
                                        Rsrc1E => ID_EX (118),
                                        Rsrc2E => ID_EX (119),
                                        aluSrc2 => ID_EX (121 DOWNTO 120),
                                        Rdst => ID_EX (124 DOWNTO 122),
                                        aluCode => ID_EX (128 DOWNTO 125),
                                        memRead => ID_EX (129),
                                        memWrite => ID_EX (130),
                                        operation => ID_EX (132 DOWNTO 131),
                                        memPCWB => ID_EX (133),
                                        registerWB => ID_EX (134),
                                        -- TODO: ALUop and MEMop
                                    );
    ID_EX (15 DOWNTO 4) <= (OTHERS => '0');
    ID_EX (47 DOWNTO 16) <= IF_ID (47 DOWNTO 16);   -- correct?

    GEN_ID_EX : work.register_rise  GENERIC MAP (137)
                                    PORT MAP (E??, clk, rst => (flushing?), ID_EX, ID_EX);

    EX_stage : work.execute_stage PORT MAP (    src1 => ID_EX (79 DOWNTO 48),
                                                    src2 => ID_EX (111 DOWNTO 80),
                                                    code => ID_EX (128 DOWNTO 125),
                                                    EA1 => ID_EX (3 DOWNTO 0),
                                                    secWord => IF_ID (15 DOWNTO 0),
                                                    src2Type => ID_EX (121 DOWNTO 120),
                                                    opType => ID_EX (132 DOWNTO 131),
                                                    dst1 => EX_MEM (31 DOWNTO 0),
                                                    dst2 => EX_MEM (63 DOWNTO 32),
                                                    FR => FR_value,
                                                    EA => ,     -- ???
                                                    FRen => FR_enable
                                                );
    EX_MEM (95 DOWNTO 64) <= ID_EX (47 DOWNTO 16);
    EX_MEM (98 DOWNTO 96) <= ID_EX (124 DOWNTO 122);
    EX_MEM (101 DOWNTO 99) <= ID_EX (114 DOWNTO 112);
    EX_MEM (102) <= ID_EX (118);
    EX_MEM (103) <= ID_EX (119);
    EX_MEM (104) <= ID_EX (129);
    EX_MEM (105) <= ID_EX (130);
    EX_MEM (107  DOWNTO 106) <= ID_EX (132 DOWNTO 131);
    EX_MEM (108) <= ID_EX (133);
    EX_MEM (109) <= ID_EX (134);
    -- TODO: ALUop and MEMop

    GEN_EX_MEM : work.register_rise GENERIC MAP (112)
                                    PORT MAP (E??, clk, rst => (flushing?), EX_MEM, EX_MEM);

    MEM_stage : work.memory_stage PORT MAP (    clk => clk,
                                                memRead => EX_MEM (104),
                                                memWrite => EX_MEM (105),
                                                datain => , -- TODO: ??
                                                address => , -- TODO: ??
                                                dataout => , -- TODO: ??
                                            );
    -- TODO: Fill MEM_WB

    GEN_MEM_WB : work.register_rise GENERIC MAP (76)
                                    PORT MAP (E??, clk, rst => (flushing?), MEM_WB, MEM_WB);

    -- TODO: Write Back stage
    --      Fill  WB_values and reg_file_enables

    -- TODO: INT state machines     (and RST?)
    PROCESS (int, clk)
    BEGIN
            IF state = i0 THEN
                IF int = '1' THEN
                    state <= i1;
                    cnt <= 5;
                END IF;
            ELSIF (state = i1) THEN
                IF rising_edge(clk) THEN
                    cnt <= cnt - 1;
                    IF cnt == 0 THEN
                        state <= i2;
                    END IF;
                END IF;
            ELSIF rising_edge(clk) THEN
                CASE state IS
                    WHEN i2 =>
                        state <= i3;
                    WHEN i3 =>
                        state <= i4;
                    WHEN i4 =>
                        state <= i0;
                    WHEN OTHERS =>
                        NULL;
                END CASE;
            END IF;
    END PROCESS;

    PROCESS (state)
    BEGIN
        CASE state IS
            WHEN i2 =>
                NULL;
                -- TODO: push PC
            WHEN i3 =>
                NULL;
                -- TODO: push FR
            WHEN i4 =>
                NULL;
                -- TODO: PC <= MEM (3 DOWNTO 2);
            CASE OTHERS =>
                NULL;
        END CASE;
    END PROCESS;

END arch;


