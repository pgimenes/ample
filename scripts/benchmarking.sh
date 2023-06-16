#!/bin/bash

# Number of times to run the Python script
num_runs=100

# Array to store elapsed times
elapsed_times=()

# Run the Python script multiple times
for ((i=0; i<num_runs; i++)); do
  echo "Running iteration $((i+1))..."

  # Execute the Python script and capture the output
  output=$($FYP_DIR/scripts/initialize.py --pubmed --gcn --in_features 64 --out_features 64 --cpu --random 2>&1)

  # Extract the elapsed time from the output
  elapsed_time=$(echo "$output" | grep "Elapsed time:" | awk '{print $5}')
  echo "Elapsed time: $elapsed_time"

  # Add the elapsed time to the array
  elapsed_times+=("$elapsed_time")
done

sum=0
for time in "${elapsed_times[@]}"; do
  sum=$(echo "$sum + $time" | bc)
done

avg_time=$(echo "scale=3; $sum / $num_runs" | bc)

# Calculate the standard deviation
sum_squared_diff=0

for time in "${elapsed_times[@]}"; do
  diff=$(echo "$time - $avg_time" | bc)
  squared_diff=$(echo "$diff * $diff" | bc)
  sum_squared_diff=$(echo "$sum_squared_diff + $squared_diff" | bc)
done

std_dev=$(echo "scale=3; sqrt($sum_squared_diff / $num_runs)" | bc)

# Print the results
echo "Average elapsed time: $avg_time ms"
echo "Standard deviation: $std_dev ms"