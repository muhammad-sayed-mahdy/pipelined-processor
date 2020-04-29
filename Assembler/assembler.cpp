#include <iostream>
#include <string>
#include <map>
#include <fstream>
#include <limits>
#include "operation.h"
#include "utility.cpp"

#include <bitset>

using namespace std;

unsigned int crnt_line = 0;

void init(map<string, operation>& o, map<string, string>& r);

int main(int argc, char const *argv[])
{
    map<string, operation> ops;
    map<string, string> reg;
    map<unsigned int, string> output;

    init(ops, reg);

    if (argc < 2)
    {
        printf("Missing argument: input file\n");
        exit(-1);
    }
    string input_file = argv[1];

    ifstream in(input_file);
    while (in.peek() != EOF)
    {
        string s;
        in >> s;
        toupper(s);

        if (ops.count(s) != 0)
        {
            operation o = ops[s];
            string instruction = o.opcode;
            unsigned int s1 = instruction.size() - 1;
            if (o.num_operands == 0)
            {
                ; // opcode complete, do nothing
            }
            else if (o.num_operands == 1)
            {
                string r;

                // Rdst
                in >> r;
                toupper(r);
                r = reg[r];
                unsigned int s2 = r.size() - 1;
                for (int i = 0; i < 3; ++i)
                {
                    instruction[s1 - (i + 4)] = r[s2 - (i)];
                }
            }
            else if (o.num_operands == 2)
            {
                string r;

                // Rsrc
                in >> r;
                toupper(r);
                r = reg[r];
                unsigned int s2 = r.size() - 1;
                for (int i = 0; i < 3; ++i)
                {
                    instruction[s1 - (i + 9)] = r[s2 - (i)];
                }
                
                // Rdst
                in >> r;
                toupper(r);
                r = reg[r];
                s2 = r.size() - 1;
                for (int i = 0; i < 3; ++i)
                {
                    instruction[s1 - (i + 4)] = r[s2 - (i)];
                }
            }
            else if (o.num_operands == 3)
            {
                string r;

                // Rsrc1
                in >> r;
                toupper(r);
                r = reg[r];
                unsigned int s2 = r.size() - 1;
                for (int i = 0; i < 3; ++i)
                {
                    instruction[s1 - (i + 9)] = r[s2 - (i)];
                }

                // Rsrc2
                in >> r;
                toupper(r);
                r = reg[r];
                s2 = r.size() - 1;
                for (int i = 0; i < 3; ++i)
                {
                    instruction[s1 - (i + 1)] = r[s2 - (i)];
                }
                
                // Rdst
                in >> r;
                toupper(r);
                r = reg[r];
                s2 = r.size() - 1;
                for (int i = 0; i < 3; ++i)
                {
                    instruction[s1 - (i + 4)] = r[s2 - (i)];
                }
            }

            if (o.two_words == 0)
            {
                output[crnt_line] = instruction;
            }
            else if (o.two_words == 1)
            {
                string instruction2;
                in >> instruction2;

                output[crnt_line] = instruction;
                ++crnt_line;
                output[crnt_line] = to_hex(instruction2);
            }
            else if (o.two_words == 2)
            {
                string instruction2;
                in >> instruction2;

                instruction2 = to_hex(instruction2);
                unsigned int s2 = instruction2.size() - 1;
                if (s2 > 16)
                {
                    for (int i = 0; i < 4; ++i)
                    {
                        instruction[s1 - (i)] = instruction2[s2 - (16 + i)];
                        instruction2.erase(0, 4);
                    }
                }
                else
                {
                    for (int i = 0; i < 4; ++i)
                    {
                        instruction[s1 - (i)] = '0';
                    }
                }

                output[crnt_line] = instruction;
                ++crnt_line;
                output[crnt_line] = instruction2;
            }

            ++crnt_line;
        }
        else if (toupper(s) == ".ORG")
        {
            string addr;
            in >> addr;
            crnt_line = stoul(addr);
        }
        else if (is_hex(s)) // could just add 16'h before ?
        {
            output[crnt_line] = to_hex(s);

            ++crnt_line;
        }
        else if (s[0] == '#')
        {
            // ignore the rest of the line
            in.ignore(numeric_limits<streamsize>::max(), in.widen('\n'));
        }
        
    }
    in.close();

    string output_file = input_file.substr(0, input_file.find('.'))+".bin";
    ofstream out(output_file);
    for (auto instrucitons : output)
    {
        out << instrucitons.first << ": " << instrucitons.second << endl;
    }
    out.close();
}

void init(map<string, operation>& o, map<string, string>& r)
{
    ifstream in("operations_data.txt");
    while(in.peek() != EOF)
    {
        string name, opcode;
        int num, extra_operand;

        in >> name >> opcode >> num >> extra_operand;

        operation* op = new operation(opcode, num, extra_operand);

        o[name] = *op;
    }
    in.close();

    in.open("registers_data.txt");
    while(in.peek() != EOF)
    {
        string name, opcode;

        in >> name >> opcode;

        r[name] = opcode;
    }
    in.close();
}


