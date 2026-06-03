package main

import (
	"log"

	"github.com/hajimehoshi/ebiten/v2"
)

func main() {
	g := &game{}
	if err := ebiten.RunGame(g); err != nil {
		log.Fatal(err)
	}
}

type game struct{}

func (g *game) Draw(image *ebiten.Image) {
	// TODO
}

func (g *game) Layout(
	outsideWidth, outsideHeight int,
) (screenWidth, screenHeight int) {
	screenWidth = 160
	screenHeight = 90
	return
}

func (g *game) Update() error {
	return nil
}
