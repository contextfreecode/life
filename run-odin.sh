set -e
# For RPi, build raylib with this:
# time make PLATFORM=PLATFORM_DESKTOP GRAPHICS=GRAPHICS_API_OPENGL_21
# flags=-o:speed
time odin build native $flags -extra-linker-flags="-lGL -lEGL -lX11" -out:life
./life
