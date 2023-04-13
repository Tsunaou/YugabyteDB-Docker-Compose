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