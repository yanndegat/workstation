#!/bin/sh

sudo yum install -y libevent-devel
(cd /home/centos && \
     git clone https://github.com/yanndegat/.tmux.git ~/.tmux && \
     curl -fsSL https://github.com/tmux/tmux/releases/download/2.7/tmux-2.7.tar.gz -o /tmp/tmux.tar.gz && \
     tar -xzf /tmp/tmux.tar.gz && \
     cd tmux-2.7 && \
     ./configure --prefix /home/centos/.local/tmux && \
     ln -s /home/centos/.tmux/.tmux.conf /home/centos/.tmux.conf && \
     ln -s /home/centos/.tmux/.tmux.conf.local /home/centos/.tmux.conf.local)
