//
// Created on 2022-09-05.
//

#include "FileUtil.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <string>
#include <unistd.h>
#include <node_api.h>

#include "napi/native_api.h"
#include "common/plugin_common.h"

FileUtil::FileUtil(){};
/**
 * 获取当前时间年月日
 * @return
 */
static std::string getYMD() {
    time_t rawtime;
    struct tm *timeinfo;
    time(&rawtime);
    timeinfo = localtime(&rawtime);
    return std::to_string(timeinfo->tm_year + 1900) + std::to_string(timeinfo->tm_mon + 1) +
           std::to_string(timeinfo->tm_mday);
}

/**
 * 获取当前时间年-月-日 时:分:秒
 * @return
 */
static std::string getYMD_HMS() {
    time_t rawtime;
    struct tm *timeinfo;
    time(&rawtime);
    timeinfo = localtime(&rawtime);
    return std::to_string(timeinfo->tm_year + 1900) + "-" + std::to_string(timeinfo->tm_mon + 1) + "-" +
           std::to_string(timeinfo->tm_mday) + " " + std::to_string(timeinfo->tm_hour) +
           ":" + std::to_string(timeinfo->tm_min) + ":" + std::to_string(timeinfo->tm_sec);
}

static void get_local_time(char *buffer) {
    time_t rawtime;
    struct tm *timeinfo;
    time(&rawtime);
    timeinfo = localtime(&rawtime);
    sprintf(buffer, "%04d-%02d-%02d %02d:%02d:%02d",
            (timeinfo->tm_year + 1900), timeinfo->tm_mon, timeinfo->tm_mday,
            timeinfo->tm_hour, timeinfo->tm_min, timeinfo->tm_sec);
}

static int createDir(char *pszDir) {
    int i = 0;
    int iRet;
    int iLen = strlen(pszDir);

    char str[512];
    strncpy(str, pszDir, 512);
    for (i = 0; i < iLen; i++) {
        if (str[i] == '/') {
            str[i] = '\0';
            if (access(str, 0) != 0) {
                mkdir(str, S_IRWXU);
            }
            str[i] = '/';
        }
    }
    if (iLen > 0 && access(str, 0) != 0) {
        mkdir(str, S_IRWXU);
    }
    return 0;
}

/**
 * File_write--操作文件目录
 * 返回0--成功
 */
int FileUtil::WriteFile(napi_env env, std::string content) {
    FILE *fp = NULL;
    std::string filepath = "/data/idolog/";
    //如果不存在,创建
    int iRet = access(filepath.c_str(), W_OK);
    if (iRet != 0) {
        iRet = createDir(const_cast<char *>(filepath.c_str()));
        if (iRet == 0) {
            LOGE("create log file success,path:%{public}s", filepath.c_str());
        } else {
            LOGE("create log file fail");
        }
    } else {
        LOGE("file is exist");
    }

    filepath = filepath + "/BarCodeReader_" + getYMD() + ".log";

    const char *file_path = filepath.c_str();
    const char *write_content = (getYMD_HMS() + " " + content + "\n").c_str();
    LOGE("file_path:%{public}s", file_path);
    fp = fopen(file_path, "a+"); //如果文件存在就添加内容，如果文件不存在就创建新文件
    if (fp == NULL) {
        LOGE("open log file fail");
    } else {
        LOGE("open log file success");
        fprintf(fp, "%{public}s", write_content);
        //4. 写入文件 fwrite(写入的数据，数据的长度，写入次数，文件)
        //    int count=fwrite(data,strlen(data),1,file);
        //    fputs(write_content, fp);//写入操作
        // 5.关掉缓冲区
        fclose(fp); //关闭文件流
    }

    //在这里再回调一下 Java 告诉他写入完成
    //    jclass j_class = env->FindClass("com/example/administrator/ndkfile/FileUtils");
    //    jmethodID  method = env->GetStaticMethodID(j_class, "callByJNI","(I)V");
    // 回调静态方法
    //    env->CallStaticVoidMethod(j_class, method, 666);
    return 0; //正确 执行返回
}

/**
 * File_write--操作文件目录
 * 返回0--成功
 */
static napi_value Napi_WriteFile(napi_env env, napi_callback_info info) {
    FILE *fp = NULL;
    std::string filepath = "/data/idolog/";
    //如果不存在,创建
    int iRet = access(filepath.c_str(), W_OK);
    if (iRet != 0) {
        iRet = createDir(const_cast<char *>(filepath.c_str()));
        if (iRet == 0) {
            //            LOGE("create log file success");
        } else {
            LOGE("create log file fail");
        }
    } else {
        LOGE("file is exist");
    }
    napi_status status;
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    filepath = filepath + "/BarCodeReader_" + getYMD() + ".log";
    char value[FILE_MAX_SIZE] = {0};
    size_t valueLen;
    napi_get_value_string_utf8(env, args[0], value, FILE_MAX_SIZE, &valueLen);
    const char *file_path = filepath.c_str();
    const char *write_content = (getYMD_HMS() + " " + value + "\n").c_str();
    LOGE("file_path:%{public}s", file_path);
    fp = fopen(file_path, "a+"); //如果文件存在就添加内容，如果文件不存在就创建新文件
    if (fp == NULL) {
        LOGE("open log file fail");
    } else {
        LOGE("open log file success");
    }
    fprintf(fp, "%s", write_content);
    //4. 写入文件 fwrite(写入的数据，数据的长度，写入次数，文件)
    //    int count=fwrite(data,strlen(data),1,file);
    //    fputs(write_content, fp);//写入操作
    // 5.关掉缓冲区
    fclose(fp); //关闭文件流

    //在这里再回调一下 Java 告诉他写入完成
    //    jclass j_class = env->FindClass("com/example/administrator/ndkfile/FileUtils");
    //    jmethodID  method = env->GetStaticMethodID(j_class, "callByJNI","(I)V");
    // 回调静态方法
    //    env->CallStaticVoidMethod(j_class, method, 666);
    return 0; //正确 执行返回
}
