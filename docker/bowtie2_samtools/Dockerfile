#------------------------------------------------------------------------------------#
#
#   Created by Alem Gusinac, last modified at 27-02-2025
#   Contains samtools & bowtie2 with parallel gzip (pigz) and GNU parallel
#
#------------------------------------------------------------------------------------#

FROM staphb/samtools:latest

ARG USER=docker

# set environment without graphical interface
ENV DEBIAN_FRONTEND=noninteractive

#------------------------------------------------------------------------------------#
# 1. Installation of essential linux packages
#------------------------------------------------------------------------------------#
RUN apt-get update && apt-get install -y \
    parallel \
    bowtie2 \
    pigz \
    && rm -rf /var/lib/apt/lists/*

#------------------------------------------------------------------------------------#
# Final steps
#------------------------------------------------------------------------------------#

RUN useradd -ms /bin/bash ${USER}
USER ${USER}