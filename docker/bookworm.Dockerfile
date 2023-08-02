FROM gcc:13-bookworm

ARG GAMEMASTER_VERSION=1.0.0
ARG GAMEMASTER_USER=gamemaster
ARG GAMEMASTER_HOME=/opt/docker_home

ADD tools/gamemaster-init.tar.gz $GAMEMASTER_HOME

WORKDIR ${GAMEMASTER_HOME}

USER root

RUN set -eux; \
  # update
  apt update; \
  # llvm gpg
  wget -O - 'https://apt.llvm.org/llvm-snapshot.gpg.key' | apt-key add -; \
  # sources.list
  [ -f /etc/apt/sources.list ] && mv /etc/apt/sources.list /etc/apt/sources.list.bak; \
  echo "deb http://mirrors.ustc.edu.cn/debian stable main contrib non-free non-free-firmware" >> /etc/apt/sources.list; \
  echo "deb http://mirrors.ustc.edu.cn/debian stable-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list; \
  echo "deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm main" >> /etc/apt/sources.list; \
  echo "deb-src http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm main" >> /etc/apt/sources.list; \
  echo "deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-17 main" >> /etc/apt/sources.list; \
  echo "deb-src http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-17 main" >> /etc/apt/sources.list; \
  # update
  apt update; \
  apt upgrade -y; \
  # software
  apt install -y --no-install-recommends \
  init \
  systemd \
  zsh \
  curl \
  vim \
  git \
  git-lfs \
  cmake \
  autoconf \
  automake \
  sudo \
  passwd \
  tmux \
  htop \
  texinfo \
  doxygen \
  openssl \
  openssh-server \
  openssh-client \
  locales \
  locales-all \
  net-tools \
  rsync \
  tar \
  bzip2 \
  zip \
  unzip \
  lrzsz \
  lsof \
  telnet \
  graphviz \
  gdb \
  nodejs \
  python3 \
  python3-venv \
  python3-pip \
  ninja-build \
  pkg-config \
  libx11-dev \
  libxft-dev \
  libxext-dev \
  libtool \
  # llvm
  libllvm-17-ocaml-dev \
  libllvm17 \
  llvm-17 \
  llvm-17-dev \
  llvm-17-doc \
  llvm-17-examples \
  llvm-17-runtime \
  clang-17 \
  clang-tools-17 \
  clang-17-doc \
  libclang-common-17-dev \
  libclang-17-dev \
  libclang1-17 \
  clang-format-17 \
  python3-clang-17 \
  clangd-17 \
  clang-tidy-17 \
  libclang-rt-17-dev \
  libpolly-17-dev \
  libfuzzer-17-dev \
  lldb-17 \
  lld-17 \
  libc++-17-dev \
  libc++abi-17-dev \
  libomp-17-dev \
  libclc-17-dev \
  libunwind-17-dev \
  libmlir-17-dev \
  mlir-17-tools \
  libbolt-17-dev \
  bolt-17 \
  flang-17 \
  libclang-rt-17-dev-wasm32 \
  libclang-rt-17-dev-wasm64 \
  libc++-17-dev-wasm32 \
  libc++abi-17-dev-wasm32 \
  libclang-rt-17-dev-wasm32 \
  libclang-rt-17-dev-wasm64; \
  # limits.conf
  [ -f /etc/security/limits.conf ] && mv /etc/security/limits.conf /etc/security/limits.conf.bak; \
  echo "*       soft    core    unlimited" >> /etc/security/limits.conf; \
  echo "*       hard    core    unlimited" >> /etc/security/limits.conf; \
  echo "*       soft    nofile  1048576" >> /etc/security/limits.conf; \
  echo "*       hard    nofile  1048576" >> /etc/security/limits.conf; \
  echo "*       soft    nproc   102400" >> /etc/security/limits.conf; \
  echo "*       hard    nproc   102400" >> /etc/security/limits.conf; \
  echo "root*   soft    core    unlimited" >> /etc/security/limits.conf; \
  echo "root*   hard    core    unlimited" >> /etc/security/limits.conf; \
  echo "root*   soft    nofile  1048576" >> /etc/security/limits.conf; \
  echo "root*   hard    nofile  1048576" >> /etc/security/limits.conf; \
  echo "root*   soft    nproc   102400" >> /etc/security/limits.conf; \
  echo "root*   hard    nproc   102400" >> /etc/security/limits.conf; \
  # localtime
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
  # sshd_config
  sed -e 's|#GSSAPIAuthentication no|GSSAPIAuthentication no|g' \
  -e 's|#PubkeyAuthentication yes|PubkeyAuthentication yes|g' \
  -e 's|#PasswordAuthentication yes|PasswordAuthentication yes|g' \
  -e '/#PermitRootLogin prohibit-password/a\PermitRootLogin yes' \
  -i /etc/ssh/sshd_config; \
  # user settings
  mkdir -p $GAMEMASTER_HOME; \
  cp -R /etc/skel/. $GAMEMASTER_HOME; \
  groupadd -r -g 1024 $GAMEMASTER_USER; \
  useradd -r -d $GAMEMASTER_HOME -s $(which zsh) -g $GAMEMASTER_USER -u 1024 $GAMEMASTER_USER; \
  usermod -aG sudo $GAMEMASTER_USER; \
  mkdir -p .ssh; \
  chmod 700 .ssh; \
  echo "" >> .ssh/authorized_keys; \
  chmod 600 .ssh/authorized_keys; \
  echo "set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936" >> .vimrc; \
  echo "set termencoding=utf-8" >> .vimrc; \
  echo "set encoding=utf-8" >> .vimrc; \
  mkdir -p .vscode-server/data/Machine; \
  mv settings.json .vscode-server/data/Machine/; \
  chown -R $GAMEMASTER_USER:$GAMEMASTER_USER $GAMEMASTER_HOME;

USER ${GAMEMASTER_USER}

RUN set eux; \
  sh install-ohmyzsh.sh --unattended; \
  rm -f install-ohmyzsh.sh; \
  mv powerlevel10k .oh-my-zsh/custom/themes/powerlevel10k; \
  sed -e 's|ZSH_THEME="robbyrussell"|ZSH_THEME="powerlevel10k/powerlevel10k"|g' \
  -i .zshrc;

RUN set eux; \
  echo "version       ${GAMEMASTER_VERSION}" >> .gamemaster-info; \
  echo "debian        bookworm" >> .gamemaster-info; \
  echo "gcc           13" >> .gamemaster-info; \
  echo "llvm          17" >> .gamemaster-info; \
  echo "user          ${GAMEMASTER_USER}" >> .gamemaster-info; \
  echo "home          ${GAMEMASTER_HOME}" >> .gamemaster-info;

USER root
WORKDIR /root
VOLUME ${GAMEMASTER_HOME}