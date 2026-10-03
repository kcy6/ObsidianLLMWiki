



### 时钟树


**BUSCLK**：由内部高频振荡器提供的CPU时钟，通常芯片出厂时设置为了32MHz。
**MFCLK**：只能使用固定的4MHz时钟(参考用户手册132页)。开启的话需要配置时钟树的SYSOSC_4M分支，才能够正常开启。
**LFCLK**：由内部的低频振荡器提供时钟（32KHz）。在运行、睡眠、停止和待机模式下有效，使用该时钟可以实现更低的功耗。

### 模块化代码
##### printf重定向
/*在使用浮点型参数时，可能会导致代码卡死，或者无法执行符点型的运算。这个时候需要配置工程的优化等级，将默认的O2级优化降为O0，即不优化即可。*/
参考以下几种方案
```c
int fputc(int c, FILE* stream)
{
	DL_UART_Main_transmitDataBlocking(UART_0_INST, c);
    return c;
}

int fputs(const char* restrict s, FILE* restrict stream)
{
    uint16_t i, len;
    len = strlen(s);
    for(i=0; i<len; i++)
    {
        DL_UART_Main_transmitDataBlocking(UART_0_INST, s[i]);
    }
    return len;
}
int puts(const char *_ptr)
{
	int count = fputs(_ptr, stdout);
	count += fputs("\n", stdout);
	return count;
}
```

```c
//重定向fputc函数
int fputc(int ch, FILE *stream)
{
    while( DL_UART_isBusy(UART_0_INST) == true );
	DL_UART_Main_transmitData(UART_0_INST, ch);
    return ch;
}
//重定向fputs函数
int fputs(const char* restrict s, FILE* restrict stream) 
{
    uint16_t char_len=0;
    while(*s!=0)
    {
        while( DL_UART_isBusy(UART_0_INST) == true );
        DL_UART_Main_transmitData(UART_0_INST, *s++);
        char_len++;
    }
    return char_len;
}

int puts(const char* _ptr)
{
	return 0;
}
```

```c
1.startup_mspm0g350x_uvision.s
修改Heap_Size    EQU    0x00000100
2.开启使用Keil中的微库Use Micro
3.//printf函数重定义
int fputc(int ch, FILE *stream)
{
    //当串口0忙的时候等待，不忙的时候再发送传进来的字符
    while (DL_UART_isBusy(UART_0_INST) == true);

    DL_UART_Main_transmitData(UART_0_INST, ch);
    return ch;
}
```

```c
#if !defined(__MICROLIB)
//不使用微库的话就需要添加下面的函数
#if (__ARMCLIB_VERSION <= 6000000)
//如果编译器是AC5  就定义下面这个结构体
struct __FILE
{
    int handle;
};
#endif

FILE __stdout;

//定义_sys_exit()以避免使用半主机模式
void _sys_exit(int x)
{
    x = x;
}
#endif
//printf函数重定义
int fputc(int ch, FILE *stream)
{
    //当串口0忙的时候等待，不忙的时候再发送传进来的字符
    while (DL_UART_isBusy(UART_0_INST) == true);
    DL_UART_Main_transmitData(UART_0_INST, ch);
    return ch;
}
```

##### systick计时
```c
volatile unsigned int delay_times = 0;

//搭配滴答定时器实现的精确ms延时
void delay_ms(unsigned int ms) 
{
        delay_times = ms;
        while( delay_times != 0 );
}   

void SysTick_Handler(void)
{
        if( delay_times != 0 )
        {
                delay_times--;
        }
}
```

##### UART接收发送
```C
volatile unsigned int delay_times = 0;
volatile unsigned char uart_data = 0;

void delay_ms(unsigned int ms);
void uart0_send_char(char ch);
void uart0_send_string(char* str);

int main(void)
{
    SYSCFG_DL_init();
    //清除串口中断标志
    NVIC_ClearPendingIRQ(UART_0_INST_INT_IRQN);
    //使能串口中断
    NVIC_EnableIRQ(UART_0_INST_INT_IRQN);
    
    while (1) 
    {                        
        //LED引脚输出高电平
        DL_GPIO_setPins(LED1_PORT, LED1_PIN_14_PIN);
        delay_ms(500);
        //LED引脚输出低电平
        DL_GPIO_clearPins(LED1_PORT, LED1_PIN_14_PIN);
        delay_ms(500);
    }
}

//搭配滴答定时器实现的精确ms延时
void delay_ms(unsigned int ms) 
{
    delay_times = ms;
    while( delay_times != 0 );
}        
//串口发送单个字符
void uart0_send_char(char ch)
{
    //当串口0忙的时候等待，不忙的时候再发送传进来的字符
    while( DL_UART_isBusy(UART_0_INST) == true );
    //发送单个字符
    DL_UART_Main_transmitData(UART_0_INST, ch);
}
//串口发送字符串
void uart0_send_string(char* str)
{
    //当前字符串地址不在结尾 并且 字符串首地址不为空
    while(*str!=0&&str!=0)
    {
        //发送字符串首地址中的字符，并且在发送完成之后首地址自增
        uart0_send_char(*str++);
    }
}

//滴答定时器的中断服务函数
void SysTick_Handler(void)
{
    if( delay_times != 0 )
    {
        delay_times--;
    }
}

//串口的中断服务函数
void UART_0_INST_IRQHandler(void)
{
    //如果产生了串口中断
    switch( DL_UART_getPendingInterrupt(UART_0_INST) )
    {
        case DL_UART_IIDX_RX://如果是接收中断
            //接发送过来的数据保存在变量中
            uart_data = DL_UART_Main_receiveData(UART_0_INST);
            //将保存的数据再发送出去
            uart0_send_char(uart_data);
            break;
        
        default://其他的串口中断
            break;
    }
}

```
**移植代码**
```c
void uart0_send_string(char* str)
{
    // 当前字符串地址不在结尾 并且 字符串首地址不为空
    while (*str != 0 && str != 0)
    {
        // 当串口0忙的时候等待，不忙的时候再发送传进来的字符
        while (DL_UART_isBusy(UART_0_INST) == true);
        // 发送字符串首地址中的字符，并且在发送完成之后首地址自增
        DL_UART_Main_transmitData(UART_0_INST, *str++);
    }
}
```

##### 定时器
```C
int main(void)
{
    SYSCFG_DL_init();
    //清除定时器中断标志
    NVIC_ClearPendingIRQ(TIMER_0_INST_INT_IRQN);
    //使能定时器中断
    NVIC_EnableIRQ(TIMER_0_INST_INT_IRQN);
    
    while (1) 
    {                        

    }
}

//定时器的中断服务函数 已配置为1秒的周期
void TIMER_0_INST_IRQHandler(void)
{
    //如果产生了定时器中断
    switch( DL_TimerG_getPendingInterrupt(TIMER_0_INST) )
    {
        case DL_TIMER_IIDX_ZERO://如果是0溢出中断
            //将LED灯的状态翻转
            DL_GPIO_togglePins(LED1_PORT, LED1_PIN_14_PIN);
            break;
        
        default://其他的定时器中断
            break;
    }
}
```

##### PWM
```C
int main(void)
{
    int i = 0;
    
    SYSCFG_DL_init();

    while (1) 
    {                        
            
        // 呼吸灯渐亮过程
        for (i = 0; i <= 999; i++) 
        {
            // 设置 LED 亮度
            DL_TimerG_setCaptureCompareValue(PWM_LED_INST,i,GPIO_PWM_LED_C0_IDX);  
            delay_ms(1);  // 延迟以控制亮度变化速度
        }
        // 呼吸灯渐暗过程
        for (i = 999; i > 0; i--) 
        {
            // 设置 LED 亮度
            DL_TimerG_setCaptureCompareValue(PWM_LED_INST,i,GPIO_PWM_LED_C0_IDX);  
            delay_ms(1);  // 延迟以控制亮度变化速度
        }
    }
}

//滴答定时器的中断服务函数
void SysTick_Handler(void)
{
    if( delay_times != 0 )
    {
        delay_times--;
    }
}
```

##### ADC采集

```c
volatile unsigned int delay_times = 0;
volatile bool gCheckADC;        //ADC采集成功标志位

void delay_ms(unsigned int ms); //搭配滴答定时器的精准毫秒级延时
unsigned int adc_getValue(void);//读取ADC的数据


int main(void)
{
    unsigned int adc_value = 0;
    unsigned int voltage_value = 0;

    SYSCFG_DL_init();

    //清除串口中断标志
    NVIC_ClearPendingIRQ(UART_0_INST_INT_IRQN);
    //开启串口中断
    NVIC_EnableIRQ(UART_0_INST_INT_IRQN);
    //开启ADC中断
    NVIC_EnableIRQ(ADC_VOLTAGE_INST_INT_IRQN);

    printf("adc Demo start\r\n");
    while (1)
    {
        //获取ADC数据
        adc_value = adc_getValue();
        printf("adc value:%d\r\n", adc_value);

        //将ADC采集的数据换算为电压
        voltage_value = (int)((adc_value / 4095.0 * 3.3) * 100);

        printf("voltage value:%d.%d%d\r\n",
               voltage_value / 100,
               voltage_value / 10 % 10,
               voltage_value % 10);

        delay_ms(1000);
    }
}
//延时函数
void delay_ms(unsigned int ms)
{
    delay_times = ms;
    while (delay_times != 0);
}

//读取ADC的数据
unsigned int adc_getValue(void)
{
    unsigned int gAdcResult = 0;

    //软件触发ADC开始转换
    DL_ADC12_startConversion(ADC_VOLTAGE_INST);
    //如果当前状态为正在转换中则等待转换结束
    while (false == gCheckADC)
    {
        __WFE();
    }
    //获取数据
    gAdcResult = DL_ADC12_getMemResult(ADC_VOLTAGE_INST, ADC_VOLTAGE_ADCMEM_ADC_CH0);

    //清除标志位
    gCheckADC = false;

    return gAdcResult;
}

//滴答定时器的中断服务函数
void SysTick_Handler(void)
{
    if (delay_times != 0)
    {
        delay_times--;
    }
}
//ADC中断服务函数
void ADC_VOLTAGE_INST_IRQHandler(void)
{
    //查询并清除ADC中断
    switch (DL_ADC12_getPendingInterrupt(ADC_VOLTAGE_INST))
    {
        //检查是否完成数据采集
        case DL_ADC12_IIDX_MEM0_RESULT_LOADED:
            gCheckADC = true;//将标志位置1
            break;
        default:
            break;
    }
}

```

##### DMA
```C
volatile unsigned int delay_times = 0;
volatile bool gCheckADC;        //ADC采集成功标志位
volatile uint16_t ADC_VALUE[20];

void delay_ms(unsigned int ms); //搭配滴答定时器的精准毫秒级延时
unsigned int adc_getValue(unsigned int number);//读取ADC的数据

int main(void)
{
    unsigned int adc_value = 0;
    unsigned int voltage_value = 0;
    int i = 0;

    SYSCFG_DL_init();

    //清除串口中断标志
    NVIC_ClearPendingIRQ(UART_0_INST_INT_IRQN);
    //开启串口中断
    NVIC_EnableIRQ(UART_0_INST_INT_IRQN);

    //设置DMA搬运的起始地址
    DL_DMA_setSrcAddr(DMA, DMA_CH0_CHAN_ID, (uint32_t) &ADC0->ULLMEM.MEMRES[0]);
    //设置DMA搬运的目的地址
    DL_DMA_setDestAddr(DMA, DMA_CH0_CHAN_ID, (uint32_t) &ADC_VALUE[0]);
    //开启DMA
    DL_DMA_enableChannel(DMA, DMA_CH0_CHAN_ID);
    //开启ADC转换
    DL_ADC12_startConversion(ADC_VOLTAGE_INST);

    printf("adc_dma Demo start\r\n");

    while (1)
    {
        //获取ADC数据
        adc_value = adc_getValue(10);
        printf("adc value:%d\r\n", adc_value);

        //将ADC采集的数据换算为电压
        voltage_value = (int)((adc_value / 4095.0 * 3.3) * 100);

        printf("voltage value:%d.%d%d\r\n",
               voltage_value / 100,
               voltage_value / 10 % 10,
               voltage_value % 10);

        delay_ms(1000);
    }
}
//延时函数
void delay_ms(unsigned int ms)
{
    delay_times = ms;
    while (delay_times != 0);
}

//读取ADC的数据
unsigned int adc_getValue(unsigned int number)
{
    unsigned int gAdcResult = 0;
    unsigned char i = 0;

    //采集多次累加
    for (i = 0; i < number; i++)
    {
        gAdcResult += ADC_VALUE[i];
    }
    //均值滤波
    gAdcResult /= number;

    return gAdcResult;
}

//滴答定时器的中断服务函数
void SysTick_Handler(void)
{
    if (delay_times != 0)
    {
        delay_times--;
    }
}
```





