#!/bin/bash -eu
EMSCRIPTEN_SDK_DIR="$HOME/apps/emsdk"
export EMSDK_QUIET=1
[[ -f "$EMSCRIPTEN_SDK_DIR/emsdk_env.sh" ]] && . "$EMSCRIPTEN_SDK_DIR/emsdk_env.sh"
# Note RAYLIB_WASM_LIB=env.o -- env.o is an internal WASM object file. You can
# see how RAYLIB_WASM_LIB is used inside <odin>/vendor/raylib/raylib.odin.
# The emcc call will be fed the actual raylib library file. That stuff will end
# up in env.o
odin build web -target:js_wasm32 -build-mode:obj -define:RAYLIB_WASM_LIB=env.o -define:RAYGUI_WASM_LIB=env.o -out:life.wasm.o
ODIN_PATH=$(odin root)
cp $ODIN_PATH/core/sys/wasm/js/odin.js .
files="life.wasm.o ${ODIN_PATH}/vendor/raylib/wasm/libraylib.a ${ODIN_PATH}/vendor/raylib/wasm/libraygui.a"
flags="-sEXPORTED_RUNTIME_METHODS=['HEAPF32'] -sUSE_GLFW=3 -sWASM_BIGINT -sWARN_ON_UNDEFINED_SYMBOLS=0 -sASSERTIONS --shell-file web/emscripten_template.html"
# For debugging: Add `-g` to `emcc` (gives better error callstack in chrome)
emcc -o emscripten.html $files $flags
rm life.wasm.o
