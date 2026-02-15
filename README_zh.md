# UniProton RISC-V 应用开发技能

该技能帮助用户在 Docker 环境中开发、编译和运行 UniProton RISC-V 应用程序。它包括环境配置、编译步骤和运行验证的完整流程。

## 描述

帮助用户在 Docker 环境中开发、编译和运行 UniProton RISC-V 应用程序。包括环境配置、编译步骤、运行验证和故障排除的完整流程。当用户需要开发 UniProton 应用程序、配置开发环境、编译或运行 UniProton 应用时使用此技能。

## 环境配置

### Docker 环境配置要求

#### Docker 镜像
- 必须使用指定的 Docker 镜像：`swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/uniproton-ci-test:v003`
- 该镜像预装了所需的工具链和其他依赖项

#### 目录挂载
- 启动 Docker 容器时，挂载宿主文件夹：`-v $(pwd)/UniProton:/home/jenkins/UniProton`
- 注意：挂载路径应该是 UniProton 目录而不是整个项目根目录
- 这样可以将宿主机的源代码映射到容器内用于编译

#### 权限设置
- 建议以 root 用户运行容器以避免权限问题：
  - `docker run -itd -u root -v $(pwd)/UniProton:/home/jenkins/UniProton ...`
- 或设置适当的用户映射，确保容器用户可以访问宿主目录
- 当使用 root 用户运行容器时，无需设置额外的宿主机文件权限

#### 编译配置
- 确保环境变量 `RISCV_NATIVE` 为空或未设置
- 由于这是交叉编译过程，不应启用原生 RISC-V 编译选项

## 操作流程

### 1. 启动 Docker 环境
- 启动 Docker 容器：`docker run -itd -u root -v $(pwd)/UniProton:/home/jenkins/UniProton swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/uniproton-ci-test:v003`
  - `-itd`：以后台交互模式运行容器
  - `-u root`：以 root 用户身份运行容器以避免权限问题
  - `-v $(pwd)/UniProton:/home/jenkins/UniProton`：将当前宿主机的 UniProton 目录挂载到容器的 /home/jenkins/UniProton 路径
  - `swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/uniproton-ci-test:v003`：指定的 Docker 镜像
  - `/bin/bash`：启动 bash shell
- 进入正在运行的容器：`docker exec -u root -it <container_id> /bin/bash`
  - `<container_id>`：容器 ID 或名称
  - `-u root`：以 root 用户身份进入容器
- 验证文件权限已正确设置：`ls -ld *`
- 停止容器：`docker stop <container_id>`
- 启动已停止的容器：`docker start <container_id>`
- 删除容器：`docker rm <container_id>`

### 2. 创建新应用程序
- 此步骤在宿主机上执行
- 进入应用目录：`cd UniProton/demos/riscv64virt/apps/`
- 创建新应用目录：`mkdir <your_app_name>`
- 在新目录中创建 main.c 和 CMakeLists.txt 文件
- 参考 UniProton/demos/riscv64virt/apps/hello_world 来创建 app，但是 console 部分如果不需要，就不要添加进去
- 从现有应用（如 hello_world）复制 console.h 和 console.c 文件到新应用目录（仅在需要控制台功能时）

### 3. 配置新应用程序
- 此步骤在宿主机上执行
- 修改 apps/CMakeLists.txt 文件，添加新应用分支：
  ```cmake
  elseif (APP STREQUAL "<your_app_name>")
      add_subdirectory(<your_app_name>)
  endif()
  ```
- 在应用目录中创建 CMakeLists.txt，配置源文件和库链接
- 修改 build/build_app.sh 文件，添加新应用支持：
  ```bash
  elif [[ $one_arg == "<your_app_name>" ]]; then
      export APP=<your_app_name>
  ```
- 确保 CMakeLists.txt 创建的是 OBJECT 库而不是 EXECUTABLE

### 4. 编译过程
- 重要：编译过程必须在 Docker 容器内完成
- 进入构建目录：`cd UniProton/demos/riscv64virt/build/`
- 执行构建脚本：`sh build_app.sh <your_app_name>`
- 构建过程执行以下主要步骤：
  - 生成 prt_buildef.h 配置文件
  - 使用 CMake 进行项目配置
  - 编译 BSP（板级支持包）组件
  - 编译应用程序代码
  - 链接生成可执行文件
  - 生成 ELF 和二进制格式的输出文件

### 5. 运行与验证
- 此步骤在 Docker 容器内完成
- 进入输出目录：`cd UniProton/demos/riscv64virt/build/out/`
- 使用 QEMU 模拟器运行程序：
  ```bash
  /opt/qemu/bin/qemu-system-riscv64 -bios none -M virt -m 512M -nographic -kernel <your_app_name>.elf -smp 1
  ```
- 观察程序输出以确认成功执行

## 技术细节
- 架构：RISC-V 64 位
- 工具链：riscv64-unknown-elf-gcc（GCC 13.2.0）
- 目标平台：RISC-V virt
- 内存分配：512MB
- 核心数：1
- 模拟器：QEMU 8.2.0（位于 /opt/qemu/bin/）

## 常见应用模板

### Hello World 示例
- 应用名称：hello_world
- 构建命令：`sh build_app.sh hello_world`
- 运行后预期输出应包含：`hard driver init end!!!` 和 `start!!!!`

### 其他应用类型
- 可以将 `<your_app_name>` 替换为其他示例应用名称
- 常见示例包括：task_manage、sem_test、mutex_test 等

## 故障排除

### 一般问题
- **容器权限问题**：建议在运行容器时使用 -u root 参数以避免权限问题
- **镜像标签问题**：确保使用正确的镜像标签（通常是 v003）
- **挂载路径问题**：确保挂载 UniProton 目录而不是父目录

### 编译错误
- **缺少头文件**：检查 CMakeLists.txt 中的 include_directories 是否包含必要的头文件路径
- **目标冲突**：确保 CMakeLists.txt 创建的是 OBJECT 库而不是 EXECUTABLE
- **语法错误**：检查 build_app.sh 等脚本的 bash 语法
- **未定义函数**：确保所需 API 头文件已正确包含

### 运行时错误
- **QEMU 路径**：确认使用完整路径 `/opt/qemu/bin/qemu-system-riscv64`
- **ELF 文件存在性**：检查 out 目录下是否正确生成了 ELF 文件
- **内存配置**：验证 QEMU 内存设置为至少 512M

### 特殊问题
- **CSR 寄存器访问**：如果使用 RISC-V CSR 寄存器访问函数（如 r_mhartid 等），请确保包含正确的头文件
- **控制台功能**：从 hello_world 复制 console.h 和 console.c 文件以获得控制台功能
- **构建脚本损坏**：如果 build_app.sh 损坏，请考虑完全重写或从备份恢复

## 最佳实践

### 开发工作流
1. 在宿主机上编辑源代码文件
2. 在容器中编译和测试
3. 当以 root 用户运行容器时，无需特殊处理文件权限
4. 可以直接在容器内编辑文件（当以 root 用户运行时不会出现权限问题）

### 调试技巧
- 使用 `docker exec -it <container_id> /bin/bash -c '<command>'` 执行单个命令
- 编译前检查文件权限：`ls -la`
- 使用 `find` 命令定位头文件位置
- 检查 CMakeLists.txt 中的包含路径设置
- 构建或者运行遇到问题的时候，通过加入必要的调试信息打印来确认运行的位置和问题所在，根据切实的输出来推断问题，解决问题
- 如果有配套的调试工具，也要用起来，例如 qemu 的 monitor 功能，可以获取相关的信息