from tb.utils.common import node_state_e, precision_e, aggregation_function_e

class Nodeslot:
    def __init__(self):
        self.state = node_state_e.EMPTY
        self.precision = precision_e.FLOAT_32
        self.aggregation_function = aggregation_function_e.SUM

class Scoreboard:
    def __init__(self, nodeslot_count=64):
        self.nodeslots = [Nodeslot() for _ in range(nodeslot_count)]

    def get_empty_nodeslot(self):
        for i, ns in enumerate(self.nodeslots):
            if ns.state == node_state_e.EMPTY:
                return i
        return None

    def set_state(self, nodeslot, state):
        self.nodeslots[nodeslot].state = state