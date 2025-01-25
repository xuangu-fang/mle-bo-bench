基础说明
官方仓库： (1) mle-bench：https://github.com/openai/mle-bench (2) AIDE：https://github.com/WecoAI/aideml (3) mle-bench下AIDE官方仓库: https://github.com/thesofakillers/aideml

【说明】 (2) 与 (3) 的区别是 OpenAI在AIDE官方仓库上进行了一些调整来嵌入mle-bench这个框架

我们的仓库： （4）mle-bench：https://github.com/WinstonLiyt/mle-bench-aide branch ytli （5）AIDE：https://github.com/WinstonLiyt/aideml_plus

【说明】 (1) 与 (4) and (3) 与 (5) 的区别是 满足了Azure OpenAI 的 API调用；可以基于已经运行结束的trace进一步接上继续跑（一开始设置跑24h，跑完后，可以在原先trace上继续跑24h/48h/...）；可以并行下载数据

如何跑通代码（基于我们的仓库）
目前的数据在10.150.240.113，/home/xuyang1/workspace/mle-bench_kaggle_data mle-bench里默认安装的路径代码：mlebench/registry.py 13行 DEFAULT_DATA_DIR


git clone https://github.com/WinstonLiyt/mle-bench-aide.git

sudo apt install git-lfs

cd mle-bench-aide
git checkout ytli


git lfs fetch --all
git lfs pull

cd ..

conda create -n mle python=3.11.10
conda activate mle

mkdir .kaggle
cd .kaggle
echo '{"username":"yuanteli","key":"33ecac28413200da7449eb1a2c8da42b"}' > kaggle.json  # 这个是我kaggle的密钥，mle-bench涉及到的所有比赛都加入了，所以可以下载数据，提交submission.csv等

cd ../mle-bench-aide

pip install -e .

mlebench prepare -c spaceship-titanic

export SUBMISSION_DIR="/home/submission"
export LOGS_DIR="/home/logs"
export CODE_DIR="/home/code"
export AGENT_DIR="/home/agent"

sudo usermod -aG docker $USER
newgrp docker
conda activate mle
docker build --network=host --platform=linux/amd64 -t mlebench-env -f environment/Dockerfile .  # 大约10-15min；如果ep03跑不需要--network=host（下面那条命令也是）

docker build --network=host --platform=linux/amd64 -t aide agents/aide/ --build-arg SUBMISSION_DIR=$SUBMISSION_DIR --build-arg LOGS_DIR=$LOGS_DIR --build-arg CODE_DIR=$CODE_DIR --build-arg AGENT_DIR=$AGENT_DIR  # 大约5min；

OPENAI_API_KEY=sk-1234
OPENAI_BASE_URL=http://10.150.240.117:38888

nohup /home/$(whoami)/miniconda3/envs/mle/bin/python /home/$(whoami)/mle-bench-aide/run_agent.py \
    --agent-id=aide \
    --n-workers=1 \
    --competition-set=experiments/exp1.txt \
    --retain
    # 这里experiments/exp1.txt每行写一个比赛id，这次运行就会处理这些比赛，n-workers可以设置成要处理的比赛数量
