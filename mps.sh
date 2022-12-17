sudo nvidia-smi -i 0 -c EXCLUSIVE_PROCESS
export CUDA_VISIBLE_DEVICES=0
nvidia-cuda-mps-control -d

ps -ef | grep mps
# mpirun -np 4 ./test
cd ~/cuda-11.1/samples/6_Advanced/simpleHyperQ
time mpirun -np 4 ./simpleHyperQ &
nvidia-smi

# echo quit | nvidia-cuda-mps-control
# sudo nvidia-smi -i 0 -c 0 

# https://www.nvidia.cn/content/dam/en-zz/zh_cn/assets/webinars/31oct2019c/20191031_MPS_davidwu.pdf