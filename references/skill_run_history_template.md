# UniProton 应用开发操作历史记录

## 记录格式

每次操作请按照以下格式记录：

```
## 项目：[项目名称]
## 时间：YYYY-MM-DD HH:MM:SS
### Skill：[skill名称或"外部操作"]
### 目的：[操作的原因和目标]
### 命令：[执行的具体命令]
### 参数：[命令的参数和选项]
### 执行结果：[命令的输出和执行状态]
### 处理：[对执行结果的处理方式]
### 方案：[采用的解决方案]
```

## 操作记录

### 示例记录

```
## 项目：hello_world_demo
## 时间：2026-02-27 10:00:00
### Skill：uniproton-app-dev
### 目的：启动 Docker 容器进行 UniProton 开发
### 命令：docker run -itd -u root -v $(pwd)/UniProton:/home/jenkins/UniProton swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/uniproton-ci-test:v003
### 参数：
- -itd: 以交互模式后台运行容器
- -u root: 以 root 用户身份运行容器
- -v $(pwd)/UniProton:/home/jenkins/UniProton: 挂载 UniProton 目录
- swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/uniproton-ci-test:v003: Docker 镜像
### 执行结果：容器启动成功，返回容器 ID
### 处理：记录容器 ID 用于后续操作
### 方案：使用 root 用户运行容器以避免权限问题
```

```
## 项目：hello_world_demo
## 时间：2026-02-27 10:05:00
### Skill：外部操作
### 目的：编辑应用程序源代码
### 命令：vim UniProton/demos/riscv64virt/apps/hello_world/main.c
### 参数：无
### 执行结果：文件编辑成功
### 处理：保存修改后的文件
### 方案：直接编辑源代码文件
```

```
## 项目：hello_world_demo
## 时间：2026-02-27 10:10:00
### Skill：uniproton-app-dev
### 目的：运行编译好的应用程序
### 命令：timeout 30 /opt/qemu/bin/qemu-system-riscv64 -bios none -M virt -m 512M -nographic -kernel hello_world.elf -smp 1
### 参数：
- timeout 30: 设置30秒超时
- -bios none: 不使用BIOS
- -M virt: 使用virt机器模型
- -m 512M: 分配512MB内存
- -nographic: 无图形界面
- -kernel hello_world.elf: 指定内核文件
- -smp 1: 使用1个CPU核心
### 执行结果：程序运行成功，输出预期信息
### 处理：观察输出，确认程序正常运行
### 方案：使用timeout命令避免程序无响应时Docker容器卡住
```

## 注意事项

1. 请确保每次操作都及时记录
2. 记录内容要详细、准确
3. 按照时间顺序排列记录
4. 保持记录的一致性和完整性
5. 对于使用技能的操作，请在Skill字段中填写具体的skill名称
6. 对于技能以外的操作，请在Skill字段中填写"外部操作"
7. 每个项目的操作记录应分组管理，便于查找和分析
