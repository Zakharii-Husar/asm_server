#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default settings
DEBUG_MODE=false
SHOULD_RUN=false
DOCKER_BUILD=false
DOCKER_RUN=false
DOCKER_BACKGROUND=false
SHOULD_COMPILE=false

# Function to display usage
show_help() {
    echo -e "${YELLOW}Usage:${NC}"
    echo "  ./script.sh [commands]"
    echo
    echo -e "${YELLOW}Commands:${NC}"
    echo "  compile                    - Compile the server"
    echo "  compile run                - Compile and run the server"
    echo "  compile debug              - Compile with debug symbols"
    echo "  compile debug run          - Compile with debug symbols and run"
    echo "  compile docker build       - Compile and build Docker image"
    echo "  compile docker run         - Compile, build Docker image and run container"
    echo "  compile docker run -d      - Compile and run Docker container in background"
    echo "  compile docker build run   - Compile, build Docker image and run container"
    echo "  compile docker build run -d - Compile, build Docker image and run container in background"
    echo "  docker stop                - Stop and remove the running container"
    echo
    echo -e "${YELLOW}Examples:${NC}"
    echo "  ./script.sh compile"
    echo "  ./script.sh compile debug run"
    echo "  ./script.sh compile docker build run"
    echo "  ./script.sh compile docker run -d"
    echo "  ./script.sh docker stop"
    exit 1
}

# Function to compile the server
compile_server() {
    echo -e "${YELLOW}Compiling server...${NC}"
    
    local debug_flags=""
    if [ "$DEBUG_MODE" = true ]; then
        debug_flags="-g"
    fi

    if as $debug_flags -o "asm_server.o" "src/main.s" &&
       ld $debug_flags -o "asm_server" "asm_server.o"; then
        if [ "$DEBUG_MODE" = true ]; then
            echo -e "${GREEN}✓ Compilation successful (with debug symbols)${NC}"
        else
            echo -e "${GREEN}✓ Compilation successful${NC}"
        fi
        
        # Clean up object file
        if [ -f "asm_server.o" ]; then
            rm asm_server.o || echo -e "${YELLOW}Warning: Failed to remove asm_server.o${NC}"
        fi
        return 0
    else
        echo -e "${RED}✗ Compilation failed${NC}"
        return 1
    fi
}

# Function to run the server
run_server() {
    echo -e "${YELLOW}Starting server...${NC}"
    if [ -f "./asm_server" ]; then
        ./asm_server
    else
        echo -e "${RED}Error: Server binary not found${NC}"
        exit 1
    fi
}

# Function to handle Docker operations
handle_docker() {
    if [ "$DOCKER_BUILD" = true ]; then
        echo -e "${YELLOW}Building Docker image...${NC}"
        if docker build -t asm-server .; then
            echo -e "${GREEN}✓ Docker image built successfully${NC}"
        else
            echo -e "${RED}✗ Docker build failed${NC}"
            exit 1
        fi
    fi

    if [ "$DOCKER_RUN" = true ]; then
        echo -e "${YELLOW}Running Docker container...${NC}"
        if [ "$DOCKER_BUILD" = false ]; then
            # Check if image exists when we're only running
            if ! docker image inspect asm-server >/dev/null 2>&1; then
                echo -e "${RED}Error: Docker image 'asm-server' not found. Build it first with 'compile docker build'${NC}"
                exit 1
            fi
        fi
        
        if [ "$DOCKER_BACKGROUND" = true ]; then
            docker run -d -p 8081:8081 --name asm-server-instance asm-server
            echo -e "${GREEN}✓ Docker container started in background${NC}"
        else
            docker run -p 8081:8081 --name asm-server-instance asm-server
        fi
    fi
}

# Function to stop Docker container
stop_docker() {
    echo -e "${YELLOW}Stopping Docker container...${NC}"
    if docker stop asm-server-instance >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Docker container stopped${NC}"
    else
        echo -e "${YELLOW}No container was running${NC}"
    fi
    
    echo -e "${YELLOW}Removing Docker container...${NC}"
    if docker rm asm-server-instance >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Docker container removed${NC}"
    else
        echo -e "${YELLOW}No container to remove${NC}"
    fi
}

# Parse arguments
if [ $# -eq 0 ]; then
    show_help
fi

# Process all arguments
while [ "$1" != "" ]; do
    case $1 in
        compile )    SHOULD_COMPILE=true
                    ;;
        debug )      DEBUG_MODE=true
                    ;;
        run )        SHOULD_RUN=true
                    ;;
        -d )        DOCKER_BACKGROUND=true
                    ;;
        docker )     shift
                    case $1 in
                        build )     DOCKER_BUILD=true
                                   shift
                                   if [ "$1" = "run" ]; then
                                       DOCKER_RUN=true
                                       shift
                                       if [ "$1" = "-d" ]; then
                                           DOCKER_BACKGROUND=true
                                       fi
                                   fi
                                   ;;
                        run )       DOCKER_RUN=true
                                   shift
                                   if [ "$1" = "-d" ]; then
                                       DOCKER_BACKGROUND=true
                                   fi
                                   ;;
                        stop )      stop_docker
                                   exit 0
                                   ;;
                        * )         show_help
                                   ;;
                    esac
                    ;;
        -h | --help )  show_help
                      ;;
        * )           show_help
                      ;;
    esac
    shift
done

# Execute commands in the correct order
if [ "$SHOULD_COMPILE" = true ]; then
    compile_server || exit 1
fi

if [ "$DOCKER_BUILD" = true ] || [ "$DOCKER_RUN" = true ]; then
    handle_docker
elif [ "$SHOULD_RUN" = true ]; then
    run_server
fi

exit 0
