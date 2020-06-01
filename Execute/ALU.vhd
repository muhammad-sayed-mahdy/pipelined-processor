library ieee;
use ieee.std_logic_1164.all;

entity alu is
    generic (n :integer := 32);
    port (
        A, B : in std_logic_vector(n-1 downto 0);
        Opcode: in std_logic_vector (3 downto 0);
        rst: in std_logic;
        F : out std_logic_vector (n-1 downto 0);
        Cout, Z, NF: out std_logic
    ) ;
end alu;

architecture alu_arch of alu is
    
    signal F0, F1 : std_logic_vector (n-1 downto 0);
    signal Cout0, Cout1 : std_logic;

begin
    u0: entity work.arithmetic generic map(n)
        port map (A, B, '0', Opcode(1 downto 0), F0, Cout0, open);
    u1: entity work.logic_shift generic map(n)
        port map (A, B, Opcode(1 downto 0), F1, Cout1);

    F <= F1 when (Opcode(3 downto 2) = "01")
    else (not A) when (Opcode = "0010")
    else F0;

    Cout <= Cout1 when (Opcode(3 downto 2) = "01")
    else Cout0 when (Opcode(3 downto 2) = "10")
    else '0' when (rst = '1');

    Z <= nor F;     --all zeros
    NF <= '1' when F(n-1) = '1' else '0';
    
end alu_arch ; 