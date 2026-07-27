#!/bin/bash

### The rustfs is deployed to accomodate S3 storage that is needed by Thanos to store the metric data block. 

WORKING_DIR=/home/gerald/rustfs

# Create data and logs directories
mkdir -p $WORKING_DIR/data $WORKING_DIR/logs

# Run the container (podman will automatically set the folders ownership)
podman run --replace --name rustfs -d -p 9000:9000 -p 9001:9001 \
    -e RUSTFS_ACCESS_KEY="gpmrustfs" \
    -e RUSTFS_SECRET_KEY="0255ec0a-72ee-448c-8823-2c652fc11a13" \
    -v ${WORKING_DIR}/data:/data:Z,U -v ${WORKING_DIR}/logs:/logs:Z,U rustfs/rustfs:latest