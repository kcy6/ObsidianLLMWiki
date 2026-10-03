# 基于江协标准库移植

https://www.bilibili.com/video/BV12o5vzwEPp?spm_id_from=333.788.videopod.episodes&vd_source=f7c094930be9069ca80f211625e6ec72
eMPL/
├── inv_mpu.h/c          # MPU硬件抽象层（与DMP交互的核心）
├── inv_mpu_dmp_motion_driver.h/c  # DMP接口封装
├── dmpKey.h             # DMP配置键（控制DMP行为）
└── dmpmap.h             # DMP内存地址映射（定义内部寄存器地址）
软件I2C读写MPU6050添加mpu6050.c/.h，添加官方源码eMPL/下的六个文件
**主要修改思路为更改两个dmp库c文件的宏定义为mpu6050设备，更换原来提供的i2c接口函数为自己提供的函数，主要过程为编写mpu6050源文件，这里将inv_mpu_dmp_motion_driver.c文件进行了填充，将部分应该写入
参考\Embedded_MotionDriver_5.1\simple_apps\msp430\motion_driver_test.c**
## 软件I2C
### inv_mpu.c
```c
...
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "inv_mpu.h"
以下为新添加头文件
#include "Delay.h"
#include "MPU6050.h"
#include "Serial.h"
...

// 添加宏定义
#define MPU6050                     // 定义传感器微MPU6050
#define MOTION_DRIVER_TARGET_MSP430 // 定义驱动部分，采用下方分支中的MSP430驱动，将其修改移植到STM32F1

/* 通过上分宏定义以下分支中的第一个分支被选择 /*
#if defined MOTION_DRIVER_TARGET_MSP430
以下几个头文件与msp430有关直接注释即可
//#include "msp430.h"
//#include "msp430_i2c.h"
//#include "msp430_clock.h"
//#include "msp430_interrupt.h"
这几个宏进行重定义
//#define i2c_write   msp430_i2c_write
//#define i2c_read    msp430_i2c_read
//#define delay_ms    msp430_delay_ms
//#define get_ms      msp430_get_clock_ms
移植为自己定义的函数
#define i2c_write   MPU6050_Write_Len
#define i2c_read    MPU6050_Read_Len
#define delay_ms    Delay_ms
#define get_ms      mget_us

//注释该函数
//static inline int reg_int_cb(struct int_param_s *int_param)
//{
//    return msp430_reg_int_cb(int_param->cb, int_param->pin, int_param->lp_exit,
//        int_param->active_low);
//}

//修改使其指向一个串口发送函数
//#define log_i(...)     do {} while (0)
//#define log_e(...)     do {} while (0)
#define log_i       Serial_Printf
#define log_e       Serial_Printf



删去mpu_init函数形参方便后续调用
int mpu_init(void)
//int mpu_init(struct int_param_s *int_param)

注释该函数下其他的警告
    if (int_param)
	    reg_int_cb(int_param);


//删去static
//static int setup_compass(void)
int setup_compass(void)

/**
 *  @}
 */
 文件末尾定义一个自己的空函数
void mget_ms(unsigned long *time)
{
 
}

```



### inv_mpu.h
```h
...
//这个位置声明宏定义
#define MOTION_DRIVER_TARGET_MSP430         //定义驱动部分，采用MSP430驱动（移植到STM32F1）

struct int_param_s {
#if defined EMPL_TARGET_MSP430 || defined MOTION_DRIVER_TARGET_MSP430
    void (*cb)(void);
    unsigned short pin;
    unsigned char lp_exit;
    unsigned char active_low;
#elif defined EMPL_TARGET_UC3L0
    unsigned long pin;
    void (*cb)(volatile void*);
    void *arg;
#endif
	//添加void *arg;防止报错
	void *arg;
};



更改初始化函数声明，删去参数方便调用
//int mpu_init(struct int_param_s *int_param);
int mpu_init(void);

声明自定义的空函数
void mget_ms(unsigned long *time);
```


### inv_mpu_dmp_motion_driver.c
```c
添加头文件
#include "Delay.h"
#include "Serial.h"


#if defined MOTION_DRIVER_TARGET_MSP430
注释这部分头文件包含
//#include "msp430.h"
//#include "msp430_clock.h"
这几个宏进行重定义
//#define delay_ms    msp430_delay_ms
//#define get_ms      msp430_get_clock_ms
//#define log_i(...)     do {} while (0)
//#define log_e(...)     do {} while (0)
使用自己定义的函数
#define delay_ms    Delay_ms
#define get_ms      mget_ms
#define log_i       Serial_Printf
#define log_e       Serial_Printf

该函数下会有一个警告注释即可
int dmp_set_accel_bias(long *bias)
//    __no_operation();

文件末尾添加三个自己定义的函数
/* add by yourself */
/*----------------------------------------*/
/* These next two functions converts the orientation matrix (see gyro_orientation) to a
 * scalar representation for use by the DMP. NOTE: These functions are borrowed from Inversense's MPL.
 */
static unsigned short inv_row_2_scale(const signed char *row)
{
    unsigned short b;
    if (row[0] > 0)
    {
        b = 0;
    }
    else if (row[0] < 0)
    {
        b = 4;
    }
    else if (row[1] > 0)
    {
        b = 1;
    }
    else if (row[1] < 0)
    {
        b = 5;
    }
    else if (row[2] > 0)
    {
        b = 2;
    }
    else if (row[2] < 0)
    {
        b = 6;
    }
    else
    {
        b = 7;    //error
    }
    return b;
}

/* add by yourself */
unsigned short inv_orientation_matrix_to_scalar(const signed char *mtx)
{
    unsigned short scalar;
    /*
        XYZ     010_001_000 Identity Matrix
        XZY     001_010_000
        YXZ     010_000_001
        YZX     000_010_001
        ZXY     001_000_010
        ZYX     000_001_010
    */
    scalar = inv_row_2_scale(mtx);
    scalar |= inv_row_2_scale(mtx + 3) << 3;
    scalar |= inv_row_2_scale(mtx + 6) << 6;
    return scalar;
}

/* add by yourself */
unsigned short run_self_test(void)
{
    int result;
    //char test_packet[4] = {0};
    long gyro[3], accel[3];
    result = mpu_run_self_test(gyro, accel);
    if (result == 0x3)
    {
        float sens;
        unsigned short accel_sens;
        mpu_get_gyro_sens(&sens);
        gyro[0] = (long)(gyro[0] * sens);
        gyro[1] = (long)(gyro[1] * sens);
        gyro[2] = (long)(gyro[2] * sens);
        dmp_set_accel_bias(gyro);
        mpu_get_accel_sens(&accel_sens);
        accel[0] *= accel_sens;
        accel[1] *= accel_sens;
        accel[2] *= accel_sens;
        dmp_set_accel_bias(accel);
        return 0;
    }
    else
    {
        return 1;
    }
}
```


### inv_mpu_dmp_motion_driver.h
```c
添加其声明
unsigned short inv_orientation_matrix_to_scalar(const signed char *mtx);
unsigned short run_self_test(void);

```


### MPU6050.c
```c
#include "stm32f10x.h"                  // Device header
#include "MyI2C.h"
#include "MPU6050_Reg.h"
#include <stdint.h>
#include <math.h>
#include "inv_mpu.h"
#include "inv_mpu_dmp_motion_driver.h"
#include "Serial.h"

/* 引脚配置 */
#define MPU6050_SCL     GPIO_Pin_10
#define MPU6050_SDA     GPIO_Pin_11

#define MPU6050_ADDRESS     0xD0            //MPU6050的I2C从机地址
#define DEFAULT_MPU_HZ      (100)           //定义输出速度
#define q30                 1073741824.0f   //q30格式，long转float时的参数

//陀螺仪方向设置
static signed char gyro_orientation[9] =
{
    1, 0, 0,
    0, 1, 0,
    0, 0, 1
};
float q0 = 1.0f, q1 = 0.0f, q2 = 0.0f, q3 = 0.0f;
unsigned long sensor_timestamp;
short gyro[3], accel[3], sensors;
unsigned char more;
long quat[4];

/**
  * 函    数：MPU6050写寄存器
  * 参    数：RegAddress 寄存器地址，范围：参考MPU6050手册的寄存器描述
  * 参    数：Data 要写入寄存器的数据，范围：0x00~0xFF
  * 返 回 值：无
  */
void MPU6050_WriteReg(uint8_t RegAddress, uint8_t Data)
{
    MyI2C_Start();                      //I2C起始
    MyI2C_SendByte(MPU6050_ADDRESS);    //发送从机地址，读写位为0，表示即将写入
    MyI2C_ReceiveAck();                 //接收应答
    MyI2C_SendByte(RegAddress);         //发送寄存器地址
    MyI2C_ReceiveAck();                 //接收应答
    MyI2C_SendByte(Data);               //发送要写入寄存器的数据
    MyI2C_ReceiveAck();                 //接收应答
    MyI2C_Stop();                       //I2C终止
}

/**
  * 函    数：MPU6050读寄存器
  * 参    数：RegAddress 寄存器地址，范围：参考MPU6050手册的寄存器描述
  * 返 回 值：读取寄存器的数据，范围：0x00~0xFF
  */
uint8_t MPU6050_ReadReg(uint8_t RegAddress)
{
    uint8_t Data;

    MyI2C_Start();                      //I2C起始
    MyI2C_SendByte(MPU6050_ADDRESS);    //发送从机地址，读写位为0，表示即将写入
    MyI2C_ReceiveAck();                 //接收应答
    MyI2C_SendByte(RegAddress);         //发送寄存器地址
    MyI2C_ReceiveAck();                 //接收应答

    MyI2C_Start();                      //I2C重复起始
    MyI2C_SendByte(MPU6050_ADDRESS | 0x01); //发送从机地址，读写位为1，表示即将读取
    MyI2C_ReceiveAck();                 //接收应答
    Data = MyI2C_ReceiveByte();         //接收指定寄存器的数据
    MyI2C_SendAck(1);                   //发送应答，给从机非应答，终止从机的数据输出
    MyI2C_Stop();                       //I2C终止

    return Data;
}

/**
  * @brief MPU6050指定地址连续写字节函数
  * @param Addr 器件地址
  * @param Reg 寄存器地址
  * @param Len 要写入的数据长度
  * @param Buf 写入数据的起始地址
  * @retval 返回0表示正常，其他表示失败
  */
uint8_t MPU6050_Write_Len(uint8_t Addr, uint8_t Reg, uint8_t Len, uint8_t *Buf)
{
    MyI2C_Start();
    MyI2C_SendByte((Addr << 1) | 0x00);    //发送器件地址+写命令
    if (MyI2C_ReceiveAck())   //等待应答
    {
        MyI2C_Stop();
        return 1;
    }
    MyI2C_SendByte(Reg);      //写寄存器地址
    if (MyI2C_ReceiveAck())   //等待应答
    {
        MyI2C_Stop();
        return 1;
    }
    while (Len--)
    {
        MyI2C_SendByte(*Buf++);    //发送数据
        if (MyI2C_ReceiveAck())    //等待ACK
        {
            MyI2C_Stop();
            return 1;
        }
    }
    MyI2C_Stop();
    return 0;
}

/**
  * @brief  MPU6050指定地址连续读字节函数
  * @param  Addr 器件地址
  * @param  Reg  寄存器地址
  * @param  Len  要读取的数据长度
  * @param  Buf  读取数据的存储区
  * @retval 返回0表示正常，其他表示失败
  */
uint8_t MPU6050_Read_Len(uint8_t Addr, uint8_t Reg, uint8_t Len, uint8_t *Buf)
{
    MyI2C_Start();
    MyI2C_SendByte((Addr << 1) | 0x00);    //发送器件地址+写命令
    if (MyI2C_ReceiveAck())
    {
        MyI2C_Stop();
        return 1;
    }
    MyI2C_SendByte(Reg);      //写寄存器地址
    if (MyI2C_ReceiveAck())   //等待应答
    {
        MyI2C_Stop();
        return 1;
    }
    MyI2C_Start();
    MyI2C_SendByte((Addr << 1) | 0x01);    //发送器件地址+读命令
    if (MyI2C_ReceiveAck())   //等待应答
    {
        MyI2C_Stop();
        return 1;
    }
    while (Len--)
    {
        *Buf++ = MyI2C_ReceiveByte();    //读数据
        if (Len)
        {
            MyI2C_SendAck(0);   //发送ACK
        }
        else
        {
            MyI2C_SendAck(1);   //发送nACK
        }
    }
    MyI2C_Stop();
    return 0;
}

/**
  * 函    数：MPU6050初始化
  * 参    数：无
  * 返 回 值：无
  */
void MPU6050_Init(void)
{
    MyI2C_Init();                                   //先初始化底层的I2C

    /*MPU6050寄存器初始化，需要对照MPU6050手册的寄存器描述配置，此处仅配置了部分重要的寄存器*/
    MPU6050_WriteReg(MPU6050_PWR_MGMT_1, 0x01);     //电源管理寄存器1，取消睡眠模式，选择时钟源为X轴陀螺仪
    MPU6050_WriteReg(MPU6050_PWR_MGMT_2, 0x00);     //电源管理寄存器2，保持默认值0，所有轴均不待机
    MPU6050_WriteReg(MPU6050_SMPLRT_DIV, 0x09);     //采样率分频寄存器，配置采样率
    MPU6050_WriteReg(MPU6050_CONFIG, 0x06);         //配置寄存器，配置DLPF
    MPU6050_WriteReg(MPU6050_GYRO_CONFIG, 0x18);    //陀螺仪配置寄存器，选择满量程为±2000°/s
    MPU6050_WriteReg(MPU6050_ACCEL_CONFIG, 0x18);   //加速度计配置寄存器，选择满量程为±16g
}

/**
  * 函    数：MPU6050获取ID号
  * 参    数：无
  * 返 回 值：MPU6050的ID号
  */
uint8_t MPU6050_GetID(void)
{
    return MPU6050_ReadReg(MPU6050_WHO_AM_I);       //返回WHO_AM_I寄存器的值
}

/**
  * 函    数：MPU6050获取数据
  * 参    数：AccX AccY AccZ 加速度计X、Y、Z轴的数据，使用输出参数的形式返回，范围：-32768~32767
  * 参    数：GyroX GyroY GyroZ 陀螺仪X、Y、Z轴的数据，使用输出参数的形式返回，范围：-32768~32767
  * 返 回 值：无
  */
void MPU6050_GetData(int16_t *AccX, int16_t *AccY, int16_t *AccZ,
                     int16_t *GyroX, int16_t *GyroY, int16_t *GyroZ)
{
    uint8_t DataH, DataL;                               //定义数据高8位和低8位的变量

    DataH = MPU6050_ReadReg(MPU6050_ACCEL_XOUT_H);      //读取加速度计X轴的高8位数据
    DataL = MPU6050_ReadReg(MPU6050_ACCEL_XOUT_L);      //读取加速度计X轴的低8位数据
    *AccX = (DataH << 8) | DataL;                       //数据拼接，通过输出参数返回

    DataH = MPU6050_ReadReg(MPU6050_ACCEL_YOUT_H);      //读取加速度计Y轴的高8位数据
    DataL = MPU6050_ReadReg(MPU6050_ACCEL_YOUT_L);      //读取加速度计Y轴的低8位数据
    *AccY = (DataH << 8) | DataL;                       //数据拼接，通过输出参数返回

    DataH = MPU6050_ReadReg(MPU6050_ACCEL_ZOUT_H);      //读取加速度计Z轴的高8位数据
    DataL = MPU6050_ReadReg(MPU6050_ACCEL_ZOUT_L);      //读取加速度计Z轴的低8位数据
    *AccZ = (DataH << 8) | DataL;                       //数据拼接，通过输出参数返回

    DataH = MPU6050_ReadReg(MPU6050_GYRO_XOUT_H);       //读取陀螺仪X轴的高8位数据
    DataL = MPU6050_ReadReg(MPU6050_GYRO_XOUT_L);       //读取陀螺仪X轴的低8位数据
    *GyroX = (DataH << 8) | DataL;                      //数据拼接，通过输出参数返回

    DataH = MPU6050_ReadReg(MPU6050_GYRO_YOUT_H);       //读取陀螺仪Y轴的高8位数据
    DataL = MPU6050_ReadReg(MPU6050_GYRO_YOUT_L);       //读取陀螺仪Y轴的低8位数据
    *GyroY = (DataH << 8) | DataL;                      //数据拼接，通过输出参数返回

    DataH = MPU6050_ReadReg(MPU6050_GYRO_ZOUT_H);       //读取陀螺仪Z轴的高8位数据
    DataL = MPU6050_ReadReg(MPU6050_GYRO_ZOUT_L);       //读取陀螺仪Z轴的低8位数据
    *GyroZ = (DataH << 8) | DataL;                      //数据拼接，通过输出参数返回
}

/**
  * @brief  DMP初始化函数
  * @param  无
  * @retval 无
  */
void MPU6050_DMPInit(void)
{
    uint8_t res = 0;

    MyI2C_Init();
    res = mpu_init();
    if (!res)
    {
        Serial_Printf("mpu initialization complete ......\r\n");

        //设置所需要的传感器
        res = mpu_set_sensors(INV_XYZ_GYRO | INV_XYZ_ACCEL);
        if (!res)
        {
            Serial_Printf("mpu_set_sensor complete ......\r\n");
        }
        else
        {
            Serial_Printf("mpu_set_sensor come across error ......\r\n");
        }

        //设置FIFO
        res = mpu_configure_fifo(INV_XYZ_GYRO | INV_XYZ_ACCEL);
        if (!res)
        {
            Serial_Printf("mpu_configure_fifo complete ......\r\n");
        }
        else
        {
            Serial_Printf("mpu_configure_fifo come across error ......\r\n");
        }

        //设置采样率
        res = mpu_set_sample_rate(DEFAULT_MPU_HZ);
        if (!res)
        {
            Serial_Printf("mpu_set_sample_rate complete ......\r\n");
        }
        else
        {
            Serial_Printf("mpu_set_sample_rate come across error ......\r\n");
        }

        //加载DMP固件
        res = dmp_load_motion_driver_firmware();
        if (!res)
        {
            Serial_Printf("dmp_load_motion_driver_firmware complete ......\r\n");
        }
        else
        {
            Serial_Printf("dmp_load_motion_driver_firmware come across error ......\r\n");
        }

        //设置陀螺仪方向
        res = dmp_set_orientation(inv_orientation_matrix_to_scalar(gyro_orientation));
        if (!res)
        {
            Serial_Printf("dmp_set_orientation complete ......\r\n");
        }
        else
        {
            Serial_Printf("dmp_set_orientation come across error ......\r\n");
        }

        //设置DMP功能
        res = dmp_enable_feature(DMP_FEATURE_6X_LP_QUAT | DMP_FEATURE_TAP |
                                 DMP_FEATURE_ANDROID_ORIENT | DMP_FEATURE_SEND_RAW_ACCEL | DMP_FEATURE_SEND_CAL_GYRO |
                                 DMP_FEATURE_GYRO_CAL);
        if (!res)
        {
            Serial_Printf("dmp_enable_feature complete ......\r\n");
        }
        else
        {
            Serial_Printf("dmp_enable_feature come across error ......\r\n");
        }

        //设置DMP输出速率(最大不超过200Hz)
        res = dmp_set_fifo_rate(DEFAULT_MPU_HZ);
        if (!res)
        {
            Serial_Printf("dmp_set_fifo_rate complete ......\r\n");
        }
        else
        {
            Serial_Printf("dmp_set_fifo_rate come across error ......\r\n");
        }

        //自检
        res = run_self_test();
        if (!res)
        {
            Serial_Printf("mpu_run_self_test complete ......\r\n");
        }
        else
        {
            Serial_Printf("mpu_run_self_test come across error ......\r\n");
        }

        //使能DMP
        res = mpu_set_dmp_state(1);
        if (!res)
        {
            Serial_Printf("mpu_set_dmp_state complete ......\r\n");
        }
        else
        {
            Serial_Printf("mpu_set_dmp_state come across error ......\r\n");
        }
    }
    else
    {
        Serial_Printf("mpu initialization come across error ......\r\n");
        while (1);
    }
}

/**
  * @brief  获取DMP处理后数据函数
  * @param  Pitch 俯仰角，精度:0.1°，范围:-90.0° ~ +90.0°
  * @param  Roll  横滚角，精度:0.1°，范围:-180.0°~ +180.0°
  * @param  yaw   偏航角，精度:0.1°，范围:-180.0°~ +180.0°
  * @retval 返回0表示正常，其他表示失败
  */
// 原有全局变量（不变，和你的原代码一致）
static float calibrated_Yaw = 0.0f;
static float init_original_Yaw = 0.0f; // 记录开机时的原始Yaw角（闭环校准用）

// 补充：新增一个全局变量，用于传递清零时刻的原始Yaw（仅这一个新增，极简）
static float reset_original_Yaw = 0.0f;

// 你的原DMP函数（仅新增1行，补全last_Yaw更新）
uint8_t MPU6050_ReadDMP(float *Pitch, float *Roll, float *Yaw)
{   
    if(dmp_read_fifo(gyro, accel, quat, &sensor_timestamp, &sensors, &more))  return 1;
    if(sensors & INV_WXYZ_QUAT)
    {    
        q0 = quat[0] / q30;    //q30格式转换为浮点数
        q1 = quat[1] / q30;
        q2 = quat[2] / q30;
        q3 = quat[3] / q30;
        
        // 计算得到俯仰角、横滚角和偏航角
        *Pitch = asin(-2 * q1 * q3 + 2 * q0 * q2) * 57.3; 
        *Roll  = atan2(2 * q2 * q3 + 2 * q0 * q1, -2 * q1 * q1 - 2 * q2 * q2 + 1) * 57.3;
        float original_Yaw  = atan2(2 * q1 * q2 + 2 * q0 * q3, -2 * q2 * q2 - 2 * q3 * q3 + 1) * 57.3;
        
        // 3. 初始化：记录开机原始角度 + 历史角度
        static float last_Yaw = 0.0f;
        static int first_run = 1;
        if (first_run)
        {
            last_Yaw = original_Yaw;
            init_original_Yaw = original_Yaw; // 保存开机时的原始角度
            first_run = 0;
        }

        // ========== 新增：清零后同步更新last_Yaw（核心修复，仅1行） ==========
        if (calibrated_Yaw == 0.0f && reset_original_Yaw == original_Yaw)
        {
            last_Yaw = original_Yaw; // 同步更新角度变化基准，解决十几度残留
        }

        // 4. 核心：计算变化量 + 补偿（你的原逻辑，不变）
        float scale = 360.0f / 305.9f;
        float delta = original_Yaw - last_Yaw;
        if (delta > 180.0f) delta -= 360.0f;
        if (delta < -180.0f) delta += 360.0f;
        calibrated_Yaw += delta * scale;

        // ========== 闭环强制校准（你的原逻辑，不变） ==========
//        float yaw_diff = fabs(original_Yaw - init_original_Yaw);
//        if (yaw_diff < 5.0f || yaw_diff > 355.0f) 
//        {
//            calibrated_Yaw = 360.0f; // 强制设为360度
//        }
        
        // 新增：判断小车是否静止（用加速度计模值，静止时加速度模值≈1g）
        float acc_mag = sqrt(accel[0]*accel[0] + accel[1]*accel[1] + accel[2]*accel[2]);
        float yaw_diff = fabs(original_Yaw - init_original_Yaw);
        // 仅在【静止】且【偏移<0.8°】时，才强制归位（适配1°偏移场景）
        if ((acc_mag > 0.95f && acc_mag < 1.05f) && (yaw_diff < 0.8f || yaw_diff > 359.2f))
        {
            calibrated_Yaw = 360.0f; // 强制设为360度
        }

        // 5. 约束在0~360°，并输出（你的原逻辑，不变）
        calibrated_Yaw = fmod(calibrated_Yaw, 360.0f);
        if(calibrated_Yaw > 180.0f) calibrated_Yaw -= 360.0f;
        *Yaw = calibrated_Yaw;
        last_Yaw = original_Yaw;
    }
    else  return 2;
    
    return 0;
}


// ========== 修复后的清零函数（去掉无效代码，补充传递清零时刻角度） ==========
void MPU6050_SimpleResetYaw(void)
{
    // 1. 直接清零核心累积变量（你的原逻辑，保留）
    calibrated_Yaw = 0.0f;
    
    // 2. 去掉无效的init_original_Yaw计算（因为q0~q3在这里访问不到有效数据）
    // （可选：若想更新闭环基准，需在DMP内部更新，外部无法获取有效q0~q3）
    
    // 3. 记录清零时刻的原始角度（用于同步更新last_Yaw，解决十几度残留）
    reset_original_Yaw = atan2(2 * q1 * q2 + 2 * q0 * q3, -2 * q2 * q2 - 2 * q3 * q3 + 1) * 57.3;
    // 新增全局变量：用于存储最新的有效四元数

}

```


### MPU6050.h
```c

#ifndef __MPU6050_H
#define __MPU6050_H

#include "stm32f10x.h"

void MPU6050_WriteReg(uint8_t RegAddress, uint8_t Data);
uint8_t MPU6050_ReadReg(uint8_t RegAddress);
uint8_t MPU6050_Write_Len(uint8_t Addr, uint8_t Reg, uint8_t Len, uint8_t *Buf);
uint8_t MPU6050_Read_Len(uint8_t Addr, uint8_t Reg, uint8_t Len, uint8_t *Buf);
void MPU6050_Init(void);
uint8_t MPU6050_GetID(void);
void MPU6050_GetData(int16_t *AccX, int16_t *AccY, int16_t *AccZ,
                     int16_t *GyroX, int16_t *GyroY, int16_t *GyroZ);

void MPU6050_DMPInit(void);
uint8_t MPU6050_ReadDMP(float *Pitch, float *Roll, float *Yaw);
void MPU6050_SimpleResetYaw(void);

#endif

```


## 硬件移植
只需要在软件I2C的基础上修改mpu6050.c文件即可

### MPU6050.c
```c
#include "stm32f10x.h"                  // Device header
#include "MPU6050_Reg.h"
#include <stdint.h>
#include <math.h>
#include "inv_mpu.h"
#include "inv_mpu_dmp_motion_driver.h"
#include "Serial.h"

/* 引脚配置 */
#define MPU6050_SCL     GPIO_Pin_10
#define SCL_GPIO_Port GPIOB
#define MPU6050_SDA     GPIO_Pin_11
#define SDA_GPIO_Port GPIOB
#define RCC_Periph RCC_APB2Periph_GPIOB


#define MPU6050_ADDRESS     0xD0            //MPU6050的I2C从机地址
#define DEFAULT_MPU_HZ      (100)           //定义输出速度
#define q30                 1073741824.0f   //q30格式，long转float时的参数

//陀螺仪方向设置
static signed char gyro_orientation[9] =
{
    1, 0, 0,
    0, 1, 0,
    0, 0, 1
};
float q0 = 1.0f, q1 = 0.0f, q2 = 0.0f, q3 = 0.0f;
unsigned long sensor_timestamp;
short gyro[3], accel[3], sensors;
unsigned char more;
long quat[4];

/**
  * 函    数：MPU6050等待事件
  * 参    数：同I2C_CheckEvent
  * 返 回 值：无
  */
void MPU6050_WaitEvent(I2C_TypeDef *I2Cx, uint32_t I2C_EVENT)
{
    uint32_t Timeout;
    Timeout = 10000;                                    //给定超时计数时间
    while (I2C_CheckEvent(I2Cx, I2C_EVENT) != SUCCESS)  //循环等待指定事件
    {
        Timeout --;                                     //等待时，计数值自减
        if (Timeout == 0)                               //自减到0后，等待超时
        {
            /*超时的错误处理代码，可以添加到此处*/
            break;                                      //跳出等待，不等了
        }
    }
}

/**
  * 函    数：MPU6050写寄存器
  * 参    数：RegAddress 寄存器地址，范围：参考MPU6050手册的寄存器描述
  * 参    数：Data 要写入寄存器的数据，范围：0x00~0xFF
  * 返 回 值：无
  */
void MPU6050_WriteReg(uint8_t RegAddress, uint8_t Data)
{
    I2C_GenerateSTART(I2C2, ENABLE);                                        //硬件I2C生成起始条件
    MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_MODE_SELECT);                  //等待EV5

    I2C_Send7bitAddress(I2C2, MPU6050_ADDRESS, I2C_Direction_Transmitter);  //硬件I2C发送从机地址，方向为发送
    MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED);    //等待EV6

    I2C_SendData(I2C2, RegAddress);                                         //硬件I2C发送寄存器地址
    MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_BYTE_TRANSMITTING);            //等待EV8

    I2C_SendData(I2C2, Data);                                               //硬件I2C发送数据
    MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_BYTE_TRANSMITTED);             //等待EV8_2

    I2C_GenerateSTOP(I2C2, ENABLE);                                         //硬件I2C生成终止条件
}

/**
  * 函    数：MPU6050读寄存器
  * 参    数：RegAddress 寄存器地址，范围：参考MPU6050手册的寄存器描述
  * 返 回 值：读取寄存器的数据，范围：0x00~0xFF
  */
uint8_t MPU6050_ReadReg(uint8_t RegAddress)
{
    uint8_t Data;

    I2C_GenerateSTART(I2C2, ENABLE);                                        //硬件I2C生成起始条件
    MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_MODE_SELECT);                  //等待EV5

    I2C_Send7bitAddress(I2C2, MPU6050_ADDRESS, I2C_Direction_Transmitter);  //硬件I2C发送从机地址，方向为发送
    MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED);    //等待EV6

    I2C_SendData(I2C2, RegAddress);                                         //硬件I2C发送寄存器地址
    MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_BYTE_TRANSMITTED);             //等待EV8_2

    
    I2C_GenerateSTART(I2C2, ENABLE);                                        //硬件I2C生成重复起始条件
    MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_MODE_SELECT);                  //等待EV5

    I2C_Send7bitAddress(I2C2, MPU6050_ADDRESS, I2C_Direction_Receiver);     //硬件I2C发送从机地址，方向为接收
    MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_RECEIVER_MODE_SELECTED);       //等待EV6

    I2C_AcknowledgeConfig(I2C2, DISABLE);                                   //在接收最后一个字节之前提前将应答失能
    I2C_GenerateSTOP(I2C2, ENABLE);                                         //在接收最后一个字节之前提前申请停止条件

    MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_BYTE_RECEIVED);                //等待EV7
    Data = I2C_ReceiveData(I2C2);                                           //接收数据寄存器

    I2C_AcknowledgeConfig(I2C2, ENABLE);                                    //将应答恢复为使能，为了不影响后续可能产生的读取多字节操作

    return Data;
}

/**
  * @brief MPU6050指定地址连续写字节函数
  * @param Addr 器件地址
  * @param Reg 寄存器地址
  * @param Len 要写入的数据长度
  * @param Buf 写入数据的起始地址
  * @retval 返回0表示正常，其他表示失败
  */
uint8_t MPU6050_Write_Len(uint8_t Addr, uint8_t Reg, uint8_t Len, uint8_t *Buf)
{
    I2C_GenerateSTART(I2C2, ENABLE);                                        //硬件I2C生成起始条件
    MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_MODE_SELECT);                  //等待EV5

    I2C_Send7bitAddress(I2C2, Addr << 1, I2C_Direction_Transmitter);        //硬件I2C发送从机地址，方向为发送
    MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED);    //等待EV6

    I2C_SendData(I2C2, Reg);                                                //硬件I2C发送寄存器地址
    MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_BYTE_TRANSMITTING);            //等待EV8

    while (Len--)
    {
        I2C_SendData(I2C2, *Buf++);                                         //硬件I2C发送数据
        MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_BYTE_TRANSMITTED);         //等待EV8_2
    }
    I2C_GenerateSTOP(I2C2, ENABLE);                                         //硬件I2C生成终止条件
    return 0;
}

/**
  * @brief  MPU6050指定地址连续读字节函数
  * @param  Addr 器件地址
  * @param  Reg  寄存器地址
  * @param  Len  要读取的数据长度
  * @param  Buf  读取数据的存储区
  * @retval 返回0表示正常，其他表示失败
  */
uint8_t MPU6050_Read_Len(uint8_t Addr, uint8_t Reg, uint8_t Len, uint8_t *Buf)
{
    I2C_GenerateSTART(I2C2, ENABLE);                                        //硬件I2C生成起始条件
    MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_MODE_SELECT);                  //等待EV5

    I2C_Send7bitAddress(I2C2, Addr << 1, I2C_Direction_Transmitter);  //硬件I2C发送从机地址，方向为发送
    MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED);    //等待EV6

    I2C_SendData(I2C2, Reg);                                         //硬件I2C发送寄存器地址
    MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_BYTE_TRANSMITTED);             //等待EV8_2
    
    I2C_GenerateSTART(I2C2, ENABLE);                                        //硬件I2C生成重复起始条件
    MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_MODE_SELECT);                  //等待EV5

    I2C_Send7bitAddress(I2C2, Addr << 1, I2C_Direction_Receiver);     //硬件I2C发送从机地址，方向为接收
    MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_RECEIVER_MODE_SELECTED);       //等待EV6

    while (Len--)
    {
        if (Len)
        {
            I2C_AcknowledgeConfig(I2C2, DISABLE);                     //在接收最后一个字节之前提前将应答使能
        }
        else
        {
            I2C_AcknowledgeConfig(I2C2, DISABLE);                     //在接收最后一个字节之前提前将应答失能
            I2C_GenerateSTOP(I2C2, ENABLE);                           //在接收最后一个字节之前提前申请停止条件
        }
        MPU6050_WaitEvent(I2C2, I2C_EVENT_MASTER_BYTE_RECEIVED);                //等待EV7
        *Buf++ = I2C_ReceiveData(I2C2);                                           //接收数据寄存器
    }
    I2C_AcknowledgeConfig(I2C2, ENABLE);                                    //将应答恢复为使能，为了不影响后续可能产生的读取多字节操作
    return 0;
}

/**
 * @brief MPU6050初始化I2C基本配置
 */
void MPU6050_I2C_Init(void)
{
    /*开启时钟*/
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_I2C2, ENABLE);        //开启I2C2的时钟
    RCC_APB2PeriphClockCmd(RCC_Periph, ENABLE);       //开启GPIOB的时钟

    /*GPIO初始化*/
    GPIO_InitTypeDef GPIO_InitStructure;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_OD;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Pin = MPU6050_SCL;
    GPIO_Init(SCL_GPIO_Port, &GPIO_InitStructure);                  //将SCL引脚初始化为开漏输出

    GPIO_InitStructure.GPIO_Pin = MPU6050_SDA;
    GPIO_Init(SDA_GPIO_Port, &GPIO_InitStructure);                  //将SDA引脚初始化为开漏输出
    /*设置默认电平*/
    GPIO_SetBits(SCL_GPIO_Port, MPU6050_SCL);         //设置SCL引脚初始化后默认为高电平（释放总线状态）
    GPIO_SetBits(SDA_GPIO_Port, MPU6050_SDA);         //设置SDA引脚初始化后默认为高电平（释放总线状态）

    /*I2C初始化*/
    I2C_InitTypeDef I2C_InitStructure;                      //定义结构体变量
    I2C_InitStructure.I2C_Mode = I2C_Mode_I2C;              //模式，选择为I2C模式
    I2C_InitStructure.I2C_ClockSpeed = 50000;               //时钟速度，选择为50KHz
    I2C_InitStructure.I2C_DutyCycle = I2C_DutyCycle_2;      //时钟占空比，选择Tlow/Thigh = 2
    I2C_InitStructure.I2C_Ack = I2C_Ack_Enable;             //应答，选择使能
    I2C_InitStructure.I2C_AcknowledgedAddress = I2C_AcknowledgedAddress_7bit;   //应答地址，选择7位，从机模式下才有效
    I2C_InitStructure.I2C_OwnAddress1 = 0x00;               //自身地址，从机模式下才有效
    I2C_Init(I2C2, &I2C_InitStructure);                     //将结构体变量交给I2C_Init，配置I2C2

    /*I2C使能*/
    I2C_Cmd(I2C2, ENABLE);                                  //使能I2C2，开始运行

}

/**
  * 函    数：MPU6050初始化
  * 参    数：无
  * 返 回 值：无
  */
void MPU6050_Init(void)
{
    MPU6050_I2C_Init();                                   //先初始化底层的I2C

    /*MPU6050寄存器初始化，需要对照MPU6050手册的寄存器描述配置，此处仅配置了部分重要的寄存器*/
    MPU6050_WriteReg(MPU6050_PWR_MGMT_1, 0x01);     //电源管理寄存器1，取消睡眠模式，选择时钟源为X轴陀螺仪
    MPU6050_WriteReg(MPU6050_PWR_MGMT_2, 0x00);     //电源管理寄存器2，保持默认值0，所有轴均不待机
    MPU6050_WriteReg(MPU6050_SMPLRT_DIV, 0x09);     //采样率分频寄存器，配置采样率
    MPU6050_WriteReg(MPU6050_CONFIG, 0x06);         //配置寄存器，配置DLPF
    MPU6050_WriteReg(MPU6050_GYRO_CONFIG, 0x18);    //陀螺仪配置寄存器，选择满量程为±2000°/s
    MPU6050_WriteReg(MPU6050_ACCEL_CONFIG, 0x18);   //加速度计配置寄存器，选择满量程为±16g
}

/**
  * 函    数：MPU6050获取ID号
  * 参    数：无
  * 返 回 值：MPU6050的ID号
  */
uint8_t MPU6050_GetID(void)
{
    return MPU6050_ReadReg(MPU6050_WHO_AM_I);       //返回WHO_AM_I寄存器的值
}

/**
  * 函    数：MPU6050获取数据
  * 参    数：AccX AccY AccZ 加速度计X、Y、Z轴的数据，使用输出参数的形式返回，范围：-32768~32767
  * 参    数：GyroX GyroY GyroZ 陀螺仪X、Y、Z轴的数据，使用输出参数的形式返回，范围：-32768~32767
  * 返 回 值：无
  */
void MPU6050_GetData(int16_t *AccX, int16_t *AccY, int16_t *AccZ,
                     int16_t *GyroX, int16_t *GyroY, int16_t *GyroZ)
{
    uint8_t DataH, DataL;                               //定义数据高8位和低8位的变量

    DataH = MPU6050_ReadReg(MPU6050_ACCEL_XOUT_H);      //读取加速度计X轴的高8位数据
    DataL = MPU6050_ReadReg(MPU6050_ACCEL_XOUT_L);      //读取加速度计X轴的低8位数据
    *AccX = (DataH << 8) | DataL;                       //数据拼接，通过输出参数返回

    DataH = MPU6050_ReadReg(MPU6050_ACCEL_YOUT_H);      //读取加速度计Y轴的高8位数据
    DataL = MPU6050_ReadReg(MPU6050_ACCEL_YOUT_L);      //读取加速度计Y轴的低8位数据
    *AccY = (DataH << 8) | DataL;                       //数据拼接，通过输出参数返回

    DataH = MPU6050_ReadReg(MPU6050_ACCEL_ZOUT_H);      //读取加速度计Z轴的高8位数据
    DataL = MPU6050_ReadReg(MPU6050_ACCEL_ZOUT_L);      //读取加速度计Z轴的低8位数据
    *AccZ = (DataH << 8) | DataL;                       //数据拼接，通过输出参数返回

    DataH = MPU6050_ReadReg(MPU6050_GYRO_XOUT_H);       //读取陀螺仪X轴的高8位数据
    DataL = MPU6050_ReadReg(MPU6050_GYRO_XOUT_L);       //读取陀螺仪X轴的低8位数据
    *GyroX = (DataH << 8) | DataL;                      //数据拼接，通过输出参数返回

    DataH = MPU6050_ReadReg(MPU6050_GYRO_YOUT_H);       //读取陀螺仪Y轴的高8位数据
    DataL = MPU6050_ReadReg(MPU6050_GYRO_YOUT_L);       //读取陀螺仪Y轴的低8位数据
    *GyroY = (DataH << 8) | DataL;                      //数据拼接，通过输出参数返回

    DataH = MPU6050_ReadReg(MPU6050_GYRO_ZOUT_H);       //读取陀螺仪Z轴的高8位数据
    DataL = MPU6050_ReadReg(MPU6050_GYRO_ZOUT_L);       //读取陀螺仪Z轴的低8位数据
    *GyroZ = (DataH << 8) | DataL;                      //数据拼接，通过输出参数返回
}

/**
  * @brief  DMP初始化函数
  * @param  无
  * @retval 无
  */
void MPU6050_DMPInit(void)
{
    uint8_t res = 0;

    MPU6050_I2C_Init();
    res = mpu_init();
    if (!res)
    {
        Serial_Printf("mpu initialization complete ......\r\n");

        //设置所需要的传感器
        res = mpu_set_sensors(INV_XYZ_GYRO | INV_XYZ_ACCEL);
        if (!res)
        {
            Serial_Printf("mpu_set_sensor complete ......\r\n");
        }
        else
        {
            Serial_Printf("mpu_set_sensor come across error ......\r\n");
        }

        //设置FIFO
        res = mpu_configure_fifo(INV_XYZ_GYRO | INV_XYZ_ACCEL);
        if (!res)
        {
            Serial_Printf("mpu_configure_fifo complete ......\r\n");
        }
        else
        {
            Serial_Printf("mpu_configure_fifo come across error ......\r\n");
        }

        //设置采样率
        res = mpu_set_sample_rate(DEFAULT_MPU_HZ);
        if (!res)
        {
            Serial_Printf("mpu_set_sample_rate complete ......\r\n");
        }
        else
        {
            Serial_Printf("mpu_set_sample_rate come across error ......\r\n");
        }

        //加载DMP固件
        res = dmp_load_motion_driver_firmware();
        if (!res)
        {
            Serial_Printf("dmp_load_motion_driver_firmware complete ......\r\n");
        }
        else
        {
            Serial_Printf("dmp_load_motion_driver_firmware come across error ......\r\n");
        }

        //设置陀螺仪方向
        res = dmp_set_orientation(inv_orientation_matrix_to_scalar(gyro_orientation));
        if (!res)
        {
            Serial_Printf("dmp_set_orientation complete ......\r\n");
        }
        else
        {
            Serial_Printf("dmp_set_orientation come across error ......\r\n");
        }

        //设置DMP功能
        res = dmp_enable_feature(DMP_FEATURE_6X_LP_QUAT | DMP_FEATURE_TAP |
                                 DMP_FEATURE_ANDROID_ORIENT | DMP_FEATURE_SEND_RAW_ACCEL | DMP_FEATURE_SEND_CAL_GYRO |
                                 DMP_FEATURE_GYRO_CAL);
        if (!res)
        {
            Serial_Printf("dmp_enable_feature complete ......\r\n");
        }
        else
        {
            Serial_Printf("dmp_enable_feature come across error ......\r\n");
        }

        //设置DMP输出速率(最大不超过200Hz)
        res = dmp_set_fifo_rate(DEFAULT_MPU_HZ);
        if (!res)
        {
            Serial_Printf("dmp_set_fifo_rate complete ......\r\n");
        }
        else
        {
            Serial_Printf("dmp_set_fifo_rate come across error ......\r\n");
        }

        //自检
        res = run_self_test();
        if (!res)
        {
            Serial_Printf("mpu_run_self_test complete ......\r\n");
        }
        else
        {
            Serial_Printf("mpu_run_self_test come across error ......\r\n");
        }

        //使能DMP
        res = mpu_set_dmp_state(1);
        if (!res)
        {
            Serial_Printf("mpu_set_dmp_state complete ......\r\n");
        }
        else
        {
            Serial_Printf("mpu_set_dmp_state come across error ......\r\n");
        }
    }
    else
    {
        Serial_Printf("mpu initialization come across error ......\r\n");
        while (1);
    }
}

/**
  * @brief  获取DMP处理后数据函数
  * @param  Pitch 俯仰角，精度:0.1°，范围:-90.0° ~ +90.0°
  * @param  Roll  横滚角，精度:0.1°，范围:-180.0°~ +180.0°
  * @param  yaw   偏航角，精度:0.1°，范围:-180.0°~ +180.0°
  * @retval 返回0表示正常，其他表示失败
  */
// 原有全局变量（不变，和你的原代码一致）
static float calibrated_Yaw = 0.0f;
static float init_original_Yaw = 0.0f; // 记录开机时的原始Yaw角（闭环校准用）

// 补充：新增一个全局变量，用于传递清零时刻的原始Yaw（仅这一个新增，极简）
static float reset_original_Yaw = 0.0f;

// 你的原DMP函数（仅新增1行，补全last_Yaw更新）
uint8_t MPU6050_ReadDMP(float *Pitch, float *Roll, float *Yaw)
{   
    if(dmp_read_fifo(gyro, accel, quat, &sensor_timestamp, &sensors, &more))  return 1;
    if(sensors & INV_WXYZ_QUAT)
    {    
        q0 = quat[0] / q30;    //q30格式转换为浮点数
        q1 = quat[1] / q30;
        q2 = quat[2] / q30;
        q3 = quat[3] / q30;
        
        // 计算得到俯仰角、横滚角和偏航角
        *Pitch = asin(-2 * q1 * q3 + 2 * q0 * q2) * 57.3; 
        *Roll  = atan2(2 * q2 * q3 + 2 * q0 * q1, -2 * q1 * q1 - 2 * q2 * q2 + 1) * 57.3;
        float original_Yaw  = atan2(2 * q1 * q2 + 2 * q0 * q3, -2 * q2 * q2 - 2 * q3 * q3 + 1) * 57.3;
        
        // 3. 初始化：记录开机原始角度 + 历史角度
        static float last_Yaw = 0.0f;
        static int first_run = 1;
        if (first_run)
        {
            last_Yaw = original_Yaw;
            init_original_Yaw = original_Yaw; // 保存开机时的原始角度
            first_run = 0;
        }

        // ========== 新增：清零后同步更新last_Yaw（核心修复，仅1行） ==========
        if (calibrated_Yaw == 0.0f && reset_original_Yaw == original_Yaw)
        {
            last_Yaw = original_Yaw; // 同步更新角度变化基准，解决十几度残留
        }

        // 4. 核心：计算变化量 + 补偿（你的原逻辑，不变）
        float scale = 360.0f / 305.9f;
        float delta = original_Yaw - last_Yaw;
        if (delta > 180.0f) delta -= 360.0f;
        if (delta < -180.0f) delta += 360.0f;
        calibrated_Yaw += delta * scale;

        // ========== 闭环强制校准（你的原逻辑，不变） ==========
//        float yaw_diff = fabs(original_Yaw - init_original_Yaw);
//        if (yaw_diff < 5.0f || yaw_diff > 355.0f) 
//        {
//            calibrated_Yaw = 360.0f; // 强制设为360度
//        }
        
        // 新增：判断小车是否静止（用加速度计模值，静止时加速度模值≈1g）
        float acc_mag = sqrt(accel[0]*accel[0] + accel[1]*accel[1] + accel[2]*accel[2]);
        float yaw_diff = fabs(original_Yaw - init_original_Yaw);
        // 仅在【静止】且【偏移<0.8°】时，才强制归位（适配1°偏移场景）
        if ((acc_mag > 0.95f && acc_mag < 1.05f) && (yaw_diff < 0.8f || yaw_diff > 359.2f))
        {
            calibrated_Yaw = 360.0f; // 强制设为360度
        }

        // 5. 约束在0~360°，并输出（你的原逻辑，不变）
        calibrated_Yaw = fmod(calibrated_Yaw, 360.0f);
        if(calibrated_Yaw > 180.0f) calibrated_Yaw -= 360.0f;
        *Yaw = calibrated_Yaw;
        last_Yaw = original_Yaw;
    }
    else  return 2;
    
    return 0;
}


// ========== 修复后的清零函数（去掉无效代码，补充传递清零时刻角度） ==========
void MPU6050_SimpleResetYaw(void)
{
    // 1. 直接清零核心累积变量（你的原逻辑，保留）
    calibrated_Yaw = 0.0f;
    
    // 2. 去掉无效的init_original_Yaw计算（因为q0~q3在这里访问不到有效数据）
    // （可选：若想更新闭环基准，需在DMP内部更新，外部无法获取有效q0~q3）
    
    // 3. 记录清零时刻的原始角度（用于同步更新last_Yaw，解决十几度残留）
    reset_original_Yaw = atan2(2 * q1 * q2 + 2 * q0 * q3, -2 * q2 * q2 - 2 * q3 * q3 + 1) * 57.3;
    // 新增全局变量：用于存储最新的有效四元数

}

```


# HAL库(基于cubemx)

## 硬件I2C移植

==参考视频==

https://www.bilibili.com/video/BV13N4y1y7Js/?spm_id_from=0.0.search-card.all.click&vd_source=f7c094930be9069ca80f211625e6ec72
添加mpu6050.c/.h，添加官方源码eMPL/下的六个文件。
**主要修改思路为更改两个dmp库c文件的宏定义为mpu6050设备，更换原来提供的i2c接口函数为自己提供的函数，主要过程为编写mpu6050源文件，参考\Embedded_MotionDriver_5.1\simple_apps\msp430\motion_driver_test.c**
### inv_mpu.c
```c
注释原MSP430宏定义，添加STM32_MPU6050宏定义
//#if defined MOTION_DRIVER_TARGET_MSP430
#if defined STM32_MPU6050 
注释以下头文件并添加自己提供的I2C调用接口的头文件
//#include "msp430.h"
//#include "msp430_i2c.h"
//#include "msp430_clock.h"
//#include "msp430_interrupt.h"
#include "i2c.h"

这部分是给dmp库的读写等函数的调用接口，将其更改为自己提供的I2C调用接口
//#define i2c_write   msp430_i2c_write
//#define i2c_read    msp430_i2c_read
//#define delay_ms    msp430_delay_ms
//#define get_ms      msp430_get_clock_ms

 * i2c_write函数注意事项：
 * 查看i2c_write函数的调用参数并将msp430_i2c_write更改为HAL_I2C_Mem_Write此处传入的句柄是i2c1可以根据需要更改
 * devaddr << 1 由于dmp库传入地址是直接传入设备的7位地址，hal库需要地址在高7位，
 * 声明I2C_MEMADD_SIZE_8BIT寄存器地址长度是 1 字节

#define I2C_TIMEOUT         20      //最长等待时间
#define i2c_write(devaddr, regaddr, size, pdata) \
        HAL_I2C_Mem_Write(&hi2c1, devaddr << 1, regaddr, I2C_MEMADD_SIZE_8BIT, pdata, size, I2C_TIMEOUT)
#define i2c_read(devaddr, regaddr, size, pdata) \
        HAL_I2C_Mem_Read(&hi2c1, devaddr << 1, regaddr, I2C_MEMADD_SIZE_8BIT, pdata, size, I2C_TIMEOUT)
#define delay_ms(ms)    HAL_Delay(ms)
#define get_ms(p)       do{*p = HAL_GetTick();}while(0)

注释这段代码
//static inline int reg_int_cb(struct int_param_s *int_param)
//{
//    return msp430_reg_int_cb(int_param->cb, int_param->pin, int_param->lp_exit,
//        int_param->active_low);
//}

此外
注释main函数下其他的警告
    if (int_param)
	    reg_int_cb(int_param);
	    
该函数会报一个定义了但是未调用的警告，由于未使用，将整个函数注释
static int setup_compass(void)
```

### inv_mpu.h
```c
添加两个宏定义
#define STM32_MPU6050
#define MPU6050

该结构体会报一个错误原因是宏定义将内部所有内容屏蔽了在#endif后面随意定义一个即可
struct int_param_s {
#if defined EMPL_TARGET_MSP430 || defined MOTION_DRIVER_TARGET_MSP430
    void (*cb)(void);
    unsigned short pin;
    unsigned char lp_exit;
    unsigned char active_low;
#elif defined EMPL_TARGET_UC3L0
    unsigned long pin;
    void (*cb)(volatile void*);
    void *arg;
#endif
	void *arg;
};

```

### inv_mpu_dmp_motion_driver.c
```c
同上更换宏定义
#if defined STM32_MPU6050
//#if defined MOTION_DRIVER_TARGET_MSP430
同上更换所含头文件
#include "i2c.h"
//#include "msp430.h"
//#include "msp430_clock.h"
同上更换这两个函数接口
#define delay_ms(ms)    HAL_Delay(ms)
#define get_ms(p)       do{*p = HAL_GetTick();}while(0)
//#define delay_ms    msp430_delay_ms
//#define get_ms      msp430_get_clock_ms

这个函数下会报一个警告，提示没有函数__no_operation，将其修改为__NOP()
int dmp_set_accel_bias(long *bias)
__no_operation();将其修改为__NOP();
```


### mpu6050.c
参考\Embedded_MotionDriver_5.1\simple_apps\msp430\motion_driver_test.c，
过程较为复杂
```c
#include "inv_mpu.h"
#include "inv_mpu_dmp_motion_driver.h"
#include "mpu6050.h"
#include <math.h>

#define DEFAULT_MPU_HZ (100)
#define Q30 (1073741824.0f)

/* The sensors can be mounted onto the board in any orientation. The mounting
 * matrix seen below tells the MPL how to rotate the raw data from thei
 * driver(s).
 * TODO: The following matrices refer to the configuration on an internal test
 * board at Invensense. If needed, please modify the matrices to match the
 * chip-to-body matrix for your particular set up.
 */
static signed char gyro_orientation[9] = {-1, 0, 0, 0, -1, 0, 0, 0, 1};

/* These next two functions converts the orientation matrix (see
 * gyro_orientation) to a scalar representation for use by the DMP.
 * NOTE: These functions are borrowed from Invensense's MPL.
 */
static unsigned short inv_row_2_scale(const signed char* row)
{
    unsigned short b;

    if (row[0] > 0)
    {
        b = 0;
    }
    else if (row[0] < 0)
    {
        b = 4;
    }
    else if (row[1] > 0)
    {
        b = 1;
    }
    else if (row[1] < 0)
    {
        b = 5;
    }
    else if (row[2] > 0)
    {
        b = 2;
    }
    else if (row[2] < 0)
    {
        b = 6;
    }
    else
    {
        b = 7; // error
    }
    return b;
}

static unsigned short inv_orientation_matrix_to_scalar(const signed char* mtx)
{
    unsigned short scalar;

    /*
       XYZ  010_001_000 Identity Matrix
       XZY  001_010_000
       YXZ  010_000_001
       YZX  000_010_001
       ZXY  001_000_010
       ZYX  000_001_010
     */

    scalar = inv_row_2_scale(mtx);
    scalar |= inv_row_2_scale(mtx + 3) << 3;
    scalar |= inv_row_2_scale(mtx + 6) << 6;

    return scalar;
}

static int run_self_test(void)
{
    int result;
    long gyro[3], accel[3];

    result = mpu_run_self_test(gyro, accel);
    if (result == 0x3)
    {
        /* Test passed. We can trust the gyro data here, so let's push it down
         * to the DMP.
         */
        float sens;
        unsigned short accel_sens;
        mpu_get_gyro_sens(&sens);
        gyro[0] = (long)(gyro[0] * sens);
        gyro[1] = (long)(gyro[1] * sens);
        gyro[2] = (long)(gyro[2] * sens);
        dmp_set_gyro_bias(gyro);
        mpu_get_accel_sens(&accel_sens);
        accel[0] *= accel_sens;
        accel[1] *= accel_sens;
        accel[2] *= accel_sens;
        dmp_set_accel_bias(accel);
    }
    else
    {
        return -1;
    }
    return 0;
}

int MPU6050_DMP_Get_Data(float* pitch, float* roll, float* yaw)
{
    float q0 = 0.0f;
    float q1 = 0.0f;
    float q2 = 0.0f;
    float q3 = 0.0f;
    short gyro[3];
    short accel[3];
    long quat[4];
    unsigned long timestamp;
    short sensors;
    unsigned char more;
    if (dmp_read_fifo(gyro, accel, quat, &timestamp, &sensors, &more))
    {
        return -1;
    }
    if (sensors & INV_WXYZ_QUAT)
    {
        q0 = quat[0] / Q30;
        q1 = quat[1] / Q30;
        q2 = quat[2] / Q30;
        q3 = quat[3] / Q30;

        *pitch = asin(-2 * q1 * q3 + 2 * q0 * q2) * 57.3;
        *roll = atan2(2 * q2 * q3 + 2 * q0 * q1, -2 * q1 * q1 - 2 * q2 * q2 + 1) * 57.3;
        *yaw = atan2(2 * (q1 * q2 + q0 * q3), q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3) * 57.3;
    }
    else
    {
        return -2;
    }
    return 0;
}

int MPU6050_DMP_Init(void)
{
    int result;
    struct int_param_s int_param;
    result = mpu_init(&int_param);
    if (result != 0) // mpu初始化
    {
        return -1;
    }
    result = mpu_set_sensors(INV_XYZ_GYRO | INV_XYZ_ACCEL); // 设置传感器
    if (result != 0)
    {
        return -2;
    }
    result = mpu_configure_fifo(INV_XYZ_GYRO | INV_XYZ_ACCEL); // 设置fifo
    if (result != 0)
    {
        return -3;
    }
    result = mpu_set_sample_rate(DEFAULT_MPU_HZ); // 设置采样率
    if (result != 0)
    {
        return -4;
    }

    /* To initialize the DMP:
     * 1. Call dmp_load_motion_driver_firmware(). This pushes the DMP image in
     *    inv_mpu_dmp_motion_driver.h into the MPU memory.
     * 2. Push the gyro and accel orientation matrix to the DMP.
     * 3. Register gesture callbacks. Don't worry, these callbacks won't be
     *    executed unless the corresponding feature is enabled.
     * 4. Call dmp_enable_feature(mask) to enable different features.
     * 5. Call dmp_set_fifo_rate(freq) to select a DMP output rate.
     * 6. Call any feature-specific control functions.
     *
     * To enable the DMP, just call mpu_set_dmp_state(1). This function can
     * be called repeatedly to enable and disable the DMP at runtime.
     *
     * The following is a short summary of the features supported in the DMP
     * image provided in inv_mpu_dmp_motion_driver.c:
     * DMP_FEATURE_LP_QUAT: Generate a gyro-only quaternion on the DMP at
     * 200Hz. Integrating the gyro data at higher rates reduces numerical
     * errors (compared to integration on the MCU at a lower sampling rate).
     * DMP_FEATURE_6X_LP_QUAT: Generate a gyro/accel quaternion on the DMP at
     * 200Hz. Cannot be used in combination with DMP_FEATURE_LP_QUAT.
     * DMP_FEATURE_TAP: Detect taps along the X, Y, and Z axes.
     * DMP_FEATURE_ANDROID_ORIENT: Google's screen rotation algorithm. Triggers
     * an event at the four orientations where the screen should rotate.
     * DMP_FEATURE_GYRO_CAL: Calibrates the gyro data after eight seconds of
     * no motion.
     * DMP_FEATURE_SEND_RAW_ACCEL: Add raw accelerometer data to the FIFO.
     * DMP_FEATURE_SEND_RAW_GYRO: Add raw gyro data to the FIFO.
     * DMP_FEATURE_SEND_CAL_GYRO: Add calibrated gyro data to the FIFO. Cannot
     * be used in combination with DMP_FEATURE_SEND_RAW_GYRO.
     */
    // 以下为dmp初始化步骤，详细见上方解释
    result = dmp_load_motion_driver_firmware(); // 加载dmp固件
    if (result != 0)
    {
        return -5;
    }
    result = dmp_set_orientation(inv_orientation_matrix_to_scalar(gyro_orientation)); // 设置陀螺仪方向
    if (result != 0)
    {
        return -6;
    }

    result = dmp_enable_feature(DMP_FEATURE_6X_LP_QUAT | DMP_FEATURE_TAP | DMP_FEATURE_ANDROID_ORIENT
                                | DMP_FEATURE_ANDROID_ORIENT | DMP_FEATURE_SEND_RAW_ACCEL | DMP_FEATURE_SEND_CAL_GYRO
                                | DMP_FEATURE_GYRO_CAL); // 设置dmp功能
    if (result != 0)
    {
        return -7;
    }
    result = dmp_set_fifo_rate(DEFAULT_MPU_HZ); // 设置输出速率
    if (result != 0)
    {
        return -8;
    }
    result = run_self_test(); // 自检
    if (result != 0)
    {
        return -9;
    }
    result = mpu_set_dmp_state(1); // 使能dmp

    if (result != 0)
    {
        return -10;
    }
    return 0;
}

```

### mpu6050.h
```c
#ifndef __MPU6050_H
#define __MPU6050_H

/* 该函数可初始化mpu6050及dmp库 */
int MPU6050_DMP_Init(void);
int MPU6050_DMP_Get_Data(float* pitch, float* roll, float* yaw);

#endif

```
### main.c
```c
/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2026 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "i2c.h"
#include "usart.h"
#include "gpio.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include <stdio.h>
#include "mpu6050.h"

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

    /* USER CODE BEGIN 1 */
    int res;
    float pitch, roll, yaw;
    /* USER CODE END 1 */

    /* MCU Configuration--------------------------------------------------------*/

    /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
    HAL_Init();

    /* USER CODE BEGIN Init */

    /* USER CODE END Init */

    /* Configure the system clock */
    SystemClock_Config();

    /* USER CODE BEGIN SysInit */

    /* USER CODE END SysInit */

    /* Initialize all configured peripherals */
    MX_GPIO_Init();
    MX_I2C1_Init();
    MX_USART1_UART_Init();
    /* USER CODE BEGIN 2 */
    res = MPU6050_DMP_Init();
    if (res != 0)
    {
        printf("MPU6050 Init ERR! res = %d\n", res);
        while (res)
        {
            HAL_Delay(1000);
            res = MPU6050_DMP_Init();
            printf("MPU6050 Init ERR! res = %d\n", res);
        }
        printf("MPU6050 Init SUCCEED!\n");
    }
    else
    {
        printf("MPU6050 Init SUCCEED!\n");
    }

    /* USER CODE END 2 */

    /* Infinite loop */
    /* USER CODE BEGIN WHILE */
    while (1)
    {
        if (MPU6050_DMP_Get_Data(&pitch, &roll, &yaw))
        {
            printf("pitch = %f, roll = %f, yaw = %f \n", pitch, roll, yaw);
        }

        HAL_Delay(100);
        /* USER CODE END WHILE */

        /* USER CODE BEGIN 3 */
    }
    /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
    RCC_OscInitTypeDef RCC_OscInitStruct = {0};
    RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

    /** Initializes the RCC Oscillators according to the specified parameters
    * in the RCC_OscInitTypeDef structure.
    */
    RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
    RCC_OscInitStruct.HSEState = RCC_HSE_ON;
    RCC_OscInitStruct.HSEPredivValue = RCC_HSE_PREDIV_DIV1;
    RCC_OscInitStruct.HSIState = RCC_HSI_ON;
    RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
    RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
    RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL9;
    if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
    {
        Error_Handler();
    }

    /** Initializes the CPU, AHB and APB buses clocks
    */
    RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_SYSCLK
                                  | RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2;
    RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
    RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
    RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
    RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

    if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK)
    {
        Error_Handler();
    }
}

/* USER CODE BEGIN 4 */
int fputc(int ch, FILE *f)
{
    HAL_UART_Transmit(&huart1, (uint8_t *)&ch, 1, 1000);
    return ch;
}
/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
    /* USER CODE BEGIN Error_Handler_Debug */
    /* User can add his own implementation to report the HAL error return state */
    __disable_irq();
    while (1)
    {
    }
    /* USER CODE END Error_Handler_Debug */
}
#ifdef USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
    /* USER CODE BEGIN 6 */
    /* User can add his own implementation to report the file name and line number,
       ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
    /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */

```





