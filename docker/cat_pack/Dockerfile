#------------------------------------------------------------------------------------#
#
#   Created by Alem Gusinac, last modified at 06-02-2025
# 
#   Contains biobakery kneaddata with custom utilities.py
#
#------------------------------------------------------------------------------------#

FROM ubuntu:20.04

ARG USER=docker

# set environment without graphical interface
ENV DEBIAN_FRONTEND=noninteractive

#------------------------------------------------------------------------------------#
# 1. Installation of essential linux packages
#------------------------------------------------------------------------------------#
RUN apt-get update && apt-get install -y \
    autoconf automake \
    make \
    pandoc \
    cargo \
    curl wget pgp \
    libtool \
    libcurl4-openssl-dev \ 
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libmariadbd-dev \
    libpq-dev \
    libssh2-1-dev \
    unixodbc-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libreadline-dev \
    libffi-dev \
    libbz2-dev \
    liblzma-dev \
    fastqc \
    parallel \
    default-jre \ 
    && rm -rf /var/lib/apt/lists/*

#------------------------------------------------------------------------------------#
# 2. Python:3.11 setup
#------------------------------------------------------------------------------------#
# Getting python 3.11 from source
RUN wget https://www.python.org/ftp/python/3.11.3/Python-3.11.3.tgz \
    && tar -xvf Python-3.11.3.tgz \
    && cd Python-3.11.3 \
    && ./configure --enable-optimizations \
    && make altinstall \
    && rm -rf /tmp/* /var/lib/apt/lists/*

# Install pip3 for Python 3.11
RUN wget https://bootstrap.pypa.io/get-pip.py \
    && python3.11 get-pip.py

#------------------------------------------------------------------------------------#
# 3. DIAMOND setup
#------------------------------------------------------------------------------------#
RUN wget https://github.com/bbuchfink/diamond/releases/download/v2.1.11/diamond-linux64.tar.gz \
    && tar -xzf diamond-linux64.tar.gz \
    && mv diamond /usr/local/bin \
    && rm diamond-linux64.tar.gz

#------------------------------------------------------------------------------------#
# 4. PRODIGAL setup
#------------------------------------------------------------------------------------#
RUN wget https://github.com/hyattpd/Prodigal/releases/download/v2.6.3/prodigal.linux \
    && chmod +x prodigal.linux \
    && mv prodigal.linux /usr/local/bin/prodigal

#------------------------------------------------------------------------------------#
# 4. CAT_pack setup
#------------------------------------------------------------------------------------#
RUN wget https://github.com/MGXlab/CAT_pack/archive/refs/tags/v6.0.1.tar.gz \
    && tar -xzf v6.0.1.tar.gz \
    && mv CAT_pack-6.0.1 /opt/CAT_pack \
    && chmod +x /opt/CAT_pack/CAT_pack/CAT_pack \
    && ln -s /opt/CAT_pack/CAT_pack/CAT_pack /usr/local/bin/CAT_pack

#------------------------------------------------------------------------------------#
# Final steps
#------------------------------------------------------------------------------------#

RUN useradd -ms /bin/bash ${USER}
USER ${USER}