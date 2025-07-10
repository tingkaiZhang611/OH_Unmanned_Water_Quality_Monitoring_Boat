#ifndef I2C_UTILS_H
#define I2C_UTILS_H

#include <stdint.h>

// 打开I2C控制器，返回文件描述符（类似Linux的open）
int i2c_open(int controller_id);

// 关闭I2C控制器（类似Linux的close）
void i2c_close(int fd);

// I2C组合读写：先写后读（仿Linux的ioctl但简化）
// 参数说明：
//   fd:       控制器描述符
//   dev_addr: I2C设备地址（7位格式）
//   wbuf:     写入数据缓冲区
//   wlen:     写入数据长度
//   rbuf:     读取数据缓冲区
//   rlen:     读取数据长度
// 返回值：成功返回0，失败返回负数错误码
int i2c_transfer(int fd, uint8_t dev_addr, 
                 const uint8_t *wbuf, int wlen, 
                 uint8_t *rbuf, int rlen);

#endif // I2C_UTILS_H