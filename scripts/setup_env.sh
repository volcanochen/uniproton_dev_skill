#!/bin/bash
# UniProton 开发环境设置脚本

echo "开始设置 UniProton 开发环境..."

# 检查是否在项目根目录
if [ ! -d "UniProton" ]; then
    echo "错误: 未找到 UniProton 目录，请确保在正确的项目根目录下运行此脚本"
    exit 1
fi

# 检查 Docker 是否安装
if ! [ -x "$(command -v docker)" ]; then
    echo "错误: Docker 未安装，请先安装 Docker"
    exit 1
fi

echo "设置文件权限..."
sudo chown -R jenkins:jenkins .

echo "启动 Docker 容器..."
CONTAINER_ID=$(docker run -itd -v $(pwd):/home/jenkins/UniProton swr.cn-north-4.myhuaweicloud.com/openeuler-embedded/uniproton-ci-test /bin/bash)

if [ $? -eq 0 ]; then
    echo "Docker 容器已启动，容器ID: $CONTAINER_ID"
    echo "请使用以下命令进入容器:"
    echo "docker exec -it $CONTAINER_ID /bin/bash"
    echo ""
    echo "在容器内，您可以执行以下命令来构建 hello_world 示例:"
    echo "cd UniProton/demos/riscv64virt/build/"
    echo "sh -x -e build_app.sh hello_world"
else
    echo "错误: 无法启动 Docker 容器"
    exit 1
fi

echo "环境设置完成！"