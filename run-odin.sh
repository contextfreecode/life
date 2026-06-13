set -e
# For RPi, build raylib with this:
# time make PLATFORM=PLATFORM_DESKTOP GRAPHICS=GRAPHICS_API_OPENGL_21
# flags=-o:speed
OUT_DIR=build/native
mkdir -p $OUT_DIR
time odin build native $flags -extra-linker-flags="-lGL -lEGL -lX11" \
    -out:$OUT_DIR/life
$OUT_DIR/life
