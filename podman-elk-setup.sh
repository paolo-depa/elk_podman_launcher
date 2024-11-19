#!/bin/bash

# This script sets up an Elasticsearch and Kibana environment using Podman.

# Variables:
# PODMAN_NET: The name of the Podman network to be used.
# PODMAN_EL_VOL: The name of the Podman volume for Elasticsearch.
# PODMAN_EL_NAME: The name of the Elasticsearch container.
# PODMAN_KIBANA_NAME: The name of the Kibana container.
# EL_MAXMAP_COUNT: The maximum map count for Elasticsearch.
# EL_VERSION: The version of Elasticsearch and Kibana to be used.

# Steps:
# 1. Check if the specified Podman network exists. If not, create it.
# 2. Check if the specified Podman volume exists. If it does, remove it.
# 3. Check the current maximum map count. If it is less than the required value, update it.
# 4. Run the Elasticsearch container with the specified settings.
# 5. Run the Kibana container with the specified settings.
# 6. Reset the password for the 'elastic' user in Elasticsearch.
# 7. Create an enrollment token for Kibana to connect to Elasticsearch.

PODMAN_NET="elastic"
PODMAN_EL_VOL="es01_vol"
PODMAN_EL_NAME="es01"
PODMAN_KIBANA_NAME="kib01"

EL_MAXMAP_COUNT=262144
EL_VERSION="8.16.0"

if ! podman network exists $PODMAN_NET; then
    podman network create $PODMAN_NET
fi

if ! podman volume exists $PODMAN_EL_VOL; then
    podman volume create $PODMAN_EL_VOL
fi

current_max_map_count=$(sysctl -n vm.max_map_count)
if [ "$current_max_map_count" -lt "$EL_MAXMAP_COUNT" ]; then
    sudo sysctl -w vm.max_map_count=$EL_MAXMAP_COUNT
fi

# Run the Elasticsearch container with a memory limit of 1GB
podman run --name $PODMAN_EL_NAME --net $PODMAN_NET -p 9200:9200 -it -m 1GB docker.elastic.co/elasticsearch/elasticsearch:$EL_VERSION
podman run --name $PODMAN_KIBANA_NAME --net $PODMAN_NET -p 5601:5601 docker.elastic.co/kibana/kibana:$EL_VERSION

podman exec -it $PODMAN_EL_NAME /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
podman exec -it $PODMAN_EL_NAME /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana

