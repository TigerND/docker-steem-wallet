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
    mkdir -p /root/dist/steem-v$STEEM_VERSION &&\
    ( \
        git clone https://github.com/steemit/steem.git steem &&\
        cd steem ;\
        ( \
            git checkout v$STEEM_VERSION &&\
            git submodule update --init --recursive &&\
            cmake \
                -DCMAKE_BUILD_TYPE=Release \
                -DCMAKE_INSTALL_PREFIX=/root/dist/steem-v$STEEM_VERSION \
                CMakeLists.txt &&\
            make install \
        ) \
    ) &&\
    ( \
        cd /root/dist; \
        (\
            echo "Building a package" &&\
            tar cfz /root/steem-v$STEEM_VERSION.tar.gz steem-v$STEEM_VERSION &&\
            sha256sum steem-v$STEEM_VERSION.tar.gz \
        ) \
    ) && \
    ( \
        cd /usr/local; \
        tar xfz /root/steem-v$STEEM_VERSION.tar.gz --strip 1 \
    ) &&\
    ( \
        rm -Rf /root/src /root/dist \
    )

RUN mkdir -p /witness_node_data_dir &&\
    touch /witness_node_data_dir/.default_dir

ADD config.ini /root/src/config.ini.sample
ADD run-steemd.sh /usr/local/bin

EXPOSE 2001 8090

VOLUME ["/witness_node_data_dir"]

CMD ["/usr/local/bin/run-steemd.sh"]
