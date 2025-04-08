#------------------------------------------------------------------------------------#
#
#   Created by Alem Gusinac, last modified at 07-04-2025
#   Contains adapterremoval with parallel gzip (pigz) and GNU parallel
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
    parallel \
    adapterremoval \
    pigz \
    && rm -rf /var/lib/apt/lists/*

#------------------------------------------------------------------------------------#
# Final steps
#------------------------------------------------------------------------------------#

RUN useradd -ms /bin/bash ${USER}
USER ${USER}