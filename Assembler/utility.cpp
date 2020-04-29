
#include <iostream>
#include <string>
#include <algorithm>
#include <sstream>
#include <vector>

using namespace std;

string parse(string&);
string toupper(string&);
vector<string> split(string, int, bool);
bool is_hex(string);
string to_hex(string);

string parse(string& s)
{
    for (auto& c : s)
    {
        if (c == ',')
        {
            c = ' ';
        }
    }

    s.erase(std::remove_if(s.begin(), s.end(), ::isspace), s.end());

    return toupper(s);;
}

string toupper(string& s)
{
    for(auto& c : s)
    {
        c = toupper(c);
    }
    return s;
}

vector<string> split(string s, int n, bool t)
{
    vector<string> operands;
    stringstream ss(s);
    string part;
    
    for (int i = 0; i < n-1; ++i)
    {
        getline(ss, part, ',');
        operands.push_back(part);
    }
    if (n > 0)
    {
        if (t)
        {
            getline(ss, part, ',');
            operands.push_back(part);
            
            ss >> part;
            operands.push_back(part);
        }
        else
        {
            ss >> part;
            operands.push_back(part);
        }
    }

    return operands;
}

bool is_hex(string s)
{
    toupper(s);
    for(auto& c : s)
    {
        if (!(c >= '0' && c <= '9' || c >= 'A' && c <= 'F'))
        {
            return false;
        }
    }
    return true;
}

string to_hex(string num)
{
    string bin;
    toupper(num);
    if (!is_hex(num))
    {
        cout << "Not a hex number\n";
        return "";
    }
    for(auto& c : num)
    {
        string v;
        if (c == '0') v = "0000";
        if (c == '1') v = "0001";
        if (c == '2') v = "0010";
        if (c == '3') v = "0011";
        if (c == '4') v = "0100";
        if (c == '5') v = "0101";
        if (c == '6') v = "0110";
        if (c == '7') v = "0111";
        if (c == '8') v = "1000";
        if (c == '9') v = "1001";
        if (c == 'A') v = "1010";
        if (c == 'B') v = "1011";
        if (c == 'C') v = "1100";
        if (c == 'D') v = "1101";
        if (c == 'E') v = "1110";
        if (c == 'F') v = "1111";
        bin.append(v);
    }
    while (bin.size() < 16)
    {
        bin.insert(0, "0000");
    }

    return bin;
}
