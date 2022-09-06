#!/usr/bin/env bash

# Console color constants
COLOR_CLEAR='\033[0m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_BLACK='\033[0;30m'
BG_WHITE='\033[47;30m'

# Build docker image
docker build -t test-node-init .

# Run newly built docker image as a container.
# If script is callsed with `with-init` argument then boot up `tini`.
if [ "$1" == "with-init" ]; then
  CONTAINER_ID=$(docker run -d --init test-node-init)
else
  CONTAINER_ID=$(docker run -d test-node-init)
fi

# Print out the process table right after starting the container.
printf "\n${BG_WHITE}Currently running processes (before kills):${COLOR_CLEAR}\n"
docker exec -it $CONTAINER_ID ps -eaf -w 10000

# Kill the process that runs `child.js`.
CHILD_PID=$(docker exec -it $CONTAINER_ID ps -eaf -w 10000 | grep /child.js | awk '{print $2}')
docker exec -it $CONTAINER_ID kill -9 $CHILD_PID
printf "\n${BG_WHITE}Killed child process${COLOR_CLEAR}\n"

# Print out the process table right after killing the child process.
printf "\n${BG_WHITE}Currently running processes (after killing child):${COLOR_CLEAR}\n"
docker exec -it $CONTAINER_ID ps -eaf -w 10000

# Kill the process that runs `sub-child.js`.
# It should become a zombie process because the parent has been terminated.
SUB_CHILD_PID=$(docker exec -it $CONTAINER_ID ps -eaf -w 10000 | grep /sub-child.js | awk '{print $2}')
docker exec -it $CONTAINER_ID kill -9 $SUB_CHILD_PID
printf "\n${BG_WHITE}Killed sub-child process${COLOR_CLEAR}\n"

# Print out the process table right after killing the sub-child process.
# Sub-child process is a zombie process at this point if container is running without an init system.
printf "\n${BG_WHITE}Currently running processes (after killing sub-child):${COLOR_CLEAR}\n"
docker exec -it $CONTAINER_ID ps -eaf -w 10000

# Count and print out the count of zombie processes.
ZOMBIE_PROCESS_COUNT=$(docker exec -it $CONTAINER_ID ps -eaf -w 10000 | awk '$7=="Z"' | wc -l)
if [ $ZOMBIE_PROCESS_COUNT != 0 ]; then
  printf "\n${COLOR_RED}Found $ZOMBIE_PROCESS_COUNT zombie processes${COLOR_CLEAR}!\n"
else
  printf "\n${COLOR_GREEN}No zombie processes!${COLOR_CLEAR}\n"
fi

docker stop $CONTAINER_ID > /dev/null
docker rm $CONTAINER_ID > /dev/null
