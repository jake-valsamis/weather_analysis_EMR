# hash:sha256:d26387ccbedfae9896ca2cbb7e2b06a22339710fc51e4623a9cbfbfe530b17ef
FROM registry.acmecorp-demo.codeocean.com/codeocean/jupyterlab:3.0.9-miniconda4.9.2-python3.8-ubuntu20.04

ARG DEBIAN_FRONTEND=noninteractive

ARG GIT_ASKPASS
ARG GIT_ACCESS_TOKEN
COPY git-askpass /

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        jq=1.6-1ubuntu0.20.04.1 \
    && rm -rf /var/lib/apt/lists/*

RUN conda install -y --channel=conda-forge \
        pyspark==3.3.0 \
    && conda clean -ya

RUN pip install -U --no-cache-dir \
    awscli==1.25.86
