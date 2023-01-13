# WasmEdge 0.11.2-2 (2023-01-13)

## GPU-enabled Torch (preferred) and TfLite backend spport.
Based on the [WasmEdge](https://github.com/WasmEdge/WasmEdge), targeting WasiNN section (plugins/wasi_nn), we made various implementations to enable ML inference to support GPU accerlation, focusing on the WasiNN portion (plugins/wasi_nn). 

Tensorflow Lite(TfLite) still has compatibility issues, and it frequently malfunctions when used with GPU delegete. and we are waiting for the solutions.

To test WasmEdge GPU ML inference, you can first set up your workload according to the [.bashrc_settings](.bashrc_settings), and then
brower the [scripts](./scripts) and [examples](./examples) to have a test.
you need to reset up the line 57 ~ 60 using Torch Backend(perferred) or line 75 ~ 94 using TfLite Backend in [WasmEdge-shenben/plugins/wasi_nn/CMakeLists.txt](./plugins/wasi_nn/CMakeLists.txt).

### Quick start.
```bash
cd ~
curl -s -L -O --remote-name-all https://download.pytorch.org/libtorch/lts/1.8/cu111/libtorch-shared-with-deps-${PYTORCH_VERSION}%2Bcu111.zip
unzip -q "libtorch-shared-with-deps-${PYTORCH_VERSION}%2Bcu111.zip"
mv libtorch libtorch-1.8.2-cu111
export PYTORCH_VERSION="1.8.2"
export LD_LIBRARY_PATH=$HOME/libtorch-1.8.2-cu111/lib:${LD_LIBRARY_PATH}
export Torch_DIR=$HOME/libtorch-1.8.2-cu111

# Please mannully install CUDA 11.1 and CuDNN 8.7.*.* 
export CUDA_HOME=/usr/local/cuda-11.1
export PATH=$PATH:$CUDA_HOME/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CUDA_HOME/lib64:$CUDA_HOME/extras/CUPTI/lib64

git clone https://github.com/shenben/WasmEdge-shenben.git ~/WasmEdge-shenben
cd ~/WasmEdge-shenben
mkdir -p build 
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DWASMEDGE_PLUGIN_WASI_NN_BACKEND="PyTorch" .. \
&& make -j 
sudo cmake --install .

git clone https://github.com/second-state/WasmEdge-WASINN-examples.git ~/WasmEdge-WASINN-examples
cd ~/WasmEdge-WASINN-examples/pytorch-mobilenet-image/
./download_data.sh
LD_LIBRARY_PATH=$HOME/libtorch-1.8.2-cu111/lib \
wasmedge --dir .:. wasmedge-wasinn-example-mobilenet-image.wasm mobilenet.pt input.jpg
```