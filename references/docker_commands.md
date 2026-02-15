# Docker 命令参考

## 常用 Docker 命令

### 启动和管理容器

```bash
# 启动新的 Docker 容器
docker run -itd -v $(pwd):/home/jenkins/UniProton <image_id> /bin/bash

# 进入正在运行的容器
docker exec -it <container_id> /bin/bash

# 查看运行中的容器
docker ps

# 查看所有容器（包括停止的）
docker ps -a

# 停止容器
docker stop <container_id>

# 启动已停止的容器
docker start <container_id>

# 删除容器
docker rm <container_id>

# 查看镜像
docker images

# 删除镜像
docker rmi <image_id>
```

### 权限管理

```bash
# 修改文件权限以适配容器内用户
sudo chown -R jenkins:jenkins .

# 检查当前权限
ls -ld *

# 查看当前用户
whoami
```

### 环境变量设置

```bash
# 确保 RISCV_NATIVE 为空
unset RISCV_NATIVE

# 或者显式设置为空
export RISCV_NATIVE=""
```