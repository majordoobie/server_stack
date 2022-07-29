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

# Provide x86 emulation (Disables ptrace)
FROM --platform=linux/amd64 ubuntu:22.04
#FROM ubuntu:20.04

RUN DEBIAN_FRONTEND="noninteractive" apt-get update && apt-get -y install tzdata

RUN apt-get update \
  && apt-get install -y ssh \
      build-essential \
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
      python3-pip \
      valgrind \
      iproute2 \ 
      neovim \
  && apt-get clean

RUN ( \
    echo 'LogLevel DEBUG2'; \
    echo 'PermitRootLogin yes'; \
    echo 'PasswordAuthentication yes'; \
    echo 'Subsystem sftp /usr/lib/openssh/sftp-server'; \
  ) > /etc/ssh/sshd_dev_config \
  && mkdir /run/sshd

RUN useradd -m user \
  && yes password | passwd user

RUN usermod -s /bin/bash user

CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_dev_config"]
