FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04


## CLeanup
RUN rm -rf /var/lib/apt/lists/* \
           /etc/apt/sources.list.d/cuda.list \
           /etc/apt/sources.list.d/nvidia-ml.list

ARG APT_INSTALL="apt-get install -y --no-install-recommends"
## Python3
# Install python3
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive ${APT_INSTALL} \
        python3.6 \
        python3.6-dev \
        python3-distutils-extra \
        wget && \
    apt-get clean && \
    rm /var/lib/apt/lists/*_*

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y python3.6-tk zlib1g-dev libjpeg-dev libsm6 libxext6 libopenblas-dev libomp-dev

# Link python to python3
RUN ln -s /usr/bin/python3.6 /usr/local/bin/python3 && \
    ln -s /usr/bin/python3.6 /usr/local/bin/python

# Setuptools
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py
RUN rm get-pip.py

## Locale
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ADD ./ /root/gene_disease_ner
WORKDIR /root/gene_disease_ner
CMD ./run_scripts/annotate.sh

