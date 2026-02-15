# UniProton 构建系统参考

## 构建脚本说明

### 主要构建脚本

- `build_app.sh` - 应用构建主脚本
  - 位置: `UniProton/demos/riscv64virt/build/build_app.sh`
  - 功能: 编译指定的应用程序
  - 用法: `sh build_app.sh <app_name>`

### 构建过程详解

1. **初始化阶段**
   - 克隆 libboundscheck 库
   - 生成配置头文件 prt_buildef.h

2. **配置阶段**
   - 运行 make_buildef_file.sh 生成构建定义
   - 设置 BUILD_TIME_TAG
   - 生成 Makefile

3. **编译阶段**
   - 编译 BSP 组件
   - 编译应用代码
   - 链接生成可执行文件

4. **输出阶段**
   - 生成 ELF 格式文件
   - 生成二进制格式文件
   - 存放到 out/ 目录

### 构建输出文件

- `out/<app_name>.elf` - ELF 格式可执行文件
- `out/<app_name>.bin` - 二进制格式文件
- `out/` 目录存放所有输出文件

### 自定义应用构建

要构建自定义应用，请遵循以下步骤：

1. 在 `demos/riscv64virt/apps/` 目录下创建应用目录
2. 实现 `main.c` 文件作为应用入口点
3. 在构建脚本中引用你的应用
4. 运行 `sh build_app.sh <your_app_name>`