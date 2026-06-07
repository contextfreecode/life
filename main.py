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
    game = Game(100)
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

    def __init__(self, boid_count: int):
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

    def draw(self, surface: pg.Surface, color: pgt.ColorLike) -> None:
        for boid in self.boids:
            pos = boid.pos.elementwise() - 1
            pg.draw.rect(surface, color, (pos[0], pos[1], 3, 3))

    def update(self, dt: float) -> None:
        speed = self.speed
        for boid in self.boids:
            boid.pos = self.wrap(boid.pos + boid.vel.elementwise() * speed * dt)

    def wrap(self, pos: pg.Vector2) -> pg.Vector2:
        return pos.elementwise() % self.size


if __name__ == "__main__":
    main()
