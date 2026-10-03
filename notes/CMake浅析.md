
## CMakeLists.txt配置思路

1.创建基础工程

```
cmake_minimum_required(VERSION 3.16)
project(MySTM32Project C)

set(CMAKE_C_STANDARD 11)
```

2.定义工程目标

```
add_executable(${PROJECT_NAME}.)
		Core/Src/main.c
)
```

3.添加多个头文件目录

```
target_include_directories(${PROJECT_NAME} PRIVATE
	${CMAKE_CURRENT_SOURCE_DIR}/Core/Inc
    ${CMAKE_CURRENT_SOURCE_DIR}/User
    ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/BSP
    ${CMAKE_CURRENT_SOURCE_DIR}/Utils
)
```

4.让CMake递归包含子模块源文件

```
file(GLOB_RECURSE USER_SOURCES
	${CMAEK_CURRENT_SOURCE_DIR}/User/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/Drivers/BSP/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/Utils/*.c
    
    target_sources(${PROJECT_NAME}.elf PRIVATE ${USER_SOURCES})
)
```

==常用这种管理方式==

5.用add_subdirectory管理更复杂结构，如果每个文件夹都有自己的CMakeLists.txt文件

```
顶层添加
add_subdirectory(User)
add_subdirectory(Drivers/BSP)
add_subdirectory(Utils)

子目录

file(GLOB_RECURSE USER_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/Src/*.c
)

target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/Inc
)

target_sources(${PROJECT_NAME} PRIVATE ${USER_SOURCES})

```

移植事项:
```
更改.ioc文件重新生成代码,更改.code-workspace文件并打开进入全局替换
替换.eide文件夹中的三个文件内的所有原工程文件名为更改后的文件名
	删除ARM-MDK文件夹中的原.uvprojx和.uvoptx文件
	删除build中的原编译文件夹
```

