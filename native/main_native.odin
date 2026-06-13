package native

import game ".."
import rl "vendor:raylib"

main :: proc() {
	game.init()
	defer game.shutdown()
	for !rl.WindowShouldClose() {
		game.update()
	}
}
