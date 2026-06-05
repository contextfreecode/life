package main

import (
	"log"

	"github.com/hajimehoshi/ebiten/v2"
)

func main() {
	ebiten.SetFullscreen(true)
	g := &game{}
	// TODO Need to wait until we know screen size?
	g.addBoids(1000)
	if err := ebiten.RunGame(g); err != nil {
		log.Fatal(err)
	}
}

type game struct {
	boids [][]boid
	reach float64
	sizeX float64
	sizeY float64
}

func (g *game) addBoids(count int) {
	// TODO
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

type boid struct {
	x  float64
	y  float64
	vx float64
	vy float64
}
