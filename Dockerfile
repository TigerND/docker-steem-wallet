
FROM teego/steem-base:0.2-Ubuntu-trusty

MAINTAINER Aleksandr Zykov <tiger@mano.email>

ENV DEBIAN_FRONTEND="noninteractive"

ENV STEEMD_ARGS="--p2p-endpoint 0.0.0.0:2001 --rpc-endpoint 0.0.0.0:8090"

RUN cho "Boost library" &&\
    mkdir -p /root/tmp && \
    ( \
        cd /root/tmp; \
        wget -O boost_1_60_0.tar.gz \
            http://sourceforge.net/projects/boost/files/boost/1.60.0/boost_1_60_0.tar.gz/download &&\
        tar xfz boost_1_60_0.tar.gz &&\
        ( \
          cd boost_1_60_0; \
          ( \
            ./bootstrap.sh --prefix=/usr &&\
            ./b2 install \
          ) \
        ) \
    ) && \
    ( \
        cd /root/tmp; \
        rm -Rf boost_1_60_0 boost_1_60_0.tar.gz \
    )

RUN mkdir -p /root/src && \
    ( \
        git clone https://github.com/steemit/steem.git steem &&\
        cd steem ;\
        ( \
            git checkout v0.12.2 &&\
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

ADD config.ini.sample /root/src
ADD run-steemd.sh /usr/local/bin

EXPOSE 2001 8090

VOLUME ["/witness_node_data_dir"]

CMD ["/usr/local/bin/run-steemd.sh"]
