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

RUN mkdir -p /root/src && \
    ( \
        git clone https://github.com/steemit/steem.git steem &&\
        cd steem ;\
        ( \
            git checkout v0.12.3 &&\
            git submodule update --init --recursive &&\
            cmake \
                -DENABLE_CONTENT_PATCHING=OFF \
                -DLOW_MEMORY_NODE=OFF \
                CMakeLists.txt &&\
            make install \
        ) \
    ) &&\
    ( \
        cd /root/src ;\
        rm -Rf steem \
    )

RUN mkdir -p /witness_node_data_dir &&\
    touch /witness_node_data_dir/.default_dir

ADD config.ini /root/src/config.ini.sample
ADD run-steemd.sh /usr/local/bin

EXPOSE 2001 8090

VOLUME ["/witness_node_data_dir"]

CMD ["/usr/local/bin/run-steemd.sh"]
