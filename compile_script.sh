#!/bin/bash

# Set default debug mode to false
if [ "$1" = "debug_mode" ]; then
    debug_mode=true
else
    debug_mode=false
fi

# Compile with debugging symbols
if as -g -o "server.o" "src/main.s" &&
   ld -g -o "server" "server.o"; then
    if [ "$debug_mode" == "true" ]; then
        echo "✓ Compilation successful (with debug symbols)"
    else
        echo "✓ Compilation successful"
    fi
else
    echo "✗ Compilation failed"
    exit 1
fi

# Clean up the object file (only print message if removal fails)
if [ -f "server.o" ]; then
    rm server.o || echo "Warning: Failed to remove server.o"
fi

exit 0
