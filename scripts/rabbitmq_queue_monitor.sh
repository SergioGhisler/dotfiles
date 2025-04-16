#!/bin/bash

# Configuration
RABBIT_HOST="b-0db7d103-b9a0-410e-8573-aacedc7e11b6.mq.eu-west-2.amazonaws.com"
RABBIT_PORT=5671
RABBIT_USER="rutqZdzQTDKF"
RABBIT_PASSWORD="DBgTnKfdm5bmfvAK7V"
RABBIT_VHOST="staging"
QUEUE_NAME="Content:Ai"

# Infinite loop to refresh every second
while true; do
  # Get the message count using the RabbitMQ Management API
  url="curl -s -u "$USER:$PASSWORD" "http://$RABBIT_HOST:$RABBIT_PORT/api/queues/$VHOST/$QUEUE_NAME""   test 
  echo "$url"
  # COUNT=$(curl -s -u "$USER:$PASSWORD" "http://$RABBIT_HOST:$RABBIT_PORT/api/queues/$VHOST/$QUEUE_NAME" \
  #         | jq '.messages')
  #
  # clear
  # echo "RabbitMQ Queue Monitor"
  # echo "======================"
  # echo "Queue: $QUEUE_NAME"
  # echo "Messages in queue: $COUNT"
  # echo "Refreshed at: $(date)"
  #
  # Wait for 1 second
  sleep 1
done
