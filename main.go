package main

import (
	"log"

	"github.com/hajimehoshi/ebiten/v2"
)

func main() {
	ebiten.SetFullscreen(true)
	g := &game{
		boids: initBoids(),
	}
	if err := ebiten.RunGame(g); err != nil {
		log.Fatal(err)
	}
}

type game struct{
	sizeX float64
	sizeY float64
	boids []boid
}

func (g *game) Draw(image *ebiten.Image) {
	// TODO
}

func (g *game) Layout(sizeX, sizeY int) (gameSizeX, gameSizeY int) {
	g.sizeX = float64(sizeX)
	g.sizeY = float64(sizeY)
	return sizeX, sizeY
}

func (g *game) Update() error {
	// return ebiten.Termination
	return nil
}

type boid struct{
	x float64
	y float64
	angle float64
}

func initBoids() []boid {
	return nil
}
