LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

package arrays_pkg is
    type reg_array is array(7 downto 0) of std_logic_vector(31 downto 0);
end package;