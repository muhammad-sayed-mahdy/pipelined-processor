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

    SIGNAL reg_file_enables : std_logic_vector (7 DOWNTO 0);
    SIGNAL reg_file_D : reg_array;
    SIGNAL reg_file_Q : reg_array;

    -- TODO: Remove PC
    SIGNAL PC_enable : std_logic;
    SIGNAL PC_D       : std_logic_vector (31 DOWNTO 0);
    SIGNAL PC_Q       : std_logic_vector (31 DOWNTO 0);
    
    SIGNAL SP_enable : std_logic;
    SIGNAL SP_D       : std_logic_vector (31 DOWNTO 0);
    SIGNAL SP_Q       : std_logic_vector (31 DOWNTO 0);
    
    SIGNAL FR_enable : std_logic;
    SIGNAL FR_D       : std_logic_vector (3 DOWNTO 0);    -- Z : <0> | N : <1> | C : <2>
    SIGNAL FR_Q       : std_logic_vector (3 DOWNTO 0);

    SIGNAL IF_ID_D    : std_logic_vector (48 DOWNTO 0);
    SIGNAL IF_ID_Q    : std_logic_vector (48 DOWNTO 0);
    
    SIGNAL ID_EX_D    : std_logic_vector (136 DOWNTO 0);
    SIGNAL ID_EX_Q    : std_logic_vector (136 DOWNTO 0);
    
    SIGNAL EX_MEM_D   : std_logic_vector (111 DOWNTO 0);
    SIGNAL EX_MEM_Q   : std_logic_vector (111 DOWNTO 0);
    
    SIGNAL MEM_WB_D   : std_logic_vector (77 DOWNTO 0);
    SIGNAL MEM_WB_Q   : std_logic_vector (77 DOWNTO 0);

    -- TODO: Save NOP instruction

    
    TYPE state_machine IS (i0, i1, i2, i3, i4);     -- No interrupt, Finishing instructions in the pipeline, Pushing PC, Saving FR, Updating PC
    SIGNAL state : state_machine;
    VARIABLE cnt : INTEGER RANGE 0 TO 5;
    
BEGIN

    GEN_REG : FOR i IN 0 TO 7 GENERATE
        REGX : work.register_fall PORT MAP (reg_file_enables (i), clk, rst, reg_file_D (i), reg_file_Q (i));
    END GENERATE GEN_REG;
    GEN_PC : work.register_fall PORT MAP (PC_enable, clk, rst, PC_D, PC_Q);
    GEN_SP : work.register_fall PORT MAP (SP_enable, clk, rst, SP_D, SP_Q);
    GEN_FR : work.register_fall GENERIC MAP (4) 
                                PORT MAP (FR_enable, clk, rst, FR_D, FR_Q);

    IF_stage : work.Fetch PORT MAP (
                                    clk => clk,
                                    rst => rst,
                                    reg_arr => reg_file,
                                    mem_signal => MEM_WB_Q (74),
                                    mem_val => MEM_WB_Q (31 DOWNTO 0),
                                    -- TODO: Muxed with Interrupt/Reset
                                    jz_singal => -- from decode with 2 more signals (prediction status and value)
                                    zero_flag => FR_Q (0),
                                    jz_address => ID_EX_Q (23 DOWNTO 16),
                                    skip_instruc => NOT ID_EX_Q (121),
                                    out_instruc => IF_ID_D (15 DOWNTO 0),
                                    out_address => IF_ID_D (47 DOWNTO 16),
                                    branch_status => IF_ID_D (48)
                                );

    GEN_IF_ID : work.register_rise  GENERIC MAP (49)
                                    PORT MAP (E??, clk, rst => (flushing?), IF_ID_D, IF_ID_Q);

    ID_stage : work.Decode PORT MAP (   clk,
                                        reg_arr => reg_file_Q,
                                        spReg => SP_Q,
                                        inPort => in_port,
                                        instruction => IF_ID_Q (15 DOWNTO 0),
                                        curinstruction => ID_EX_Q (3 DOWNTO 0),
                                        incrementedPc => IF_ID_Q (47 DOWNTO 16),
                                        -- TODO: Split ^ into input and output?
                                        src1 => ID_EX_D (79 DOWNTO 48),
                                        src2 => ID_EX_D (111 DOWNTO 80),
                                        Rsrc1 => ID_EX_D (114 DOWNTO 112),
                                        Rsrc2 => ID_EX_D (117 DOWNTO 115),
                                        Rsrc1E => ID_EX_D (118),
                                        Rsrc2E => ID_EX_D (119),
                                        aluSrc2 => ID_EX_D (121 DOWNTO 120),
                                        Rdst => ID_EX_D (124 DOWNTO 122),
                                        aluCode => ID_EX_D (128 DOWNTO 125),
                                        memRead => ID_EX_D (129),
                                        memWrite => ID_EX_D (130),
                                        operation => ID_EX_D (132 DOWNTO 131),
                                        memPCWB => ID_EX_D (133),
                                        registerWB => ID_EX_D (134),
                                        -- TODO: ALUop and MEMop
                                        -- TODO: More signals, going to fetch
                                            -- JZ_signal
                                            -- Corrected prediction
                                            -- Corrected PC <31,0>
                                    );
    ID_EX_D (15 DOWNTO 4) <= (OTHERS => '0');
    ID_EX_D (47 DOWNTO 16) <= IF_ID_Q (47 DOWNTO 16);

    GEN_ID_EX : work.register_rise  GENERIC MAP (137)
                                    PORT MAP (E??, clk, rst => (flushing?), ID_EX_D, ID_EX_Q);

    EX_stage : work.execute_stage PORT MAP (    src1 => ID_EX_Q (79 DOWNTO 48),
                                                src2 => ID_EX_Q (111 DOWNTO 80),
                                                code => ID_EX_Q (128 DOWNTO 125),
                                                EA1 => ID_EX_Q (3 DOWNTO 0),
                                                secWord => IF_ID_Q (15 DOWNTO 0),
                                                src2Type => ID_EX_Q (121 DOWNTO 120),
                                                opType => ID_EX_Q (132 DOWNTO 131),
                                                dst1 => EX_MEM_D (31 DOWNTO 0),
                                                dst2 => EX_MEM_D (63 DOWNTO 32),
                                                FR => FR_D,
                                                FRen => FR_enable
                                            );
    EX_MEM_D (95 DOWNTO 64) <= ID_EX (47 DOWNTO 16);
    EX_MEM_D (98 DOWNTO 96) <= ID_EX_Q (124 DOWNTO 122);
    EX_MEM_D (101 DOWNTO 99) <= ID_EX_Q (114 DOWNTO 112);
    EX_MEM_D (102) <= ID_EX_Q (118);
    EX_MEM_D (103) <= ID_EX_Q (119);
    EX_MEM_D (104) <= ID_EX_Q (129);
    EX_MEM_D (105) <= ID_EX_Q (130);
    EX_MEM_D (107  DOWNTO 106) <= ID_EX_Q (132 DOWNTO 131);
    EX_MEM_D (108) <= ID_EX_Q (133);
    EX_MEM_D (109) <= ID_EX_Q (134);
    -- TODO: ALUop and MEMop

    GEN_EX_MEM : work.register_rise GENERIC MAP (112)
                                    PORT MAP (E??, clk, rst => (flushing?), EX_MEM_D, EX_MEM_Q);

    MEM_stage : work.memory_stage PORT MAP (    clk => clk,
                                                memRead => EX_MEM_Q (104),
                                                memWrite => EX_MEM_Q (105),
                                                oldSP => SP_Q,
                                                datain => EX_MEM_Q (31 DOWNTO 0),
                                                address => EX_MEM_Q (63 DOWNTO 32),
                                                dataout => MEM_WB_D (31 DOWNTO 0)
                                            );
    MEM_WB_D (63 DOWNTO 32) <= EX_MEM_Q (63 DOWNTO 32);
    MEM_WB_D (66 DOWNTO 64) <= EX_MEM_Q (98 DOWNTO 96);
    MEM_WB_D (69 DOWNTO 67) <= EX_MEM_Q (101 DOWNTO 99);
    MEM_WB_D (70) <= EX_MEM_Q (102);
    MEM_WB_D (71) <= EX_MEM_Q (103);
    MEM_WB_D (73 DOWNTO 72) <= EX_MEM_Q (107 DOWNTO 106);
    MEM_WB_D (74) <= EX_MEM_Q (108);
    MEM_WB_D (75) <= EX_MEM_Q (109);
    -- TODO: ALUop and MEMop

    GEN_MEM_WB : work.register_rise GENERIC MAP (78)
                                    PORT MAP (E??, clk, rst => (flushing?), MEM_WB_D, MEM_WB_Q);

    -- TODO: Write Back stage
    --      Fill  reg_file_D and reg_file_enables

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
                -- TODO: push PC
            WHEN i3 =>
                -- TODO: push FR
            WHEN i4 =>
                -- TODO: PC <= MEM (3 DOWNTO 2);
            CASE OTHERS =>
                NULL;
        END CASE;
    END PROCESS;

END arch;


