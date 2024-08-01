import torch
import torch.nn as nn
from torch_geometric.nn import GCNConv
import graphviz

class ModelMapper:
    def __init__(self, model):
        self.model = model
        self.connections = {}
        self.tensor_tracker = {}

    def register_hooks(self, module, parent_name=""):
        for name, child in module.named_children():
            layer_name = f'{parent_name}.{name}' if parent_name else name
            if '.' not in layer_name:  # Track only top-level modules
                self.connections[layer_name] = {
                    "inputs": [],
                    "class_name": child.__class__.__name__,
                    "in_features": getattr(child, 'in_features', None),
                    "out_features": getattr(child, 'out_features', None)
                }
                child.register_forward_hook(self.create_hook(layer_name))
            self.register_hooks(child, layer_name)

    def create_hook(self, layer_name):
        def hook(module, inputs, output):
            input_descriptions = []
            for inp in inputs:
                if isinstance(inp, torch.Tensor):
                    inp_id = id(inp)
                    description = self.tensor_tracker.get(inp_id, "untracked tensor")
                    input_descriptions.append(description)
            if layer_name in self.connections:
                self.connections[layer_name]["inputs"] = input_descriptions
            self.tensor_tracker[id(output)] = f"output of {layer_name}"
        return hook

    def model_hierarchy_and_connections(self, x_dummy, edge_index_dummy=None):
        # Initialize the input tensor descriptions
        self.tensor_tracker[id(x_dummy)] = "initial model input x"
        if edge_index_dummy is not None:
            self.tensor_tracker[id(edge_index_dummy)] = "edge_index input"
        
        # Register hooks and run model to capture connections
        self.register_hooks(self.model)
        if edge_index_dummy is not None:
            _ = self.model(x_dummy, edge_index_dummy)
        else:
            _ = self.model(x_dummy)
        
        return self.connections

    def format_connections(self):
        def format_layer(layer_name, layer_info, indent=0):
            indent_str = '  ' * indent
            formatted_str = f"{indent_str}{layer_name} ({layer_info['class_name']}, in_features={layer_info['in_features']}, out_features={layer_info['out_features']})\n"
            formatted_str += f"{indent_str}  Inputs: {', '.join(layer_info['inputs'])}\n"
            return formatted_str
        
        def format_dict(connections_dict, indent=0):
            formatted_str = ""
            for layer_name, layer_info in connections_dict.items():
                if isinstance(layer_info, dict) and 'class_name' in layer_info:
                    formatted_str += format_layer(layer_name, layer_info, indent)
            return formatted_str

        return format_dict(self.connections)

    def visualize_connections(self):
        dot = graphviz.Digraph(comment='Model Connections')
        
        # Add nodes and edges based on the connections
        for layer_name, layer_info in self.connections.items():
            if 'class_name' in layer_info:
                # Add node for the layer
                label = f"{layer_name}\n({layer_info['class_name']})\nIn: {layer_info['in_features']} Out: {layer_info['out_features']}"
                dot.node(layer_name, label=label)
                
                # Add edges for inputs
                for inp in layer_info['inputs']:
                    if "output of" in inp:
                        input_layer_name = inp.replace("output of ", "").strip()
                        dot.edge(input_layer_name, layer_name)

        dot.render('model_connections', format='png')  # Save the graph as a PNG image
        dot.save()


class AGG_MLP_Model(nn.Module):
    def __init__(self, in_channels, out_channels):
        super().__init__()
        self.fc1 = nn.Linear(in_channels, out_channels)

    def forward(self, edge_embed, src_embed, rx_embed):
        agg = edge_embed + src_embed + rx_embed
        out = self.fc1(agg)
        return out

class Edge_ConcatEmbedding_Model(nn.Module):
    def __init__(self, in_channels=32, out_channels=32, hidden_dimension=32):
        super().__init__()
        self.src_embed = nn.Linear(in_channels, out_channels, bias=False)
        self.rx_embed = nn.Linear(in_channels, out_channels, bias=False)
        self.edge_embed = nn.Linear(in_channels, hidden_dimension, bias=False)
        self.edge_update = AGG_MLP_Model(hidden_dimension, out_channels)

    def forward(self, x, edge_index):
        outputs = {}
        src_embed = self.src_embed(x)
        rx_embed = self.rx_embed(x)
        edge_embed = self.edge_embed(x)
        edge_update = self.edge_update(edge_embed, src_embed, rx_embed)

        outputs['src_embed'] = src_embed

        ...
        return edge_update


# Visualize the connections
  # This will open the image automatically if supported
