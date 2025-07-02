#------------------------------------------------------------------------------------#
#
#   Created by Alem Gusinac, last modified at 14-5-2025
# 
#   Contains efficient data wrangling structures, such as scipy, numpy, polars and biom
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
    bowtie2 \
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

RUN pip install scipy \
                numpy \
                polars \
                biom-format \
                pyfastx

#------------------------------------------------------------------------------------#
# Final steps
#------------------------------------------------------------------------------------#

RUN useradd -ms /bin/bash ${USER}
USER ${USER}