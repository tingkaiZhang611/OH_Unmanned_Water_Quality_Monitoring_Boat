//
// Created on 2022-09-05.
//
#include <node_api.h>
#include <string>
#include "napi/native_api.h"


#ifndef SerialPortApi_FileUtil_H
#define SerialPortApi_FileUtil_H

const int FILE_MAX_SIZE = 1024*1024;//buff字节长度,1M

class FileUtil {

public:
    FileUtil();

    int DeleteFile(napi_env env);

    int WriteFile(napi_env env, std::string content);

    void writeLogFile(char *filename, long max_size, char *buffer, unsigned int buf_size);

};
#endif //SerialPortApi_FileUtil_H
