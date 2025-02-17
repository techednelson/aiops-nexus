#!/bin/bash

urls=(
    "http://localhost:8080/unhealthy-app/product/1024"
    "http://localhost:8080/unhealthy-app/checkout?order_id=100005&payment_method=bitcoin"
    "http://localhost:8080/unhealthy-app/checkout?order_id=100005&payment_method=paypal"
    "http://localhost:8080/unhealthy-app/fulfill-order?order_id=100005"
)
# port 8080 is set to hit unhealthy-app inside virtualbox if you run the app with python 
# from the CLI or the Containired app directly, change 8080 to 5001

# Get the current timestamp
start_time=$(date +%s)

# Run the loop for 5 minutes (300 seconds)
while [ $(($(date +%s) - $start_time)) -lt 300 ]; do
    for url in "${urls[@]}"; do
        echo "Hitting URL: $url"
        curl -s -w "\nHTTP status: %{http_code}\n" $url  # Waits for server response, showing the HTTP status
    done
done

echo "Completed 5 minutes of hitting the URLs."
