// odin run . -extra-linker-flags="-lGL -ldrm -lEGL -lgbm"
package main

import "core:c"
import "core:fmt"
import "core:math/linalg"
import "core:math/rand"
import rl "vendor:raylib"

Game :: struct {
	boids:         [dynamic]Boid,
	reach:         f32,
	reach_fraction: f32,
	size:          [2]f32,
}

Boid :: struct {
	pos: [2]f32,
	vel: [2]f32,
}

main :: proc() {
	// Init.
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.SetTraceLogLevel(.WARNING)
	rl.InitWindow(0, 0, "Boids")
	defer rl.CloseWindow()
	game := game_init(500)
	color := rl.Color{0xe8, 0xe8, 0xe8, 0xff}
	// Loop.
	for !rl.WindowShouldClose() {
		// Prep.
		defer free_all(context.temp_allocator)
		rl.BeginDrawing()
		defer rl.EndDrawing()
		// Update.
		game_update(&game, rl.GetFrameTime())
		// Draw.
		rl.ClearBackground(rl.Color{0x2b, 0x2b, 0x38, 0xff})
		game_draw(&game, color)
		rl.DrawText(fmt.ctprint("FPS: ", rl.GetFPS()), 10, 10, 20, color)
		// break
	}
}

game_init :: proc(boid_count: int) -> Game {
	game := Game {
		reach_fraction = 0.1,
		size = {f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())},
	}
	game.reach = game.reach_fraction * max(game.size[0], game.size[1])
	for _ in 0..<boid_count {
		game_add_boid(&game)
	}
	return game
}

game_add_boid :: proc(game: ^Game) {
	append(&game.boids, Boid{
		pos = [2]f32{rand.float32(), rand.float32()} * game.size,
		vel = linalg.normalize([2]f32{rand.float32(), rand.float32()} - 0.5),
	})
}

game_draw :: proc(game: ^Game, color: rl.Color) {
	for boid in game.boids {
		x, y := c.int(boid.pos[0] - 1), c.int(boid.pos[1] - 1)
		rl.DrawRectangle(x, y, 3, 3, color)
	}
}

game_update :: proc(game: ^Game, dt: f32) {
	reach := game.reach
	speed := reach
	for &boid in game.boids {
		vel := boid.vel
		// TODO Update vel.
		boid.pos = game_wrap(game^, boid.pos + vel * speed * dt)
		boid.vel = vel
	}
}

game_wrap :: proc(game: Game, pos: [2]f32) -> [2]f32 {
	return linalg.mod(pos, game.size)
}
