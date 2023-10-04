#!/bin/bash

# Function to calculate network IP address from IP address and subnet mask in CIDR notation
calculate_network_ip() {
    local ip_with_mask="$1"
    IFS='/' read -r -a parts <<< "$ip_with_mask"
    local ip_address="${parts[0]}"
    local cidr="${parts[1]}"

    IFS='.' read -r -a ip_parts <<< "$ip_address"
    local binary_mask=""
    local network_address=""

    # Convert IP address to binary
    for octet in "${ip_parts[@]}"; do
        binary_mask+=$(printf "%08d" "$(echo "obase=2; $octet" | bc)")
    done

    # Calculate network address by applying subnet mask
    binary_mask="${binary_mask:0:$cidr}$(printf "%0.$((32 - $cidr))d" 0)"
    for ((i = 0; i < 32; i += 8)); do
        network_address+=$((2#${binary_mask:$i:8}))
        if [ $i -lt 24 ]; then
            network_address+="."
        fi
    done

    echo "$network_address"
}

# Read input from file and calculate network IP addresses
input_file="IP.txt"
while IFS= read -r line; do
    network_ip=$(calculate_network_ip "$line")
    echo "$line: $network_ip"
done < "$input_file"
