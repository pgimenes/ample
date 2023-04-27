import pygame
import random
from node import Node
from packet import Packet

class Network:
    def __init__(self, rows=17, cols=65, receivers_per_sender=16, packets_per_receiver=8):
        self.rows = rows
        self.cols = cols

        self.nodes = []
        
        self.packets = []

        self.senders = []
        self.active_senders = []

        self.receivers_per_sender = receivers_per_sender
        self.packets_per_receiver = packets_per_receiver

        self.create_nodes()

    def create_nodes(self):
        for y in range(self.rows):
            row = []
            for x in range(self.cols):
                node = Node(x, y)
                row.append(node)
            self.nodes.append(row)
        self.senders = self.nodes[-1]

    def create_packets(self, nodes, num_receivers):
        for i, sender in enumerate(nodes):
            for receiver in range(num_receivers):
                while True:
                    # Choose a receiver that has not yet been allocated
                    receiver = random.choice(random.choice(self.nodes[:-1][:16]))
                    if receiver.allocated == False:
                        break
                receiver.allocated = True
                sender.packets.extend([Packet(sender, receiver) for _ in range(self.packets_per_receiver)])
            self.packets.extend(sender.packets)

    def activate_sender(self, sender):
        sender.active = True
        self.active_senders.append(sender)
        self.create_packets([sender], num_receivers=self.receivers_per_sender)

    def activate_random_sender(self):
        while(True):
            new_sender = random.choice(self.senders)
            if new_sender.active == False:
                break
        self.activate_sender(new_sender)

    def draw_grid(self, screen, width, height, square_size):
        lw = 1
        for x in range(0, width, square_size):
            pygame.draw.line(screen, (0, 0, 0), (x, 0), (x, height), lw)
        for y in range(0, height, square_size):
            pygame.draw.line(screen, (0, 0, 0), (0, y), (width, y), lw)

    def brighten_color(self, color, percentage):
        r, g, b = color
        percentage = max(min(percentage, 100), 0)  # Clamp percentage between 0 and 100

        # Calculate the new RGB values
        r = min(int(r + (255 - r) * percentage / 100), 255)
        g = min(int(g + (255 - g) * percentage / 100), 255)
        b = min(int(b + (255 - b) * percentage / 100), 255)

        return (r, g, b)