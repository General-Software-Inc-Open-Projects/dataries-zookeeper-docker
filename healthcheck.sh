#!/bin/bash

zoo_status=$(zkServer.sh status | grep -o Error | wc -l)

if [[ $zoo_status -eq 0 ]]; then
    exit 0
else
    exit 1
fi
