#!/bin/bash

if [[ -f /witness_node_data_dir/.default_dir ]]; then
    echo "WARN: Volumes are not configured." 1>&2
fi

if [[ ! -f /witness_node_data_dir/config.ini ]]; then
    cp $FILESROOT/config.ini.sample /witness_node_data_dir/config.ini
    echo "INFO: Sample config file is copied to your data dir."
fi

${STEEMD_EXEC} ${STEEMD_ARGS} $*

if [[ $? -ne 0 ]]; then
    echo "FAIL: Exited with errors" 1>&2
    exit 1
else
    echo "INFO: Exited normally"
fi
