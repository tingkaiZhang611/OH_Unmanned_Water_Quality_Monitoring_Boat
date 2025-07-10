#include "napi/native_api.h"
#include <fcntl.h>
#include <ios>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include "common/plugin_common.h"
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <cstddef>
#include <node_api.h>
#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <termios.h>
#include <js_native_api_types.h>

#include "napi/native_api.h"
#include "serialport.h"
#include "FileUtil.h"

#include "i2c_utils.h"
//#include "i2c_if.h"     // OpenHarmony I2C标准头文件[1](@ref)




#define NAN 0
#define gpio_pin "gpio22"

struct CallbackContext {
    napi_env env = nullptr;
    napi_ref callbackRef = nullptr;
    int status = -1;
    napi_async_work worker = nullptr;
    char retData[512] = {""};
};
//蜂鸣器控制
static napi_value Add(napi_env env, napi_callback_info info)
{
    const char *export_path = "/sys/class/gpio/export";
    const char *gpio_dir = "/sys/class/gpio/gpio23/direction";
    const char *gpio_val = "/sys/class/gpio/gpio23/value";

    int fd;
    size_t ret;
    
    size_t argc = 2;
    napi_value args[2] = {nullptr};

    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr);

    napi_valuetype valuetype0;
    napi_typeof(env, args[0], &valuetype0);

    napi_valuetype valuetype1;
    napi_typeof(env, args[1], &valuetype1);

    double value0;
    napi_get_value_double(env, args[0], &value0);

    double value1;
    napi_get_value_double(env, args[1], &value1);
    
    
    // 导出 GPIO23
    fd = open(export_path, O_WRONLY);


    ret = write(fd, "23", 2);

    close(fd);

    // 等待内核创建 GPIO 目录
    usleep(100000);  // 等待 100 毫秒（100,000 微秒）

    // 设置 GPIO 方向为输出
    fd = open(gpio_dir, O_WRONLY);


    ret = write(fd, "out", 3);

    close(fd);

    // 设置输出高电平
    fd = open(gpio_val, O_WRONLY);

    ret = write(fd, "1", 1);
    close(fd);

    
    napi_value sum;
    napi_create_double(env, 2.0, &sum);
    return sum;
    
}
//温度传感器
static napi_value GetOnnDou(napi_env env, napi_callback_info info)
{
    int fd;
    size_t ret;
    
    size_t argc = 2;
    napi_value args[2] = {nullptr};

    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr);

    napi_valuetype valuetype0;
    napi_typeof(env, args[0], &valuetype0);

    napi_valuetype valuetype1;
    napi_typeof(env, args[1], &valuetype1);

    double value0;
    napi_get_value_double(env, args[0], &value0);

    double value1;
    napi_get_value_double(env, args[1], &value1);
    
    //
    char path[128];

    // 1. 导出GPIO
    fd = open("/sys/class/gpio/export", O_WRONLY);
    if (fd < 0) return NAN;
    
    ret = write(fd, gpio_pin, strlen(gpio_pin));
    close(fd);
    
    // 等待内核创建GPIO目录
    usleep(100000);  // 等待100ms
    
    // 2. 设置GPIO方向为输出
    snprintf(path, sizeof(path), "/sys/class/gpio/gpio22/direction", gpio_pin);
    fd = open(path, O_WRONLY);
    if (fd < 0) return NAN;
    
    ret = write(fd, "out", 3);
    close(fd);
    
    // 单总线协议实现
    // 3. 复位序列
    snprintf(path, sizeof(path), "/sys/class/gpio/gpio22/value", gpio_pin);
    fd = open(path, O_WRONLY);
    if (fd < 0) return NAN;
    
    // 拉低总线480μs (复位脉冲)
    write(fd, "0", 1);
    usleep(480);
    
    // 释放总线 (等待存在脉冲)
    write(fd, "1", 1);
    close(fd);
    
    // 读取存在脉冲
    fd = open(path, O_RDWR);
    if (fd < 0) return NAN;
    
    usleep(70);
    char presence_val;
    read(fd, &presence_val, 1);
    int presence = (presence_val == '0');
    close(fd);
    usleep(410);
    
    if (!presence) return NAN;  // 传感器无响应
    
    // 4. 发送跳过ROM命令 (0xCC)
    for (int i = 0; i < 8; i++) {
        fd = open(path, O_WRONLY);
        if (fd < 0) return NAN;
        
        // 拉低总线
        write(fd, "0", 1);
        
        // 0xCC = 11001100
        if (i == 0 || i == 1 || i == 4 || i == 5) {  // '1' bits
            usleep(5);
        } else {  // '0' bits
            usleep(60);
        }
        
        // 释放总线
        write(fd, "1", 1);
        close(fd);
        
        // 完成时隙
        if (i == 0 || i == 1 || i == 4 || i == 5) {
            usleep(55);
        } else {
            usleep(1);
        }
    }
    
    // 5. 发送转换命令 (0x44)
    for (int i = 0; i < 8; i++) {
        fd = open(path, O_WRONLY);
        if (fd < 0) return NAN;
        
        // 拉低总线
        write(fd, "0", 1);
        
        // 0x44 = 01000100
        if (i == 1 || i == 5) {  // '1' bits
            usleep(5);
        } else {  // '0' bits
            usleep(60);
        }
        
        // 释放总线
        write(fd, "1", 1);
        close(fd);
        
        // 完成时隙
        if (i == 1 || i == 5) {
            usleep(55);
        } else {
            usleep(1);
        }
    }
    
    // 6. 等待转换完成
    usleep(800000);  // 800ms
    
    // 7. 再次执行复位序列
    fd = open(path, O_WRONLY);
    if (fd < 0) return NAN;
    
    write(fd, "0", 1);
    usleep(480);
    write(fd, "1", 1);
    close(fd);
    
    fd = open(path, O_RDWR);
    if (fd < 0) return NAN;
    
    usleep(70);
    read(fd, &presence_val, 1);
    presence = (presence_val == '0');
    close(fd);
    usleep(410);
    
    if (!presence) return NAN;  // 转换超时
    
    // 8. 再次发送跳过ROM命令
    for (int i = 0; i < 8; i++) {
        fd = open(path, O_WRONLY);
        if (fd < 0) return NAN;
        
        write(fd, "0", 1);
        
        if (i == 0 || i == 1 || i == 4 || i == 5) {
            usleep(5);
        } else {
            usleep(60);
        }
        
        write(fd, "1", 1);
        close(fd);
        
        if (i == 0 || i == 1 || i == 4 || i == 5) {
            usleep(55);
        } else {
            usleep(1);
        }
    }
    
    // 9. 发送读取暂存器命令 (0xBE)
    for (int i = 0; i < 8; i++) {
        fd = open(path, O_WRONLY);
        if (fd < 0) return NAN;
        
        write(fd, "0", 1);
        
        // 0xBE = 10111110
        if (i == 0 || i == 2 || i == 3 || i == 4 || i == 5 || i == 7) {
            usleep(5);
        } else {
            usleep(60);
        }
        
        write(fd, "1", 1);
        close(fd);
        
        if (i == 0 || i == 2 || i == 3 || i == 4 || i == 5 || i == 7) {
            usleep(55);
        } else {
            usleep(1);
        }
    }
    
    // 10. 读取9字节数据
    unsigned char data[9] = {0};
    
    for (int byte_idx = 0; byte_idx < 9; byte_idx++) {
        unsigned char byte = 0;
        
        for (int bit_idx = 0; bit_idx < 8; bit_idx++) {
            fd = open(path, O_WRONLY);
            if (fd < 0) return NAN;
            
            // 读比特序列
            write(fd, "0", 1);  // 拉低总线
            close(fd);
            usleep(2);
            
            fd = open(path, O_RDWR);
            if (fd < 0) return NAN;
            
            // 释放总线并采样
            write(fd, "1", 1);
            usleep(8);
            
            char bit_val;
            read(fd, &bit_val, 1);
            close(fd);
            
            if (bit_val == '1') {
                byte |= (1 << bit_idx);
            }
            
            usleep(50);  // 完成时隙
        }
        
        data[byte_idx] = byte;
    }
    
    // 11. 解析温度值
    short temp = (data[1] << 8) | data[0];
    
    
    //

    napi_value sum;
    napi_create_double(env, (float)temp / 16.0f, &sum);
    return sum;
    
}
//左电机控制
static napi_value Left(napi_env env, napi_callback_info info) {
    // TODO: implements the code;
    const char *export_path = "/sys/class/gpio/export";
    const char *gpio_dir = "/sys/class/gpio/gpio123/direction";
    const char *gpio_val = "/sys/class/gpio/gpio123/value";
     const char *export_path1 = "/sys/class/gpio/export";
    const char *gpio_dir1 = "/sys/class/gpio/gpio127/direction";
    const char *gpio_val1 = "/sys/class/gpio/gpio127/value";
    int fd;
    size_t ret;
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr);
    napi_valuetype valuetype0;
    napi_typeof(env, args[0], &valuetype0);
    double value0;
    napi_get_value_double(env, args[0], &value0);
    
    napi_valuetype valuetype1;
    napi_typeof(env, args[1], &valuetype1);
    double value1;
    napi_get_value_double(env, args[1], &value1);
    bool isON=true;
    if(value0==0){
        isON=false;
    }
    bool isZhengZhuan=true;
    if(value0==0){
        isZhengZhuan=false;
    }
    // 导出 GPIO123
    fd = open(export_path, O_WRONLY);
    ret = write(fd, "123", 2);
    close(fd);
    //导出GPIO127
     fd = open(export_path1, O_WRONLY);
    ret = write(fd, "127", 2);
    close(fd);
    // 等待内核创建 GPIO 目录
    usleep(100000);  // 等待 100 毫秒（100,000 微秒）
    // 设置 GPIO123 方向为输出
    fd = open(gpio_dir, O_WRONLY);
    ret = write(fd, "out", 3);
    close(fd);
     // 设置 GPIO127 方向为输出
    fd = open(gpio_dir1, O_WRONLY);
    ret = write(fd, "out", 3);
    close(fd);
    // 设置123输出电平
    fd = open(gpio_val, O_WRONLY);
    if(isON){
       if(value1){
         ret = write(fd, "1", 1);
        } else {
          ret = write(fd, "0", 1);
        }
    }else{
        ret = write(fd, "0", 1);
    }
    close(fd);
     // 设置127输出电平
    fd = open(gpio_val1, O_WRONLY);
    if(isON){
      if(value1){
            ret = write(fd, "0", 1);
      }else{
           ret = write(fd, "1", 1); 
        }
    }else{
        ret = write(fd, "0", 1);
    }
    close(fd);
    napi_value sum;
    napi_create_double(env, 4.0, &sum);
    return sum;
}
//右电机控制
static napi_value Right(napi_env env, napi_callback_info info) {
    // TODO: implements the code;
    const char *export_path = "/sys/class/gpio/export";
    const char *gpio_dir = "/sys/class/gpio/gpio133/direction";
    const char *gpio_val = "/sys/class/gpio/gpio133/value";
     const char *export_path1 = "/sys/class/gpio/export";
    const char *gpio_dir1 = "/sys/class/gpio/gpio126/direction";
    const char *gpio_val1 = "/sys/class/gpio/gpio126/value";
    int fd;
    size_t ret;
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr);
    napi_valuetype valuetype0;
    napi_typeof(env, args[0], &valuetype0);
    double value0;
    napi_get_value_double(env, args[0], &value0);
    
    napi_valuetype valuetype1;
    napi_typeof(env, args[1], &valuetype1);
    double value1;
    napi_get_value_double(env, args[1], &value1);
    bool isON=true;
    if(value0==0){
        isON=false;
    }
    bool isZhengZhuan=true;
    if(value0==0){
        isZhengZhuan=false;
    }
    // 导出 GPIO123
    fd = open(export_path, O_WRONLY);
    ret = write(fd, "133", 2);
    close(fd);
    //导出GPIO127
     fd = open(export_path1, O_WRONLY);
    ret = write(fd, "126", 2);
    close(fd);
    // 等待内核创建 GPIO 目录
    usleep(100000);  // 等待 100 毫秒（100,000 微秒）
    // 设置 GPIO123 方向为输出
    fd = open(gpio_dir, O_WRONLY);
    ret = write(fd, "out", 3);
    close(fd);
     // 设置 GPIO127 方向为输出
    fd = open(gpio_dir1, O_WRONLY);
    ret = write(fd, "out", 3);
    close(fd);
    // 设置123输出电平
    fd = open(gpio_val, O_WRONLY);
    if(isON){
       if(value1){
         ret = write(fd, "1", 1);
        } else {
          ret = write(fd, "0", 1);
        }
    }else{
        ret = write(fd, "0", 1);
    }
    close(fd);
     // 设置127输出电平
    fd = open(gpio_val1, O_WRONLY);
    if(isON){
      if(value1){
            ret = write(fd, "0", 1);
      }else{
           ret = write(fd, "1", 1); 
        }
    }else{
        ret = write(fd, "0", 1);
    }
    close(fd);
    napi_value sum;
    napi_create_double(env, 4.0, &sum);
    return sum;
}
//打开串口通信
static napi_value Open(napi_env env, napi_callback_info info)
{
    napi_status status;
    size_t requireArgc = 2;
    size_t argc = 2;
    napi_value args[2] = { nullptr };

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_valuetype valuetype;
    status = napi_typeof(env, args[0], &valuetype);
    if (status != napi_ok) {
        return nullptr;
    }
    if (valuetype != napi_string) {
        LOGE("Wrong arguments");
        return nullptr;
    }

    status = napi_typeof(env, args[1], &valuetype);
    if (status != napi_ok) {
        return nullptr;
    }
    if (valuetype != napi_number) {
        napi_throw_type_error(env, NULL, "Wrong arguments");
        return nullptr;
    }
    char port[MAX_SIZE] = { 0 };
    size_t portLen = 0;
    napi_get_value_string_utf8(env, args[0], port, MAX_SIZE, &portLen);
    double baudrate;
    napi_get_value_double(env, args[1], &baudrate);
    
    if (fd > 0) {
        napi_value sum;
        napi_create_double(env, fd, &sum);
        return sum;
    }
    fd = open(port, O_RDWR | O_NOCTTY | O_NONBLOCK);

    /*---------- Setting the Attributes of the serial port using termios structure --------- */

    /* Create the structure                          */
    struct termios cfg;

    tcgetattr(fd, &cfg);	/* Get the current attributes of the Serial port */

    cfmakeraw(&cfg);
    cfsetispeed(&cfg,getBaudrate(baudrate)); /* 输入波特率 Set Read  Speed as 9600                       */
    cfsetospeed(&cfg,getBaudrate(baudrate)); /* 输出波特率 Set Write Speed as 9600                       */

    cfg.c_cflag &= ~PARENB;   /* 控制参数Disables the Parity Enable bit(PARENB),So No Parity   */
    cfg.c_cflag &= ~CSTOPB;   /* CSTOPB = 2 Stop bits,here it is cleared so 1 Stop bit */
    cfg.c_cflag &= ~CSIZE;	 /* Clears the mask for setting the data size             */
    cfg.c_cflag |=  CS8;      /* Set the data bits = 8                                 */

    cfg.c_cflag &= ~CRTSCTS;       /* No Hardware flow Control                         */
    cfg.c_cflag |= CREAD | CLOCAL; /* Enable receiver,Ignore Modem Control lines       */


    cfg.c_iflag &= ~(IXON | IXOFF | IXANY);          /* 输入参数 Disable XON/XOFF flow control both i/p and o/p */
    cfg.c_iflag &= ~(ICANON | ECHO | ECHOE | ISIG);  /* Non Cannonical mode                            */

    cfg.c_oflag &= ~OPOST;  /* 输出参数 No Output Processing*/

    /* Setting Time outs */
    cfg.c_cc[VMIN] = 0;    /* 控制字符 noncanonical mode中规定read()返回的的最小字节数*/
    cfg.c_cc[VTIME] = 5;    /* 0.5s延迟 noncanonical mode中规定read()返回的超时时间（100ms为单位） */

    if((tcsetattr(fd,TCSANOW,&cfg)) != 0) /* Set the attributes to the termios structure*/
        printf("\n  ERROR ! in Setting attributes");
    else
        printf("\n  BaudRate = 9600 \n  StopBits = 1 \n  Parity   = none");

    napi_value sum;
    napi_create_double(env, fd, &sum);
    return sum;
}
//写
static napi_value Write(napi_env env, napi_callback_info info)
{
    int ret = -1;
    napi_status status;
    size_t argc = 1;
    napi_value args[1] = { nullptr };
    bool isArray = false;

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (fd > 0) {
        napi_valuetype valuetype;        
        char buf[MAX_SIZE] = { 0 };
       
        status = napi_typeof(env, args[0], &valuetype);
                
        if (status != napi_ok) {
            return nullptr;
        }
        
        if (valuetype == napi_string) {
             size_t valueLen;
             napi_get_value_string_utf8(env, args[0], buf, MAX_SIZE, &valueLen);            
             ret = write(fd, buf, valueLen);
        } else {
            // napi_is_array(env, args[0], &isArray);
            // LOGE("Lyle,write isArray:%{public}d",isArray);

            uint32_t arrayLength = 0;
            napi_get_array_length(env, args[0], &arrayLength);
            // LOGE("Lyle,write arrayLength:%{public}d",arrayLength);
            for (size_t i = 0; i < arrayLength; i++) {
                //bool hasElement = false;
                //napi_has_element(env, args[0], i, &hasElement);
                // NAPI_ASSERT(env, hasElement == true, "parameter check error");
                napi_value element = nullptr;
                napi_get_element(env, args[0], i, &element);

                int32_t value = 0;
                napi_get_value_int32(env, element, &value);
                buf[i] = value;
            }
            ret = write(fd, buf, arrayLength);
        }
    }
    napi_value result;
    napi_create_double(env, ret, &result);
    
    return result;
}
//获取
static napi_value Read(napi_env env, napi_callback_info info)
{
    int ret = -1,i;
    char read_buffer[MAX_SIZE] = { 0 };/* Buffer to store the data received              */
    size_t valueLen = MAX_SIZE;
    napi_value result = nullptr;
    if (fd > 0) {
        //tcflush(fd, TCIFLUSH);   /* Discards old data in the rx buffer            */
        ret = read(fd,&read_buffer,valueLen); /* Read the data                   */        
    } else {
         return 0;
    } 
    
    if (ret > 0) {
        //LOGE("uart read len: %{public}d\n",ret);
        //napi_create_string_utf8(env, read_buffer, ret, &result);
        napi_create_array_with_length(env,ret,&result);        
        for(i=0;i<ret;i++) {   
            napi_value num = nullptr;
            napi_create_int32(env, read_buffer[i], &num);
            napi_set_element(env,result,i,num);
        }
        LOGE("Lyle,read len:%{public}d",ret);
    } else {
        result = 0;
        napi_create_string_utf8(env, nullptr, 0, &result);
    }    
    return result;
}
//关闭串口
static napi_value Close(napi_env env, napi_callback_info info)
{
    int ret = -1;
    if (fd > 0) {
        ret = close(fd);
        fd = -1;
    }
    napi_value sum;
    napi_create_double(env, ret, &sum);

    return sum;

}


static napi_value I2c_open(napi_env env, napi_callback_info info)
{
    int ret = -1;
    if (fd > 0) {
        ret = close(fd);
        fd = -1;
    }
    napi_value sum;
    napi_create_double(env, ret, &sum);

    return sum;

}

static napi_value I2c_close(napi_env env, napi_callback_info info)
{
    int ret = -1;
    if (fd > 0) {
        ret = close(fd);
        fd = -1;
    }
    napi_value sum;
    napi_create_double(env, ret, &sum);

    return sum;

}


static napi_value I2c_transfer(napi_env env, napi_callback_info info)
{
    int ret = -1;
    if (fd > 0) {
        ret = close(fd);
        fd = -1;
    }
    napi_value sum;
    napi_create_double(env, ret, &sum);

    return sum;

}





EXTERN_C_START static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
       
        {"add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"left", nullptr, Left, nullptr, nullptr, nullptr, napi_default, nullptr},
         {"right", nullptr, Right, nullptr, nullptr, nullptr, napi_default, nullptr},
         { "open", nullptr, Open, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "write", nullptr, Write, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "read", nullptr, Read, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "close", nullptr, Close, nullptr, nullptr, nullptr, napi_default, nullptr },
        {"getOnnDou", nullptr, GetOnnDou, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"i2c_open", nullptr, I2c_open, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"i2c_close", nullptr, I2c_close, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"i2c_transfer", nullptr, I2c_transfer, nullptr, nullptr, nullptr, napi_default, nullptr}
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "entry",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void)
{
    napi_module_register(&demoModule);
}
