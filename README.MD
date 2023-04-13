# 使用 Docker 和 Docker-Compose 构建 YugabyteDB 集群

本项目介绍一个使用 Docker-Compose 构建

## 1. 构建适合的 Docker 镜像

参考 YugabyteDB 官方镜像的 IMAGE LAYERS：
- 从 `almalinux:8` 开始构建，然后安装必要的依赖。
- 下载 YugabyteDB 压缩包并解压，同时运行 `post_install.sh`安装 YugabyteDB 所需的依赖
- 暴露 YugabyteDB 服务所需的端口

``` Dockerfile
FROM almalinux:8

# Install necessary dependencies
RUN yum install -y epel-release \
    && yum install -y python3 \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && yum install -y java-1.8.0-openjdk-headless which less bind-utils net-tools rsync \
    && yum install -y openssl openssl-devel diffutils \
    && yum install -y s3cmd sysstat iotop tcpdump fio \
    && yum install -y wget \
    && yum install -y chrony \
    && yum install -y tini \
    && yum clean all \
    && rm -rf /var/cache/yum

# Download and extract YugabyteDB
WORKDIR /opt
RUN wget https://downloads.yugabyte.com/releases/2.17.2.0/yugabyte-2.17.2.0-b216-linux-x86_64.tar.gz \
    && tar xvfz yugabyte-2.17.2.0-b216-linux-x86_64.tar.gz \
    && rm yugabyte-2.17.2.0-b216-linux-x86_64.tar.gz \
    && cd yugabyte-2.17.2.0 \
    && ./bin/post_install.sh

# Set environment variables
ENV PATH="/opt/yugabyte-2.17.2.0/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/yugabyte-2.17.2.0/lib:${LD_LIBRARY_PATH}"

# Expose necessary ports
EXPOSE 10100 11000 12000 5433 6379 7000 7100 7200 9000 9042 9100

# Set entrypoint
ENTRYPOINT ["/usr/bin/tini", "--", "/bin/bash"]
```

之后，在本地构建镜像：
```bash
docker build -t raw-yb-2.17.2.0 .
```

##  2. 使用 Docker-Compose 搭建 YugabyteDB 集群
构建了一个由 3 个节点组成的 YugabyteDB，每个节点上都运行一个 `YB-Master` 与 `YB-TServer`，通过 Raft 协议提供高可用服务。

构建所需的 `docker-compose.yaml` 文件已经提供。

使用如下命令启动：
``` bash
docker-compose up
```

启动成功后，可以在本机 `localhost:17000` 访问 UI 界面。