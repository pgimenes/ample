import torch
import torch.nn as nn
from torch.fx import Tracer, GraphModule
from torch.fx.passes.graph_drawer import FxGraphDrawer
from torch_geometric.nn import GCNConv
import pydot


class GraphTracer:
    def __init__(self, model: nn.Module):
        self.model = model
        self.graph_module = self.trace_model(model)

    def trace_model(self, model):
        tracer = Tracer()
        graph = tracer.trace(model)
        return GraphModule(model, graph)

    def get_input_output_layers(self):
        inputs_outputs = []
        for node in self.graph_module.graph.nodes:
            print(node)
            if node.op == 'call_module' or node.op == 'call_function':  # Include call_function for wrapped functions
                if node.op == 'call_module':
                    layer = dict(self.graph_module.named_modules())[node.target]
                else:
                    layer = node.target  # For call_function, layer is the function itself
                inputs = node.args
                outputs = node
                inputs_outputs.append((layer, inputs, outputs))
        return inputs_outputs




    def print_input_output_layers(self):
        for layer, inputs, outputs in self.get_input_output_layers():
            print(f"Layer: {layer}")
            print(f"  Inputs: {inputs}")
            print(f"  Outputs: {outputs}")
            print("")

    def draw(self, file="mase_graph.svg"):
        drawer = FxGraphDrawer(self.graph_module, "masegraph")
        drawer.get_dot_graph().write_svg(file)

