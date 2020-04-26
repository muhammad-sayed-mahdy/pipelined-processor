#pragma once

#include <string>

using namespace std;

class operation
{
    public:

    string opcode;
    int num_operands;
    int two_words; // 0: 1 word - 1: immediate value - 2: extended address

    operation();
    operation(string, int, int);
};

operation::operation()
{
    opcode = "";
    num_operands = -1;
    two_words = -1;
}

operation::operation(string s, int n, int t)
{
    opcode = s;
    num_operands = n;
    two_words = t;
}
