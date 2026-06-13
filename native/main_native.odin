package native

import game ".."
import rl "vendor:raylib"

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT, .WINDOW_UNDECORATED})
	rl.SetTraceLogLevel(.NONE)
	rl.InitWindow(0, 0, "Boids")
	game.init()
	defer game.shutdown()
	for !rl.WindowShouldClose() {
		game.update()
	}
}
