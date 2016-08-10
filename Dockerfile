FROM teego/steem-base:0.2

MAINTAINER Aleksandr Zykov <tiger@mano.email>

ENV DEBIAN_FRONTEND="noninteractive"

ENV STEEMD_ARGS="--p2p-endpoint 0.0.0.0:2001 --rpc-endpoint 0.0.0.0:8090"

RUN echo "Boost library" &&\
    ( \
        apt-get install -qy --no-install-recommends \
            libboost-all-dev \
    ) && \
    apt-get clean -qy

ENV STEEM_VERSION 0.12.3a

RUN mkdir -p /root/src &&\
    ( \
        git clone https://github.com/steemit/steem.git steem &&\
        cd steem ;\
        ( \
            git checkout v$STEEM_VERSION &&\
            git submodule update --init --recursive &&\
            cmake \
                -DCMAKE_BUILD_TYPE=Release \
                -DCMAKE_INSTALL_PREFIX=/usr/local \
                CMakeLists.txt &&\
            make install \
        ) \
    ) &&\
    ( \
        rm -Rf /root/src \
    )

RUN mkdir -p /witness_node_data_dir &&\
    touch /witness_node_data_dir/.default_dir

ADD config.ini /root/src/config.ini.sample
ADD run-steemd.sh /usr/local/bin

EXPOSE 2001 8090

VOLUME ["/witness_node_data_dir"]

CMD ["/usr/local/bin/run-steemd.sh"]
