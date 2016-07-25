#!/bin/bash

if [[ -f /witness_node_data_dir/.default_dir ]]; then
    echo "Volumes are not configured."
    exit 1
fi

if [[ ! -f /witness_node_data_dir/config.ini ]]; then
    cp /root/src/config.ini.sample /witness_node_data_dir/config.ini
    echo "Sample config file is copied to your data dir."
    exit 0
fi

/usr/local/bin/steemd --rpc-endpoint ${STEEMD_ARGS} $*

if [[ $? -ne 0 ]]; then
    exit 1
fi
