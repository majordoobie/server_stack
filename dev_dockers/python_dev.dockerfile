# Taken and modified from: https://github.com/JetBrains/clion-remote/blob/master/Dockerfile.remote-cpp-env
#
#
# Build and run:
#  https://stackoverflow.com/questions/30905674/newer-versions-of-docker-have-cap-add-what-caps-can-be-added
#  https://stackoverflow.com/questions/34856092/gdb-does-not-hit-any-breakpoints-when-i-run-it-from-inside-docker-container

# docker build -t clion/image_ubuntu_20_wssh:1.0 -f ubuntu20_image_wssh_Dockerfile.yml .
# docker run -d --security-opt seccomp=unconfined --cap-add=SYS_PTRACE -p127.0.0.1:2222:22 --name clion_remote_env clion/image_ubuntu_20_wssh:1.0
# docker run -d --cap-add sys_ptrace -p127.0.0.1:2222:22 --name clion_remote_env clion/image_ubuntu_20_wssh:1.0
#
#
# ssh credentials (test user):
#   user@password 

# Provide x86 emulation (Disables ptrace making gdb useless)
FROM --platform=linux/amd64 ubuntu:22.04

# Uncommet here to get the native version of ubuntu
#FROM ubuntu:22.04

RUN DEBIAN_FRONTEND="noninteractive" \
    apt-get update && \
    apt-get install -y \
    tzdata \
    software-properties-common

# Set up Ubuntu 22 comes with 3.10
RUN add-apt-repository -y ppa:deadsnakes/ppa; \
    apt update; \
    apt install -y \
    python3.9 \
    python3-pip \
    python3.9-venv; \
    python3.9 -m pip install --upgrade pip

    
# Prep the default installation just in case it is needed
RUN apt install -y \
    python3.10-venv; \
    python3 -m pip install --upgrade pip
    

# Set up C environment 
RUN apt install -y \
    sudo \
    build-essential \
    ssh \
    gcc \
    g++ \
    gdb \
    clang \
    make \
    cmake \
    autoconf \
    automake \
    rsync \
    tar \
    valgrind; \
    apt-get clean

# Add misc utilities
RUN apt install -y \
    iproute2


# Set up SSH
RUN ( \
    echo 'LogLevel DEBUG2'; \
    echo 'PermitRootLogin yes'; \
    echo 'PasswordAuthentication yes'; \
    echo 'Subsystem sftp /usr/lib/openssh/sftp-server'; \
  ) > /etc/ssh/sshd_dev_config \
  && mkdir /run/sshd

# Add user "ssh user@<ip>" "password = password"
RUN useradd -m user; \
    yes password | passwd user; \
    usermod -s /bin/bash user; \
    usermod -aG sudo user

CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_dev_config"]
