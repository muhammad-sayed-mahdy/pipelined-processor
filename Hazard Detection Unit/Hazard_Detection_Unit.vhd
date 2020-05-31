LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY Hazard_Detection_Unit IS
    PORT(   
            -- Branch Stalling
            opcode          : in std_logic_vector(3 downto 0);
            br_reg          : in std_logic_vector(2 downto 0);
            d_alu_src2      : in std_logic;
            d_rdst_wb       : in std_logic;
            d_rdst          : in std_logic_vector(2 downto 0);
            d_rsrc1         : in std_logic_vector(2 downto 0);
            d_swap          : in std_logic_vector(1 downto 0);
            ex_mem_read     : in std_logic;
            ex_mem_op       : in std_logic;
            ex_rdst         : in std_logic_vector(2 downto 0);
            fetch_stall     : out std_logic;
            -- Data Hazard Stalling
            m_mem_read      : in std_logic;
            m_mem_op        : in std_logic;
            m_stack         : in std_logic_vector(1 downto 0);
            m_rdst          : in std_logic_vector(2 downto 0);
            ex_rsrc1        : in std_logic_vector(2 downto 0);
            ex_rsrc2        : in std_logic_vector(2 downto 0);
            ex_rsrc1_enable : in std_logic;
            ex_rsrc2_enable : in std_logic;
            fde_stall       : out std_logic
        );
END ENTITY Hazard_Detection_Unit;

ARCHITECTURE rtl OF Hazard_Detection_Unit IS
    SIGNAL D_error, E_error         : std_logic;
    SIGNAL m_pop, instruc_hazard    : std_logic;
    
BEGIN
    D_error <= '1' WHEN (((br_reg = d_rdst) OR ((br_reg = d_rsrc1) AND (d_swap = "01"))) 
                            AND (d_alu_src2 = '1') AND (d_rdst_wb = '1'))
    ELSE '0';

    E_error <= '1' WHEN ((br_reg = ex_rdst) AND (ex_mem_read = '1') AND (ex_mem_op = '1'))
    ELSE '0';
    
    fetch_stall <= '1' WHEN (opcode = "1100" AND (D_error = '1' OR E_error = '1'))
    ELSE '0';

    m_pop <= '1' WHEN (m_mem_read = '1' AND m_mem_op = '1' AND m_stack = "10")
    ELSE '0';

    instruc_hazard <= '1' WHEN ((ex_rsrc1_enable = '1' AND (ex_rsrc1 = m_rdst)) OR
                        (ex_rsrc2_enable = '1' AND (ex_rsrc2 = m_rdst)))
                        -- AND ex_mem_op = '0'
    ELSE '0';
    
    fde_stall <= m_pop AND instruc_hazard;
END rtl;