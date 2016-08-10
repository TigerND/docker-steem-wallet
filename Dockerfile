FROM teego/steem-base:0.2-Ubuntu-trusty

MAINTAINER Aleksandr Zykov <tiger@mano.email>

ENV DEBIAN_FRONTEND="noninteractive"

ENV STEEMD_ARGS="--p2p-endpoint 0.0.0.0:2001 --rpc-endpoint 0.0.0.0:8090"

ENV BOOST_VERSION 1.60.0

RUN echo "Boost library" &&\
    mkdir -p /root/tmp && \
    ( \
        cd /root/tmp; \
        wget -O boost_`echo $BOOST_VERSION | sed 's/\./_/g'`.tar.gz \
            http://sourceforge.net/projects/boost/files/boost/$BOOST_VERSION/boost_`echo $BOOST_VERSION | sed 's/\./_/g'`.tar.gz/download &&\
        tar xfz boost_`echo $BOOST_VERSION | sed 's/\./_/g'`.tar.gz &&\
        ( \
          cd boost_`echo $BOOST_VERSION | sed 's/\./_/g'`; \
          ( \
            ./bootstrap.sh --prefix=/usr &&\
            ./b2 install \
          ) \
        ) \
    ) && \
    ( \
        cd /root/tmp; \
        rm -Rf boost_`echo $BOOST_VERSION | sed 's/\./_/g'` boost_`echo $BOOST_VERSION | sed 's/\./_/g'`.tar.gz \
    )

ENV STEEM_VERSION 0.12.3

RUN mkdir -p /root/src && \
    ( \
        git clone https://github.com/steemit/steem.git steem &&\
        cd steem ;\
        ( \
            git checkout v$STEEM_VERSION &&\
            git submodule update --init --recursive &&\
            cmake \
                -DCMAKE_BUILD_TYPE=Release \
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
