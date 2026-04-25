#!/bin/bash
set -e

IMAGE="ghcr.io/qwrtln/homm3bg:latest"

# Help message
show_help() {
    echo "Usage: $0 SCRIPT_PATH [ARGUMENTS]"
    echo ""
    echo "Where SCRIPT_PATH is the full path to the script, e.g.:"
    echo "  tools/build.sh"
    echo "  tools/compare_pages.sh"
    echo ""
    echo "Any additional arguments will be passed to the script."
    echo ""
    echo "Example: $0 tools/build.sh pl"
    echo "Example: $0 tools/build.sh -s \"search\""
    echo "Example: $0 tools/compare_pages.sh -l en -r 5-9"
    exit 1
}

if [[ $# -eq 0 ]] || [[ "$1" == "help" ]] || [[ "$1" == "--help" ]]; then
    show_help
fi

SCRIPT_PATH="$1"
shift  # Remove the script path from arguments

# Extract the script name for PDF opening functionality
SCRIPT_NAME=$(basename "$SCRIPT_PATH" .sh)

CONTAINER_ENGINE=""

if command -v podman &>/dev/null; then
    CONTAINER_ENGINE="podman"
elif command -v docker &>/dev/null; then
    CONTAINER_ENGINE="docker"
else
    echo "Error: No container engine found. Please install podman or docker."
    exit 1
fi

temp_output=$(mktemp)
trap 'rm -f "$temp_output"' EXIT

if [[ "$CONTAINER_ENGINE" = "podman" ]]; then
    podman run --rm -v "$(pwd):/data" "$IMAGE" "$SCRIPT_PATH" "$@" | tee "$temp_output"
else
    # For Docker, we also specify the user to avoid permission issues
    docker run --rm -v "$(pwd):/data" --user "$(id -u):$(id -g)" "$IMAGE" "$SCRIPT_PATH" "$@" | tee "$temp_output"
fi

# Open PDF only after build script
if [[ "$SCRIPT_NAME" == "build" ]]; then
    # Determine the open command based on OS
    case "$(uname -s)" in
        Darwin*)    open_cmd="open";;
        Linux*)     open_cmd="xdg-open";;
        MINGW*|MSYS*|CYGWIN*)    open_cmd="start";;
    esac

    # Get the last line of output which should contain the PDF filename
    pdf_file=$(tail -n 1 "$temp_output" | tr -d '[:space:]')
    $open_cmd "$pdf_file" &> /dev/null &
fi
