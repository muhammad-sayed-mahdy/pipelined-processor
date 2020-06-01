LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

entity execute_stage is 
    generic (n: integer := 32);
    port(src1, src2: in std_logic_vector(n-1 downto 0);
        code : in std_logic_vector(3 downto 0);
        EA1: in std_logic_vector(n/2-1 downto 0);   -- the first part of EA (16-bit)
        secWord: in std_logic_vector(n/2-1 downto 0); -- the second part of EA (16-bit) or Imm
        src2Type: in std_logic_vector(1 downto 0); --(00: imm, 01: EA, 1X: val)
        opType: in std_logic_vector(1 downto 0); --(00: other, 01: swap, 10: stack, 11: out)
        fwdRsrc1En: in std_logic;
        fwdRsrc1Val: in std_logic_vector(n-1 downto 0);
        fwdRsrc2En: in std_logic;
        fwdRsrc2Val: in std_logic_vector(n-1 downto 0);
        dst1, dst2: out std_logic_vector(n-1 downto 0); --dst2 in case of swap
        FR: out std_logic_vector(3 downto 0);   --flag register value
        FRen: out std_logic);   --flag register enable
end entity execute_stage;

architecture execute_stage_arch of execute_stage is
    signal src1i, src2i, aluSrc2, aluDist, aluSrc1, EA: std_logic_vector(n-1 downto 0);
    begin
        EA <= EA1 & secWord;

        src1i <= fwdRsrc1Val when (fwdRsrc1En = '1')
        else src1;

        src2i <= fwdRsrc2Val when (fwdRsrc2En = '1')
        else src2;

        aluSrc1 <= src2i  when (opType = "10")     --src1 is SP in case of stack operation
        else src1i;

        aluSrc2 <= std_logic_vector(to_unsigned(2, n)) when (opType = "10")    --src2 is '2' in case of stack operation
        else src2i when (src2Type(1) = '1')
        else EA when (src2Type = "01")
        else (n/2-1 downto 0 => secWord(n/2-1)) & secWord;  -- sign extend immediate value

        FR(3) <= '0';

        u0: entity work.alu generic map(n)
            port map (aluSrc1, aluSrc2, code, aluDist, FR(2), FR(0), FR(1));

        dst1 <= src1i when (code = "0000" or opType = "10") -- NOP or (Stack operation src1 contains data)
        else aluSrc2 when (code = "0001")  -- swap
        else aluDist;

        dst2 <= aluDist when (opType = "10")    -- Stack operation output (SP +or- 2)
        else src1i when (code = "0001")  -- Swap
        else aluSrc2;  -- NOP

        FRen <= '1' when (code(3 downto 2) = "01" or code(3 downto 2) = "10" or code = "0010")
        else '0';
    end execute_stage_arch;
