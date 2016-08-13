# -*- coding: utf-8 -*-

FROM teego/steem-devel:0.3-Ubuntu-trusty

MAINTAINER Aleksandr Zykov <tiger@mano.email>

# Automatic build has been temporarily disabled
RUN /bin/false

ENV BUILDBASE /r
ENV BUILDROOT $BUILDBASE/build
ENV FILESROOT $BUILDBASE/files

RUN mkdir -p $BUILDROOT $FILESROOT

ENV STEEM_VERSION 0.13.0
ENV STEEM_RELEASE $STEEM_VERSION-rc3

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

ENV STEEMD_ARGS="--p2p-endpoint 0.0.0.0:2001 --rpc-endpoint 0.0.0.0:8090"

ADD run-steemd.sh /usr/local/bin

EXPOSE 2001 8090

VOLUME ["/witness_node_data_dir"]

CMD ["/usr/local/bin/run-steemd.sh"]
