use macroquad::prelude::*;

#[macroquad::main(window_conf)]
async fn main() {
    loop {
        next_frame().await
    }
}

fn window_conf() -> Conf {
    Conf {
        fullscreen: true,
        ..Default::default()
    }
}
