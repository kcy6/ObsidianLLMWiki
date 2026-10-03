---
title: "FreeRTOS源码探析之——任务调度相关"
source: "https://zhuanlan.zhihu.com/p/336687316"
author:
  - "[[码农爱学习​中国计量大学 控制理论与控制工程硕士]]"
published:
created: 2026-04-27
description:
tags:
  - "clippings"
---
[收录于 · FreeRTOS入门实践与源码解析](https://www.zhihu.com/column/c_1389353944091549697)

65 人赞同了该文章

[FreeRTOS](https://zhida.zhihu.com/search?content_id=162949656&content_type=Article&match_order=1&q=FreeRTOS&zhida_source=entity) 可以运行多任务，在于其内核的任务调度功能，本篇介绍任务调度的基本思路与部分源码分析。

## 1 裸机编程与RTOS 的区别

## 1.1 裸机程序基本框架

```c
/*主函数*/
int main()
{
    init();//一些初始化
    /*死循环*/
    while(1)
    {
        do_something_1();//执行一些逻辑
        do_something_2();
    }//循环执行
}

/*中断服务函数*/
IRQ_Handler()
{
    set_flag();//简短的标记操作
}
```

单片机裸机编程的思路比较简单，就是一个死循环，程序依次执行while(1)中的各条语句，循环往复即可，需要处理某些紧急事件时，通过中断服务函数来打断while(1)的执行。

裸机编程虽然简单，但只能在一个循环中执行各种裸机，第一项功能执行完后才能执行第二项功能， **就好比有多个人在轮流干活** ，CPU的利用率不高，不能处理并行逻辑。

## 1.2 RTOS程序基本框架

```c
/*主函数*/
int main()
{
    init();//一些初始化
    xTaskCreate();
    vTaskStartScheduler(); //启动调度器
}

/*子任务1（死循环）*/
void task1()
{
    while(1)
    {
        do_something_1();//执行一些逻辑(如采集传感器信息)
        vTaskDelay();
    }
}

/*子任务2（死循环）*/
void task2()
{
    while(1)
    {
        do_something_2();//执行一些逻辑(如执行电机运动)
        vTaskDelay();
    }
}

/*中断服务函数*/
IRQ_Handler()
{
    set_event();//触发事件、信号量等
}
```

单片机引入RTOS，可以将各个功能模块分别设计为单独的 **任务** ，每个任务都是一个死循环， **就好比有多个人在同时干活** ，这样CPU的利用率就提高了，并且可以处理一些并行逻辑。

单片机只有一个CPU（核），那怎么让多个人同时干活呢？其实每个子任务虽然都是死循环，但并不是每个子任务一直都在执行，每个子任务在执行期间，可能需要延时，也可能需要等另一个任务的数据到来，所有， **在某个任务在等待的时候，CPU就可以停止此任务，然后切换到其它任务执行，这样看起来就是多个人在同时干活了** 。

## 2 RTOS任务间通信

在裸机编程中，当设计了一个稍微复杂的功能是，会设计处许多子函数来实现一个整体功能，这之中通知会用到一些 **全局变量** 或 **全局数组** 等来实现各个子函数之间的联系。

在RTOS中，当然也可以使用全局变量，但RTOS更推荐我们使用系统自带的 **任务间通信机制** 。原因有二：

1. **阻塞等待机制比轮询等待更高效**

全局变量当用作某种事件标志时，获取该标志的任务需要轮询检测标志是否变化，这样会产生大量无效的判断，而使用任务间通信中的阻塞等待机制，CPU可以转而处理其它事情，当标志变化时，解除阻塞，又可以及时执行后续处理。

1. **全局变量会产生不可重入函数造成逻辑混乱**

RTOS运行时，CPU是在各个任务间跳来跳去的，若使用全局变量不恰当，会导致原本设计的逻辑产生混乱。比如某个 **低优先级** 任务正在访问某个公共函数，并对该函数中的全局变量进行了修改，还未退出该函数时， **更高优先级** 的任务抢占了CPU的使用权，并也对该函数中的全局变量进行了修改，此时，如果低优先级的任务若认为自己对变量修改成功，并因此而执行自己后续的逻辑，则会导致逻辑错误。

**FreeRTOS任务间通信方式**

- `信号量` (Semaphore)：用于任务间的 **同步** ，一个任务 **以阻塞方式等待** 另一个任务 **等待另一个** 任务释放信号量。
- `互斥量` (Mutex)：用于任务间共享资源的 **互斥访问** ，使用前获取锁，使用后释放锁。
- `事件标志组` （EventGroup)：也是用于任务间的 **同步** ，相比信号量，事件标志组可以 **等待多个** 事件发生。
- `消息队列` (Queue)：类比全局数据，它可以一次发送多个数据（一般将数据定义成结构体发送），每次数据的大小固定不变。
- `流缓冲区` (StreamBuffer)：在队列的基础上，优化的一种更适合的数据结构，可以一次写入任意数量的字节，并且可以一次读取任意数量的字节。
- `消息缓冲区` (MessageBuffer)：在流式缓冲区的基础上实现的，其进一步针对“消息”进行设计改进，每一条消息的写入增加了一个字节用来表示该条消息的长度，读取时需要一次性读出至少一条消息，否则会返回 0。
- `任务通知` (Notify)：不同于上面的任务间通信方式（使用某种 **通信对象** ，通信对象是独立于任务的实体，有单独的存储空间，可以实现数据传递和较复杂的同步、互斥功能）， **通知是发向一个指定的任务的，直接改变该任务TCB的某些变量** 。

## 3 RTOS任务调度

## 3.1 任务状态

![[20260427-144737_FreeRTOS源码探析之——任务调度相关_81dd843d4298.jpg]]

- 1 `创建任务→就绪态` （Ready）： **任务创建完成后** 进入就绪态，表明任务已准备就绪，随时可以运行，只等待调度器进行调度。
- 2 `就绪态→运行态` （Running）：发生 **任务切换时，就绪列表中最高优先级的任务被执行** ，从而进入运行态。
- 3 `运行态→就绪态` ：有更高优先级任务创建或者恢复后，会发生任务调度，此刻就绪列表中 **最高优先级任务变为运行态，那么原先运行的任务由运行态变为就绪态** ，依然在就绪列表中，等待最高优先级的任务运行完毕继续运行原来的任务。
- 4 `运行态→阻塞态` （Blocked）： **正在运行的任务发生阻塞（挂起、延时、读信号量等待）** 时，该任务会从就绪列表中删除，任务状态由运行态变成阻塞态，然后发生任务切换，运行就绪列表中当前最高优先级任务。
- 5 `阻塞态→就绪态` ： **阻塞的任务被恢复** 后（任务恢复、延时时间超时、读信号量超时或读到信号量等），此时被恢复的任务会被加入就绪列表，从而由阻塞态变成就绪态；如果此时被恢复任务的优先级高于正在运行任务的优先级，则会发生任务切换，将该任务将再次转换任务状态，由就绪态变成运行态。
- 6、7、8 `就绪态、阻塞态、运行态→挂起态` （Suspended）：任务可以通过 **调用vTaskSuspend()** API 函数都可以将处于任何状态的任务挂起，被挂起的任务得不到CPU的使用权，也不会参与调度，除非它从挂起态中解除。
- 9 `挂起态→就绪态` ：把 一 个 挂 起 状态 的 任 务 恢复的 唯 一 途 径 就 是 **调 用 vTaskResume() 或vTaskResumeFromISR()** API 函数，如果此时被恢复任务的优先级高于正在运行任务的优先级，则会发生任务切换，将该任务将再次转换任务状态，由就绪态变成运行态。

> 以上是任务运行的各种状态，看起来有点复杂，可以这样理解：  
> 为简单起见，先不考虑挂起态，在任一时刻，CPU只能处理某一个任务，则该任务就处于 **运行态** ，对于其它任 务，当是自己想要延时或等待时，则处于 **阻塞态** ，当自己想要执行但因为优先级低而不能执行时，则处于 **就绪态** 。  
> 然后，以上状态如何被改变呢？  
> 1.运行态的自己想进入阻塞态，则就绪态的任务即可运行。  
> 2.阻塞态的解除阻塞进入就绪，若该任务的优先级更高，则可抢占当前处于运行的任务，使自己运行，使对方就绪。

有没有发现，阻塞态的任务要想运行，必须先进入就绪态，再进入运行态。

## 3.2 调度器

FreeRTOS中提供的任务调度器是基于优先级的 **抢占式调度** ：在系统中除了中断处理函数、调度器上锁部分的代码和禁止中断的代码是不可抢占的之外，系统的其他部分都是可以抢占的。

调度器就是使用相关的调度算法来 **决定当前需要执行的任务** 。所有的调度器有一些共同的特性：

- 调度器可以区分 **就绪态** 任务和 **挂起态** 任务（由于延迟，信号量等待，事件组等待等原因而使得任务被挂起）。
- 调度器可以选择 **就绪态** 中的一个任务，然后激活它（通过执行这个任务）。 当前正在执行的任务是 **运行态** 的任务。

FreeRTOS 主要有两种调度方式

- 抢占式调度：每个任务都有不同的优先级，任务会一直运行直到被高优先级任务抢占或者遇到阻塞式的 API 函数，如 vTaskDelay。
- 时间片调度：每个任务都有相同的优先级，任务会运行固定的时间片个数或者遇到阻塞式的 API 函数，比如vTaskDelay，才会执行同优先级任务之间的任务切换。

### 3.2.1 抢占式调度示例

![[20260427-144737_FreeRTOS源码探析之——任务调度相关_ad52cbb3d208.jpg]]

- 创建 3 个任务 Task1，Task2 和 Task3，优先级依次为1、2、3，即Task3的优先级最高。
- 起初任务 Task1处于运行态（占用CPU），运行过程中由于 Task2 就绪，在抢占式调度器的作用下任务 Task2 抢占Task1 的执行。

所以： **Task2 由就绪态进入到运行态，Task1 由运行态进入到就绪态** 。

- 任务 Task2 在运行中，由于 Task3 又处于了就绪态，在抢占式调度器的作用下任务 Task3 又抢占 Task2的执行。

所以： **Task3 由就绪态进入到运行态，Task2 由运行态进入到就绪态** 。

- 任务 Task3 运行过程中调用了阻塞式 API 函数，比如 vTaskDelay，任务 Task3 被挂起，进入挂起态，在抢占式调度器的作用下查找到下一个要执行的最高优先级任务是 Task2，所以： **任务 Task2 由就绪态又回到了运行态** 。
- 任务 Task2 在运行中，由于 Task3 的阻塞时间结束， Task3 再次就绪，在抢占式调度器的作用下 **任务 Task3 再次抢占Task2 的执行。 Task3 进入到运行态，Task2 由运行态进入到就绪态** 。

### 3.2.2 时间片调度示例

![[20260427-144737_FreeRTOS源码探析之——任务调度相关_18be97965a11.jpg]]

- 创建 4 个同优先级任务 Task1，Task2，Task3 和 Task4。
- 每个任务分配的时间片大小是 5 个系统时钟节拍。
- 先运行任务 Task1，运行够 5 个系统时钟节拍后，通过时间片调度切换到任务 Task2。
- 任务 Task2 运行够 5 个系统时钟节拍后，通过时间片调度切换到任务 Task3。
- 任务 Task3 在运行期间调用了 **阻塞式 API 函数** ，调用函数时，虽然 5 个系统时钟节拍的时间片大小还没有用完，此时依然会通过时间片调度切换到下一个任务 Task4。
- 任务 Task4 运行够 5 个系统时钟节拍后，通过时间片调度切换到任务 Task1。

注：以上以5个Tick的时间片举例，而FreeRTOS的时间片只能是1个Tick。

## 4 RTOS与TSOS

## RTOS

英文为Real Time Operating System，即实时操作系统， **实时** 是指当外界事件或数据产生时，能够接收并以足够快的速度予以处理，其处理的结果又能在规定的时间之内来控制生产过程或对处理系统作出快速响应，并控制所有实时任务协调一致运行的操作系统。

RTOS一般用于相对低速的MCU，比如运动控制类、按键输入等动作要求实时处理的系统，一般要求ms级，甚至us级响应。

## TSOS

英文为Time Sharing Operating System，即分时操作系统， **分时** 是指将系统处理机时间和内存空间按照一定的时间间隔（也就是我们所说的 **时间片** ）轮流地切换给各线程的程序使用。

TSOS一般用于相对高速的CPU，如多用户的桌面系统、服务器等系统（Windows、Linux）。

## 主要区别

RTOS具有高优先级任务 **抢占** 功能，以及同优先级间的 **时间片** 轮转调度，因而可以对事件进行及时响应（即具有较好的实时性），而TSOS是固定的时间片轮转调度，当有事件发送时，也只能等当前时间片执行完后，才能执行下一个时间片，因此可能不能及时响应某些紧急事件。

## 5 FreeRTOS任务调度相关源码

## 5.1 任务控制块TCB\_t

FreeRTOS对各个任务进行调度，首先需要一种方式来访问和控制各个任务，任务控制块就可以实现这种功能，它本质是一个结构体，记录了任务的堆栈指针、任务当前状态、任务优先级等。

```c
typedef struct tskTaskControlBlock
{
    volatile StackType_t    *pxTopOfStack;  /*栈顶 */

    ListItem_t          xStateListItem;     /*标记任务状态的列表(Ready, Blocked, Suspended ) */
    ListItem_t          xEventListItem;     /*任务的事件列表 */
    UBaseType_t         uxPriority;         /*任务优先级 */
    StackType_t         *pxStack;           /*任务栈起始地址 */
    char                pcTaskName[ configMAX_TASK_NAME_LEN ]; /*创建时给任务的描述性名称，便于调试 */

    #if(...省略部分)
    ...省略部分
    #endif

} tskTCB;
typedef tskTCB TCB_t;
```

## 5.2 阻塞延时vTaskDelay

当某个任务需要延时，调用vTaskDelay()，则该任务进入 **阻塞态** ，此时调度器会从就绪列表中找到优先级最高的就绪任务开始执行。

那vTaskDelay()里面具体执行了哪些内容你呢？

```c
#if ( INCLUDE_vTaskDelay == 1 )
    void vTaskDelay( const TickType_t xTicksToDelay )
    {
    BaseType_t xAlreadyYielded = pdFALSE;

        /*delay时间为0则强制进行任务切换 */
        if( xTicksToDelay > ( TickType_t ) 0U )
        {
            configASSERT( uxSchedulerSuspended == 0 );
            /*停止任务调度*/
            vTaskSuspenvdAll();
            {
                traceTASK_DELAY();

                /* 在调度器被挂起时从事件列表中删除的任务，在恢复调度器之前，不会被放置在就绪列表中或从阻塞列表中删除
                此任务不能出现在事件列表中，因为它是当前正在执行的任务。*/
                prvAddCurrentTaskToDelayedList( xTicksToDelay, pdFALSE );
            }
            xAlreadyYielded = xTaskResumeAll();
        }
        else
        {
            mtCOVERAGE_TEST_MARKER();
        }

        /* 如果xTaskResumeAll没有进行任务切换，则强制进行任务切换 */
        if( xAlreadyYielded == pdFALSE )
        {
            portYIELD_WITHIN_API();
        }
        else
        {
            mtCOVERAGE_TEST_MARKER();
        }
    }
#endif /* INCLUDE_vTaskDelay */
```

vTaskDelay的延时参数是以tick为单位的，即vTaskDelay(1)延时1ms。

- 当延时参数不为0时，即正常调用延时函数时，先停止任务调度，将当前任务添加至延时列表中，再恢复任务调度。
- 当延时参数为0时，会强制进行任务切换（portYIELD\_WITHIN\_API）（疑问：如果当前任务的优先级是最高的，虽然强制切换，但由于该任务的优先级最高，所起其实没有切换到其它任务？如果真的是强制切换到另一个任务，那上面时候这个最高优先级的任务再抢会CPU的使用权呢？）。

### 5.2.1添加任务到延时列表

```c
static void prvAddCurrentTaskToDelayedList( TickType_t xTicksToWait, const BaseType_t xCanBlockIndefinitely )
{
TickType_t xTimeToWake;
const TickType_t xConstTickCount = xTickCount;

    #if( INCLUDE_xTaskAbortDelay == 1 )
    //...省略部分
    #endif

    /* 在将任务添加到阻塞列表前先将其从就绪列表中移除*/
    if( uxListRemove( &( pxCurrentTCB->xStateListItem ) ) == ( UBaseType_t ) 0 )
    {
        /* 当前任务必定在就绪列表中, 所以无需检测, 并且port reset macro 可以被立即调用 */
        portRESET_READY_PRIORITY( pxCurrentTCB->uxPriority, uxTopReadyPriority );
    }
    else
    {
        mtCOVERAGE_TEST_MARKER();
    }

    #if ( INCLUDE_vTaskSuspend == 1 )
    {
        if( ( xTicksToWait == portMAX_DELAY ) && ( xCanBlockIndefinitely != pdFALSE ) )
        {
            /* 为确保不是被定时器事件唤醒，添加任务到挂起列表而不是延时列表. 它将会无定期的阻塞*/
            vListInsertEnd( &xSuspendedTaskList, &( pxCurrentTCB->xStateListItem ) );
        }
        else
        {
            /* 如果事件没有发生，计算任务应该被唤醒的时间。这可能会溢出，但这无关紧要，内核会正确地管理它*/
            xTimeToWake = xConstTickCount + xTicksToWait;

            /* 列表项将按唤醒顺序插入 */
            listSET_LIST_ITEM_VALUE( &( pxCurrentTCB->xStateListItem ), xTimeToWake );

            if( xTimeToWake < xConstTickCount )
            {
                /* 唤醒时间已溢出，将该项放入溢出列表 */
                vListInsert( pxOverflowDelayedTaskList, &( pxCurrentTCB->xStateListItem ) );
            }
            else
            {
                /* 唤醒时间未溢出，所以当前的阻塞列表被使用. */
                vListInsert( pxDelayedTaskList, &( pxCurrentTCB->xStateListItem ) );

                /* 如果进入阻塞状态的任务被放置在阻塞任务列表的顶部，那么xNextTaskUnblockTime也需要更新 */
                if( xTimeToWake < xNextTaskUnblockTime )
                {
                    xNextTaskUnblockTime = xTimeToWake;
                }
                else
                {
                    mtCOVERAGE_TEST_MARKER();
                }
            }
        }
    }
    #else /* INCLUDE_vTaskSuspend */
    //...省略部分
    #endif /* INCLUDE_vTaskSuspend */
}
```

### 5.2.2 任务切换

```c
#define portNVIC_PENDSVSET_BIT      ( 1UL << 28UL ) //PendSV的悬起位（第28位）

#ifndef portYIELD_WITHIN_API
    #define portYIELD_WITHIN_API portYIELD
#endif

/* Scheduler utilities. */
#define portYIELD()                                                             \
{                                                                               \
    /* Set a PendSV to request a context switch. */                             \
    portNVIC_INT_CTRL_REG = portNVIC_PENDSVSET_BIT;                             \
                                                                                \
    /* 触发PendSV，产生上下文切换 */                      \
    __dsb( portSY_FULL_READ_WRITE );                                            \
    __isb( portSY_FULL_READ_WRITE );                                            \
}
```

portYIELD()任务切换函数，主要就是将PendSV的悬起位置1，在没有其它中断运行时执行PendSV中断服务函数，在这个中断函数中实现任务切换。

### 5.2.3 PendSV中断服务函数

PendSV中断服务函数是一段汇编代码，可能不太容易看懂，该函数需要先了解如下：

外部变量pxCurrentTCB是当前正在运行的任务的任务控制块

当进入PendSV中断服务函数时，上一任务的运行环境为：xPSR，PC(任务入口地址)，R14，R12，R3,R2,R1,R0（任务的形参），这些CPU寄存器的值会自动保存到任务的栈中，剩下的R4~R11需要手动保存。

![[20260427-144737_FreeRTOS源码探析之——任务调度相关_abf6b2c6defc.jpg]]

总的来说，该函数实现3部分功能：上文保存，下文切换，中间调用了一个C函数vTaskSwitchContext，用于寻找要运行的任务。

```c
__asm void xPortPendSVHandler( void )
{
    extern uxCriticalNesting;
    extern pxCurrentTCB;
    extern vTaskSwitchContext;

    PRESERVE8

    mrs r0, psp       /* 保存当前任务PSP地址到R0中 */
    isb

    ldr r3, =pxCurrentTCB  /* 获取pxCurrentTCBConst指针地址 */
    ldr r2, [r3]           /* R2被赋予当前TCB地址 */

    /* Is the task using the FPU context?  If so, push high vfp registers. */
    tst r14, #0x10
    it eq
    vstmdbeq r0!, {s16-s31}

    /* Save the core registers. */
    stmdb r0!, {r4-r11, r14}

    /* Save the new top of stack into the first member of the TCB. */
    str r0, [r2]

    stmdb sp!, {r3}
    mov r0, #configMAX_SYSCALL_INTERRUPT_PRIORITY
    msr basepri, r0  /*屏蔽中断*/
    dsb
    isb
    bl vTaskSwitchContext  /*调用vTaskSwitchContext*/
    mov r0, #0
    msr basepri, r0  /*打开中断*/
    ldmia sp!, {r3}

    /* The first item in pxCurrentTCB is the task top of stack. */
    ldr r1, [r3] /* R3依然是pxCurrentTCBConst指针地址，R1变为新TCB地址 */
    ldr r0, [r1] /* R0值成为新TCB的栈地址（该TCB发生上一次调度的PSP值） */

    /* Pop the core registers. */
    ldmia r0!, {r4-r11, r14}

    /* Is the task using the FPU context?  If so, pop the high vfp registers
    too. */
    tst r14, #0x10
    it eq
    vldmiaeq r0!, {s16-s31}

    msr psp, r0
    isb
    #ifdef WORKAROUND_PMU_CM001 /* XMC4000 specific errata */
        #if WORKAROUND_PMU_CM001 == 1
            push { r14 }
            pop { pc }
            nop
        #endif
    #endif

    bx r14
}
```

### 5.2.4 寻找要运行的任务

该函数实际是选择一个最高优先级的任务运行

```c
void vTaskSwitchContext( void )
{
    if( uxSchedulerSuspended != ( UBaseType_t ) pdFALSE )
    {
        /* The scheduler is currently suspended - do not allow a context
        switch. */
        xYieldPending = pdTRUE;
    }
    else
    {
        xYieldPending = pdFALSE;
        traceTASK_SWITCHED_OUT();

        #if ( configGENERATE_RUN_TIME_STATS == 1 )
        //...省略部分
        #endif /* configGENERATE_RUN_TIME_STATS */

        /* 检查堆栈是否溢出 */
        taskCHECK_FOR_STACK_OVERFLOW();

        /* 选择一个最高优先级的任务运行*/
        taskSELECT_HIGHEST_PRIORITY_TASK();
        traceTASK_SWITCHED_IN();

        #if ( configUSE_NEWLIB_REENTRANT == 1 )
        //...省略部分
        #endif /* configUSE_NEWLIB_REENTRANT */
    }
}
```

选择一个最高优先级的任务的函数实现如下：

获取任务的本质是获取任务的控制块(TCB)

```c
define taskSELECT_HIGHEST_PRIORITY_TASK()                                                       \
    {                                                                                               \
    UBaseType_t uxTopPriority;                                                                      \
                                                                                                    \
        /* 寻找就绪任务的最高休闲级 */                                                                  \
        portGET_HIGHEST_PRIORITY( uxTopPriority, uxTopReadyPriority );                              \
        configASSERT( listCURRENT_LIST_LENGTH( &( pxReadyTasksLists[ uxTopPriority ] ) ) > 0 );     \
        /*获取优先级最高的就绪任务的TCB,更新到pxCurrentTCB*/                                             \
        listGET_OWNER_OF_NEXT_ENTRY( pxCurrentTCB, &( pxReadyTasksLists[ uxTopPriority ] ) );       \ 
    } /* taskSELECT_HIGHEST_PRIORITY_TASK() */
```

获取优先级最高的就绪任务的TCB的函数实现如下：

```c
#define listGET_OWNER_OF_NEXT_ENTRY( pxTCB, pxList )                                        \
{                                                                                           \
List_t * const pxConstList = ( pxList );                                                    \
    /* Increment the index to the next item and return the item, ensuring */                \
    /* we don't return the marker used at the end of the list.  */                          \
    ( pxConstList )->pxIndex = ( pxConstList )->pxIndex->pxNext;                            \
    if( ( void * ) ( pxConstList )->pxIndex == ( void * ) &( ( pxConstList )->xListEnd ) )  \
    {                                                                                       \
        ( pxConstList )->pxIndex = ( pxConstList )->pxIndex->pxNext;                        \
    }                                                                                       \
    ( pxTCB ) = ( pxConstList )->pxIndex->pvOwner;                                          \
}
```

## 5.3 停止/恢复任务调度

### 5.3.1 vTaskSuspenvdAll()

挂起调度程序可以防止发生上下文切换，但可以使能中断。如果在挂起调度程序时中断请求上下文切换，则该请求将保持挂起状态，并且仅在重新启动调度程序（未挂起）时才执行该请求。

该函数就是将调度器锁定，每调用一次该函数，会对变量uxSchedulerSuspended进行自加，用于嵌套调用时记录嵌套的深度。

```c
PRIVILEGED_DATA static volatile UBaseType_t uxSchedulerSuspended    = ( UBaseType_t ) pdFALSE;

void vTaskSuspendAll( void )
{
    ++uxSchedulerSuspended;
}
```

### 5.3.2xTaskResumeAll()

每调用一次vTaskSuspendAll()函数就会将uxSchedulerSuspended变量加一，那么调用对应的xTaskResumeAll()肯定就是将变量减一

如果恢复调度程序导致上下文切换，则返回pdTRUE，否则返回pdFALSE

```c
BaseType_t xTaskResumeAll( void )
{
TCB_t *pxTCB = NULL;
BaseType_t xAlreadyYielded = pdFALSE;

    /* 如果uxSchedulerSuspended为0，则此函数与先前对vTaskSuspendAll（）的调用不匹配 */
    configASSERT( uxSchedulerSuspended );

    /* 当调度器被挂起时，ISR可能导致任务从事件列表中删除。如果是这种情况，
    那么删除的任务将被添加到xPendingReadyList中。一旦调度程序被恢复，
    就可以安全地将所有挂起的就绪任务从这个列表移动到它们相应的就绪列表中 */
    taskENTER_CRITICAL();
    {
        --uxSchedulerSuspended;

        if( uxSchedulerSuspended == ( UBaseType_t ) pdFALSE )
        {
            if( uxCurrentNumberOfTasks > ( UBaseType_t ) 0U )
            {
                /* 将任何准备好的任务从待处理就绪列表移动到相应的就绪列表中 */
                while( listLIST_IS_EMPTY( &xPendingReadyList ) == pdFALSE )
                {
                    pxTCB = ( TCB_t * ) listGET_OWNER_OF_HEAD_ENTRY( ( &xPendingReadyList ) );
                    ( void ) uxListRemove( &( pxTCB->xEventListItem ) );
                    ( void ) uxListRemove( &( pxTCB->xStateListItem ) );
                    prvAddTaskToReadyList( pxTCB );

                    /* 如果移动的任务的优先级高于当前任务，需要进行一次任务的切换 */
                    if( pxTCB->uxPriority >= pxCurrentTCB->uxPriority )
                    {
                        xYieldPending = pdTRUE;
                    }
                    else
                    {
                        mtCOVERAGE_TEST_MARKER();
                    }
                }

                if( pxTCB != NULL )
                {
                    /*当调度程序被挂起时，一个任务被解除阻塞，这可能阻止了重新计算下一个解除阻塞时间，
                    在这种情况下，现在重新计算它。这对于低功耗无tickless实现非常重要，
                    它可以防止从低功耗状态进行不必要的退出*/
                    prvResetNextTaskUnblockTime();
                }

                /* 如果在调度器被挂起时发生任何滴答，那么现在应该处理它们。
                这可以确保滴答计数不会滑动，并且任何延迟的任务都能在正确的时间恢复 */
                {
                    UBaseType_t uxPendedCounts = uxPendedTicks; /* Non-volatile copy. */

                    if( uxPendedCounts > ( UBaseType_t ) 0U )
                    {
                        do
                        {
                            /*查找是否有待进行切换的任务，如果有则应该进行任务切换*/
                            if( xTaskIncrementTick() != pdFALSE )
                            {
                                xYieldPending = pdTRUE;
                            }
                            else
                            {
                                mtCOVERAGE_TEST_MARKER();
                            }
                            --uxPendedCounts;
                        } while( uxPendedCounts > ( UBaseType_t ) 0U );

                        uxPendedTicks = 0;
                    }
                    else
                    {
                        mtCOVERAGE_TEST_MARKER();
                    }
                }

                if( xYieldPending != pdFALSE )
                {
                    #if( configUSE_PREEMPTION != 0 )
                    {
                        xAlreadyYielded = pdTRUE;
                    }
                    #endif
                    /*如果需要任务切换，则调用taskYIELD_IF_USING_PREEMPTION()函数发起一次任务切换*/
                    taskYIELD_IF_USING_PREEMPTION();
                }
                else
                {
                    mtCOVERAGE_TEST_MARKER();
                }
            }
        }
        else
        {
            mtCOVERAGE_TEST_MARKER();
        }
    }
    taskEXIT_CRITICAL();

    return xAlreadyYielded;
}
```

编辑于 2021-01-12 00:16[单片机](https://www.zhihu.com/topic/19577755)[实时操作系统](https://www.zhihu.com/topic/19702781)[编程](https://www.zhihu.com/topic/19554298)