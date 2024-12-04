#!/bin/bash

while true; do
    export AZURE_OPENAI_AD_TOKEN=$(curl -s -X POST http://localhost:9999)
    sleep 2h
done