#!/bin/bash

# Check if input file is provided via command line argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file="$1"
input_filename=$(basename "$input_file" .m4a)

# Log file for silence detection results
silence_log="silence_log.txt"

# Minimum duration for valid segments
min_duration=30

silence_level="-30dB"
silence_duration_sec="0.5"

if command -v ggrep >/dev/null 2>&1; then
    GREP_COMMAND="ggrep"
else
    GREP_COMMAND="grep"
fi

# Detect silence and store the result in the log file
ffmpeg -i "$input_file" -af silencedetect=noise=$silence_level:d=$silence_duration_sec -f null - 2> "$silence_log"

# Initialize variables
start_time=0
index=1
output_files=()

# Helper function to calculate duration
calculate_duration() {
    start=$1
    end=$2
    echo | awk -v start="$start" -v end="$end" '{printf "%.0f", end - start}'
}

# Process the silence detection log and split the audio
while read -r line; do
    if [[ $line == *"silence_start:"* ]]; then
        # Get the start time of the silence
        silence_start=$(echo $line | $GREP_COMMAND -oP 'silence_start: \K[0-9.]+')

        # Calculate the duration of the segment
        duration=$(calculate_duration "$start_time" "$silence_start")

        # Only split if the duration is greater than the minimum duration (60 seconds)
        if (( duration >= min_duration )); then
            # Create output filename with zero-padded index (e.g., test001.m4a)
            output_file=$(printf "%s_%03d.m4a" "$input_filename" "$index")

            # Split the audio file up to the silence start time
            ffmpeg -i "$input_file" -ss "$start_time" -to "$silence_start" -c copy "$output_file"
            echo "Output: $output_file (Start: $start_time, End: $silence_start, Duration: $duration seconds)"

            # Update the index for the next segment
            index=$((index + 1))
        else
            echo "Skipping segment from $start_time to $silence_start (Duration: $duration seconds, too short)"
        fi

        # Update the start time for the next segment
        start_time=$silence_start
    elif [[ $line == *"silence_end:"* ]]; then
        # Get the end time of the silence
        silence_end=$(echo $line | $GREP_COMMAND -oP 'silence_end: \K[0-9.]+')
        start_time=$silence_end  # Set the start time after the silence ends
    fi
done < "$silence_log"

# Process the last segment until the end of the file
# Get the total duration of the audio file using ffprobe
total_duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input_file")
last_segment_duration=$(calculate_duration "$start_time" "$total_duration")

# Only split the last segment if its duration is greater than the minimum duration (60 seconds)
if (( last_segment_duration >= min_duration )); then
    output_file=$(printf "%s_%03d.m4a" "$input_filename" "$index")
    if [ -z "$start_time" ]; then
      start_time=0
    fi
    ffmpeg -i "$input_file" -ss "$start_time" -c copy "$output_file"
    echo "Output: $output_file (Start: $start_time, End: End of File, Duration: $last_segment_duration seconds)"
else
    echo "Skipping last segment from $start_time to End of File (Duration: $last_segment_duration seconds, too short)"
fi
