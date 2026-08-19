#!/bin/sh
# Fake pinact: simulates pinact behavior for testing
case "$1" in
  -v|--version)
    echo "pinact version 0.0.0-fake"
    exit 0
    ;;
  run)
    echo "pinact run: no changes needed"
    exit 0
    ;;
  *)
    echo "pinact: unknown command: $1"
    exit 1
    ;;
esac
