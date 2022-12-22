cd ~/WasmEdge-shenben
sudo rm build -rf
# sudo rm -rf $(find . -name CMakeFiles)
# sudo rm -rf $(find . -name CMakeCache.txt)
# sudo rm -rf $(find . -name *.cmake)
# sudo rm -rf $(find . -name Makefile)
# sudo cp ~/wasm-bak/WasmEdge/cmake ~/WasmEdge-shenben -r
# # sudo rm ~/libtorch/* -rf
# # sudo cp ~/libtorch-1.8.2-cpu/* ~/libtorch -r
# # sudo cp ~/libtorch-1.8.2-cu111/* ~/libtorch -r


mkdir -p build 
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DWASMEDGE_PLUGIN_WASI_NN_BACKEND="PyTorch" .. \
&& make -j 
# For the WASI-NN plugin, you should install this project.
sudo cmake --install .

cd ~/WasmEdge-WASINN-examples/pytorch-mobilenet-image/
./download_data.sh
cd rust
rustup target add wasm32-wasi
cargo clean
cargo build --target=wasm32-wasi --release
cd ..

wasmedge --dir .:. wasmedge-wasinn-example-mobilenet-image.wasm mobilenet.pt input.jpg
# wasmedge --dir .:. rust/target/wasm32-wasi/release/wasmedge-wasinn-example-mobilenet-image.wasm mobilenet.pt input.jpg
# LD_LIBRARY_PATH=$HOME/libtorch-1.8.2-cpu/lib \
# wasmedge --dir .:. rust/target/wasm32-wasi/release/wasmedge-wasinn-example-mobilenet-image.wasm mobilenet.pt input.jpg

# LD_LIBRARY_PATH=$HOME/libtorch-1.8.2-cu111/lib \
# wasmedge --dir .:. rust/target/wasm32-wasi/release/wasmedge-wasinn-example-mobilenet-image.wasm mobilenet.pt input.jpg

LD_PRELOAD=$HOME/libtorch-1.8.2-cu111/lib/libtorch.so \
wasmedge --dir .:. rust/target/wasm32-wasi/release/wasmedge-wasinn-example-mobilenet-image.wasm mobilenet.pt input.jpg
