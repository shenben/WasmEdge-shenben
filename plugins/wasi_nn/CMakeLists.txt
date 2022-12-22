# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2019-2022 Second State INC

wasmedge_add_library(wasmedgePluginWasiNN
  SHARED
  wasinnenv.cpp
  wasinnfunc.cpp
  wasinnmodule.cpp
)

target_compile_options(wasmedgePluginWasiNN
  PUBLIC
  -DWASMEDGE_PLUGIN
)

if(CMAKE_SYSTEM_NAME MATCHES "Darwin")
  target_link_options(wasmedgePluginWasiNN
    PUBLIC
    -Wl,-U,__ZN8WasmEdge6Plugin14PluginRegisterC1EPKNS0_6Plugin16PluginDescriptorE
    -Wl,-U,__ZN8WasmEdge6Plugin14PluginRegisterD1Ev
  )
endif()

target_include_directories(wasmedgePluginWasiNN
  PUBLIC
  $<TARGET_PROPERTY:wasmedgePlugin,INCLUDE_DIRECTORIES>
  ${CMAKE_CURRENT_SOURCE_DIR}
)

if(WASMEDGE_LINK_PLUGINS_STATIC)
  target_link_libraries(wasmedgePluginWasiNN
    PRIVATE
    wasmedgeCAPI
  )
else()
  target_link_libraries(wasmedgePluginWasiNN
    PRIVATE
    wasmedge_shared
  )
endif()

install(TARGETS wasmedgePluginWasiNN DESTINATION ${CMAKE_INSTALL_LIBDIR}/wasmedge)

# Add backends building flags.
foreach(BACKEND ${WASMEDGE_PLUGIN_WASI_NN_BACKEND})
  string(TOLOWER ${BACKEND} BACKEND)
  if(BACKEND STREQUAL "openvino")
    message(STATUS "WASI-NN: Build OpenVINO backend for WASI-NN")
    find_package(InferenceEngine REQUIRED)
    add_definitions(-DWASMEDGE_PLUGIN_WASI_NN_BACKEND_OPENVINO)
    target_link_libraries(wasmedgePluginWasiNN
      PUBLIC
      ${InferenceEngine_LIBRARIES}
    )
  elseif(BACKEND STREQUAL "pytorch")
    message(STATUS "WASI-NN: Build PyTorch backend for WASI-NN")
    set(Torch_DIR /home/waynexzhou/libtorch-1.8.2-cu111/share/cmake/Torch)
    set(CMAKE_CUDA_COMPILER /home/waynexzhou/cuda-11.1/bin/nvcc)
    find_package(PythonInterp REQUIRED)
    find_package(Torch REQUIRED)
    add_definitions(-DWASMEDGE_PLUGIN_WASI_NN_BACKEND_TORCH)
    target_link_libraries(wasmedgePluginWasiNN
      PUBLIC
      ${TORCH_LIBRARIES}
    )
  elseif(BACKEND STREQUAL "tensorflowlite")
    message(STATUS "WASI-NN: Build Tensorflow lite backend for WASI-NN")
    # TODO: Move these complicated steps into a helper cmake.
    add_definitions(-DWASMEDGE_PLUGIN_WASI_NN_BACKEND_TFLITE)

    if(NOT WASMEDGE_DEPS_VERSION)
      set(WASMEDGE_DEPS_VERSION "0.11.1")
    endif()

    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_STANDARD 17)
    find_package(OpenGL REQUIRED COMPONENTS EGL GLX) # OpenGL

    # TensorFlow Lite Integration
    set(tflite_dist_dir /home/waynexzhou/code/tflite-dist)
    set(TFLITE_LIBS_DIR "${tflite_dist_dir}/libs_linux_gpu_tflite_host")
    set(TENSORFLOW_INCLUDE ${tflite_dist_dir}/include)
    target_include_directories(wasmedgePluginWasiNN  PUBLIC ${TENSORFLOW_INCLUDE}) 
    # TFLite GPU libraries
    foreach(_target
        libtensorflowlite
        libtensorflowlite_c
        libtensorflowlite_gpu_delegate)
      add_library(${_target} SHARED IMPORTED)
      set_target_properties(${_target} PROPERTIES IMPORTED_LOCATION ${TFLITE_LIBS_DIR}/${_target}.so)
      target_link_libraries(${_target} INTERFACE OpenGL::GLX OpenGL::EGL)
      list(APPEND TFLITE_LIBS ${_target})
    endforeach()
    target_link_libraries(wasmedgePluginWasiNN PUBLIC ${TFLITE_LIBS}) 

  else()
    # Add the other backends here.
    message(FATAL_ERROR "WASI-NN: backend ${BACKEND} not found or unimplemented.")
  endif()
endforeach()
