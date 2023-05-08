import pygame

class Button:
    def __init__(self, x, y, width, height, text, font_size=24, text_color=(255, 255, 255), bg_color=(50, 50, 50)):
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.text = text
        self.font_size = font_size
        self.text_color = text_color
        self.bg_color = bg_color

    def draw(self, screen):
        pygame.draw.rect(screen, self.bg_color, (self.x, self.y, self.width, self.height))
        font = pygame.font.Font(None, self.font_size)
        text_surface = font.render(self.text, True, self.text_color)
        screen.blit(text_surface, (self.x + (self.width - text_surface.get_width()) // 2, self.y + (self.height - text_surface.get_height()) // 2))

    def is_clicked(self, mouse_pos):
        x, y = mouse_pos
        return self.x <= x <= self.x + self.width and self.y <= y <= self.y + self.height