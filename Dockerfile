# -*- coding: utf-8 -*-

FROM teego/steem-base:0.3-Debian-jessie

MAINTAINER Aleksandr Zykov <tiger@mano.email>

ENV DEBIAN_FRONTEND="noninteractive"

RUN echo "Development requirements" &&\
    ( \
        apt-get install -qy --no-install-recommends \
            git \
            cmake \
            g++ \
            python3 \
            python3-dev \
            autotools-dev \
            libicu-dev \
            build-essential \
            libbz2-dev \
            libssl-dev \
            libncurses5-dev \
            doxygen \
            libreadline-dev \
            dh-autoreconf \
            python2.7-dev \
    ) && \
    apt-get clean -qy

RUN echo "Boost library" &&\
    ( \
        apt-get install -qy --no-install-recommends \
            libboost-all-dev \
    ) && \
    apt-get clean -qy

RUN apt-cache show libboost-all-dev

ENV STEEM_VERSION 0.13.0
ENV STEEM_RELEASE $STEEM_VERSION-rc3

ENV STEEMD_ARGS="--p2p-endpoint 0.0.0.0:2001 --rpc-endpoint 0.0.0.0:8090"

ENV BUILDBASE /r
ENV BUILDROOT $BUILDBASE/build
ENV FILESROOT $BUILDBASE/files

RUN mkdir -p $BUILDROOT $FILESROOT

RUN cd $BUILDROOT && \
    ( \
        git clone https://github.com/steemit/steem.git steem &&\
        cd steem ;\
        ( \
            git checkout $STEEM_RELEASE &&\
            git submodule update --init --recursive &&\
            cmake \
                -DCMAKE_BUILD_TYPE=Release \
                -DCMAKE_INSTALL_PREFIX=/usr/local \
                CMakeLists.txt &&\
            make install \
        ) \
    ) &&\
    ( \
        rm -Rf $BUILDROOT/steem \
    )

RUN mkdir -p /witness_node_data_dir &&\
    touch /witness_node_data_dir/.default_dir

ADD config.ini $FILESROOT/config.ini.sample
ADD run-steemd.sh /usr/local/bin

EXPOSE 2001 8090

VOLUME ["/witness_node_data_dir"]

CMD ["/usr/local/bin/run-steemd.sh"]
