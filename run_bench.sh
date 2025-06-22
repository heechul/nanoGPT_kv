#!/bin/bash

# Define the models and devices
models=("gpt2" "gpt2-medium" "gpt2-large" "gpt2-xl") # Pre-trained models to test
devices=("cuda" "cpu") # "mps" "xpu" "hpu" can be added if supported
dtypes=("float32" "float16" "bfloat16") # Define the data types to test

for dtype in "${dtypes[@]}"; do
    for device in "${devices[@]}"; do
        echo -e "\ndevice: ${device}, dtype: ${dtype}"
        echo -e "Model, Base, +KV "
        for model in "${models[@]}"; do
            echo -n "${model}, "
            for kv_cache in False True; do
                file="${model}_${device}_${dtype}_kv_${kv_cache}_output.txt"
                # Run the Python script with the specified parameters
                python sample.py --init_from="${model}" --kv_cache="${kv_cache}" --max_new_tokens=500 --device="${device}" --dtype="${dtype}" > "${file}"
                # Extract the average tokens per second from the output file
                if [[ ! -f "${file}" ]]; then
                    echo "Error: Output file ${file} not found!"
                    continue
                fi
                tops="$(grep 'Average tokens per second:' "${file}" | awk '{ print $5 }')"
                echo -n "${tops}, "
            done
            echo ""  # New line after each model
        done
    done
done

echo -e "\nAll sampling runs complete!"