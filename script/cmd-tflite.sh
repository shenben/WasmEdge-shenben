cd ~/WasmEdge-shenben
sudo rm build -rf
mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DWASMEDGE_PLUGIN_WASI_NN_BACKEND="TensorflowLite" .. \
&& make -j \
&& sudo cmake --install .

# curl -s -L -O --remote-name-all https://github.com/second-state/WasmEdge-tensorflow-deps/releases/download/0.11.2/WasmEdge-tensorflow-deps-TFLite-0.11.2-manylinux2014_x86_64.tar.gz
# tar -zxf WasmEdge-tensorflow-deps-TFLite-0.11.2-manylinux2014_x86_64.tar.gz
# rm -f WasmEdge-tensorflow-deps-TFLite-0.11.2-manylinux2014_x86_64.tar.gz
# sudo mv libtensorflowlite_c.so /usr/local/lib

cd ~/WasmEdge-WASINN-examples/tflite-birds_v1-image/
# # ./download_data.sh
# cd rust/tflite-bird
# rustup target add wasm32-wasi
# cargo clean
# cargo build --target=wasm32-wasi --release
# cd ../..

# wasmedgec rust/tflite-bird/target/wasm32-wasi/release/wasmedge-wasinn-example-tflite-bird-image.wasm wasmedge-wasinn-example-tflite-bird-image.wasm

LD_LIBRARY_PATH=$HOME/code/tflite-dist/libs_linux_gpu_tflite_host \
wasmedge --dir .:. rust/tflite-bird/target/wasm32-wasi/release/wasmedge-wasinn-example-tflite-bird-image.wasm lite-model_aiy_vision_classifier_birds_V1_3.tflite bird.jpg
# ERROR: Following operations are not supported by GPU delegate:
# ADD: OP is supported, but tensor type/shape isn't compatible.
# AVERAGE_POOL_2D: OP is supported, but tensor type/shape isn't compatible.
# CONV_2D: OP is supported, but tensor type/shape isn't compatible.
# DEPTHWISE_CONV_2D: OP is supported, but tensor type/shape isn't compatible.
# FULLY_CONNECTED: OP is supported, but tensor type/shape isn't compatible.
# SOFTMAX: OP is supported, but tensor type/shape isn't compatible.
# No operations will run on the GPU, and all 65 operations will run on the CPU.
# INFO: Created 0 GPU delegate kernels.