cd ~/WasmEdge-shenben
sudo rm build -rf
mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DWASMEDGE_PLUGIN_WASI_NN_BACKEND="TensorflowLite" .. && make -j
# For the WASI-NN plugin, you should install this project.
sudo cmake --install .

# curl -s -L -O --remote-name-all https://github.com/second-state/WasmEdge-tensorflow-deps/releases/download/0.11.2/WasmEdge-tensorflow-deps-TFLite-0.11.2-manylinux2014_x86_64.tar.gz
# tar -zxf WasmEdge-tensorflow-deps-TFLite-0.11.2-manylinux2014_x86_64.tar.gz
# rm -f WasmEdge-tensorflow-deps-TFLite-0.11.2-manylinux2014_x86_64.tar.gz
# sudo mv libtensorflowlite_c.so /usr/local/lib

cd ~/WasmEdge-WASINN-examples/tflite-birds_v1-image/
./download_data.sh
cd rust/tflite-bird
rustup target add wasm32-wasi
cargo clean
cargo build --target=wasm32-wasi --release
cd ../..
wasmedgec rust/tflite-bird/target/wasm32-wasi/release/wasmedge-wasinn-example-tflite-bird-image.wasm wasmedge-wasinn-example-tflite-bird-image.wasm

LD_PRELOAD=/usr/local/lib/libtensorflowlite_c.so \
wasmedge --dir .:. rust/tflite-bird/target/wasm32-wasi/release/wasmedge-wasinn-example-tflite-bird-image.wasm lite-model_aiy_vision_classifier_birds_V1_3.tflite bird.jpg
