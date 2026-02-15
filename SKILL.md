---
name: uniproton-app-dev
description: "帮助用户在 Docker 环境中开发、编译和运行 UniProton RISC-V 应用程序。包括环境配置、编译步骤、运行验证等完整流程。当用户需要开发 UniProton 应用程序、配置开发环境、编译或运行 UniProton 应用时使用此技能。"
---

# UniProton RISC-V 应用开发技能

## 何时使用此技能

使用此技能帮助用户开发 UniProton RISC-V 应用程序，包括：
1. 配置 UniProton 开发环境
2. 编译 UniProton 应用程序
3. 运行和调试 UniProton 应用
4. 解决开发过程中的常见问题

## 环境配置

### Docker 环境配置要求

#### Docker 镜像
- 必须使用指定的 Docker 镜像: `swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/uniproton-ci-test:v003`
- 该镜像预装了所需的编译链工具和其他依赖项

#### 目录挂载
- 启动 Docker 容器时必须挂载宿主机文件夹: `-v $(pwd)/UniProton:/home/jenkins/UniProton`
- 注意：挂载路径应为 UniProton 目录而非整个项目根目录
- 这样可以将宿主机的源码映射到容器内部供编译使用

#### 权限设置
- 推荐使用 root 用户运行容器以避免权限问题:
  - `docker run -itd -u root -v $(pwd)/UniProton:/home/jenkins/UniProton ...`
- 或者设置适当的用户映射，确保容器内的用户能访问宿主机目录
- 当使用 root 用户运行容器时，无需额外设置宿主机文件权限

#### 编译配置
- 确保环境变量 `RISCV_NATIVE` 为空或未设置
- 因为这是交叉编译过程，不需要启用原生 RISC-V 编译选项

## 操作流程

### 1. 启动 Docker 环境
- 启动 Docker 容器: `docker run -itd -u root -v $(pwd)/UniProton:/home/jenkins/UniProton swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/uniproton-ci-test:v003`
  - `-itd`: 以交互模式后台运行容器
  - `-u root`: 以 root 用户身份运行容器，避免权限问题
  - `-v $(pwd)/UniProton:/home/jenkins/UniProton`: 将当前宿主机的UniProton目录挂载到容器内的 /home/jenkins/UniProton 路径
  - `swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/uniproton-ci-test:v003`: 指定的Docker镜像
  - `/bin/bash`: 启动 bash shell
- 进入正在运行的容器: `docker exec -u root -it <container_id> /bin/bash`
  - `<container_id>`: 容器 ID 或名称
  - `-u root`: 以 root 用户身份进入容器
- 验证文件权限已正确设置: `ls -ld *`
- 如需停止容器: `docker stop <container_id>`
- 如需启动已停止的容器: `docker start <container_id>`
- 如需删除容器: `docker rm <container_id>`

### 2. 创建新应用程序
- 此步骤在Host上完成
- 进入应用目录: `cd UniProton/demos/riscv64virt/apps/`
- 创建新的应用目录: `mkdir <your_app_name>`
- 在新目录中创建 main.c 和 CMakeLists.txt 文件
- 参考 UniProton/demos/riscv64virt/apps/hello_world 来创建 app，但是 console 部分如果不需要，就不要添加进去
- 从已有应用（如hello_world）复制console.h和console.c文件到新应用目录（仅在需要控制台功能时）

### 3. 配置新应用程序
- 此步骤在Host上完成
- 修改 apps/CMakeLists.txt 文件，添加新的应用分支:
  ```cmake
  elseif (APP STREQUAL "<your_app_name>")
      add_subdirectory(<your_app_name>)
  endif()
  ```
- 在应用目录中创建 CMakeLists.txt，配置源文件和库链接
- 修改 build/build_app.sh 文件，添加新的应用支持:
  ```bash
  elif [[ $one_arg == "<your_app_name>" ]]; then
      export APP=<your_app_name>
  ```
- 确保CMakeLists.txt创建的是OBJECT库而不是EXECUTABLE

### 4. 编译过程
- 重要：编译过程必须在Docker容器内完成
- 进入构建目录: `cd UniProton/demos/riscv64virt/build/`
- 执行构建脚本: `sh build_app.sh <your_app_name>`
- 构建过程中执行了以下主要步骤:
  - 生成 prt_buildef.h 配置文件
  - 使用 CMake 进行项目配置
  - 编译 BSP (Board Support Package) 组件
  - 编译应用代码
  - 链接生成可执行文件
  - 生成 ELF 和二进制格式的输出文件

### 5. 运行与验证
- 此步骤在Docker容器内完成
- 进入输出目录: `cd UniProton/demos/riscv64virt/build/out/`
- 使用 QEMU 模拟器运行程序: 
  ```bash
  /opt/qemu/bin/qemu-system-riscv64 -bios none -M virt -m 512M -nographic -kernel <your_app_name>.elf -smp 1
  ```
- 观察程序输出，确认成功运行

## 技术细节
- 架构: RISC-V 64位
- 工具链: riscv64-unknown-elf-gcc (GCC 13.2.0)
- 目标平台: RISC-V virt
- 内存分配: 512MB
- 核心数: 1
- 模拟器: QEMU 8.2.0 (位于 /opt/qemu/bin/)

## 常见应用模板

### Hello World 示例
- 应用名称: hello_world
- 构建命令: `sh build_app.sh hello_world`
- 运行后输出应包含: `hard driver init end!!!` 和 `start!!!!`

### 其他应用类型
- 可以替换 `<your_app_name>` 为其他示例应用名称
- 常见示例包括: task_manage, sem_test, mutex_test 等

## 故障排除

### 通用问题
- **容器权限问题**: 推荐使用 -u root 参数运行容器以避免权限问题
- **镜像标签问题**: 确保使用正确的镜像标签（通常是v003）
- **挂载路径问题**: 确保挂载的是UniProton目录而不是父目录

### 编译错误
- **头文件缺失**: 检查CMakeLists.txt中的include_directories是否包含了必要的头文件路径
- **目标冲突**: 确保CMakeLists.txt创建的是OBJECT库而不是EXECUTABLE
- **语法错误**: 检查build_app.sh等脚本的bash语法
- **函数未定义**: 确保所需的API头文件已被正确包含

### 运行错误
- **QEMU路径**: 确认使用完整路径`/opt/qemu/bin/qemu-system-riscv64`
- **ELF文件存在**: 检查out目录下是否生成了正确的ELF文件
- **内存配置**: 验证QEMU内存设置为至少512M

### 特殊问题
- **CSR寄存器访问**: 如果使用RISC-V CSR寄存器访问函数（如r_mhartid等），确保包含正确的头文件
- **控制台功能**: 从hello_world复制console.h和console.c文件以获得控制台功能
- **构建脚本损坏**: 如果build_app.sh损坏，考虑完全重写或从备份恢复

## 最佳实践

### 开发流程
1. 在宿主机上编辑源代码文件
2. 在容器中进行编译和测试
3. 当以 root 用户运行容器时，无需特别处理文件权限问题
4. 可以在容器内直接编辑文件（当以 root 用户运行时不会导致权限问题）

### 调试技巧
- 使用`docker exec -it <container_id> /bin/bash -c '<command>'`执行单个命令
- 在编译前检查文件权限: `ls -la` 
- 使用`find`命令定位头文件位置
- 检查CMakeLists.txt的include路径设置
- 构建或者运行遇到问题的时候，通过加入必要的调试信息打印来确认运行的位置和问题所在，根据切实的输出来推断问题，解决问题
- 如果有配套的调试工具，也要用起来，例如 qemu 的 monitor 功能，可以获取相关的信息

## 成功验证
- 编译成功完成，没有错误
- 程序在 QEMU 模拟器中正常启动
- 输出了预期的启动信息
- 可以通过Ctrl+C退出 QEMU 模拟器