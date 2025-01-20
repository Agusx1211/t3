#!/bin/bash

# Default values
filename="$(date +%s%3N).tmp"  # Unix timestamp in milliseconds + .tmp extension
delay=30
lock_mode=false
unsafe_mode=false
verbose_mode=false
hash_algorithm="sha256sum"

help_message="
Usage: t3 [OPTIONS]

Options:
    -h, --help           Show this help message and exit.
    -n <name>, --name=<name>
                         Specify a custom filename (default: <unix_timestamp>.tmp).
    -s <seconds>, --seconds=<seconds>
                         Set the delay before deletion (default: 30).
    -l, --lock           Lock mode: wait for the delay in the foreground
                         without spawning a background process.
    -u, --unsafe         Disable safety checks and delete file regardless of changes.
                         Also bypasses existing file check.
    -v, --verbose        Enable verbose logging to display detailed information.

The script saves piped input to a file and automatically deletes it after
the specified delay. When called with --lock, it waits in the foreground instead
of immediately exiting. The --unsafe option bypasses SHA-based safety checks.
"

# Function to log messages with timestamps and verbosity level
log_message() {
    local level="$1"
    local message="$2"
    if [ "$verbose_mode" = true ]; then
        local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        echo -e "\n[$timestamp] [$level]: $message"
    fi
}

# Parse arguments
while [[ "$1" != "" ]]; do
    case $1 in
        -h | --help)
            echo "$help_message"
            exit 0
            ;;
        -n | --name)
            filename="$2"
            shift
            ;;
        -s | --seconds)
            delay="$2"
            shift
            ;;
        -l | --lock)
            lock_mode=true
            ;;
        -u | --unsafe)
            unsafe_mode=true
            ;;
        -v | --verbose)
            verbose_mode=true
            ;;
        *)
            echo "Invalid option: $1" >&2
            echo "$help_message" >&2
            exit 1
            ;;
    esac
    shift
done

# Check for piped input
if [ -t 0 ]; then
    echo "Error: No piped input detected." >&2
    echo "Usage: your_command | t3" >&2
    exit 1
fi

log_message "INFO" "Starting script with the following parameters:"
log_message "INFO" "- Filename: $filename"
log_message "INFO" "- Delay: $delay seconds"
log_message "INFO" "- Lock mode: $lock_mode"
log_message "INFO" "- Unsafe mode: $unsafe_mode"
log_message "INFO" "- Verbose mode: $verbose_mode"

# Check if file exists (unless in unsafe mode)
if [ -e "$filename" ] && [ "$unsafe_mode" = false ]; then
    log_message "ERROR" "File '$filename' already exists. Aborting."
    echo "Error: File '$filename' already exists." >&2
    exit 1
fi

# Function to compute file hash
compute_hash() {
    local file_path="$1"
    $hash_algorithm < "$file_path" | awk '{print $1}'
}

# Create the file with piped content and compute initial SHA
cat > "$filename"
initial_hash=$(compute_hash "$filename")

log_message "INFO" "File '$filename' created successfully."
log_message "INFO" "Initial hash: $initial_hash"

if [ "$unsafe_mode" = true ]; then
    log_message "WARNING" "Unsafe mode is enabled. Safety checks are bypassed."
    delete_file() {
        log_message "INFO" "Deleting file '$filename' without safety check."
        rm -f "$filename"
    }
else
    # Safety check: verify hash before deletion
    delete_file() {
        current_hash=$(compute_hash "$filename")
        if [ "$current_hash" == "$initial_hash" ]; then
            log_message "INFO" "Hash matches. Deleting file '$filename'."
            rm -f "$filename"
        else
            log_message "WARNING" "File '$filename' has been modified; not deleting."
        fi
    }
fi

if [ "$lock_mode" = true ]; then
    # Lock mode: wait and delete in foreground
    log_message "INFO" "Running in lock mode. Sleeping for $delay seconds..."
    sleep "$delay"
    delete_file
else
    # Start background deletion process
    (log_message "INFO" "Starting background process with PID $$."
    log_message "INFO" "Sleeping for $delay seconds..."
    sleep "$delay"
    delete_file) &
fi

# Return success immediately
exit 0
