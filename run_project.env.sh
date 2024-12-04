#!/bin/bash
git lfs fetch --all
git lfs pull

conda env create -n mle python=3.10
conda activate mle

pip install -e .

mlebench prepare --all

export SUBMISSION_DIR="/home/submission"
export LOGS_DIR="/home/logs"
export CODE_DIR="/home/code"
export AGENT_DIR="/home/agent"

export AZURE_OPENAI_ENDPOINT="xxx"
export OPENAI_API_VERSION="xxx"
export CHAT_MODEL="xxx"
export AZURE_OPENAI_AD_TOKEN="xxx"

export MLE_BENCH_ABSOLUTE_PATH="xxxx"

nohup /home/v-yuanteli/miniconda3/envs/mle/bin/python /data/userdata/v-yuanteli/mle-bench/run_agent.py \
    --agent-id=aide \
    --n-workers=5 \
    --competition-set=experiments/exp1.txt \
