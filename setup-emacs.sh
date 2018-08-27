#!/bin/sh

sudo yum install -y gnutls-devel
(cd /home/centos && \
     git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d && \
     mkdir -p .local && \
     curl -fsSL https://ftp.gnu.org/gnu/emacs/emacs-26.1.tar.xz -o /tmp/emacs.tar.xz && \
     tar -xJf /tmp/emacs.tar.xz && \
     cd emacs-26.1 && \
     ./configure --without-x --prefix /home/centos/.local/emacs && \
     make && make install && \
     cp /tmp/emacsclient /home/centos/.local/emacs/bin/emacsclient.sh && \
     chmod +x /home/centos/.local/emacs/bin/emacsclient.sh)
