# Podman ELK Setup

This script sets up an Elasticsearch and Kibana environment using Podman.

## Variables

- `PODMAN_NET`: The name of the Podman network to be used.
- `PODMAN_EL_VOL`: The name of the Podman volume for Elasticsearch.
- `PODMAN_EL_NAME`: The name of the Elasticsearch container.
- `PODMAN_KIBANA_NAME`: The name of the Kibana container.
- `EL_MAXMAP_COUNT`: The maximum map count for Elasticsearch.
- `EL_VERSION`: The version of Elasticsearch and Kibana to be used.

## Steps

1. Check if the specified Podman network exists. If not, create it.
2. Check if the specified Podman volume exists. If it does, remove it.
3. Check the current maximum map count. If it is less than the required value, update it.
4. Run the Elasticsearch container with the specified settings.
5. Run the Kibana container with the specified settings.
6. Reset the password for the 'elastic' user in Elasticsearch.
7. Create an enrollment token for Kibana to connect to Elasticsearch.

## Usage

1. Clone the repository.
2. Navigate to the directory containing the script.
3. Make the script executable: