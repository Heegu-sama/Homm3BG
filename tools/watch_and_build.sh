#!/usr/bin/env bash

usage() {
  echo "Usage: $0 [--container]"
  echo "Watch all sections/*.tex files and automatically rebuild when changed."
  echo ""
  echo "Each file gets its own entr process, so editing sections/setup.tex triggers:"
  echo "  tools/build.sh -s setup --args \"-silent\""
  echo ""
  echo "Options:"
  echo "  --container    Run build.sh via ./run.sh container wrapper"
  echo "  --help, -h     Show this help message"
  echo ""
  echo "Example:"
  echo "  $0 --container  # Builds inside container"
  echo ""
  echo "Press Ctrl-C to stop all watchers."
  exit 1
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  usage
fi

CONTAINER=""
[[ "$1" == "--container" ]] && CONTAINER="./run.sh"


for file in sections/*.tex; do
    name=$(basename "$file" .tex)
    echo "$file" | entr -cps "echo 'Detected changes in \"$file\"'; ${CONTAINER} tools/build.sh -s \"$name\" --args \"-silent\"" &
done

echo "Waiting for file changes"
wait
