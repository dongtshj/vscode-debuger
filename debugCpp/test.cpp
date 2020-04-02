#include <string>
#include <exception>
#include <iostream>
#include <signal.h>

#include "./xxtea/xxtea.h"
#include <fstream>
#include <sstream>
#include <algorithm>

void f(int)
{
    std::cout<<"sss";
}

int main(int argc, char** argv)
{

    std::ifstream t("config.luac");
    std::stringstream buff;
    buff << t.rdbuf();
    std::string content(buff.str());

    std::string key = "03f0fdcbf5215b45fc790aaf2b965237";
    unsigned char* pKey = (unsigned char*)key.c_str();
    xxtea_long l = 0;
    void* pDeRet = NULL;
    std::string sign = "bianfengqipai";
    std::string tmp = "";

    std::replace(content.begin(), content.end(), sign, tmp);

    unsigned char* pData = (unsigned char*)content.c_str();
    std::string temp((char*)pData + sign.size());
    pDeRet = xxtea_decrypt(pData, l, pKey, key.size(), &l);
    std::string s((char*)pDeRet);


    // signal(SIGSEGV, f);
    // std::set_terminate([](){ std::cout << "Unhandled exception\n"; });
    // std::string str;
    // const char* pStr = str.c_str();
    // printf(pStr);

    // int a[1];
    // a[2000] = 1;

    while (true)
    {
        /* code */
    }
    
    return 0;
}