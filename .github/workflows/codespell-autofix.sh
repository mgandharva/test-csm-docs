#!/bin/bash
script_dir=$(dirname "$(readlink -f "$0")")
echo "Script dir: $script_dir"
# Run codespell and capture output
output=$(find ../.. -type f -name "*.md" -exec codespell --ignore-words="$script_dir"/codespell.txt --builtin clear,rare,informal --write-changes --quiet-level=0 {} +)

echo "Output: $output"

# Process the output and apply the first suggestion
echo "$output" | while read -r line; do
    if [[ $line == *"=="* ]]; then
        file=$(echo "$line" | cut -d':' -f1)
        error_line=$(echo "$line" | cut -d':' -f2)
        original=$(echo "$line" | awk -F ' ' '{print $2}')
        suggestion=$(echo "$line" | grep -oP '(?<= ==>)\s\K[^,]*')
        
        # Apply the first suggestion
        if [ -n "$suggestion" ] && [ -f "$file" ]; then
            sed -i "${error_line}s/$original/$suggestion/" "$file"
            echo "Fixed $original to $suggestion in $file on line $error_line"
        fi
    fi
done