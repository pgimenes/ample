from tb.utils.common import NodeState, NodePrecision, AggregationFunction

class Nodeslot:
    def __init__(self):
        self.state = NodeState.EMPTY
        self.precision = NodePrecision.FLOAT_32
        self.aggregation_function = AggregationFunction.SUM
        self.programming = {}

class Scoreboard:
    def __init__(self, nodeslot_count=256):
        self.nodeslots = [Nodeslot() for _ in range(nodeslot_count)]

    def get_empty_nodeslot(self, ns_range=(0, 256)):
        for i, ns in enumerate(self.nodeslots)[ns_range[0]:ns_range[1]]:
            if ns.state == NodeState.EMPTY:
                return i
        return None

    def set_state(self, nodeslot, state):
        self.nodeslots[nodeslot].state = state

    def set_programming(self, nodeslot, programming):
        self.nodeslots[nodeslot].programming = programming