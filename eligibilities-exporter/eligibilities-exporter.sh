#!/bin/bash

# array of nodes to be queried
readonly NODES=(
    "smh-node-01|127.0.0.1:9093"
    "smh-node-02|127.0.0.1:9093"
)

# Fetch JSON data from multiple sources using curl and append to a single variable
echo "starting read of eligibilities..."
json_input=""
for NODE in "${NODES[@]}"; do
    IFS='|' read -r NAME IP_PORT <<< "$NODE"
    echo "reading $NAME eligibilities from $IP_PORT..."
    json_input+=$(docker exec "$NAME" bash -c "grpcurl -plaintext -d {} -max-time 10 $IP_PORT spacemesh.v1.AdminService.EventsStream")
done
echo "finished read of eligibilities..."

# Process each JSON object individually with multiple jq commands
filtered_json=$(echo "$json_input" | jq -s '
  # Read the entire input as a single JSON array
  [
    .[] | select(.eligibilities)                                            # Filter objects with the "eligibilities" key
  ] | group_by(.eligibilities.epoch)                                        # Group by the "epoch" value
  | map({
      epoch: .[0].eligibilities.epoch,                                      # Extract the "epoch" value
      layers: (map(.eligibilities.eligibilities[].layer) | sort),           # Extract and sort the "layers" array in ascending order
      layer_count: (map(.eligibilities.eligibilities[].layer) | length),    # Correctly count the number of layers
      smeshers: (map(.eligibilities.smesher) | unique)                      # Capture unique smeshers
    })
  | sort_by(.epoch) | reverse                                               # Sort by "epoch" in descending order
  | {eligibilities: .}                                                      # Encompass all in an "eligibilities" key
')

# Write the epoch with the highest value to a JSON file
highest_epoch=$(echo "$filtered_json" | jq -c '.eligibilities[0]')
epoch=$(echo "$highest_epoch" | jq -r '.epoch')
echo "$highest_epoch" | jq '.' > "eligibilities_epoch${epoch}.json"

# Echo the JSON written to the file
cat "eligibilities_epoch${epoch}.json"
