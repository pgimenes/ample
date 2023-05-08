import pygame
import time
import random

HEIGHT = 600
ROWS = 17
SQUARE_SIZE = HEIGHT // ROWS

class Node:
    def __init__(self, x, y, sender=False, receiver=False):
        self.x = x
        self.y = y

        self.assigned_color = (random.randint(50, 255), random.randint(50, 255), random.randint(50, 255))
        self.color = (255, 255, 255)  # White
        
        self.packets = []
        self.sent_packets = []

        self.sender = sender
        self.receiver = receiver

        self.allocated = False # for receivers
        self.active = False # for senders

    def draw_label(self, screen, text, font, color=(0, 0, 0)):
        text_surface = font.render(text, True, color)
        text_rect = text_surface.get_rect()
        text_rect.center = (self.x * SQUARE_SIZE + SQUARE_SIZE // 2, self.y * SQUARE_SIZE + SQUARE_SIZE // 2)
        screen.blit(text_surface, text_rect)

    def draw(self, screen):
        pygame.draw.rect(screen, self.color, (self.x * SQUARE_SIZE, self.y * SQUARE_SIZE, SQUARE_SIZE, SQUARE_SIZE))

    def set_color(self, color):
        self.color = color

    def get_position(self):
        return self.x, self.y

    # def increment_packets_sent(self):
    #     self.packets_sent += 1

    def send_packet(self):
        if (self.packets == []):
            return
        packet = self.packets[-1]
        packet.sent = True
        self.sent_packets.extend([packet])
        self.packets.remove(packet)
        if len(self.sent_packets) == 1:
            self.set_color(self.assigned_color)