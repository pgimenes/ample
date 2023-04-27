import pygame

HEIGHT = 600
ROWS = 17
SQUARE_SIZE = HEIGHT // ROWS

class Packet:
    def __init__(self, sender, receiver):
        self.sender = sender
        self.receiver = receiver

        self.color = sender.assigned_color
        
        self.position = sender.get_position()
        self.target_position = receiver.get_position()
        
        self.radius = SQUARE_SIZE // 4

        self.sent = False

    def draw_arrow(self, surf, x, y, dx, dy, color=(0, 0, 0)):
        arrow_length = self.radius * 2
        arrow_width = 3
        arrow_head_length = 6

        start_x = x - (dx * self.radius)
        start_y = y - (dy * self.radius)
        end_x = x + (dx * self.radius)
        end_y = y + (dy * self.radius)

        pygame.draw.line(surf, color, (start_x, start_y), (end_x, end_y), arrow_width)
        pygame.draw.line(surf, color, (end_x, end_y), (end_x - dy * arrow_head_length - dx * arrow_head_length, end_y + dx * arrow_head_length - dy * arrow_head_length), arrow_width)
        pygame.draw.line(surf, color, (end_x, end_y), (end_x + dy * arrow_head_length - dx * arrow_head_length, end_y - dx * arrow_head_length - dy * arrow_head_length), arrow_width)

    def draw(self, screen, bounding_box_pos=None):
        if bounding_box_pos:
            x_offset, y_offset = bounding_box_pos
            x = self.position[0] * SQUARE_SIZE + SQUARE_SIZE // 4 * (x_offset + 1)
            y = self.position[1] * SQUARE_SIZE + SQUARE_SIZE // 4 * (y_offset + 1)
        else:
            x = self.position[0] * SQUARE_SIZE + SQUARE_SIZE // 2
            y = self.position[1] * SQUARE_SIZE + SQUARE_SIZE // 2

        pygame.draw.circle(screen, self.color, (x, y), self.radius)

        dx, dy = 0, 0
        if self.position[0] < self.target_position[0]:
            dx = 1
        elif self.position[0] > self.target_position[0]:
            dx = -1
        elif self.position[1] < self.target_position[1]:
            dy = 1
        elif self.position[1] > self.target_position[1]:
            dy = -1

        self.draw_arrow(screen, x, y, dx, dy)
        
    def reached_destination(self):
        return self.position == self.target_position

    def update(self):
        # Move packet towards target position
        if self.position != self.target_position:
            if self.position[0] < self.target_position[0]:
                self.position = (self.position[0] + 1, self.position[1])
            elif self.position[0] > self.target_position[0]:
                self.position = (self.position[0] - 1, self.position[1])
            elif self.position[1] < self.target_position[1]:
                self.position = (self.position[0], self.position[1] + 1)
            elif self.position[1] > self.target_position[1]:
                self.position = (self.position[0], self.position[1] - 1)

    def __repr__(self):
        return str(self.target_position)