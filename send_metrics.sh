#!/bin/bash

# CPU usage = 100 - idle
get_cpu_usage() {
}

# RAM used in MB
get_ram_used() {
}

# Total RAM in MB
get_ram_total() {
}

# MEMORY_USAGE = used / total * 100 (integer math only)
get_memory_usage_percent() {

}

# Count tasks
get_task_count() {
}

# CPU core count
get_cpu_cores() {
}

# Disk total MB
get_disk_total() {
}

# Disk free MB
get_disk_free() {
}

# DISK_FREE % = free / total * 100
get_disk_free_percent() {
}


########################################
# Send Metrics via OTLP/JSON
########################################
send_metrics() {

    local AUTH="Basic MTQzOTY4NDpnbGNfZXlKdklqb2lNVFU1TURneE5TSXNJbTRpT2lKemRHRmpheTB4TkRNNU5qZzBMV2x1ZEdWbmNtRjBhVzl1TFhSbGMzUWlMQ0pySWpvaWJ6a3lSbFl6ZDBRMk5XWmtOM281TjJNNVNtbDVjVFJHSWl3aWJTSTZleUp5SWpvaWNISnZaQzFsZFMxM1pYTjBMVElpZlgwPQ=="
    local ENDPOINT="https://otlp-gateway-prod-eu-west-2.grafana.net/otlp/v1/metrics"

    local CPU_USAGE=$(get_cpu_usage)
    local MEMORY_USAGE=$(get_ram_used)
    local TASKS=$(get_task_count)
    local CORES=$(get_cpu_cores)
    local DISK_FREE=$(get_disk_free)
    local DISK_FREE_PERCENT=$(get_disk_free_percent)

    TIMESTAMP=$(($(date +%s%N)))
    HOST=$HOSTNAME

    echo "CPU_USAGE: $CPU_USAGE"
    echo "MEMORY_USAGE: $MEMORY_USAGE"
    echo "TASKS: $TASKS"
    echo "CORES: $CORES"
    echo "DISK_FREE: $DISK_FREE"
    echo "DISK_FREE_%: $DISK_FREE_PERCENT"
    echo "HOST: $HOST"


    JSON_DATA=$(cat <<EOF
{
  "resourceMetrics": [{
    "scopeMetrics": [{
      "metrics": [
        {
          "name": "cpu_usage",
          "unit": "percent",
          "gauge": {
            "dataPoints": [{
              "asDouble": $CPU_USAGE,
              "timeUnixNano": $TIMESTAMP,
              "attributes": [{ "key": "host", "value": {"stringValue": "$HOST"} }]
            }]
          }
        },
        {
          "name": "memory_used",
          "unit": "MB",
          "gauge": {
            "dataPoints": [{
              "asDouble": $MEMORY_USAGE,
              "timeUnixNano": $TIMESTAMP,
              "attributes": [{ "key": "host", "value": {"stringValue": "$HOST"} }]
            }]
          }
        },
        {
          "name": "tasks_running",
          "unit": "count",
          "gauge": {
            "dataPoints": [{
              "asDouble": $TASKS,
              "timeUnixNano": $TIMESTAMP,
              "attributes": [{ "key": "host", "value": {"stringValue": "$HOST"} }]
            }]
          }
        },
        {
          "name": "cpu_cores",
          "unit": "count",
          "gauge": {
            "dataPoints": [{
              "asDouble": $CORES,
              "timeUnixNano": $TIMESTAMP,
              "attributes": [{ "key": "host", "value": {"stringValue": "$HOST"} }]
            }]
          }
        },
        {
          "name": "disk_free",
          "unit": "MB",
          "gauge": {
            "dataPoints": [{
              "asDouble": $DISK_FREE,
              "timeUnixNano": $TIMESTAMP,
              "attributes": [{ "key": "host", "value": {"stringValue": "$HOST"} }]
            }]
          }
        },
        {
          "name": "disk_free",
          "unit": "percent",
          "gauge": {
            "dataPoints": [{
              "asDouble": $DISK_FREE_PERCENT,
              "timeUnixNano": $TIMESTAMP,
              "attributes": [{ "key": "host", "value": {"stringValue": "$HOST"} }]
            }]
          }
        }
      ]
    }]
  }]
}
EOF
)

    curl --location "$ENDPOINT" \
      --header 'Content-Type: application/json' \
      --header "Authorization: $AUTH" \
      --data "$JSON_DATA"
}

########################################
# RUN
########################################

while true
do
  send_metrics
  sleep 60
done
