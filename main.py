import dataclasses as dc
import os
import random as r
# import numpy as np

os.environ["PYGAME_HIDE_SUPPORT_PROMPT"] = "1"

import pygame as pg
import pygame.typing as pgt


def main() -> None:
    pg.init()
    screen = pg.display.set_mode((0, 0), pg.FULLSCREEN, vsync=1)
    clock = pg.time.Clock()
    color = (0xE8, 0xE8, 0xE8)
    font = pg.font.Font(None, 20)
    game = Game(70)
    running = True
    while running:
        for event in pg.event.get():
            if event.type == pg.QUIT:
                running = False
        game.update(clock.tick() * 1e-3)
        screen.fill((0x2B, 0x2B, 0x38))
        game.draw(screen, color)
        fps = font.render(f"FPS: {clock.get_fps():.0f}", True, color)
        screen.blit(fps, (10, 10))
        pg.display.flip()
        # break
    pg.quit()


@dc.dataclass
class Boid:
    pos: pg.Vector2
    vel: pg.Vector2


class Game:
    boids: list[Boid]
    reach: float
    size: pg.Vector2
    speed: float

    def __init__(self, boid_count: int) -> None:
        display_info = pg.display.Info()
        size = pg.Vector2(display_info.current_w, display_info.current_h)
        size_max = max(*size)
        self.boids = []
        self.reach = 0.05 * size_max
        self.size = size
        self.speed = 0.1 * size_max
        for _ in range(boid_count):
            self.add_boid()

    def add_boid(self) -> None:
        pos = pg.Vector2(r.random(), r.random()).elementwise() * self.size
        vel = pg.Vector2(r.random(), r.random()).elementwise() - 0.5
        vel = vel.normalize()
        self.boids.append(Boid(pos=pos, vel=vel))

    def delta(self, *, origin: pg.Vector2, toward: pg.Vector2) -> pg.Vector2:
        size = self.size
        half = size.elementwise() * 0.5
        delta = toward - origin
        # Wrap delta.
        if delta[0] < -half[0]:
            delta[0] += size[0]
        elif delta[0] > half[0]:
            delta[0] -= size[0]
        if delta[1] < -half[1]:
            delta[1] += size[1]
        elif delta[1] > half[1]:
            delta[1] -= size[1]
        return delta

    def draw(self, surface: pg.Surface, color: pgt.ColorLike) -> None:
        for boid in self.boids:
            pos = boid.pos.elementwise() - 1
            pg.draw.rect(surface, color, (pos[0], pos[1], 3, 3))

    def update(self, dt: float) -> None:
        speed = self.speed
        for boid in self.boids:
            self.update_boid_vel(boid)
            boid.pos = self.wrap(boid.pos + boid.vel.elementwise() * speed * dt)

    def update_boid_vel(self, boid: Boid) -> None:
        reach = self.reach
        mean_delta = pg.Vector2()
        mean_trend = pg.Vector2()
        mean_spread = pg.Vector2()
        weight = 0.0
        spread_weight = 0.0
        for other_boid in self.boids:
            delta = self.delta(origin=boid.pos, toward=other_boid.pos)
            distance = delta.length()
            if distance < reach:
                delta_elementwise = delta.elementwise()
                w = 1.0 - distance / reach
                wdt = w**5.0
                mean_delta += delta_elementwise * wdt
                mean_trend += other_boid.vel.elementwise() * wdt
                weight += wdt
                # Spread.
                ws = w**10.0
                mean_spread -= delta_elementwise * ws
                spread_weight += ws
        # Mix together.
        if weight:
            # TODO Would all this be faster with separate x & y than pg.Vector2?
            vel = boid.vel.elementwise() * 1
            # TODO Adjust impact by update time duration.
            mean_delta = mean_delta.elementwise() / weight * 0.01
            mean_trend = mean_trend.elementwise() / weight * 0.03
            mean_spread = mean_spread.elementwise() / spread_weight * 0.02
            boid.vel = (vel + mean_delta + mean_trend + mean_spread).normalize()

    def wrap(self, pos: pg.Vector2) -> pg.Vector2:
        return pos.elementwise() % self.size


if __name__ == "__main__":
    main()
