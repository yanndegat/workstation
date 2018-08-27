#!/bin/sh

sudo yum install -y gcc-c++ ncurses-devel python-devel
(cd /home/centos && \
     mkdir -p .local && \
     git clone https://github.com/vim/vim.git && \
     cd vim/src && \
     git checkout v8.1.0328 && \
     ./configure \
         --disable-nls \
         --enable-cscope \
         --enable-gui=no \
         --enable-multibyte  \
         --enable-pythoninterp \
         --enable-rubyinterp \
         --prefix=/home/centos/.local/vim \
         --with-features=huge  \
         --with-python-config-dir=/usr/lib/python2.7/config \
         --with-tlib=ncurses \
         --without-x && \
     make && make install && \
     curl -sLf https://spacevim.org/install.sh | bash -s)
