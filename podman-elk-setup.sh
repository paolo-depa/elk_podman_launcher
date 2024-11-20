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

source podman-elk-setup.conf

if ! podman network exists $PODMAN_NET; then
    echo "Creating network $PODMAN_NET"
    podman network create $PODMAN_NET
fi

if ! podman volume exists $PODMAN_EL_VOL; then
    echo "Creating volume $PODMAN_EL_VOL"
    podman volume create $PODMAN_EL_VOL
fi

current_max_map_count=$(sysctl -n vm.max_map_count)
if [ "$current_max_map_count" -lt "$EL_MAXMAP_COUNT" ]; then
    echo "Updating max_map_count to $EL_MAXMAP_COUNT"
    sudo sysctl -w vm.max_map_count=$EL_MAXMAP_COUNT
fi

# Run the Elasticsearch container with a memory limit of 1GB
containers=$(podman ps -a --format "{{.Names}}")
if echo "$containers" | grep -w $PODMAN_EL_NAME > /dev/null; then
    echo "Removing existing container $PODMAN_EL_NAME"
    podman rm -f $PODMAN_EL_NAME
fi
podman run -d --name $PODMAN_EL_NAME --net $PODMAN_NET -p 9200:9200  -m 1GB docker.elastic.co/elasticsearch/elasticsearch:$EL_VERSION >> /dev/null
echo "Elasticsearch started"

if echo "$containers" | grep -w $PODMAN_KIBANA_NAME > /dev/null; then
    echo "Removing existing container $PODMAN_KIBANA_NAME"
    podman rm -f $PODMAN_KIBANA_NAME
fi
podman run -d --name $PODMAN_KIBANA_NAME --net $PODMAN_NET -p 5601:5601 docker.elastic.co/kibana/kibana:$EL_VERSION >> /dev/null
echo "Kibana started"
echo
echo "Run: podman exec -it $PODMAN_EL_NAME /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic"
echo "Then: podman exec $PODMAN_EL_NAME /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana"
echo "And: podman exec $PODMAN_KIBANA_NAME bin/kibana-verification-code"
echo
echo "Elasticsearch and Kibana are now running. You can access Kibana at http://localhost:5601"

