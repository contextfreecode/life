// odin run . -extra-linker-flags="-lGL -ldrm -lEGL -lgbm"
package main

import "core:c"
import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import rl "vendor:raylib"

Game :: struct {
	boids: [dynamic]Boid,
	reach: f32,
	size:  [2]f32,
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
	game := game_init(500) // 1100
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

// Public by default is constant stress.
game_init :: proc(boid_count: int) -> Game {
	reach_fraction := f32(0.1)
	game := Game {
		size = {f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())},
	}
	game.reach = reach_fraction * max(game.size[0], game.size[1])
	for _ in 0 ..< boid_count {
		game_add_boid(&game)
	}
	return game
}

game_add_boid :: proc(game: ^Game) {
	pos := [2]f32{rand.float32(), rand.float32()} * game.size
	vel := linalg.normalize([2]f32{rand.float32(), rand.float32()} - 0.5)
	append(&game.boids, Boid{pos = pos, vel = vel})
}

game_delta :: proc(game: Game, from: [2]f32, toward: [2]f32) -> [2]f32 {
	size := game.size
	half := size / 2
	delta := toward - from
	// Wrap delta.
	// TODO Some clever vector version of this?
	if delta[0] < -half[0] {
		delta[0] += size[0]
	} else if delta[0] > half[0] {
		delta[0] -= size[0]
	}
	if delta[1] < -half[1] {
		delta[1] += size[1]
	} else if delta[1] > half[1] {
		delta[1] -= size[1]
	}
	return delta
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
		game_update_boid_vel(game^, &boid)
		boid.pos = game_wrap(game^, boid.pos + boid.vel * speed * dt)
	}
}

game_update_boid_vel :: proc(game: Game, boid: ^Boid) {
	reach := game.reach
	mean_delta: [2]f32
	mean_spread: [2]f32
	mean_trend: [2]f32
	weight: f32
	spread_weight: f32
	for other_boid in game.boids {
		delta := game_delta(game, boid.pos, other_boid.pos)
		distance := linalg.length(delta)
		if distance < reach {
			w := 1 - distance / reach
			wdt := math.pow(w, 5)
			mean_delta += delta * wdt
			mean_trend += other_boid.vel * wdt
			weight += wdt
			// Spread.
			ws := math.pow(w, 10)
			mean_spread -= delta * ws
			spread_weight += ws
		}
	}
	// Mix together.
	if weight != 0 {
		mean_delta /= weight
		mean_trend /= weight
		mean_spread /= spread_weight
		vel := boid.vel
		boid.vel = linalg.normalize(
			vel * 5 + mean_trend * 0.03 + mean_delta * 0.01 + mean_spread * 0.02,
		)
	}
}

game_wrap :: proc(game: Game, pos: [2]f32) -> [2]f32 {
	return linalg.mod(pos, game.size)
}
