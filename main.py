import pygame


def main():
    print("Hello from life!")
    pygame.init()
    screen = pygame.display.set_mode((0, 0), pygame.FULLSCREEN)
    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
    pygame.quit()


if __name__ == "__main__":
    main()
