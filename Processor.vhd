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
    SIGNAL reg_file_D       : reg_array;
    SIGNAL reg_file_Q       : reg_array;
    
    SIGNAL SP_enable    : std_logic;
    SIGNAL SP_D         : std_logic_vector (31 DOWNTO 0);
    SIGNAL SP_Q         : std_logic_vector (31 DOWNTO 0);
    
    SIGNAL FR_enable    : std_logic;
    SIGNAL FR_EX_en     : std_logic;
    SIGNAL FR_EX        : std_logic_vector (3 DOWNTO 0);
    SIGNAL FR_D         : std_logic_vector (3 DOWNTO 0);    -- Z : <0> | N : <1> | C : <2>
    SIGNAL FR_Q         : std_logic_vector (3 DOWNTO 0);


    SIGNAL jz_sig           : std_logic;
    SIGNAL jz_correction    : std_logic;
    SIGNAL jz_pc            : std_logic_vector (31 DOWNTO 0);
    

    SIGNAL IF_ID_D    : std_logic_vector (80 DOWNTO 0);
    SIGNAL IF_ID_Q    : std_logic_vector (80 DOWNTO 0);
    
    SIGNAL ID_EX_D    : std_logic_vector (137 DOWNTO 0);
    SIGNAL ID_EX_Q    : std_logic_vector (137 DOWNTO 0);
    
    SIGNAL EX_MEM_D   : std_logic_vector (112 DOWNTO 0);
    SIGNAL EX_MEM_Q   : std_logic_vector (112 DOWNTO 0);
    
    SIGNAL MEM_WB_D   : std_logic_vector (78 DOWNTO 0);
    SIGNAL MEM_WB_Q   : std_logic_vector (78 DOWNTO 0);

    
    -- Normal operation, Finishing instructions in the pipeline, Pushing PC, Saving FR, Updating PC, Reset
    TYPE state_machine IS (i0, i1, i2, i3, i4, r);
    SIGNAL state : state_machine;

    SIGNAL IF_ID_INT    : std_logic_vector (80 DOWNTO 0);
    SIGNAL IF_ID_RST    : std_logic_vector (80 DOWNTO 0);

    SIGNAL FETCH_STALL  : std_logic_vector (80 DOWNTO 0);
    SIGNAL FINAL_FETCH  : std_logic_vector (80 DOWNTO 0);
    SIGNAL ID_INPUT     : std_logic_vector (80 DOWNTO 0);
    SIGNAL ID_OUTPUT    : std_logic_vector (137 DOWNTO 0);

    SIGNAL BUBBLE       : std_logic_vector (3 DOWNTO 0);
    SIGNAL STALL        : std_logic_vector (2 DOWNTO 0);        -- IF: <0>, ID: <1>, EX: <2>

    SIGNAL IF_FWD_en    : std_logic;
    SIGNAL IF_FWD_val   : std_logic_vector (31 DOWNTO 0);

    SIGNAL EX_FWD_1     : std_logic_vector (31 DOWNTO 0);
    SIGNAL EX_FWD_2     : std_logic_vector (31 DOWNTO 0);
BEGIN

    GEN_REG : FOR i IN 0 TO 7 GENERATE
        REGX : ENTITY work.reg_fall PORT MAP (reg_file_enables (i), clk, rst, reg_file_D (i), reg_file_Q (i));
    END GENERATE GEN_REG;
    GEN_SP : ENTITY work.reg_fall PORT MAP (SP_enable, clk, '0', SP_D, SP_Q);
    GEN_FR : ENTITY work.reg_fall GENERIC MAP (4) 
                                PORT MAP (FR_enable, clk, rst, FR_D, FR_Q);

    IF_stage : ENTITY work.Fetch PORT MAP (
                                            clk => clk,
                                            rst => rst,
                                            reg_arr => reg_file_Q,
                                            mem_signal => MEM_WB_Q (74),
                                            mem_val => MEM_WB_Q (31 DOWNTO 0),
                                            jz_signal => jz_sig,
                                            force_pc => jz_correction,
                                            correct_pc => jz_pc,
                                            zero_flag => FR_Q (0),
                                            jz_address => ID_EX_Q (23 DOWNTO 16),
                                            skip_instruc => NOT ID_EX_D (121),
                                            out_instruc => IF_ID_D (15 DOWNTO 0),
                                            out_address => IF_ID_D (47 DOWNTO 16),
                                            branch_status => IF_ID_D (48),
                                            -- Forwarding
                                            reg_match => IF_FWD_en,
                                            reg_fwd_val => IF_FWD_val,
                                            -- Stalling
                                            stall => STALL (0) OR STALL (2)
                                        );
    IF_ID_D (80 DOWNTO 49) <= in_port;

    FETCH_STALL <= IF_ID_D (80 DOWNTO 16) & "1110000000000000";
    
    FINAL_FETCH <= FETCH_STALL WHEN STALL (0) = '1' OR STALL (2) = '1' OR ID_EX_Q (133) = '1' OR EX_MEM_Q (108) = '1'
                                -- OR jz_correction = '1' -- Flushing
            ELSE IF_ID_D;

    GEN_IF_ID : ENTITY work.reg_rise GENERIC MAP (81)
                                    PORT MAP (NOT STALL (0) AND NOT STALL (2), clk, '0', FINAL_FETCH, IF_ID_Q);


    ID_INPUT    <=      IF_ID_RST                                   WHEN state = r
                ELSE    IF_ID_INT                                   WHEN (state = i2) OR (state = i3) OR (state = i4)
                ELSE    IF_ID_Q (80 DOWNTO 16) & "1110000000000000" WHEN (ID_EX_Q (121) = '0')  OR ID_EX_Q (137) = '1' -- Second word
                                                                        OR (ID_EX_Q (133) = '1' OR EX_MEM_Q (108) = '1' OR MEM_WB_Q (74) = '1') -- Stalling
                ELSE    IF_ID_Q;

    ID_stage : ENTITY work.Decode PORT MAP (   
                                            clk => clk,
                                            reg_arr => reg_file_Q,
                                            spReg => SP_Q,
                                            inPort => IF_ID_Q (80 DOWNTO 49),
                                            instruction => ID_INPUT (15 DOWNTO 0),
                                            zflag => FR_Q (0),
                                            decision => ID_INPUT (48),
                                            incrementedPcIn => ID_INPUT (47 DOWNTO 16),
                                            curinstruction => ID_OUTPUT (3 DOWNTO 0),
                                            incrementedPcOut => ID_OUTPUT (47 DOWNTO 16),
                                            src1 => ID_OUTPUT (79 DOWNTO 48),
                                            src2 => ID_OUTPUT (111 DOWNTO 80),
                                            Rsrc1 => ID_OUTPUT (114 DOWNTO 112),
                                            Rsrc2 => ID_OUTPUT (117 DOWNTO 115),
                                            Rsrc1E => ID_OUTPUT (118),
                                            Rsrc2E => ID_OUTPUT (119),
                                            aluSrc2 => ID_OUTPUT (121 DOWNTO 120),
                                            Rdst => ID_OUTPUT (124 DOWNTO 122),
                                            aluCode => ID_OUTPUT (128 DOWNTO 125),
                                            memRead => ID_OUTPUT (129),
                                            memWrite => ID_OUTPUT (130),
                                            operation => ID_OUTPUT (132 DOWNTO 131),
                                            memPCWB => ID_OUTPUT (133),
                                            registerWB => ID_OUTPUT (134),
                                            isJz => jz_sig,
                                            chdecision => jz_correction,
                                            rightPc => jz_pc,
                                            alu_op => ID_OUTPUT (135),
                                            mem_op => ID_OUTPUT (136),
                                            frWB => ID_OUTPUT (137),
                                            rti_2 => ID_EX_Q (137)
                                        );
    ID_OUTPUT (15 DOWNTO 4) <= (OTHERS => '0');

    ID_EX_D <= ID_OUTPUT;   -- TODO: Rst data forwarding unit (bits 136-135, 119-118)

    GEN_ID_EX : ENTITY work.reg_rise  GENERIC MAP (138)
                                    PORT MAP (NOT STALL (2), clk, '0', ID_EX_D, ID_EX_Q);

    EX_stage : ENTITY work.execute_stage PORT MAP (
                                                    rst => rst,
                                                    src1 => EX_FWD_1,
                                                    src2 => EX_FWD_2,
                                                    code => ID_EX_Q (128 DOWNTO 125),
                                                    EA1 => ID_EX_Q (15 DOWNTO 0),
                                                    secWord => IF_ID_Q (15 DOWNTO 0),
                                                    src2Type => ID_EX_Q (121 DOWNTO 120),
                                                    opType => ID_EX_Q (132 DOWNTO 131),
                                                    dst1 => EX_MEM_D (31 DOWNTO 0),
                                                    dst2 => EX_MEM_D (63 DOWNTO 32),
                                                    FR => FR_EX,
                                                    FRen => FR_EX_en
                                                );
    EX_MEM_D (95 DOWNTO 64) <= ID_EX_Q (47 DOWNTO 16);
    EX_MEM_D (98 DOWNTO 96) <= ID_EX_Q (124 DOWNTO 122);
    EX_MEM_D (101 DOWNTO 99) <= ID_EX_Q (114 DOWNTO 112);
    EX_MEM_D (102) <= ID_EX_Q (118); -- TODO: Rst data forwarding unit
    EX_MEM_D (103) <= ID_EX_Q (119); -- ``
    EX_MEM_D (104)  <=   ID_EX_Q (129)   WHEN rst = '0' AND STALL (2) = '0'
                    ELSE '0';
    EX_MEM_D (105)  <= ID_EX_Q (130)   WHEN rst = '0' AND STALL (2) = '0'
                    ELSE '0';
    EX_MEM_D (107  DOWNTO 106)  <= ID_EX_Q (132 DOWNTO 131) WHEN rst = '0' AND STALL (2) = '0'
                                ELSE "00";
    EX_MEM_D (108)  <=      ID_EX_Q (133) WHEN rst = '0' AND STALL (2) = '0'
                    ELSE    '0';
    EX_MEM_D (109)  <=      ID_EX_Q (134) WHEN rst = '0' AND STALL (2) = '0'
                    ELSE    '0';
    EX_MEM_D (110)  <= ID_EX_Q (135);
    EX_MEM_D (111)  <= ID_EX_Q (136);
    EX_MEM_D (112)  <= ID_EX_Q (137) WHEN rst = '0' AND STALL (2) = '0'
                    ELSE '0';

    GEN_EX_MEM : ENTITY work.reg_rise GENERIC MAP (113)
                                    PORT MAP ('1', clk, '0', EX_MEM_D, EX_MEM_Q);

    MEM_stage :ENTITY  work.memory_stage PORT MAP (    
                                                    clk => clk,
                                                    memRead => EX_MEM_Q (104),
                                                    memWrite => EX_MEM_Q (105),
                                                    opType => EX_MEM_Q (107 DOWNTO 106),
                                                    oldSP => SP_Q,
                                                    datain => EX_MEM_Q (31 DOWNTO 0),
                                                    address => EX_MEM_Q (63 DOWNTO 32),
                                                    dataout => MEM_WB_D (31 DOWNTO 0)
                                                );
    MEM_WB_D (63 DOWNTO 32) <= EX_MEM_Q (63 DOWNTO 32);
    MEM_WB_D (66 DOWNTO 64) <= EX_MEM_Q (98 DOWNTO 96);
    MEM_WB_D (69 DOWNTO 67) <= EX_MEM_Q (101 DOWNTO 99);
    MEM_WB_D (70) <= EX_MEM_Q (102);    -- TODO: Rst data forwarding unit
    MEM_WB_D (71) <= EX_MEM_Q (103);    -- ``
    MEM_WB_D (73 DOWNTO 72) <=      EX_MEM_Q (107 DOWNTO 106) WHEN rst = '0'
                            ELSE    "00";
    MEM_WB_D (74)   <=      EX_MEM_Q (108) WHEN rst = '0'
                    ELSE    '0';
    MEM_WB_D (75)   <=      EX_MEM_Q (109) WHEN rst = '0'
                    ELSE    '0';
    MEM_WB_D (76)   <= EX_MEM_Q (110);
    MEM_WB_D (77)   <= EX_MEM_Q (111);
    MEM_WB_D (78)   <= EX_MEM_Q (112) WHEN rst = '0'
                    ELSE '0';

    GEN_MEM_WB : ENTITY work.reg_rise GENERIC MAP (79)
                                    PORT MAP ('1', clk, rst, MEM_WB_D, MEM_WB_Q);

    -- Write Back Stage
    -- BEGIN
    SP_D <= MEM_WB_Q(63 DOWNTO 32) WHEN rst = '0'
        ELSE std_logic_vector(to_unsigned(2046, SP_D'length));
    SP_enable <= '1' WHEN MEM_WB_Q(73 DOWNTO 72) = "10" OR rst = '1'
                ELSE '0';
    out_port    <=      MEM_WB_Q(31 DOWNTO 0)    WHEN    MEM_WB_Q(73 DOWNTO 72) = "11"
                ELSE    (OTHERS => 'Z');

    FR_enable   <=  MEM_WB_Q (78) OR FR_EX_en;
    FR_D    <=      FR_EX   WHEN FR_EX_en = '1'
            ELSE    MEM_WB_Q (3 DOWNTO 0);

    PROCESS (MEM_WB_Q)
    BEGIN
        FOR i IN 0 TO 7 LOOP
            reg_file_enables (i) <= '1' WHEN (((i = (to_integer(unsigned(MEM_WB_Q(66 DOWNTO 64))))) AND (MEM_WB_Q(75) = '1')) 
                                            OR ((i = (to_integer(unsigned(MEM_WB_Q(69 DOWNTO 67))))) AND (MEM_WB_Q(73 DOWNTO 72) = "01")))
                                            
                                ELSE '0';

            reg_file_D (i) <= MEM_WB_Q(31 DOWNTO 0) WHEN (i = (to_integer(unsigned(MEM_WB_Q(66 DOWNTO 64)))))
                            ELSE MEM_WB_Q(63 DOWNTO 32) WHEN (i = (to_integer(unsigned(MEM_WB_Q(69 DOWNTO 67)))))
                            ELSE (OTHERS => 'Z');
        END LOOP;
    END PROCESS;
    -- END

    STALL (1) <= STALL (2);

    -- Additional hardware
    HZRD_UNIT :ENTITY  work.Hazard_Detection_Unit PORT MAP (   
                                                        -- Branch Stalling
                                                        opcode => IF_ID_D (15 DOWNTO 12),
                                                        br_reg => IF_ID_D (6 DOWNTO 4),
                                                        d_alu_src2 => ID_OUTPUT (121),
                                                        d_rdst_wb => ID_OUTPUT (134),
                                                        d_rdst => ID_OUTPUT (124 DOWNTO 122),
                                                        d_rsrc1 => ID_OUTPUT (114 DOWNTO 112),
                                                        d_swap => ID_OUTPUT (132 DOWNTO 131),
                                                        ex_mem_read => ID_EX_Q (129),
                                                        ex_mem_op => ID_EX_Q (136),
                                                        ex_rdst => ID_EX_Q (124 DOWNTO 122),
                                                        fetch_stall => STALL (0),
                                                        -- Data Hazard Stalling
                                                        m_mem_read => EX_MEM_Q (104),
                                                        m_mem_op => EX_MEM_Q (111),
                                                        m_stack => EX_MEM_Q (107 DOWNTO 106),
                                                        m_rdst => EX_MEM_Q (98 DOWNTO 96),
                                                        ex_rsrc1 => ID_EX_Q (114 DOWNTO 112),
                                                        ex_rsrc2 => ID_EX_Q (117 DOWNTO 115),
                                                        ex_rsrc1_enable => ID_EX_Q (118),
                                                        ex_rsrc2_enable => ID_EX_Q (119),
                                                        fde_stall => STALL (2)
                                                    );

    IF_FWD : ENTITY work.forward_fetch GENERIC MAP (32)
                                        PORT MAP (
                                                opcode => IF_ID_Q (15 DOWNTO 10),
                                                Rdst_fetch => IF_ID_D (6 DOWNTO 4),
                                                Rdst_decode => IF_ID_Q (6 DOWNTO 4),
                                                Rdst_decode_en => ID_EX_D (134),
                                                Rdst_decode_val => IF_ID_Q (80 DOWNTO 49),
                                                Rdst_execute => ID_EX_Q (124 DOWNTO 122),
                                                Rdst_execute_en => ID_EX_Q (134),
                                                Rdst_execute_val => EX_MEM_D (31 DOWNTO 0),
                                                Rsrc1_execute => ID_EX_Q (114 DOWNTO 112),
                                                execute_opType => ID_EX_Q (132 DOWNTO 131),
                                                Rsrc1_execute_val => EX_MEM_D (63 DOWNTO 32),
                                                Rdst_memory => EX_MEM_Q (98 DOWNTO 96),
                                                Rdst_memory_en => EX_MEM_Q (109),
                                                Rdst_memory_val => MEM_WB_D (31 DOWNTO 0),
                                                Rsrc1_memory => EX_MEM_Q (101 DOWNTO 99),
                                                memory_opType => EX_MEM_Q (107 DOWNTO 106),
                                                Rsrc1_memory_val => MEM_WB_D (63 DOWNTO 32),
                                                forwarded_Rdst_en => IF_FWD_en,
                                                forwarded_Rdst_val => IF_FWD_val
                                            );

    EX_FWD : ENTITY work.forward_execute GENERIC MAP (32)
                                        PORT MAP (
                                            Rsrc1 => ID_EX_Q (114 DOWNTO 112),
                                            Rsrc2 => ID_EX_Q (117 DOWNTO 115),
                                            Rsrc1_enable => ID_EX_Q (118),
                                            Rsrc2_enable => ID_EX_Q (119),
                                            Rdst_WB => MEM_WB_Q (66 DOWNTO 64),
                                            Rdst_Mem => EX_MEM_Q (98 DOWNTO 96),
                                            WB_WB => MEM_WB_Q (75),
                                            Mem_WB => EX_MEM_Q (109),
                                            Rsrc1_WB => MEM_WB_Q (69 DOWNTO 67),
                                            Rsrc1_Mem => EX_MEM_Q (101 DOWNTO 99),
                                            FR1_WB => MEM_WB_Q (31 DOWNTO 0),
                                            FR2_WB => MEM_WB_Q (63 DOWNTO 32),
                                            FR1_Mem => EX_MEM_Q (31 DOWNTO 0),
                                            FR2_Mem => EX_MEM_Q (63 DOWNTO 32),
                                            decode_Operand1 => ID_EX_Q (79 DOWNTO 48),
                                            decode_Operand2 => ID_EX_Q (111 DOWNTO 80),
                                            op_Mem => EX_MEM_Q (107 DOWNTO 106),
                                            op_WB => MEM_WB_Q (73 DOWNTO 72),
                                            op_E => ID_EX_Q (132 DOWNTO 131),
                                            Operand1 => EX_FWD_1,
                                            Operand2 => EX_FWD_2
                                        );

    PROCESS (rst, int, clk)
    BEGIN
            IF rst = '1' THEN
                state <= r;
            ELSIF (state = r) THEN
                state <= i0;
            ELSIF state = i0 THEN
                IF int = '1' THEN
                    state <= i1;
                END IF;
            ELSIF (state = i1) THEN
                IF rising_edge(clk) THEN
                    state <= i2;
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
            WHEN r =>
                IF_ID_RST (15 DOWNTO 0) <= "1111000000000000";
                IF_ID_RST (47 DOWNTO 16) <= (47 DOWNTO 18 => '0', 17 DOWNTO 16 => "00");
                IF_ID_RST (48) <= '0';
                IF_ID_RST (80 DOWNTO 49) <= in_port (31 DOWNTO 0);
            WHEN i2 =>
                IF_ID_INT (15 DOWNTO 0) <= "1100001000000000";
                IF_ID_INT (47 DOWNTO 16) <= ID_EX_Q (47 DOWNTO 16);
                IF_ID_INT (48) <= '0';
                IF_ID_INT (80 DOWNTO 49) <= in_port (31 DOWNTO 0);
            WHEN i3 =>
                IF_ID_INT (15 DOWNTO 0) <= "1100001000000000";
                IF_ID_INT (47 DOWNTO 20) <= (OTHERS => '0');
                IF_ID_INT (19 DOWNTO 16) <= FR_Q (3 DOWNTO 0);
                IF_ID_INT (48) <= '0';
                IF_ID_INT (80 DOWNTO 49) <= in_port (31 DOWNTO 0);
            WHEN i4 =>
                IF_ID_INT (15 DOWNTO 0) <= "1111000000000000";
                IF_ID_INT (47 DOWNTO 16) <= (47 DOWNTO 18 => '0', 17 DOWNTO 16 => "10");
                IF_ID_INT (48) <= '0';
                IF_ID_INT (80 DOWNTO 49) <= in_port (31 DOWNTO 0);
            WHEN OTHERS =>
                IF_ID_RST <= (OTHERS => '0');
                IF_ID_INT <= (OTHERS => '0');
        END CASE;
    END PROCESS;

END arch;

