#!/bin/bash

# 设置基础环境变量
export OPENAI_API_KEY="sk-1234"
export OPENAI_BASE_URL="http://10.150.240.117:38888"
export CHAT_MODEL="gpt-4o"

# 设置 MLE-bench 所需的环境变量
export SUBMISSION_DIR="/home/submission"
export LOGS_DIR="/home/logs"
export CODE_DIR="/home/code"
export AGENT_DIR="/home/agent"

# 确保使用正确的 conda 环境
CONDA_BASE=$(conda info --base)
source $CONDA_BASE/etc/profile.d/conda.sh
conda activate mle

# 检查 Docker 镜像是否存在，如果不存在则构建
if ! docker images | grep -q "^mlebench-env "; then
    echo "Building mlebench-env image..."
    docker build --network=host --platform=linux/amd64 -t mlebench-env -f environment/Dockerfile .
fi

if ! docker images | grep -q "^aide "; then
    echo "Building aide image..."
    docker build --network=host --platform=linux/amd64 -t aide agents/aide/ \
        --build-arg SUBMISSION_DIR=$SUBMISSION_DIR \
        --build-arg LOGS_DIR=$LOGS_DIR \
        --build-arg CODE_DIR=$CODE_DIR \
        --build-arg AGENT_DIR=$AGENT_DIR
fi

# 创建运行时间戳目录
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_DIR="logs/${TIMESTAMP}"
mkdir -p $LOG_DIR

# 运行 agent（保留容器）
echo "Starting agent with retain flag..."
nohup /home/$(whoami)/miniconda3/envs/mle/bin/python /home/$(whoami)/mle-bench-aide/run_agent.py \
    --agent-id=aide \
    --n-workers=1 \
    --competition-set=experiments/exp1.txt \
    --retain \
    > "${LOG_DIR}/run.log" 2>&1 &

# 保存进程ID
echo $! > "${LOG_DIR}/pid.txt"

echo "Agent started with PID $(cat ${LOG_DIR}/pid.txt)"
echo "Logs are being written to ${LOG_DIR}/run.log"
echo "To monitor logs: tail -f ${LOG_DIR}/run.log"
echo "To stop the agent: kill $(cat ${LOG_DIR}/pid.txt)"