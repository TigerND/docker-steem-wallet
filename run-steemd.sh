#!/bin/bash

if [[ -f /witness_node_data_dir/.default_dir ]]; then
    echo "Volumes are not configured."
    exit 1
fi

if [[ ! -f /witness_node_data_dir/config.ini ]]; then
    cp /root/src/config.ini.sample /witness_node_data_dir/config.ini
    echo "Sample config file is copied to your data dir."
fi

/usr/local/bin/steemd --p2p-endpoint 0.0.0.0:2001 --rpc-endpoint 0.0.0.0:8090 ${STEEMD_ARGS} $*

if [[ $? -ne 0 ]]; then
    echo "Exited with error"
    exit 1
else
    echo "Exited normally"
fi
