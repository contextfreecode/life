package native

import game ".."

main :: proc() {
	game.init()
	defer game.shutdown()
	for {
		done := game.update()
		if done {
			break
		}
	}
}
