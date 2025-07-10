//
// Created on 2022-06-07.
//

#ifndef SerialPortApi_serialport_H
#define SerialPortApi_serialport_H

#include <string>
//#include <fstream> // For file I/O (reading/writing to COM port)
//#include <sstream>
#include <termios.h> // POSIX terminal control definitions (struct termios)
#include <vector>

static int fd = -1; // 串口打开的文件描述符
const int MAX_SIZE = 1024;//buff字节长度

extern bool echo_;

extern int32_t timeout_ms_;

static speed_t getBaudrate(int baudrate) {
    switch (baudrate) {
        case 0:
        return B0;
        case 50:
        return B50;
        case 75:
        return B75;
        case 110:
        return B110;
        case 134:
        return B134;
        case 150:
        return B150;
        case 200:
        return B200;
        case 300:
        return B300;
        case 600:
        return B600;
        case 1200:
        return B1200;
        case 1800:
        return B1800;
        case 2400:
        return B2400;
        case 4800:
        return B4800;
        case 9600:
        return B9600;
        case 19200:
        return B19200;
        case 38400:
        return B38400;
        case 57600:
        return B57600;
        case 115200:
        return B115200;
        case 230400:
        return B230400;
        case 460800:
        return B460800;
        case 500000:
        return B500000;
        case 576000:
        return B576000;
        case 921600:
        return B921600;
        case 1000000:
        return B1000000;
        case 1152000:
        return B1152000;
        case 1500000:
        return B1500000;
        case 2000000:
        return B2000000;
        case 2500000:
        return B2500000;
        case 3000000:
        return B3000000;
        case 3500000:
        return B3500000;
        case 4000000:
        return B4000000;
        default:
        return -1;
    }
}

termios GetTermios() {
    struct termios tty;
    memset(&tty, 0, sizeof(tty));
    return tty;
}

#endif //SerialPortApi_serialport_H
