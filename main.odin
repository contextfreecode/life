// odin run . -extra-linker-flags="-lGL -ldrm -lEGL -lgbm"
package main

import rl "vendor:raylib"

main :: proc() {
	rl.SetTraceLogLevel(.WARNING)
	rl.InitWindow(0, 0, "Boids")
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground(rl.Color{0x2b, 0x2b, 0x38, 0xff})
        // rl.Color{0xe8, 0xe8, 0xe8, 0xff}
		// break
	}
	defer rl.CloseWindow()
}
