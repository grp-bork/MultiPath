FROM condaforge/miniforge3:24.7.1-0

LABEL maintainer="cschu1981@gmail.com"
LABEL version="xxx"
LABEL description="carveme docker image"


ARG DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt upgrade -y

RUN apt install -y wget python3-pip git
RUN apt clean

RUN conda install -y -c conda-forge -c bioconda -c nodefaults diamond pyscipopt && \
pip install carveme

WORKDIR /opt/conda/lib/python3.12/site-packages

RUN ln -s libscip.so.8.1.0.0 libscip.so.8.0

ENV PATH /opt/conda/bin:$PATH

WORKDIR /opt/conda/lib/python3.12/site-packages/carveme/data/generated

RUN diamond makedb --in bigg_proteins.faa -d bigg_proteins
