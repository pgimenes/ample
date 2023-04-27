import pygame
import time
import random

from node import Node
from packet import Packet
from network import Network
from button import Button

# Constants
WIDTH = 600
HEIGHT = 600

ROWS = 17
COLS = 17
SQUARE_SIZE = HEIGHT // ROWS
SENDERS = ROWS - 1
RECEIVERS = 16
MAX_SENDERS = 4
PACKETS_PER_RECEIVER = 3


def main():
    pygame.init()
    screen = pygame.display.set_mode((WIDTH, HEIGHT))
    pygame.display.set_caption("Aggregation Engine")
    clock = pygame.time.Clock()
    font = pygame.font.Font(None, 36)

    start_button = Button(WIDTH // 2 - 50, HEIGHT // 2 + 50, 100, 40, "Start")
    simulation_started = False

    net = Network(rows=ROWS, cols=COLS, 
        receivers_per_sender=RECEIVERS,
        packets_per_receiver=PACKETS_PER_RECEIVER)

    # Initialize first sender and send its first 8 packets
    # net.activate_sender(net.senders[0])
    # print("Activated first sender")
    # print(len(net.packets))

    running = True
    while running:
        screen.fill((0, 0, 0))

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            if event.type == pygame.MOUSEBUTTONUP:
                if not simulation_started and start_button.is_clicked(pygame.mouse.get_pos()):
                    simulation_started = True
                    net.activate_sender(net.senders[0])
                    print("Activated first sender")
                    print(len(net.packets))

        if (not simulation_started):
            start_button.draw(screen)
            pygame.display.flip()
            clock.tick(10)
            continue

        # Draw nodes and senders
        for row in net.nodes:
            for node in row:
                node.draw(screen)

        # Draw the label on each active sender node
        for sender in net.active_senders:
            num_packets_sent = len(sender.sent_packets)
            sender.draw_label(screen, str(num_packets_sent), font)

        net.draw_grid(screen, WIDTH, WIDTH, SQUARE_SIZE)

        # Activate/deactivate senders and create/send packets
        if len(net.active_senders) < MAX_SENDERS and len(net.active_senders[-1].sent_packets) >= PACKETS_PER_RECEIVER * 8:
            net.activate_random_sender()

        # Deactivate senders that have finished sending packets
        for i, sender in enumerate(net.active_senders):
            if len(sender.sent_packets) >= PACKETS_PER_RECEIVER * RECEIVERS:
                # sender.set_color((255, 255, 255))
                # net.active_senders.remove(sender)
                pass
            else:
                sender.send_packet()

        # Draw and update packets
        packet_positions = {}

        for packet in net.packets:
            if packet.reached_destination() and net.nodes[packet.receiver.y][packet.receiver.x].color == (255, 255, 255):
                net.nodes[packet.receiver.y][packet.receiver.x].set_color(net.brighten_color((packet.color[0], packet.color[1], packet.color[2]), 50))
                net.packets.remove(packet)
            
        for packet in net.packets:
            # Create dictionary of packet positions containing list of packets
            if packet.sent:
                packet.update()
                pos_key = packet.position
                if pos_key in packet_positions:
                    packet_positions[pos_key].append(packet)
                else:
                    packet_positions[pos_key] = [packet]

        # For each position, draw packet normally if it's the single one,
        # otherwise draw combined
        for pos_key, packets in packet_positions.items():
            if len(packets) > 1:
                for i, packet in enumerate(packets):
                    x_offset = i % 4
                    y_offset = i // 4
                    packet.draw(screen, bounding_box_pos=(x_offset, y_offset))
            else:
                packets[0].draw(screen)

        pygame.display.flip()
        clock.tick(5)

    pygame.quit()

if __name__ == "__main__":
    main()