use macroquad::{prelude::*, rand::gen_range};

fn window_conf() -> Conf {
    Conf {
        fullscreen: true,
        window_title: "Boids".to_string(),
        ..Default::default()
    }
}

struct Game {
    boids: Vec<Boid>,
    reach: f32,
    size: Vec2,
    speed: f32,
}

#[derive(Clone, Copy)]
struct Boid {
    pos: Vec2,
    vel: Vec2,
}

#[macroquad::main(window_conf)]
async fn main() {
    // Burn frames in hope we get the right screen size.
    for _ in 0..5 {
        next_frame().await;
    }
    // Move on.
    let mut fps = 0.0;
    let mut game = Game::new(0);
    let color = Color::from_rgba(0xe8, 0xe8, 0xe8, 0xff);
    loop {
        clear_background(Color::from_rgba(0x2b, 0x2b, 0x38, 0xff));
        game.update(get_frame_time());
        game.draw(color);
        fps = 0.9 * fps + 0.1 * (1.0 / get_frame_time());
        if fps > 40.0 {
            game.add_boid();
        }
        let label = format!("FPS: {}", fps.round() as i32);
        draw_text(&label, 10.0, 40.0, 50.0, color);
        let label = format!("Boids: {}", game.boids.len());
        draw_text(&label, 10.0, 80.0, 50.0, color);
        next_frame().await;
        // break
    }
}

impl Game {
    fn new(boid_count: usize) -> Game {
        let size = Vec2::new(screen_width(), screen_height());
        let size_max = size.max_element();
        let mut game = Game {
            boids: vec![],
            reach: 0.05 * size_max,
            size,
            speed: 0.1 * size_max,
        };
        for _ in 0..boid_count {
            game.add_boid();
        }
        game
    }

    fn add_boid(&mut self) {
        self.boids.push(Boid {
            pos: rand2() * self.size,
            vel: (rand2() - 0.5).normalize(),
        });
    }

    fn delta(&self, toward: Vec2, from: Vec2) -> Vec2 {
        let size = self.size;
        let half = size / 2.0;
        let mut delta = toward - from;
        // Wrap delta.
        if delta.x < -half.x {
            delta.x += size.x;
        } else if delta.x > half.x {
            delta.x -= size.x;
        }
        if delta.y < -half.y {
            delta.y += size.y;
        } else if delta.y > half.y {
            delta.y -= size.y;
        }
        delta
    }

    fn draw(&self, color: Color) {
        for boid in &self.boids {
            let pos = boid.pos - 1.0;
            draw_rectangle(pos.x, pos.y, 3.0, 3.0, color);
        }
    }

    fn update(&mut self, dt: f32) {
        let speed = self.speed;
        for boid_index in 0..self.boids.len() {
            let mut boid = self.boids[boid_index];
            self.update_boid_vel(&mut boid);
            boid.pos = self.wrap(boid.pos + boid.vel * speed * dt);
            self.boids[boid_index] = boid;
        }
    }

    fn update_boid_vel(&self, boid: &mut Boid) {
        let reach = self.reach;
        let mut mean_delta = Vec2::ZERO;
        let mut mean_trend = Vec2::ZERO;
        let mut mean_spread = Vec2::ZERO;
        let mut weight = 0.0;
        let mut spread_weight = 0.0;
        for other_boid in &self.boids {
            let delta = self.delta(other_boid.pos, boid.pos);
            let distance = delta.length();
            if distance < reach {
                let w = 1.0 - distance / reach;
                let wdt = w.powf(5.0);
                mean_delta += delta * wdt;
                mean_trend += other_boid.vel * wdt;
                weight += wdt;
                // Spread.
                let ws = w.powf(10.0);
                mean_spread -= delta * ws;
                spread_weight += ws;
            }
        }
        // Mix together.
        if weight != 0.0 {
            let mut vel = 1.0 * boid.vel;
            vel += 0.01 * mean_delta / weight;
            vel += 0.03 * mean_trend / weight;
            vel += 0.02 * mean_spread / spread_weight;
            boid.vel = vel.normalize();
        }
    }

    fn wrap(&self, pos: Vec2) -> Vec2 {
        Vec2::new(pos.x.rem_euclid(self.size.x), pos.y.rem_euclid(self.size.y))
    }
}

fn rand2() -> Vec2 {
    Vec2::new(gen_range(0.0, 1.0), gen_range(0.0, 1.0))
}
