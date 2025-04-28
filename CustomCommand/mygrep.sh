#!/bin/bash

# Function to display usage information
display_help() {
    echo "Usage: ./mygrep.sh [OPTIONS] PATTERN FILE"
    echo "Search for PATTERN in FILE and print matching lines."
    echo ""
    echo "Options:"
    echo "  -n         Show line numbers for each match"
    echo "  -v         Invert the match (print lines that do not match)"
    echo "  --help     Display this help message and exit"
    echo ""
    echo "Combinations like -vn or -nv are also supported."
    exit 0
}

# Initialize variables
show_line_numbers=false
invert_match=false
pattern=""
file=""

# Parse command-line options
while [[ "$1" == -* ]]; do
    case "$1" in
        --help)
            display_help
            ;;
        -v*n* | -n*v*)
            # Handle combined options like -vn or -nv
            invert_match=true
            show_line_numbers=true
            ;;
        -v*)
            invert_match=true
            ;;
        -n*)
            show_line_numbers=true
            ;;
        *)
            echo "Error: Unknown option $1" >&2
            display_help
            ;;
    esac
    shift
done

# Check if required arguments are provided
if [ $# -lt 2 ]; then
    echo "Error: Missing required arguments" >&2
    echo "Usage: ./mygrep.sh [OPTIONS] PATTERN FILE" >&2
    exit 1
fi

# Get pattern and file
pattern="$1"
file="$2"

# Check if file exists
if [ ! -f "$file" ]; then
    echo "Error: File '$file' not found" >&2
    exit 1
fi

# Read file line by line
line_number=0
while IFS= read -r line; do
    line_number=$((line_number + 1))
    
    # Case-insensitive pattern matching
    if echo "$line" | grep -qi "$pattern"; then
        match=true
    else
        match=false
    fi
    
    # Apply invert match if needed
    if [ "$invert_match" = true ]; then
        match=$([ "$match" = true ] && echo false || echo true)
    fi
    
    # Print matching line
    if [ "$match" = true ]; then
        if [ "$show_line_numbers" = true ]; then
            echo "$line_number:$line"
        else
            echo "$line"
        fi
    fi
done < "$file"
