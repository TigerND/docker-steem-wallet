#!/bin/bash

if [[ -f /witness_node_data_dir/.default_dir ]]; then
    echo "Volumes are not configured."
    exit 1
fi

/usr/local/bin/steemd $*

if [[ $? -ne 0 ]]; then
    exit 1
fi
