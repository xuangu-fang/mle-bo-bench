#!/bin/bash
sudo apt install git-lfs

git lfs fetch --all
git lfs pull

conda create -n mle python=3.11.10
conda activate mle

mkdir .kaggle
cd .kaggle
echo '{"username":"xxx","key":"xxx"}' > kaggle.json

cd ../mle-bench-aide

pip install -e .

mlebench prepare --all

export SUBMISSION_DIR="/home/submission"
export LOGS_DIR="/home/logs"
export CODE_DIR="/home/code"
export AGENT_DIR="/home/agent"

docker build --network=host --platform=linux/amd64 -t mlebench-env -f environment/Dockerfile .
docker build --platform=linux/amd64 -t aide agents/aide/ --build-arg SUBMISSION_DIR=$SUBMISSION_DIR --build-arg LOGS_DIR=$LOGS_DIR --build-arg CODE_DIR=$CODE_DIR --build-arg AGENT_DIR=$AGENT_DIR

export AZURE_OPENAI_ENDPOINT="xxx"
export OPENAI_API_VERSION="xxx"
export CHAT_MODEL="xxx"
export AZURE_OPENAI_AD_TOKEN="xxx"

export MLE_BENCH_ABSOLUTE_PATH="xxxx"

nohup /home/$(whoami)/miniconda3/envs/mle/bin/python /home/$(whoami)/mle-bench-aide/run_agent.py \
    --agent-id=aide \
    --n-workers=1 \
    --competition-set=experiments/exp1.txt
