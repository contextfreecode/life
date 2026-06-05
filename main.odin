// odin run . -extra-linker-flags="-lGL -ldrm -lEGL -lgbm"
package main

import rl "vendor:raylib"

main :: proc() {
    rl.SetTraceLogLevel(.WARNING)
    rl.InitWindow(0, 0, "Hi!")
    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        // rl.ClearBackground(rl.Color{})
        rl.EndDrawing()
        // break
    }
    defer rl.CloseWindow()
}
