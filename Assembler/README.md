# Assembler

## Required Software
only `g++` is required, or any applicable c++ compiler

## How to Run
1. Open the terminal and make sure you are in the assembler directory
2. Compile the file using `g++ assembler.cpp -o assembler.exe` (assuming running from windows)
3. Run the file using `./assembler.exe <input file>`
4. Open ModelSim and make sure that you created a project in the outer directory and added the vhdl files of the project
5. Write `do <do file>` in the transcript window, where `<do file>` is the do file that you want to run like  `do assembler/tests/delivery\ Cases/OneOperand.do`