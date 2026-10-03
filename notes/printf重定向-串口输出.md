





添加MicroLIB库，重定向fputc，借用串口1输出printf的数据
```c
int fputc(int ch, FILE* f)
{
    HAL_UART_Transmit(&huart1, (uint8_t*)&ch, 1, 1000);
    return ch;
}
```